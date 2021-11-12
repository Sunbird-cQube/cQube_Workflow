const router = require('express').Router();
const { logger } = require('../../../lib/logger');
const auth = require('../../../middleware/check-auth');
const s3File = require('../../../lib/reads3File');

router.post('/allClusterWise', auth.authController, async (req, res) => {
    try {
        logger.info('---Infra cluster wise api ---');
        var management = req.body.management;
        var category = req.body.category;
        let fileName;

        if (management != 'overall' && category == 'overall') {
            fileName = `infra/school_management_category/overall_category/${management}/infra_cluster_map.json`;
        } else {
            fileName = `infra/infra_cluster_map.json`
        }
        let clusterData = await s3File.readFileConfig(fileName);
        var mydata = clusterData.data;
        logger.info('---Infra cluster wise api response sent---');
        res.status(200).send({ data: mydata, footer: clusterData.allClustersFooter.totalSchools });
    } catch (e) {
        logger.error(`Error :: ${e}`)
        res.status(500).json({ errMessage: "Internal error. Please try again!!" });
    }
});

router.post('/clusterWise/:distId/:blockId', auth.authController, async (req, res) => {
    try {
        logger.info('---Infra clusterperBlock api ---');
        var management = req.body.management;
        var category = req.body.category;
        let fileName;

        if (management != 'overall' && category == 'overall') {
            fileName = `infra/school_management_category/overall_category/${management}/infra_cluster_map.json`;
        } else {
            fileName = `infra/infra_cluster_map.json`
        }
        let clusterData = await s3File.readFileConfig(fileName);

        let blockId = req.params.blockId;

        let filterData = clusterData.data.filter(obj => {
            return (obj.details.block_id == blockId)
        })
        let mydata = filterData;
        logger.info('---Infra clusterperBlock api response sent---');
        res.status(200).send({ data: mydata, footer: clusterData.footer[`${blockId}`].totalSchools });


    } catch (e) {
        logger.error(e);
        res.status(500).json({ errMessage: "Internal error. Please try again!!" });
    }
})


module.exports = router;