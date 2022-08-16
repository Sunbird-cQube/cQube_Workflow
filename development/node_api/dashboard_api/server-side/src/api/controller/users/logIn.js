const router = require('express').Router();
const { logger } = require('../../lib/logger');
const auth = require('../../middleware/check-auth');
const axios = require('axios');
const dotenv = require('dotenv');
const querystring = require('querystring');
const qr = require('qrcode');

const common = require('./common');
const { generateSecret, verify } = require('2fa-util');
const db = require('../keycloakDB/db')
dotenv.config();
const authURL = process.env.AUTH_API
const keyCloakURL = process.env.KEYCLOAK_HOST
const keyClockRealm = process.env.KEYCLOAK_REALM
const keyClockClient = process.env.KEYCLOAK_CLIENT

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
            client_id: keyClockClient,
            username: req.body.email,
            password: req.body.password,
            grant_type: 'password',

        });

        let kcUrl = `${keyCloakURL}/auth/realms/${keyClockRealm}/protocol/openid-connect/token`



        await axios.post(kcUrl, keyCloakdetails, { headers: keycloakheaders }).then(resp => {
            logger.info('---token generated from keyclock ---');
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
                        logger.info('---user status from DB error ---');
                        throw error
                    }
                    if (results.rows.length) {
                        logger.info('---user status from DB success ---');
                        res.send({ token: jwt, role: role, username: username, userId: userId, status: results.rows[0].status, res: response })

                    } else {
                        logger.info('---user status not available in DB ---');
                        res.send({ token: jwt, role: role, username: username, userId: userId, res: response })
                    }

                })

            }

            if (role === 'emission') {
                res.status(401).json({
                    errMessage: "Not authoruzer to view the reports!!"
                });

            }
            if (role == 'report_viewer') {

                let url = authURL;
                let headers = {
                    "Content-Type": "application/json",
                }

                let details = {
                    username: email,
                    password: password
                };

                axios.post(url, details, { headers: headers }).then(resp => {
                    logger.info('---token from state api success ---');


                    let token = resp.data.access_token;
                    userId = resp.data.payload.id
                    let userLevel = resp.data.payload.user_level;
                    let userLocation = resp.data.payload.user_location;
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

                    if (userLevel === 'Cluster') {
                        db.query('SELECT distinct block_id,district_id FROM school_hierarchy_details WHERE cluster_id=$1;', [userLocation], (error, results) => {
                            if (error) {
                                logger.info('---user level from DB error ---');
                                res.send({ status: "401", err: "Invalid Cluster user, Please Contact Respective Team" })
                                throw error
                            }
                            if (results['rowCount']) {
                                let blockId = results.rows[0]['block_id']
                                let districtId = results.rows[0]['district_id']
                                res.send({ token: token, role: 'report_viewer', username: username, userId: userId, user_level: userLevel, user_location: userLocation, clusterId: userLocation, blockId: blockId, districtId: districtId })
                            } else {
                                res.send({ status: "401", err: "Invalid Cluster user, Please Contact Respective Team" })
                            }

                        })
                    } else if (userLevel === 'Block') {

                        db.query('SELECT distinct district_id FROM school_hierarchy_details WHERE block_id=$1;', [userLocation], (error, results) => {
                            if (error) {
                                logger.info('---user block level from DB error ---');
                                res.send({ status: "401", err: "Invalid Block user, Please Contact Respective Team" })
                                throw error

                            }
                            logger.info('---user block level from DB  success ---');

                            if (results['rowCount']) {
                                let districtId = results.rows[0]['district_id']
                                res.send({ token: token, role: 'report_viewer', username: username, userId: userId, user_level: userLevel, user_location: userLocation, blockId: userLocation, districtId: districtId })
                            } else {
                                res.send({ status: "401", err: "Invalid Block user, Please Contact Respective Team" })
                            }

                        })
                    } else if (userLevel === 'School') {

                        db.query('SELECT distinct cluster_id,block_id,district_id FROM school_hierarchy_details WHERE school_id=$1;', [userLocation], (error, results) => {
                            if (error) {
                                logger.info('---user school level from DB error ---');
                                res.send({ status: "401", err: "Invalid school user, Please Contact Respective Team" })
                                throw error

                            }
                            logger.info('---user school level from DB  success ---');
                          
                            if (results['rowCount']) {
                                let clusterId = results.rows[0]['cluster_id']
                                let blockId = results.rows[0]['block_id']
                                let districtId = results.rows[0]['district_id']
                                res.send({ token: token, role: 'report_viewer', username: username, userId: userId, user_level: userLevel, user_location: userLocation, clusterId: clusterId, blockId: blockId, districtId: districtId, schoolId: userLocation })
                            } else {
                                res.send({ status: "401", err: "Invalid school user, Please Contact Respective Team" })
                            }

                        })
                    } else if (userLevel === 'District') {
                        if (userLocation === "") {
                            logger.info('---user block level from DB error ---');
                            res.send({ status: "401", err: "Invalid District user, Please Contact Respective Team" })
                            return
                        }
                        db.query('SELECT distinct district_id FROM school_hierarchy_details WHERE district_id=$1;', [userLocation], (error, results) => {
                            if (error) {
                                logger.info('---user District level from DB error ---');
                                res.send({ status: "401", err: "Invalid District user, Please Contact Respective Team" })
                                throw error

                            }

                            if (results['rowCount']) {

                                res.send({ token: token, role: 'report_viewer', username: username, userId: userId, user_level: userLevel, user_location: userLocation, districtId: userLocation })
                            } else {
                                res.send({ status: "401", err: "Invalid District user, Please Contact Respective Team" })
                            }

                        })

                    } else {
                        res.send({ token: token, role: 'report_viewer', username: username, userId: userId, user_level: userLevel, user_location: userLocation })
                    }
                  
                }).catch(error => {

                    res.status(409).json({ errMsg: error.response.data.errorMessage });
                })
            }


        }

        ).catch(error => {
            
            if (role === '' || role === undefined) {
                let url = authURL;

                let username = '';
                let userId = '';

                let details = {
                    username: email,
                    password: password
                };

                axios.post(url, details, { headers: stateheaders }).then(resp => {
                    logger.info('---user token from state success ---');

                    let token = resp.data.access_token;
                    userId = resp.data.payload.id
                    let userLevel = resp.data.payload.user_level;
                    let userLocation = resp.data.payload.user_location;


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
                        decodingJWT(token);

                    };


                    if (userLevel === 'Cluster') {
                        db.query('SELECT distinct block_id,district_id FROM school_hierarchy_details WHERE cluster_id=$1;', [userLocation], (error, results) => {
                            if (error) {
                                logger.info('---user level from DB error ---');
                                res.send({ status: "401", err: "Invalid Cluster user, Please Contact Respective Team" })
                                throw error
                            }
                            if (results['rowCount']) {
                                let blockId = results.rows[0]['block_id']
                                let districtId = results.rows[0]['district_id']
                                res.send({ token: token, role: 'report_viewer', username: username, userId: userId, user_level: userLevel, user_location: userLocation, clusterId: userLocation, blockId: blockId, districtId: districtId })
                            } else {
                                res.send({ status: "401", err: "Invalid Cluster user, Please Contact Respective Team" })
                            }

                        })
                    } else if (userLevel === 'Block') {

                        db.query('SELECT distinct district_id FROM school_hierarchy_details WHERE block_id=$1;', [userLocation], (error, results) => {
                            if (error) {
                                logger.info('---user block level from DB error ---');
                                res.send({ status: "401", err: "Invalid Block user, Please Contact Respective Team" })
                                throw error

                            }
                            logger.info('---user block level from DB  success ---');

                            if (results['rowCount']) {
                                let districtId = results.rows[0]['district_id']
                                res.send({ token: token, role: 'report_viewer', username: username, userId: userId, user_level: userLevel, user_location: userLocation, blockId: userLocation, districtId: districtId })
                            } else {
                                res.send({ status: "401", err: "Invalid Block user, Please Contact Respective Team" })
                            }

                        })
                    } else if (userLevel === 'School') {

                        db.query('SELECT distinct cluster_id,block_id,district_id FROM school_hierarchy_details WHERE school_id=$1;', [userLocation], (error, results) => {
                            if (error) {
                                logger.info('---user school level from DB error ---');
                                res.send({ status: "401", err: "Invalid school user, Please Contact Respective Team" })
                                throw error

                            }
                            logger.info('---user school level from DB  success ---');
                          
                            if (results['rowCount']) {
                                let clusterId = results.rows[0]['cluster_id'] 
                                let blockId = results.rows[0]['block_id']
                                let districtId = results.rows[0]['district_id']
                                res.send({ token: token, role: 'report_viewer', username: username, userId: userId, user_level: userLevel, user_location: userLocation, clusterId: clusterId, blockId: blockId, districtId: districtId, schoolId: userLocation })
                            } else {
                                res.send({ status: "401", err: "Invalid school user, Please Contact Respective Team" })
                            }

                        })
                    } else if (userLevel === 'District') {
                        if (userLocation === "") {
                            logger.info('---user block level from DB error ---');
                            res.send({ status: "401", err: "Invalid District user, Please Contact Respective Team" })
                            return
                        }
                        db.query('SELECT distinct district_id FROM school_hierarchy_details WHERE district_id=$1;', [userLocation], (error, results) => {
                            if (error) {
                                logger.info('---user District level from DB error ---');
                                res.send({ status: "401", err: "Invalid District user, Please Contact Respective Team" })
                                throw error

                            }
                          
                            if (results['rowCount']) {

                                res.send({ token: token, role: 'report_viewer', username: username, userId: userId, user_level: userLevel, user_location: userLocation, districtId: userLocation })
                            } else {
                                res.send({ status: "401", err: "Invalid District user, Please Contact Respective Team" })
                            }

                        })
                        

                    } else {
                        res.send({ token: token, role: 'report_viewer', username: username, userId: userId, user_level: userLevel, user_location: userLocation })
                    }

                }).catch(error => {
                    logger.error(`Error :: ${error}`)
                    res.status(409).json({ errMsg: 'please check user name and password' });
                })
            }


        })



    } catch (error) {
        logger.error(`Error :: ${error}`)
        res.status(404).json({ errMessage: "Internal error. Please try again!!" })
    }
})

router.post('/adduser', async (req, res, next) => {
    const { email } = req.body
    logger.info('---new user added ---');
    db.query('INSERT INTO keycloak_users (keycloak_username, status) VALUES ($1, $2)', [req.body.username, "false"], (error, results) => {
        if (error) {
            logger.info('---user create in DB error ---');
            throw error
        }
        logger.info('---user created in DB success ---');
        res.status(201).json({ msg: "User Created" });
    })

})
router.post('/getTotp', async (req, res, next) => {
    const { email, password } = req.body;

    const secret = await generateSecret(email, 'cQube');
    db.query('UPDATE keycloak_users set qr_secret= $2 where keycloak_username=$1;', [req.body.email, secret.secret], (error, results) => {
        if (error) {
            logger.info('---QR code from DB error ---');
            throw error
        }
        logger.info('---qr code from DB success ---');
        res.status(201).json({ msg: "qrcode saved" });

    })
    return res.json({
        message: 'TFA Auth needs to be verified',
        tempSecret: secret.secret,
        dataURL: secret.qrcode,
        tfaURL: secret.otpauth
    })


})

router.post('/logout', async (req, res, next) => {

    let headers = {
        "Content-Type": "application/x-www-form-urlencoded",
    }
    let details = new URLSearchParams({
        client_id: keyClockClient,
        refresh_token: req.body.refToken

    });
    let logoutUrl = `${keyCloakURL}/auth/realms/${keyClockRealm}/protocol/openid-connect/logout`

    await axios.post(logoutUrl, details, { headers: headers }).then(resp => {
        return res.send({
            status: 200
        })
    }).catch(err => {
        logger.error(`Error :: ${err}`)
        res.status(404).json({ errMessage: "Internal error. Please try again!!" })
    })


})

router.post('/getSecret', async (req, res) => {

    const { username } = req.body

    db.query('SELECT qr_secret FROM keycloak_users WHERE keycloak_username = $1', [req.body.username], (error, results) => {
        if (error) {
            logger.info('---user secrect from DB error  ---');
            throw error
        }
        logger.info('---user secrect from DB success  ---');
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
        "message": "Invalid Auth Code"
    });
});

module.exports = router;