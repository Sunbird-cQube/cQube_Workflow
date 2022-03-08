const router = require('express').Router();
var const_data = require('../../../../lib/config'); // Log Variables
const { logger } = require('../../../../lib/logger');
const auth = require('../../../../middleware/check-auth');
const s3File = require('../../../../lib/reads3File');

router.post('/allBlockWise', auth.authController, async(req, res) => {
    try {
        logger.info('--- all blocks dropout api ---');
        var management = req.body.management;
        var category = req.body.category;
        let fileName;
        fileName = `data_science/dropout/dropout_block_map.json`
        var blockData = await s3File.readFileConfig(fileName);
        var mydata = blockData.data;
        logger.info('--- blocks dropout api response sent---');
        res.status(200).send({ data: mydata, footer: blockData.allBlocksFooter.totalSchools });

    } catch (e) {
        logger.error(`Error :: ${e}`);
        res.status(500).json({ errMessage: "Internal error. Please try again!!" });
    }
})

router.post('/blockWise/:distId', auth.authController, async(req, res) => {
    try {
        logger.info('--- block per district dropout api ---');
        var management = req.body.management;
        var category = req.body.category;
        let fileName;
        fileName = `data_science/dropout/dropout_block_map.json`
        var blockData = await s3File.readFileConfig(fileName);

        let distId = req.params.distId

        let filterData = blockData.data.filter(obj => {
            return (obj.details.district_id == distId)
        })
        let mydata = filterData;
        logger.info('--- block per dist dropout api response sent---');
        res.status(200).send({ data: mydata, footer: blockData.footer[0][`${distId}`].totalSchools });

    } catch (e) {
        logger.error(e);
        res.status(500).json({ errMessage: "Internal error. Please try again!!" });
    }
})

module.exports = router;
