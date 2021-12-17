const router = require('express').Router();
const { logger } = require('../../../lib/logger');
const auth = require('../../../middleware/check-auth');
const s3File = require('../../../lib/reads3File');

router.post('/allDistData', auth.authController, async (req, res) => {
    try {
        logger.info('--- diksha chart allData api ---');
        let timePeriod = req.body.timePeriod;
        var fileName = `diksha_tpd/report2/${timePeriod}/district/all_collections.json`;
        let jsonData = await s3File.readFileConfig(fileName);
        var footer = jsonData['footer'];
        var chartData = {
            labels: '',
            data: ''
        }
        jsonData = jsonData.data.sort((a, b) => (a.district_name > b.district_name) ? 1 : -1)
        chartData['labels'] = jsonData.map(a => {
            return a.district_name
        })
        
        chartData['data'] = jsonData.map(a => {
            return { enrollment: a.total_enrolled, 
                completion: a.total_completed, 
                 percent_completion: a.percentage_completion, 
                 expected_enrolled: a.expected_total_enrolled, 
                 enrolled_percentage:a.total_enrolled_percentage,
                 certificate_value: a.certificate_count,
                 certificate_per: a.certificate_percentage
                }
        })
        logger.info('--- diksha chart allData api response sent ---');
        res.send({ chartData, downloadData: jsonData, footer });
    } catch (e) {
        logger.error(`Error :: ${e}`)
        res.status(500).json({ errMessage: "Internal error. Please try again!!" });
    }
})

router.post('/getCollections', auth.authController, async (req, res) => {
    try {
        logger.info('--- diksha chart dikshaGetCollections api ---');
        var fileName;
        var allCollections;
        let timePeriod = req.body.timePeriod
        let level = req.body.level;
        let id = req.body.id;
        if (level == 'district') {
            fileName = `diksha_tpd/report2/${timePeriod}/district/collections.json`;
        } else {
            fileName = `diksha_tpd/report2/${timePeriod}/${level}/collections/${id}.json`;
        }
        let jsonData = await s3File.readFileConfig(fileName);
        console.log('coll', jsonData)
        if (jsonData) {
            let collections;
            collections = jsonData.data.map(val => {
                return val.collection_name
            })
            allCollections = collections.filter(function (elem, pos) {
                return collections.indexOf(elem) == pos;
            });

        }
        logger.info('--- diksha chart dikshaGetCollections api response sent ---');
        res.send({ allCollections })
    } catch (e) {
        logger.error(`Error :: ${e}`)
        res.status(500).json({ errMessage: "Internal error. Please try again!!" });
    }
});

router.post('/getCollectionData', auth.authController, async (req, res) => {
    try {
        logger.info('--- diksha get data on collection select api ---');
        let collection_name = req.body.collection_name
        var fileName;

        let timePeriod = req.body.timePeriod
        let level = req.body.level;
        let id = req.body.id;
        let clusterId = req.body.clusterId;

        if (level == 'district') {
            fileName = `diksha_tpd/report2/${timePeriod}/district/collections.json`;
        } else {
            fileName = `diksha_tpd/report2/${timePeriod}/${level}/collections/${id}.json`;
        }

        let jsonData = await s3File.readFileConfig(fileName);
        jsonData = jsonData.data.filter(a => {
            return a.collection_name == collection_name
        })
        var chartData = {
            labels: '',
            data: ''
        }
        if (level == "district") {
            jsonData = jsonData.sort((a, b) => (a.district_name > b.district_name) ? 1 : -1)
            chartData['labels'] = jsonData.map(a => {
                return a.district_name
            })
        }
        if (level == "block") {
            jsonData = jsonData.filter(a => {
                return a.district_id == id;
            });
            jsonData = jsonData.sort((a, b) => (a.block_name > b.block_name) ? 1 : -1)
            chartData['labels'] = jsonData.map(a => {
                return a.block_name
            })
        }
        if (level == "cluster") {
            jsonData = jsonData.filter(a => {
                return a.block_id == id;
            });
            jsonData = jsonData.sort((a, b) => (a.cluster_name > b.cluster_name) ? 1 : -1)
            chartData['labels'] = jsonData.map(a => {
                return a.cluster_name
            })
        }
        if (level == "school") {
            jsonData = jsonData.filter(a => {
                return a.cluster_id == clusterId;
            });
            jsonData = jsonData.sort((a, b) => (a.school_name > b.school_name) ? 1 : -1)
            chartData['labels'] = jsonData.map(a => {
                return a.school_name
            })
        }

        chartData['data'] = jsonData.map(a => {
            return { enrollment: a.total_enrolled, completion: a.total_completed, percent_teachers: a.percentage_teachers, certificate_count: a.certificate_count }
        })
        logger.info('--- diksha get data on collection select api response sent ---');
        res.send({ chartData, downloadData: jsonData });
    } catch (e) {
        logger.error(`Error :: ${e}`)
        res.status(500).json({ errMessage: "Internal error. Please try again!!" });
    }
});


module.exports = router;