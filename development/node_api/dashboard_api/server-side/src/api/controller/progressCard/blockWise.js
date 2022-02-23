const router = require('express').Router();
const { logger } = require('../../lib/logger');
const auth = require('../../middleware/check-auth');
const s3File = require('../../lib/reads3File');

router.post('/blockWise', auth.authController, async (req, res) => {
    try {
        logger.info('---progressCard block wise api ---');
        var blockId = req.body.id;
        var timePeriod = req.body.timePeriod;
        var management = req.body.management;
        var category = req.body.category;
        let fileName;

        if (management != 'overall' && category == 'overall') {
            fileName = `progressCard/school_management_category/${timePeriod}/overall_category/${management}/block/${blockId}.json`;
        } else {
            fileName = `progressCard/block/${timePeriod}/${blockId}.json`;
        }
        let blockData = await s3File.readFileConfig(fileName);
        logger.info('--- progressCard block wise api response sent ---');
        res.status(200).send({ blockData });
    } catch (e) {
        logger.error(`Error :: ${e}`)
        res.status(500).json({ errMessage: "Internal error. Please try again!!" });
    }
});

module.exports = router;