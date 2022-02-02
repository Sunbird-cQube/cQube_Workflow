const router = require('express').Router();
var const_data = require('../../../../lib/config');
const { logger } = require('../../../../lib/logger');
const auth = require('../../../../middleware/check-auth');
const s3File = require('../../../../lib/reads3File');

router.post('/allSchoolWise', auth.authController, async (req, res) => {
    try {
        logger.info('---Dropout school wise api ---');
        var management = req.body.management;
        var category = req.body.category;
        let fileName;
        fileName = `data_science/dropout/dropout_school_map.json`
        var schoolData = await s3File.readFileConfig(fileName); //await s3File.storageType == "s3" ? await s3File.readS3File(fileName) : await s3File.readLocalFile(fileName);;
        var mydata = schoolData.data;
        logger.info('---Dropout school wise api response sent---');
        res.status(200).send({ data: mydata, footer: schoolData.allSchoolsFooter.totalSchools });
    } catch (e) {
        logger.error(`Error :: ${e}`)
        res.status(500).json({ errMessage: "Internal error. Please try again!!" });
    }
});

router.post('/schoolWise/:distId/:blockId/:clusterId', async (req, res) => {
    try {
        logger.info('---Dropout schoolPerCluster api ---');
        var management = req.body.management;
        var category = req.body.category;
        let fileName;
        fileName = `data_science/dropout/dropout_school_map.json`

        // if (management != 'overall' && category == 'overall') {
        //    fileName = `infra/school_management_category/overall_category/${management}/infra_school_map.json`;
        // } else {
        //    fileName = `infra/infra_school_map.json`
        // }
        var schoolData = await s3File.readFileConfig(fileName); //await s3File.storageType == "s3" ? await s3File.readS3File(fileName) : await s3File.readLocalFile(fileName);;

        let clusterId = req.params.clusterId;

        let filterData = schoolData.data.filter(obj => {
            return (parseInt(obj.details.cluster_id) == clusterId)
        })

        let mydata = filterData;
        logger.info('---Dropout schoolPerCluster api response sent---');
        res.status(200).send({ data: mydata, footer: schoolData.footer[0][`${clusterId}`].totalSchools });

    } catch (e) {
        logger.error(e);
        res.status(500).json({ errMessage: "Internal error. Please try again!!" });
    }
})

module.exports = router;
