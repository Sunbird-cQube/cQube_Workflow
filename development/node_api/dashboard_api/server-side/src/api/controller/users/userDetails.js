const router = require('express').Router();
const { logger } = require('../../lib/logger');
const auth = require('../../middleware/check-auth');
const axios = require('axios');
const dotenv = require('dotenv');
const db = require('../keycloakDB/db')
const Querystring = require('querystring');
dotenv.config();

var host = process.env.KEYCLOAK_HOST;
var realm = process.env.KEYCLOAK_REALM;
var authType = process.env.AUTH_API;
var client_id = process.env.KEYCLOAK_CLIENT

router.post('/userlevel', auth.authController, async (req, res) => {
    try {
       
            logger.info('---change password api response sent---');
            db.query('UPDATE keycloak_users set status= $2 where keycloak_username=$1;', [req.body.username, 'false'], (error, results) => {
                if (error) {
                    throw error
                }
                res.status(201).json({ msg: "Password changed" });

            })

    } catch (e) {
        logger.error(`Error :: ${e}`);
        res.status(500).json({ errMsg: "Internal error. Please try again!!" });
    }
});





module.exports = router;