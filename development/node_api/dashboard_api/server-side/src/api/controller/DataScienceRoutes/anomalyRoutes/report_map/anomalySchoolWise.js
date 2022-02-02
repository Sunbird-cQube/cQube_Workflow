const router = require('express').Router();
var const_data = require('../../../../lib/config');
const { logger } = require('../../../../lib/logger');
const auth = require('../../../../middleware/check-auth');
const s3File = require('../../../../lib/reads3File');

router.post('/allSchoolWise', auth.authController, async (req, res) => {
    try {
        logger.info('---Anomaly school wise api ---');
        var management = req.body.management;
        var category = req.body.category;
        var anomaly_type = req.body.anomaly_type;
        let fileName;
        fileName = `data_science/anomaly/anomaly_school_map_${anomaly_type}.json`
        var schoolData = await s3File.readFileConfig(fileName); //await s3File.storageType == "s3" ? await s3File.readS3File(fileName) : await s3File.readLocalFile(fileName);;
        var mydata = schoolData.data;
        logger.info('---Anomaly school wise api response sent---');
        res.status(200).send({ data: mydata, footer: schoolData.allSchoolsFooter.totalSchools });
    } catch (e) {
        logger.error(`Error :: ${e}`)
        res.status(500).json({ errMessage: "Internal error. Please try again!!" });
    }
});

router.post('/schoolWise/:distId/:blockId/:clusterId', async (req, res) => {
    try {
        logger.info('---Anomaly schoolPerCluster api ---');
        var management = req.body.management;
        var category = req.body.category;
        var anomaly_type = req.body.anomaly_type;
        let fileName;
        fileName = `data_science/anomaly/anomaly_school_map_${anomaly_type}.json`

        var schoolData = await s3File.readFileConfig(fileName); //await s3File.storageType == "s3" ? await s3File.readS3File(fileName) : await s3File.readLocalFile(fileName);;

        let clusterId = req.params.clusterId;

        let filterData = schoolData.data.filter(obj => {
            return (parseInt(obj.details.cluster_id) == clusterId)
        })

        let mydata = filterData;
        logger.info('---Anomaly schoolPerCluster api response sent---');
        res.status(200).send({ data: mydata, footer: schoolData.footer[0][`${clusterId}`].totalSchools });

    } catch (e) {
        logger.error(e);
        res.status(500).json({ errMessage: "Internal error. Please try again!!" });
    }
});

module.exports = router;
