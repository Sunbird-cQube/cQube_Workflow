
const router = require('express').Router();
var const_data = require('../../lib/config');
const { logger } = require('../../lib/logger');
const auth = require('../../middleware/check-auth');
const groupArray = require('group-array');
const s3File = require('../../lib/reads3File');

router.get('/getDateRange', auth.authController, async (req, res)=> {
    try {
        logger.info('---getDateRange api ---');
        let fileName = `pat/metaData.json`;
        var jsonData = await s3File.storageType == "s3" ? await s3File.readS3File(fileName) : await s3File.readLocalFile(fileName);
        logger.info('--- getDateRange response sent ---');
        res.status(200).send(jsonData);
    } catch (e) {
        logger.error(`Error :: ${e}`)
        res.status(500).json({ errMessage: "Internal error. Please try again!!" });
    }
});

module.exports = router;