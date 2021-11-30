const router = require('express').Router();
const { logger } = require('../../lib/logger');
const auth = require('../../middleware/check-auth');
const s3File = require('../../lib/reads3File');

router.post('/clusterWise', auth.authController, async (req, res) => {
    try {
        logger.info('---progressCard cluster wise api ---');
        var blockId = req.body.blockId;
        var clusterId = req.body.id;
        var timePeriod = req.body.timePeriod;
        var management = req.body.management;
        var category = req.body.category;
        let fileName;

        if (management != 'overall' && category == 'overall') {
            fileName = `progressCard/school_management_category/${timePeriod}/overall_category/${management}/cluster/${blockId}.json`;
        } else {
            fileName = `progressCard/cluster/${timePeriod}/${blockId}.json`;
        }
        let clusterData = await s3File.readFileConfig(fileName);
        clusterData = clusterData.filter(a => {
            if (a.cluster_id == clusterId) {
                return a;
            }
        });
        logger.info('--- progressCard cluster wise api response sent ---');
        if (clusterData.length > 0) {
            res.status(200).send({ clusterData });
        } else {
            res.status(403).json({ errMessage: "Data not available" });
        }
    } catch (e) {
        logger.error(`Error :: ${e}`)
        res.status(500).json({ errMessage: "Internal error. Please try again!!" });
    }
});

module.exports = router;