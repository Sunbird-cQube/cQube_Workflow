const router = require('express').Router();
var const_data = require('../../../../lib/config'); // Log Variables
const { logger } = require('../../../../lib/logger');
const auth = require('../../../../middleware/check-auth');
const s3File = require('../../../../lib/reads3File');

router.post('/allBlockWise', auth.authController, async(req, res) => {
    try {
        logger.info('--- all blocks anomaly api ---');
        var management = req.body.management;
        var category = req.body.category;
        var anomaly_type = req.body.anomaly_type;
        let fileName;
        fileName = `data_science/anomaly/anomaly_block_map_${anomaly_type}.json`
        var blockData = await s3File.readFileConfig(fileName);
        var mydata = blockData.data;
        logger.info('--- blocks anomaly api response sent---');
        res.status(200).send({ data: mydata, footer: blockData.allBlocksFooter.totalSchools });

    } catch (e) {
        logger.error(`Error :: ${e}`);
        res.status(500).json({ errMessage: "Internal error. Please try again!!" });
    }
})

router.post('/blockWise/:distId', auth.authController, async(req, res) => {
    try {
        logger.info('--- block per district anomaly api ---');
        var management = req.body.management;
        var category = req.body.category;
        var anomaly_type = req.body.anomaly_type;
        let fileName;
        fileName = `data_science/anomaly/anomaly_block_map_${anomaly_type}.json`
        var blockData = await s3File.readFileConfig(fileName);

        let distId = req.params.distId

        let filterData = blockData.data.filter(obj => {
            return (obj.details.district_id == distId)
        })
        let mydata = filterData;
        logger.info('--- block per dist anomaly api response sent---');
        res.status(200).send({ data: mydata, footer: blockData.footer[0][distId].total_schools });

    } catch (e) {
        logger.error(e);
        res.status(500).json({ errMessage: "Internal error. Please try again!!" });
    }
})

module.exports = router;
