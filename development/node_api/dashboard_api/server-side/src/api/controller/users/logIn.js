const router = require('express').Router();
const { logger } = require('../../lib/logger');
const auth = require('../../middleware/check-auth');
const axios = require('axios');
const dotenv = require('dotenv');
const querystring = require('querystring');
const qr = require('qrcode');
const speakeasy = require("speakeasy");
const common = require('./common');
const { generateSecret, verify } = require('2fa-util');
const db = require('../kekcloakDB/db')
dotenv.config();
const authURL = process.env.AUTH_API
const keyCloakURL = process.env.KEYCLOAK_HOST
const keyClockRealm = process.env.KEYCLOAK_REALM

router.post('/login', async (req, res, next) => {

    const { email, password } = req.body;
    let role = '';
    let userStatus = ''

    let stateheaders = {
        "Content-Type": "application/json",
    }


    if (!email || !password) {
        return next(new ErrorResponse('Please provide an email and password', 400));
    }

    try {
        logger.info('--- custom login  api ---');

        let url = authURL;
        let headers = {
            "Content-Type": "application/json",
        }

        let details = {
            username: email,
            password: password,
        };

        let keycloakheaders = {
            "Content-Type": "application/x-www-form-urlencoded",
        }

        let keyCloakdetails = new URLSearchParams({
            client_id: 'cQube_Application',
            username: req.body.email,
            password: req.body.password,
            grant_type: 'password',

        });

        let kcUrl = `${keyCloakURL}/auth/realms/${keyClockRealm}/protocol/openid-connect/token`



        await axios.post(kcUrl, keyCloakdetails, { headers: keycloakheaders }).then(resp => {

            let response = resp['data']
            let jwt = resp['data'].access_token;
            let username = ''
            let userId = ''
            if (resp.status === 200) {
                const decodingJWT = (token) => {
                    if (token !== null || token !== undefined) {
                        const base64String = token.split('.')[1];
                        const decodedValue = JSON.parse(Buffer.from(base64String,
                            'base64').toString('ascii'));

                        if (decodedValue.realm_access.roles.includes('admin')) {
                            role = 'admin'
                        }
                        if (decodedValue.realm_access.roles.includes('report_viewer')) {
                            role = 'report_viewer'
                        }
                        if (decodedValue.realm_access.roles.includes('emission')) {
                            role = 'emission'
                        }

                        username = decodedValue.preferred_username;
                        userId = decodedValue.sub

                        return decodedValue;
                    }
                    return null;
                }
                decodingJWT(jwt)
            };


            if (role === 'admin') {
                let userStatus = ''

                db.query('SELECT * FROM keycloak_users WHERE keycloak_username = $1', [req.body.email], (error, results) => {
                    if (error) {
                        throw error
                    }

                    res.send({ token: jwt, role: role, username: username, userId: userId, status: results.rows[0].status, res: response })

                })

            }

            if (role === 'emission') {
                res.status(401).json({
                    errMessage: "Not authoruzer to view the reports!!"
                });

            }
            if (role == 'report_viewer') {

                let url = 'http://0.0.0.0:6001/login';
                let headers = {
                    "Content-Type": "application/json",
                }

                let details = {
                    username: email,
                    password: password
                };

                axios.post(url, details, { headers: headers }).then(resp => {

                    let token = resp.data.access_token
                    userId = resp.data.payload.id
                    if (resp.status === 200) {
                        const decodingJWT = (token) => {
                            if (token !== null || token !== undefined) {
                                const base64String = token.split('.')[1];
                                const decodedValue = JSON.parse(Buffer.from(base64String,
                                    'base64').toString('ascii'));

                                username = decodedValue.sub

                                return decodedValue;
                            }
                            return null;
                        }
                        decodingJWT(token)
                    };


                    res.send({ token: token, role: 'report_viewer' })
                }).catch(error => {

                    res.status(409).json({ errMsg: error.response.data.errorMessage });
                })
            }


        }

        ).catch(error => {
            logger.error(`Error :: ${error}`)
            if (role === '' || role === undefined) {
                let url = 'http://0.0.0.0:6001/login';

                let username = '';
                let userId = '';

                let details = {
                    username: email,
                    password: password
                };

                axios.post(url, details, { headers: stateheaders }).then(resp => {

                    let token = resp.data.access_token;
                    userId = resp.data.payload.id
                    if (resp.status === 200) {
                        const decodingJWT = (token) => {
                            if (token !== null || token !== undefined) {
                                const base64String = token.split('.')[1];
                                const decodedValue = JSON.parse(Buffer.from(base64String,
                                    'base64').toString('ascii'));
                                username = decodedValue.sub

                                return decodedValue;
                            }
                            return null;
                        }
                        decodingJWT(token)
                    };

                    res.send({ token: token, role: 'report_viewer', username: username, userId: userId })
                }).catch(error => {

                    res.status(409).json({ errMsg: 'please check user name and password' });
                })
            }


        })



    } catch (error) {
        logger.error(`Error :: ${error}`)
        res.status(404).json({ errMessage: "Internal error. Please try again!!" })
    }
})

router.get('/authenticate', async (req, res, next) => {
    let url = 'http://localhost:8080/auth/realms/cQube/account'
    let header = {
        'Content-Type': 'text/html;charset=utf-8',

    }

    try {

        await axios.get(url, { headers: header }).then(resp => {

            resp.send({ data: resp })
        })
    } catch (error) {

        res.status(409).json({ errMsg: error.response.data.errorMessage });
    }
})
router.post('/getTotp', async (req, res, next) => {
    const { email, password } = req.body;

    const secret = await generateSecret(email, 'cQube');
    db.query('UPDATE keycloak_users set qr_secret= $2 where keycloak_username=$1;', [req.body.email, secret.secret], (error, results) => {
        if (error) {
            throw error
        }
        res.status(201).json({ msg: "qrcode saved" });

    })
    return res.json({
        message: 'TFA Auth needs to be verified',
        tempSecret: secret.secret,
        dataURL: secret.qrcode,
        tfaURL: secret.otpauth
    })


})

router.post('/getSecret', async (req, res) => {

    const { username } = req.body

    db.query('SELECT qr_secret FROM keycloak_users WHERE keycloak_username = $1', [req.body.username], (error, results) => {
        if (error) {
            throw error
        }

        res.send({ status: 200, secret: results.rows[0].qr_secret })

    })
});


router.post('/totpVerify', async (req, res) => {
    const { secret, token } = req.body

    let isVerified = await verify(token, secret);

    if (isVerified) {
        return res.send({
            "status": 200,
            "message": "Two-factor Auth is enabled successfully",
            "loginedIn": common.userObject.loginedIn
        });
    }

    return res.send({
        "status": 403,
        "message": "Invalid Auth Code, verification failed. Please verify the system Date and Time"
    });
});

module.exports = router;