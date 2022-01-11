const router = require('express').Router();
const { logger } = require('../../lib/logger');
const auth = require('../../middleware/check-auth');
const axios = require('axios');
const dotenv = require('dotenv');




router.post('/login', async (req, res) => {
    try {
        logger.info('---sign In api ---');
        var url = 'http://0.0.0.0:6001/login';
        var headers = {
            "Content-Type": "application/json",
        }
        
        var details = {
            username: 'admin',
            password: 'admin'
        };

        await axios.post(url, details, { headers: headers }).then(resp => {

            let token = resp.data.access_token
            logger.info('---sign In successfully api ---');
            res.status(200).json({ msg: "Signed In Successfully" });
            res.send({ token: token })
        }).catch(error => {
            logger.error(`Error :: ${error}`)
            console.log(error)
            res.status(409).json({ errMsg: error.response.data.errorMessage });
        })

    } catch (error) {
        logger.error(`Error :: ${error}`)
        res.status(500).json({ errMessage: "Internal error. Please try again!!" });
    }

})

module.exports = router;