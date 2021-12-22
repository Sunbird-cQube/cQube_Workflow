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

        let programId = req.body.programId;
        let courseId = req.body.courseId;
        let districtId = req.body.districtId;
        var fileName = `diksha_tpd/report2/${timePeriod}/school/collections/${blockId}.json`;
        let jsonData = await s3File.readFileConfig(fileName);
        var footer = jsonData['footer'][`${clusterId}`];
        if(programId !== undefined && courseId !== undefined && districtId !== undefined && clusterId !== undefined){
            var  result = jsonData.data.filter( data => {
               return  data.program_id === programId 
            }).filter( block => {
                return block.collection_id === courseId
            }).filter(cluster => {
               
               cluster.district_id === districtId 
            }).filter( school =>{
                school.cluster_id === clusterId
            })
        }
       
        result = result.filter(a => {
            return a.cluster_id == clusterId;
        });
        var chartData = {
            labels: '',
            data: ''
        }

        result = result.sort((a, b) => (a.school_name > b.school_name) ? 1 : -1);
        chartData['labels'] = result.map(a => {
            return a.school_name
        })
        chartData['data'] = result.map(a => {
            return { enrollment: a.total_enrolled, completion: a.total_completed, percent_teachers: a.percentage_teachers, certificate_count: a.certificate_count }
        })
        logger.info('--- diksha chart allData api response sent ---');
        res.send({ chartData, downloadData: result, footer });
    } catch (e) {
        logger.error(`Error :: ${e}`)
        res.status(500).json({ errMessage: "Internal error. Please try again!!" });
    }
})


module.exports = router;