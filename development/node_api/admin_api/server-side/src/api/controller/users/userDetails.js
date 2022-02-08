const router = require('express').Router();
const { logger } = require('../../lib/logger');
const auth = require('../../middleware/check-auth');


const axios = require('axios');
const dotenv = require('dotenv');
const Querystring = require('querystring');

dotenv.config();

var host = process.env.KEYCLOAK_HOST;
var realm = process.env.KEYCLOAK_REALM;


router.post('/userdetails', async function (req, res) {
    try {
        logger.info('---userdetails api ---');
        

        userSessionDetails[req.body.userid] = Object.assign({}, req.body)
        
        return res.send({
            status: 200
        })


    } catch (e) {
        logger.error(`Error :: ${e}`);
        res.status(500).json({ errMsg: "Internal error. Please try again!!" });
    }


});

module.exports = router;