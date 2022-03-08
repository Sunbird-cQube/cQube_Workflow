const router = require('express').Router();
var const_data = require('../../../../lib/config');
const { logger } = require('../../../../lib/logger');
const auth = require('../../../../middleware/check-auth');
const s3File = require('../../../../lib/reads3File');

router.post('/allClusterWise', auth.authController, async(req, res) => {
    try {
        logger.info('---Anomaly cluster wise api ---');
        var management = req.body.management;
        var category = req.body.category;
        var anomaly_type = req.body.anomaly_type;
        let fileName;

        fileName = `data_science/anomaly/anomaly_cluster_map_${anomaly_type}.json`
        var clusterData = await s3File.readFileConfig(fileName);
        var mydata = clusterData.data;
        logger.info('---Anomaly cluster wise api response sent---');
        res.status(200).send({ data: mydata, footer: clusterData.allClustersFooter.totalSchools });
    } catch (e) {
        logger.error(`Error :: ${e}`)
        res.status(500).json({ errMessage: "Internal error. Please try again!!" });
    }
});

router.post('/clusterWise/:distId/:blockId', auth.authController, async(req, res) => {
    try {
        logger.info('---Anomaly clusterperBlock api ---');
        var management = req.body.management;
        var category = req.body.category;
        var anomaly_type = req.body.anomaly_type;
        let fileName;

        fileName = `data_science/anomaly/anomaly_cluster_map_${anomaly_type}.json`
        var clusterData = await s3File.readFileConfig(fileName);

        let blockId = req.params.blockId;

        let filterData = clusterData.data.filter(obj => {
            return (obj.details.block_id == blockId)
        })
        let mydata = filterData;
        logger.info('---Anomaly clusterperBlock api response sent---');
        res.status(200).send({ data: mydata, footer: clusterData.footer[0][blockId].total_schools });


    } catch (e) {
        logger.error(e);
        res.status(500).json({ errMessage: "Internal error. Please try again!!" });
    }
})


module.exports = router;
