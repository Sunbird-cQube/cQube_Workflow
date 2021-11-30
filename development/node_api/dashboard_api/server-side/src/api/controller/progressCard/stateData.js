const router = require('express').Router();
const { logger } = require('../../lib/logger');
const auth = require('../../middleware/check-auth');
const s3File = require('../../lib/reads3File');

router.post('/stateData', auth.authController, async (req, res) => {
    try {
        logger.info('---progressCard stateData api ---');
        var timePeriod = req.body.timePeriod;
        var management = req.body.management;
        var category = req.body.category;
        let fileName;

        if (management != 'overall' && category == 'overall') {
            fileName = `progressCard/school_management_category/${timePeriod}/overall_category/${management}/stateData.json`;
        } else {
            fileName = `progressCard/${timePeriod}/state.json`;
        }
        let data = await s3File.readFileConfig(fileName);
        logger.info('--- progressCard stateData api response sent ---');
        res.status(200).send({ data });
    } catch (e) {
        logger.error(`Error :: ${e}`)
        res.status(500).json({ errMessage: "Internal error. Please try again!!" });
    }
});

module.exports = router;