const router = require('express').Router();
var const_data = require('../../../../lib/config');
const { logger } = require('../../../../lib/logger');
const auth = require('../../../../middleware/check-auth');
const s3File = require('../../../../lib/reads3File');

router.post('/distWise', auth.authController, async(req, res) => {
    try {
        logger.info('---Anomaly dist wise api ---');
        var management = req.body.management;
        var category = req.body.category;
        var anomaly_type = req.body.anomaly_type;
        let fileName;
        fileName = `data_science/anomaly/anomaly_district_map_${anomaly_type}.json`
        var districtData = await s3File.readFileConfig(fileName);
        var mydata = districtData.data;

        logger.info('--- Anomaly dist wise api response sent ---');
        res.status(200).send({ data: mydata, footer: districtData.allDistrictsFooter.totalSchools });
    } catch (e) {
        logger.error(`Error :: ${e}`)
        res.status(500).json({ errMessage: "Internal error. Please try again!!" });
    }
});

module.exports = router;
