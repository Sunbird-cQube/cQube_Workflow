const router = require('express').Router();
var const_data = require('../../../../lib/config');
const { logger } = require('../../../../lib/logger');
const auth = require('../../../../middleware/check-auth');
const s3File = require('../../../../lib/reads3File');

router.post('/allClusterWise', auth.authController, async(req, res) => {
    try {
        logger.info('---Dropout cluster wise api ---');
        var management = req.body.management;
        var category = req.body.category;
        let fileName;

        fileName = `data_science/dropout/dropout_cluster_map.json`
        // var clusterData = await s3File.readS3File(fileName);
        var clusterData = await s3File.readFileConfig(fileName); //await s3File.storageType == "s3" ? await s3File.readS3File(fileName) : await s3File.readLocalFile(fileName);;
        var mydata = clusterData.data;
        logger.info('---Dropout cluster wise api response sent---');
        res.status(200).send({ data: mydata, footer: clusterData.allClustersFooter.totalSchools });
    } catch (e) {
        logger.error(`Error :: ${e}`)
        res.status(500).json({ errMessage: "Internal error. Please try again!!" });
    }
});

router.post('/clusterWise/:distId/:blockId', auth.authController, async(req, res) => {
    try {
        logger.info('---Dropout clusterperBlock api ---');
        var management = req.body.management;
        var category = req.body.category;
        let fileName;

        fileName = `data_science/dropout/dropout_cluster_map.json`
        console.log(fileName)
        // var clusterData = await s3File.readS3File(fileName);
        var clusterData = await s3File.readFileConfig(fileName); //await s3File.storageType == "s3" ? await s3File.readS3File(fileName) : await s3File.readLocalFile(fileName);;

        let blockId = req.params.blockId;

        let filterData = clusterData.data.filter(obj => {
            return (obj.details.block_id == blockId)
        })
        let mydata = filterData;
        logger.info('---Dropout clusterperBlock api response sent---');
        res.status(200).send({ data: mydata, footer: clusterData.footer[0][`${blockId}`].totalSchools });


    } catch (e) {
        logger.error(e);
        res.status(500).json({ errMessage: "Internal error. Please try again!!" });
    }
})


module.exports = router;
