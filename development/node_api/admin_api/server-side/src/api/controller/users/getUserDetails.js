const router = require('express').Router();
const { logger } = require('../../lib/logger');
const auth = require('../../middleware/check-auth');


const axios = require('axios');
const dotenv = require('dotenv');
const Querystring = require('querystring');

dotenv.config();


router.get('/getUserdetails/:id', async function (req, res) {
    try {
        logger.info('---userdetails api ---');

        return res.send({
            status: 200,
            userObj: global.userSessionDetails[req.params.id]
        })



    } catch (e) {
        logger.error(`Error :: ${e}`);
        res.status(500).json({ errMsg: "Internal error. Please try again!!" });
    }


});

module.exports = router;