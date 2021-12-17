const router = require('express').Router();
const { logger } = require('../../../lib/logger');
const auth = require('../../../middleware/check-auth');
const s3File = require('../../../lib/reads3File');

router.post('/schoolData', auth.authController, async (req, res) => {
    try {
        logger.info('--- diksha chart allData api ---');
        let timePeriod = req.body.timePeriod;
        let blockId = req.body.blockId;
        let clusterId = req.body.clusterId
        var fileName = `diksha_tpd/report2/${timePeriod}/school/all_collections/${blockId}.json`;
        let jsonData = await s3File.readFileConfig(fileName);
        var footer = jsonData['footer'][`${clusterId}`];
        jsonData = jsonData.data.filter(a => {
            return a.cluster_id == clusterId;
        });
        var chartData = {
            labels: '',
            data: ''
        }

        jsonData = jsonData.sort((a, b) => (a.school_name > b.school_name) ? 1 : -1);
        chartData['labels'] = jsonData.map(a => {
            return a.school_name
        })
        chartData['data'] = jsonData.map(a => {
            return { enrollment: a.total_enrolled, completion: a.total_completed, percent_teachers: a.percentage_teachers, certificate_count: a.certificate_count }
        })
        logger.info('--- diksha chart allData api response sent ---');
        res.send({ chartData, downloadData: jsonData, footer });
    } catch (e) {
        logger.error(`Error :: ${e}`)
        res.status(500).json({ errMessage: "Internal error. Please try again!!" });
    }
})


module.exports = router;