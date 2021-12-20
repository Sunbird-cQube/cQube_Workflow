const router = require('express').Router();
const { logger } = require('../../../lib/logger');
const auth = require('../../../middleware/check-auth');
const s3File = require('../../../lib/reads3File');

router.get('/programData', auth.authController, async (req, res) => {
    try {
        logger.info('--- diksha multi bar chart program api api ---');
        
        var fileName = `diksha_tpd/report2/overall/district/all_program_collections.json`;
        let jsonData = await s3File.readFileConfig(fileName);
        console.log('progrma', jsonData)
        // var footer = jsonData['footer'][`${clusterId}`];
        // var chartData = {
        //     labels: '',
        //     data: ''
        // }
        // jsonData = jsonData.data.sort((a, b) => (a.district_name > b.district_name) ? 1 : -1)
        // chartData['labels'] = jsonData.map(a => {
        //     return a.district_name
        // })
        
        // chartData['data'] = jsonData.map(a => {
        //     return { enrollment: a.total_enrolled, 
        //         completion: a.total_completed, 
        //          percent_completion: a.percentage_completion, 
        //          expected_enrolled: a.expected_total_enrolled, 
        //          enrolled_percentage:a.total_enrolled_percentage,
        //          certificate_value: a.certificate_count,
        //          certificate_per: a.certificate_percentage
        //         }
        // })
        logger.info('--- diksha multi bar chart api response sent ---');
        res.send({ data:jsonData, downloadData: jsonData, dropDown: jsonData });
    } catch (e) {
        logger.error(`Error :: ${e}`)
        res.status(500).json({ errMessage: "Internal error. Please try again!!" });
    }
})


module.exports = router;