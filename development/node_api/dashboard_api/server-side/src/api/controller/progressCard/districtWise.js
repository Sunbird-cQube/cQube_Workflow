const router = require('express').Router();
const { logger } = require('../../lib/logger');
const auth = require('../../middleware/check-auth');
const s3File = require('../../lib/reads3File');

router.post('/distWise', auth.authController, async (req, res) => {
    try {
        var districtId = req.body.id;
        logger.info('---progressCard dist wise api ---');
        var timePeriod = req.body.timePeriod;
        var management = req.body.management;
        var category = req.body.category;
        let fileName;

        if (management != 'overall' && category == 'overall') {
            fileName = `progressCard/school_management_category/${timePeriod}/overall_category/${management}/district/${districtId}.json`;
        } else {
            fileName = `progressCard/district/${timePeriod}/${districtId}.json`;
        }

        let districtData = await s3File.readFileConfig(fileName);
        logger.info('--- progressCard dist wise api response sent ---');
        res.status(200).send({ districtData });
    } catch (e) {
        logger.error(`Error :: ${e}`)
        res.status(500).json({ errMessage: "Internal error. Please try again!!" });
    }
});

module.exports = router;