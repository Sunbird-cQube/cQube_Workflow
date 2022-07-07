const router = require('express').Router();
const { logger } = require('../../lib/logger');
var const_data = require('../../lib/config');
const auth = require('../../middleware/check-auth');
const s3File = require('../../lib/reads3File');

router.post('/clusterWise', auth.authController, async (req, res) => {
    try {
        logger.info('---Common table clusterWise api ---');

        let { year, month, grade, subject_name, exam_date, viewBy, blockId, management, category } = req.body
        let fileName;
        if (management != 'overall' && category == 'overall') {
            if (viewBy == 'indicator') {
                fileName = `pat/school_management_category/heatChart/indicatorIdLevel/${year}/${month}/overall_category/${management}/blocks/${blockId}.json`;
            } else if (viewBy == 'question_id')
                fileName = `pat/school_management_category/heatChart/questionIdLevel/${year}/${month}/overall_category/${management}/blocks/${blockId}.json`;
        } else {
            if (viewBy == 'indicator') {
                fileName = `pat/heatChart/indicatorIdLevel/${year}/${month}/blocks/${blockId}.json`;
            } else if (viewBy == 'question_id')
                fileName = `pat/heatChart/questionIdLevel/${year}/${month}/blocks/${blockId}.json`;
        }

        // let data = await s3File.readFileConfig(fileName);

        let data = [
            {
                "academic_year": "2021-22",
                "grade": "Grade 1",
                "subject_name": "Hindi",
                "Performance": 55.6,
                "block_id": 90112,
                "block_name": "Muzaffarabad",
                "cluster_id": "901120008",
                "cluster_name": "Chutmalpur",
                "district_id": 901,
                "district_name": "Saharanpur",
                "latitude": 30.04318,
                "longitude": 77.7465,
                "month": "November",
                "week": 4,
                "date": "26-04-2021",
                "school_id": 9011207703,
                "school_name": "U.P.S.Alipur Sambhalki",
                "school_management_type": "govt"
            },
            {
                "academic_year": "2021-22",
                "grade": "Grade 1",
                "subject_name": "Hindi",
                "Performance": 77.8,
                "block_id": 90112,
                "block_name": "Muzaffarabad",
                "cluster_id": "901120005",
                "cluster_name": "Fatehpur Kalan",
                "district_id": 901,
                "district_name": "Saharanpur",
                "latitude": 30.164156,
                "longitude": 77.683854,
                "month": "November",
                "week": 4,
                "date": "26-04-2021",
                "school_id": 9011207902,
                "school_name": "U.P.S.Saluni Merge"

            }
        ]

        if (blockId) {
            data = data.filter(val => {
                return (
                    val.block_id == blockId
                )
            })
        }

        let clusterDetails = data.map(e => {
            return {
                district_id: e.district_id,
                district_name: e.district_name,
                block_id: e.block_id,
                block_name: e.block_name,
                cluster_id: e.cluster_id,
                cluster_name: e.cluster_name
            }
        })

        clusterDetails = clusterDetails.reduce((unique, o) => {
            if (!unique.some(obj => obj.cluster_id === o.cluster_id)) {
                unique.push(o);
            }
            return unique;
        }, []);

        let arr = {}

        if (grade) {
            data = data.filter(val => {
                return val.grade == grade
            })
        }
        if (subject_name) {
            data = data.filter(val => {
                return val.subject_name == subject_name
            })
        }
        if (exam_date) {
            data = data.filter(val => {
                return val.exam_date == exam_date
            })
        }

        Promise.all(data.map(item => {
            let label = item.exam_date + "/" +
                "grade" + item.grade + "/" +
                item.subject_name + "/"
            label += viewBy == "indicator" ? item.indicator : item.question_id

            arr[label] = arr.hasOwnProperty(label) ? [...arr[label], ...[item]] : [item];

        })).then(() => {
            let keys = Object.keys(arr)
            let val = []
            for (let i = 0; i < keys.length; i++) {
                let z = arr[keys[i]].sort((a, b) => (a.cluster_name) > (b.cluster_name) ? 1 : -1)
                let splitVal = keys[i].split('/')
                var x = {
                    date: splitVal[0],
                    grade: splitVal[1],
                    subject: splitVal[2],
                    [`${viewBy}`]: splitVal[3],
                }
                z.map(val1 => {
                    let y = {
                        [`${val1.cluster_name}`]: { percentage: val1.percentage, mark: val1.marks }
                    }
                    x = { ...x, ...y }
                })
                val.push(x);
            }

            var tableData = [];
            // filling the missing key - value to make the object contains same data set
            if (val.length > 0) {
                let obj = val.reduce((res1, item) => ({ ...res1, ...item }));
                let keys1 = Object.keys(obj);
                let def = keys1.reduce((result1, key) => {
                    result1[key] = ''
                    return result1;
                }, {});
                tableData = val.map((item) => ({ ...def, ...item }));
                logger.info('--- commn table clusterWise response sent ---');
                res.status(200).send({ clusterDetails, tableData });
            } else {
                logger.info('--- common table schoolWise response sent ---');
                res.status(500).send({ errMsg: "No record found" });
            }

        })
    } catch (e) {
        logger.error(`Error :: ${e}`)
        res.status(500).json({ errMessage: "Internal error. Please try again!!" });
    }
});

module.exports = router;