const router = require('express').Router();
var const_data = require('../../../lib/config'); // Log Variables
const { logger } = require('../../../lib/logger');
const auth = require('../../../middleware/check-auth');
const s3File = require('../../../lib/reads3File');

router.post('/allBlockWise', auth.authController, async (req, res) => {
    try {
        logger.info('--- all blocks infra api ---');
        var management = req.body.management;
        var category = req.body.category;
        let fileName;

        if (management != 'overall' && category == 'overall') {
            fileName = `infra/school_management_category/overall_category/${management}/infra_block_map.json`;
        } else {
            fileName = `infra/infra_block_map.json`
        }
        var blockData = await s3File.storageType == "s3" ? await s3File.readS3File(fileName) : await s3File.readLocalFile(fileName);;
        var mydata = blockData.data;
        logger.info('--- blocks infra api response sent---');
        res.status(200).send({ data: mydata, footer: blockData.allBlocksFooter.totalSchools });

    } catch (e) {
        logger.error(`Error :: ${e}`);
        res.status(500).json({ errMessage: "Internal error. Please try again!!" });
    }
})

router.post('/blockWise/:distId', auth.authController, async (req, res) => {
    try {
        logger.info('--- block per district infra api ---');
        var management = req.body.management;
        var category = req.body.category;
        let fileName;

        if (management != 'overall' && category == 'overall') {
            fileName = `infra/school_management_category/overall_category/${management}/infra_block_map.json`;
        } else {
            fileName = `infra/infra_block_map.json`
        }
        var blockData = await s3File.storageType == "s3" ? await s3File.readS3File(fileName) : await s3File.readLocalFile(fileName);;

        let distId = req.params.distId

        let filterData = blockData.data.filter(obj => {
            return (obj.details.district_id == distId)
        })
        let mydata = filterData;
        logger.info('--- block per dist infra api response sent---');
        res.status(200).send({ data: mydata, footer: blockData.footer[`${distId}`].totalSchools });

    } catch (e) {
        logger.error(e);
        res.status(500).json({ errMessage: "Internal error. Please try again!!" });
    }
})

module.exports = router;