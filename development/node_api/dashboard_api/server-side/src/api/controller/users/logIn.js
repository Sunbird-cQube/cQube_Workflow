const router = require('express').Router();
const { logger } = require('../../lib/logger');
const auth = require('../../middleware/check-auth');
const axios = require('axios');
const dotenv = require('dotenv');
const querystring = require('querystring');
const qr = require('qrcode');
const speakeasy = require("speakeasy");
const common = require('./common');
const { userInfo } = require('os');

dotenv.config();
const authURL = process.env.AUTH_API
const keyCloakURL = process.env.KEYCLOAK_HOST
const keyClockRealm = process.env.KEYCLOAK_REALM

router.post('/login', async (req, res, next) => {

    const { email, password } = req.body;
    let role = '';

    let stateheaders = {
        "Content-Type": "application/json",
    }


    if (!email || !password) {
        return next(new ErrorResponse('Please provide an email and password', 400));
    }

    try {
        logger.info('--- custom login  api ---');
        // let url = 'http://0.0.0.0:6001/login';
        let url = authURL;
        let headers = {
            "Content-Type": "application/json",
        }

        let details = {
            username: email,
            password: password,
        };

        axios.post(url, details, { headers: stateheaders }).then(resp => {

            let token = resp.data.access_token;
            let username = '';
            let userId = resp.data.payload.id

            const decodingJWT = (token1) => {

                if (token1 !== null || token1 !== undefined) {
                    const base64String = token1.split('.')[1];
                    const decodedValue = JSON.parse(Buffer.from(base64String,
                        'base64').toString('ascii'));
                    username = decodedValue.sub

                    return decodedValue;
                }
                return null;
            }
            decodingJWT(token)
            logger.info('--- custom login  api sent success---');
            res.send({ token: token, role: 'report_viewer', username: username, userId: userId })
        }).catch(error => {

            logger.error(`Error :: ${error}`)
            res.status(409).json({ errMsg: 'please check user name and password' });
        })


    } catch (error) {
        logger.error(`Error :: ${error}`)
        res.status(404).json({ errMessage: "Internal error. Please try again!!" })
    }
})

router.post('/role', async (req, res, next) => {

})
router.post('/getTotp', async (req, res, next) => {
    const { email, password } = req.body;
    common.userObject = {};

    common.userObject.uname = email;
    common.userObject.upass = password;

    const secret = speakeasy.generateSecret({
        length: 10,
        name: common.userObject.uname,
    });

    var url = speakeasy.otpauthURL({
        secret: secret.base32,
        label: common.userObject.uname,
        encoding: 'base32',
        step: 200
    });


    qr.toDataURL(url, (err, dataURL) => {
        common.userObject.tfa = {
            secret: '',
            tempSecret: secret.base32,
            dataURL,
            tfaURL: url,
            lable: email
        };
        return res.json({
            message: 'TFA Auth needs to be verified',
            tempSecret: secret.base32,
            dataURL,
            tfaURL: secret.otpauth_url
        });
    });


})


router.post('/totpVerify', (req, res) => {
    const { secret, token } = req.body

    let isVerified = speakeasy.totp.verify({
        secret: secret,
        encoding: 'base32',
        token: token,
    });
    if (isVerified) {
        return res.send({
            "status": 200,
            "message": "Two-factor Auth is enabled successfully"
        });
    }

    return res.send({
        "status": 403,
        "message": "Invalid Auth Code, verification failed. Please verify the system Date and Time"
    });
});

module.exports = router;