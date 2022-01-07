const router = require('express').Router();
const { logger } = require('../../../lib/logger');
const auth = require('../../../middleware/check-auth');
const s3File = require('../../../lib/reads3File');

router.get('/programData', auth.authController, async (req, res) => {
    try {
        logger.info('--- diksha multi bar chart program api api ---');
        
        var fileName = `diksha_tpd/report2/overall/district/all_programs.json`;
        let jsonData = await s3File.readFileConfig(fileName);
        logger.info('--- diksha multi bar chart api response sent ---');
        
        res.send({ data:jsonData, downloadData: jsonData, dropDown: jsonData });
    } catch (e) {
        logger.error(`Error :: ${e}`)
        res.status(500).json({ errMessage: "Internal error. Please try again!!" });
    }
})


module.exports = router;