const router = require('express').Router();
const { logger } = require('../../lib/logger');
const auth = require('../../middleware/check-auth');
const s3File = require('../../lib/reads3File');


router.post('/schoolWise', auth.authController, async (req, res) => {
    try {
        logger.info('---Common table schoolWise api ---');
        let schoolLevel = req.body.schoolLevel
        let { year, month, dataSource, grade, subject_name, exam_date, week, period, blockId, clusterId, management, category, reportType } = req.body
        let fileName;

        if (reportType == "loTable") {
            if (category == 'overall') {
                fileName = `${dataSource}/overall/school_subject_footer.json`;
            }
        } else {
            if (category == 'overall') {
                if (period === "overall") {
                    if (grade && !subject_name) {
                        fileName = `${dataSource}/overall/school/${grade}.json`;
                    } else if (grade && subject_name) {
                        fileName = `${dataSource}/overall/school_subject_footer.json`;
                    } else if (!grade && !subject_name) {
                        fileName = `${dataSource}/overall/school.json`;
                    }
                } else if (period === "last 30 days") {
                    if (grade && !subject_name) {
                        fileName = `${dataSource}/last_30_day/school/${grade}.json`;
                    } else if (grade && subject_name) {
                        fileName = `${dataSource}/last_30_day/school_subject_footer.json`;
                    } else if (!grade && !subject_name) {
                        fileName = `${dataSource}/last_30_day/school.json`;
                    }
                } else if (period === "last 7 days") {
                    if (grade && !subject_name) {
                        fileName = `${dataSource}/last_7_day/school/${grade}.json`;
                    } else if (grade && subject_name) {
                        fileName = `${dataSource}/last_7_day/school_subject_footer.json`;
                    } else if (!grade && !subject_name) {
                        fileName = `${dataSource}/last_7_day/school.json`;
                    }
                } else if (period === "year and month") {
                    if (month && !week && !exam_date && !grade && !subject_name) {
                        console.log('month+++++++++++')
                        fileName = `${dataSource}/${year}/${month}/school.json`
                    } else if ((month && week && !exam_date && !grade && !subject_name)) {
                        console.log('month && week')
                        fileName = `${dataSource}/${year}/${month}/week_${week}/school.json`
                    } else if ((month && week && exam_date && !grade && !subject_name)) {
                        console.log('month && week && day')
                        fileName = `${dataSource}/${year}/${month}/week_${week}/${exam_date}/school.json`
                    } else if ((month && week && exam_date && grade && !subject_name)) {
                        fileName = `${dataSource}/${year}/${month}/week_${week}/${exam_date}/school/${grade}.json`
                    } else if ((month && week && exam_date && grade && subject_name)) {
                        fileName = `${dataSource}/${year}/${month}/week_${week}/${exam_date}/school_subject_footer.json`
                    } else {
                        // if (grade) {
                        fileName = `${dataSource}/overall/school.json`;
                        // }
                    }
                }

            }
        }
        console.log('filename', fileName)
        let data = await s3File.readFileConfig(fileName);
        data = data['data']

        if (schoolLevel) {
            data = data.filter(id => id.school_id === req.body.schoolId)
        }

        if (clusterId) {
            data = data.filter(val => {
                return (
                    val.cluster_id == clusterId
                )
            })
        }

        let schoolDetails = data.map(e => {
            return {
                district_id: e.district_id,
                district_name: e.district_name,
                block_id: e.block_id,
                block_name: e.block_name,
                cluster_id: e.cluster_id,
                cluster_name: e.cluster_name,
                school_id: e.school_id,
                school_name: e.school_name
            }
        })

        schoolDetails = schoolDetails.reduce((unique, o) => {
            if (!unique.some(obj => obj.school_id === o.school_id)) {
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
                return val.subject == subject_name
            })
        }
        if (exam_date) {
            data = data.filter(val => {
                return val.distribution_date == exam_date
            })
        }
        console.log('map', data)
        if (reportType == "Map") {
            data = data.map(({
                school_latitude: lat,
                school_longitude: long,

                ...rest
            }) => ({
                lat, long,
                ...rest
            }));
            res.status(200).send({ data, schoolDetails })
        }

        if (reportType == "loTable") {
            Promise.all(data.map(item => {
                let label =
                    "grade" + item.grade + "/" +
                    item.subject_name + item.no_of_books_distributed
                // label += day  ? item.date : item.question_id

                arr[label] = arr.hasOwnProperty(label) ? [...arr[label], ...[item]] : [item];

            })).then(() => {
                let keys = Object.keys(arr)
                let val = []
                for (let i = 0; i < keys.length; i++) {
                    let z = arr[keys[i]].sort((a, b) => (a.school_name) > (b.school_name) ? 1 : -1)
                    let splitVal = keys[i].split('/')
                    var x = {
                        // date: splitVal[0],
                        grade: splitVal[0],
                        subject: splitVal[1],
                        // [`${viewBy}`]: splitVal[3],
                    }
                    z.map(val1 => {
                        let y = {
                            [`${val1.school_name}`]: { percentage: val1.no_of_books_distributed, mark: val1.marks }
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
                    logger.info('--- PAT LO table schoolWise response sent ---');
                    res.status(200).send({ schoolDetails, tableData, data1 });
                } else {
                    logger.info('--- PAT LO table schoolWise response sent ---');
                    res.status(500).send({ errMsg: "No record found" });
                }

            })
        }


    } catch (e) {
        logger.error(`Error :: ${e}`)
        res.status(500).json({ errMessage: "Internal error. Please try again!!" });
    }
});

router.post('/AllSchoolWise', auth.authController, async (req, res) => {
    try {
        logger.info('---Common table blockWise api ---');

        let { year, grade, month, dataSource, subject_name, exam_date, viewBy, districtId, management, category, reportType } = req.body
        let fileName;
        if (reportType == "loTable") {
            if (category == 'overall') {
                fileName = `${dataSource}/overall/school.json`;
            }
        } else {
            if (category == 'overall') {
                fileName = `${dataSource}/overall/cluster.json`;
            }
        }

        let data = await s3File.readFileConfig(fileName);
        data = data['data']

        if (districtId) {
            data = data.filter(val => {
                return val.district_id == districtId
            })
        }

        let blockDetails = data.map(e => {
            return {
                district_id: e.district_id,
                district_name: e.district_name,
                block_id: e.block_id,
                block_name: e.block_name
            }
        })

        blockDetails = blockDetails.reduce((unique, o) => {
            if (!unique.some(obj => obj.block_id === o.block_id)) {
                unique.push(o);
            }
            return unique;
        }, []);

        let arr = {}
        

        res.status(200).send({ data });


    } catch (e) {
        logger.error(`Error :: ${e}`)
        res.status(500).json({ errMessage: "Internal error. Please try again!!" });
    }
});

module.exports = router;