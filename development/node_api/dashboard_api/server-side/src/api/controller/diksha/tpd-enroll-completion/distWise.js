const router = require('express').Router();
const { logger } = require('../../../lib/logger');
const auth = require('../../../middleware/check-auth');
const s3File = require('../../../lib/reads3File');

router.post('/allDistData', auth.authController, async (req, res) => {
    try {
        logger.info('--- diksha chart allData api ---');
        let timePeriod = req.body.timePeriod;
        var fileName = `diksha_tpd/report2/${timePeriod}/district/all.json`;
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


        chartData['dropDown'] = jsonData.map(a => {
            return {
                district_name: a.district_name,
                district_id: a.district_id
            }

        })

        const key = 'district_name';

        chartData['dropDown'] = [...new Map(chartData['dropDown'].map(item =>
            [item[key], item])).values()];



        chartData['data'] = jsonData.map(a => {
            return {
                enrollment: a.total_enrolled,
                completion: a.total_completed,
                percent_completion: a.percentage_completion,
                expected_enrolled: a.expected_total_enrolled,
                enrolled_percentage: a.total_enrolled_percentage,
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
            fileName = `diksha_tpd/report2/${timePeriod}/district/all_collections.json`;
        } else if (level == 'program') {
            fileName = `diksha_tpd/report2/${timePeriod}/district/all_program_collections.json`;
        } else {
            fileName = `diksha_tpd/report2/${timePeriod}/${level}/all_program_collections/${id}.json`;
        }


        let jsonData = await s3File.readFileConfig(fileName);
        if (jsonData) {
            let collections;
            collections = jsonData.data.map(val => {
                return {
                    collection_name: val.collection_name,
                    collection_id: val.collection_id
                }
            })
            allCollections = [];

            let collectionMap = new Map();

            collections.forEach(collection => {
                if (!collectionMap.has(collection.collection_id)) {
                    allCollections.push(collection);
                    collectionMap.set(collection.collection_id, true);
                }
            })

        }
        logger.info('--- diksha chart dikshaGetCollections api response sent ---');
        res.send({ allCollections, allData: jsonData })
    } catch (e) {
        logger.error(`Error :: ${e}`)
        res.status(500).json({ errMessage: "Internal error. Please try again!!" });
    }
});

router.post('/getCollectionData', auth.authController, async (req, res) => {
    try {
        logger.info('--- diksha get data on collection select api ---');
        let collectionId = req.body.collection_name
        var fileName;

        let timePeriod = req.body.timePeriod
        let level = req.body.level;
        let id = req.body.id;
        let clusterId = req.body.clusterId;
        let programId = req.body.programId;

        if (level == 'district') {
            fileName = `diksha_tpd/report2/${timePeriod}/district/all_collections.json`;
        } else if (level == 'program') {
            fileName = `diksha_tpd/report2/${timePeriod}/district/all_program_collections.json`;
        } else {
            fileName = `diksha_tpd/report2/${timePeriod}/${level}/all_collections/${id}.json`;
        }

        let collectionDataRes = await s3File.readFileConfig(fileName);
        let collectionData = collectionDataRes.data;

        if (programId !== undefined) {
            collectionData = collectionData.filter(collection => {
                return collection.program_id === programId;
            });
        }

        if (collectionId !== undefined) {
            collectionData = collectionData.filter(collection => {
                return collection.collection_id === collectionId;
            });
        }
        let chartData = {
            labels: '',
            data: ''
        };

        if (level == "district" || level == "program") {
            collectionData = collectionData.sort((a, b) => (a.district_name > b.district_name) ? 1 : -1)
            chartData['labels'] = collectionData.map(a => {
                return a.district_name
            })
        }
        if (level == "block") {
            collectionData = collectionData.filter(a => {
                return a.district_id == id;
            });
            collectionData = collectionData.sort((a, b) => (a.block_name > b.block_name) ? 1 : -1)
            chartData['labels'] = collectionData.map(a => {
                return a.block_name
            })
        }
        if (level == "cluster") {
            collectionData = collectionData.filter(a => {
                return a.block_id == id;
            });
            collectionData = collectionData.sort((a, b) => (a.cluster_name > b.cluster_name) ? 1 : -1)
            chartData['labels'] = collectionData.map(a => {
                return a.cluster_name
            })
        }
        if (level == "school") {
            collectionData = collectionData.filter(a => {
                return a.cluster_id == clusterId;
            });
            collectionData = collectionData.sort((a, b) => (a.school_name > b.school_name) ? 1 : -1)
            chartData['labels'] = collectionData.map(a => {
                return a.school_name
            })
        }

        chartData['data'] = collectionData.map(a => {
            return {
                enrollment: a.total_enrolled,
                completion: a.total_completed,
                percent_completion: a.percentage_completion,
                expected_enrolled: a.expected_total_enrolled,
                enrolled_percentage: a.total_enrolled_percentage,
                certificate_value: a.certificate_count,
                certificate_per: a.certificate_percentage,
                collectionId: a.collection_id
            }
        })
        logger.info('--- diksha get data on collection select api response sent ---');
        res.send({ chartData, downloadData: collectionData, collectionData: collectionData, collectionDataRes });
    } catch (e) {
        logger.error(`Error :: ${e}`)
        res.status(500).json({ errMessage: "Internal error. Please try again!!" });
    }
});


module.exports = router;