const router = require('express').Router();
const { logger } = require('../../../lib/logger');
const auth = require('../../../middleware/check-auth');
const s3File = require('../../../lib/reads3File');

router.post('/clusterData', auth.authController, async (req, res) => {
    try {
        logger.info('--- diksha chart allData api ---');
        let timePeriod = req.body.timePeriod;
        let blockId = req.body.blockId;
        var fileName = `diksha_tpd/report2/${timePeriod}/cluster/all_collections/${blockId}.json`;
        let jsonData = await s3File.readFileConfig(fileName);
        var footer = jsonData['footer'][`${blockId}`];
        console.log('clust', jsonData)
        jsonData = jsonData.data.filter(a => {
            return a.block_id == blockId;
        });
        var chartData = {
            labels: '',
            data: ''
        }

        jsonData = jsonData.sort((a, b) => (a.cluster_name > b.cluster_name) ? 1 : -1);
        chartData['labels'] = jsonData.map(a => {
            return a.cluster_name
        })
        chartData['data'] = jsonData.map(a => {
            return { enrollment: a.total_enrolled, completion: a.total_completed, certificate_count: a.certificate_count }
        })
        logger.info('--- diksha chart allData api response sent ---');
        res.send({ chartData, downloadData: jsonData, footer });
    } catch (e) {
        logger.error(`Error :: ${e}`)
        res.status(500).json({ errMessage: "Internal error. Please try again!!" });
    }
})


module.exports = router;