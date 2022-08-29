const router = require('express').Router();
const { logger } = require('../../lib/logger');
const auth = require('../../middleware/check-auth');
const s3File = require('../../lib/reads3File');


router.post('/schoolWise', auth.authController, async (req, res) => {
    try {
        logger.info('---Common table schoolWise api ---');
        let schoolLevel = req.body.schoolLevel
        let { year, month, dataSource, grade, subject_name, exam_date, week, period, blockId, clusterId, management, category, reportType } = req.body

        let metaFile = `${dataSource}/meta.json`
        let metaData = await s3File.readFileConfig(metaFile);
        metaData = metaData[0].data.grades[0]
        let isSubjAvailable = metaData.hasOwnProperty('subjects')
        logger.info(`---subject ${isSubjAvailable}  ---`);

        let fileName;

        if (reportType == "lotable") {
            if (category == 'overall') {
                if (period == "overall") {
                    
                    if (isSubjAvailable) {
                        fileName = `${dataSource}/overall/school_subject.json`;
                    } else {
                        fileName = `${dataSource}/overall/school_grade.json`;
                    }
                } else if (period == "year and month") {

                    if (month && !week && !exam_date && !grade && !subject_name) {
                        if (isSubjAvailable) {
                            fileName = `${dataSource}/${year}/${month}/school_subject.json`
                        } else {
                            fileName = `${dataSource}/${year}/${month}/school_grade.json`
                        }

                    } else if (month && !week && !exam_date && grade && !subject_name) {
                        if (isSubjAvailable) {
                            fileName = `${dataSource}/${year}/${month}/school_subject.json`
                        } else {
                            fileName = `${dataSource}/${year}/${month}/school_grade.json`
                        }

                    } else if (month && !week && !exam_date && grade && subject_name) {
                        if (isSubjAvailable) {
                            fileName = `${dataSource}/${year}/${month}/school_subject.json`
                        } else {
                            fileName = `${dataSource}/${year}/${month}/school_grade.json`
                        }

                    } else if (month && week && !exam_date && !grade && !subject_name) {
                        if (isSubjAvailable) {
                            fileName = `${dataSource}/${year}/${month}/week_${week}/school_subject.json`
                        } else {
                            fileName = `${dataSource}/${year}/${month}/week_${week}/school_grade.json`
                        }

                    } else if (month && week && !exam_date && grade && !subject_name) {
                        if (isSubjAvailable) {
                            fileName = `${dataSource}/${year}/${month}/week_${week}/school_subject.json`
                        } else {
                            fileName = `${dataSource}/${year}/${month}/week_${week}/school_grade.json`
                        }

                    } else if (month && week && !exam_date && !grade && !subject_name) {
                        if (isSubjAvailable) {
                            fileName = `${dataSource}/${year}/${month}/week_${week}/school_subject.json`
                        } else {
                            fileName = `${dataSource}/${year}/${month}/week_${week}/school_grade.json`
                        }

                    } else if ((month && !week && !exam_date && grade && subject_name)) {
                        if (isSubjAvailable) {
                            fileName = `${dataSource}/${year}/${month}/school_subject.json`
                        } else {
                            fileName = `${dataSource}/${year}/${month}/school_grade.json`
                        }

                    } else if (month && week && exam_date && grade && subject_name) {
                        if (isSubjAvailable) {
                            fileName = `${dataSource}/${year}/${month}/week_${week}/${exam_date}/school_subject.json`
                        } else {
                            fileName = `${dataSource}/${year}/${month}/week_${week}/${exam_date}/school_grade.json`
                        }

                    } else if (month && week && exam_date && grade && !subject_name) {
                        if (isSubjAvailable) {
                            fileName = `${dataSource}/${year}/${month}/week_${week}/${exam_date}/school_subject.json`
                        } else {
                            fileName = `${dataSource}/${year}/${month}/week_${week}/${exam_date}/school_grade.json`
                        }

                    } else if (month && week && exam_date && grade && subject_name) {
                        if (isSubjAvailable) {
                            fileName = `${dataSource}/${year}/${month}/week_${week}/${exam_date}/school_subject.json`
                        } else {
                            fileName = `${dataSource}/${year}/${month}/week_${week}/${exam_date}/school_grade.json`
                        }

                    }
                } else if (period == "last 7 days") {
                    if (isSubjAvailable) {
                        fileName = `${dataSource}/last_7_day/school_subject.json`;
                    } else {
                        fileName = `${dataSource}/last_7_day/school_grade.json`;
                    }

                } else if (period == "last 30 days") {
                    fileName = `${dataSource}/last_30_day/school_subject.json`;
                } else if (period == "last day") {
                    fileName = `${dataSource}/last_day/school_grade.json`;
                }
            }
        } else {
            if (category == 'overall') {
                if (period === "overall") {
                    if (grade && !subject_name) {
                        fileName = `${dataSource}/overall/school/${grade}.json`;
                    } else if (grade && subject_name) {
                        if (isSubjAvailable) {
                            fileName = `${dataSource}/overall/school_subject.json`;
                        } else {
                            fileName = `${dataSource}/overall/school_grade.json`;
                        }

                    } else if (!grade && !subject_name) {
                        fileName = `${dataSource}/overall/school.json`;
                    }
                } else if (period === "last 30 days") {
                    if (grade && !subject_name) {
                        fileName = `${dataSource}/last_30_day/school/${grade}.json`;
                    } else if (grade && subject_name) {
                        if (isSubjAvailable) {
                            fileName = `${dataSource}/last_30_day/school_subject.json`;
                        } else {
                            fileName = `${dataSource}/last_30_day/school_grade.json`;
                        }

                    } else if (!grade && !subject_name) {
                        fileName = `${dataSource}/last_30_day/school.json`;
                    }
                } else if (period === "last 7 days") {
                    if (grade && !subject_name) {
                        fileName = `${dataSource}/last_7_day/school/${grade}.json`;
                    } else if (grade && subject_name) {
                        if (isSubjAvailable) {
                            fileName = `${dataSource}/last_7_day/school_subject.json`;
                        } else {
                            fileName = `${dataSource}/last_7_day/school_grade.json`;
                        }

                    } else if (!grade && !subject_name) {
                        fileName = `${dataSource}/last_7_day/school.json`;
                    }
                } else if (period === "last day") {
                    if (grade && !subject_name) {
                        fileName = `${dataSource}/last_day/school/${grade}.json`;
                    } else if (grade && subject_name) {
                        if (isSubjAvailable) {
                            fileName = `${dataSource}/last_day/school_subject.json`;
                        } else {
                            fileName = `${dataSource}/last_day/school_grade.json`;
                        }

                    } else if (!grade && !subject_name) {
                        fileName = `${dataSource}/last_day/school.json`;
                    }
                } else if (period === "year and month") {
                    if (month && !week && !exam_date && !grade && !subject_name) {

                        fileName = `${dataSource}/${year}/${month}/school.json`
                    } else if (month && !week && !exam_date && grade && !subject_name) {

                        fileName = `${dataSource}/${year}/${month}/school/${grade}.json`
                    } else if (month && !week && !exam_date && grade && subject_name) {
                        if (isSubjAvailable) {
                            fileName = `${dataSource}/${year}/${month}/school_subject.json`
                        } else {
                            fileName = `${dataSource}/${year}/${month}/school_grade.json`
                        }

                    } else if ((month && week && !exam_date && !grade && !subject_name)) {

                        fileName = `${dataSource}/${year}/${month}/week_${week}/school.json`
                    } else if ((month && week && exam_date && !grade && !subject_name)) {

                        fileName = `${dataSource}/${year}/${month}/week_${week}/${exam_date}/school.json`
                    } else if ((month && week && !exam_date && grade && !subject_name)) {
                        if (isSubjAvailable) {
                            fileName = `${dataSource}/${year}/${month}/week_${week}/school_subject.json`
                        } else {
                            fileName = `${dataSource}/${year}/${month}/week_${week}/school_grade.json`
                        }

                    } else if ((month && week && !exam_date && grade && subject_name)) {
                        if (isSubjAvailable) {
                            fileName = `${dataSource}/${year}/${month}/week_${week}/school_subject.json`
                        } else {
                            fileName = `${dataSource}/${year}/${month}/week_${week}/school_grade.json`
                        }

                    } else if ((month && week && exam_date && grade && !subject_name)) {
                        fileName = `${dataSource}/${year}/${month}/week_${week}/${exam_date}/school/${grade}.json`
                    } else if ((month && week && exam_date && grade && subject_name)) {
                        if (isSubjAvailable) {
                            fileName = `${dataSource}/${year}/${month}/week_${week}/${exam_date}/school_subject.json`
                        } else {
                            fileName = `${dataSource}/${year}/${month}/week_${week}/${exam_date}/school_grade.json`
                        }

                    }
                }

            }
        }

        let sourceName = ""
        let filename1 = `${dataSource}/meta_tooltip.json`
        let metricValue = await s3File.readFileConfig(filename1);
        metricValue.forEach(metric => sourceName = metric.result_column)
        let date = ""
        metricValue.forEach(metric => date = metric.date)

        let data = await s3File.readFileConfig(fileName);

        if (clusterId) {
            footer = data['footer']
            footer = footer[clusterId.toString()]
        } else {
            footer = data['allDistrictsFooter']
        }

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
                return val[`${date.trim()}`] == exam_date
            })
        }

        if (reportType == "Map") {
            data = data.map(({
                school_latitude: lat,
                school_longitude: long,

                ...rest
            }) => ({
                lat, long,
                ...rest
            }));
            res.status(200).send({ data, schoolDetails, footer })
        }

        if (reportType == "lotable") {
            Promise.all(data.map(item => {

                if (week && !exam_date) {

                    label =
                        item.grade + "/" +
                        item.subject + "/" + item.week.split("_")[1] + item
                    arr[label] = arr.hasOwnProperty(label) ? [...arr[label], ...[item]] : [item];
                } else if (week && exam_date) {

                    label = item.distribution_date + "/" + item.grade + "/" + item.subject + "/" + item.week.split("_")[1]
                    arr[label] = arr.hasOwnProperty(label) ? [...arr[label], ...[item]] : [item];
                } else {
                    label =
                        item.grade + "/" +
                        item.subject + "/" + item.week
                    arr[label] = arr.hasOwnProperty(label) ? [...arr[label], ...[item]] : [item];
                }

            })).then(() => {
                let keys = Object.keys(arr)
                let val = []
                for (let i = 0; i < keys.length; i++) {
                    let z = arr[keys[i]].sort((a, b) => (a.school_name) > (b.school_name) ? 1 : -1)
                    let splitVal = keys[i].split('/')
                    var x = {

                        grade: splitVal[0],
                        subject: splitVal[1],

                    }
                    z.map(val1 => {
                        let y = {
                            [`${val1.school_name}`]: { percentage: val1[`${sourceName.trim()}`] }
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
                    res.status(200).send({ schoolDetails, tableData });
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

        if (category == 'overall') {
            fileName = `${dataSource}/overall/school.json`;
        }


        let data = await s3File.readFileConfig(fileName);
        let footer = data['allDistrictsFooter']
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
        data = data.map(({
            school_latitude: lat,
            school_longitude: long,

            ...rest
        }) => ({
            lat, long,
            ...rest
        }));


        res.status(200).send({ data, footer });


    } catch (e) {
        logger.error(`Error :: ${e}`)
        res.status(500).json({ errMessage: "Internal error. Please try again!!" });
    }
});

module.exports = router;