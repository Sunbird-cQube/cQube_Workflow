const router = require('express').Router();
const { logger } = require('../../lib/logger');
const auth = require('../../middleware/check-auth');
const s3File = require('../../lib/reads3File');


router.post('/blockWise', auth.authController, async (req, res) => {
    try {
        logger.info('---Common table blockWise api ---');

        let { year, grade, month, dataSource, reportType, subject_name, exam_date, week, period, districtId, management, category } = req.body


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
                        fileName = `${dataSource}/overall/block_subject.json`;
                    } else {
                        fileName = `${dataSource}/overall/block_grade.json`;
                    }

                } else if (period == "last 30 days") {
                    if (isSubjAvailable) {
                        fileName = `${dataSource}/last_30_day/block_subject.json`;
                    } else {
                        fileName = `${dataSource}/last_30_day/block_grade.json`;
                    }
                } else if (period == "last 7 days") {
                    if (isSubjAvailable) {
                        fileName = `${dataSource}/last_7_day/block_subject.json`;
                    } else {
                        fileName = `${dataSource}/last_7_day/block_grade.json`;
                    }
                } else if (period == "last day") {
                    if (isSubjAvailable) {
                        fileName = `${dataSource}/last_day/block_subject.json`;
                    } else {
                        fileName = `${dataSource}/last_day/block_grade.json`;
                    }

                } else if (period == "year and month") {

                    if (month && !week && !exam_date && !grade && !subject_name) {
                        if (isSubjAvailable) {
                            fileName = `${dataSource}/${year}/${month}/block_subject.json`
                        } else {
                            fileName = `${dataSource}/${year}/${month}/block_grade.json`
                        }

                    } else if (month && !week && !exam_date && grade && !subject_name) {
                        if (isSubjAvailable) {
                            fileName = `${dataSource}/${year}/${month}/block_subject.json`
                        } else {
                            fileName = `${dataSource}/${year}/${month}/block_grade.json`
                        }

                    } else if (month && !week && !exam_date && grade && subject_name) {
                        if (isSubjAvailable) {
                            fileName = `${dataSource}/${year}/${month}/block_subject.json`
                        } else {
                            fileName = `${dataSource}/${year}/${month}/block_grade.json`
                        }
                    } else if (month && week && !exam_date && !grade && !subject_name) {
                        if (isSubjAvailable) {
                            fileName = `${dataSource}/${year}/${month}/week_${week}/block_subject.json`
                        } else {
                            fileName = `${dataSource}/${year}/${month}/week_${week}/block_grade.json`
                        }

                    } else if (month && week && !exam_date && grade && !subject_name) {
                        if (isSubjAvailable) {
                            fileName = `${dataSource}/${year}/${month}/week_${week}/block_subject.json`
                        } else {
                            fileName = `${dataSource}/${year}/${month}/week_${week}/block_grade.json`
                        }
                    } else if ((month && !week && !exam_date && grade && subject_name)) {
                        if (isSubjAvailable) {
                            fileName = `${dataSource}/${year}/${month}/block_subject.json`
                        } else {
                            fileName = `${dataSource}/${year}/${month}/block_grade.json`
                        }

                    } else if (month && week && !exam_date && grade && subject_name) {
                        if (isSubjAvailable) {
                            fileName = `${dataSource}/${year}/${month}/week_${week}/block_subject.json`
                        } else {
                            fileName = `${dataSource}/${year}/${month}/week_${week}/block_grade.json`
                        }

                    } else if (month && week && exam_date && !grade && !subject_name) {
                        if (isSubjAvailable) {
                            fileName = `${dataSource}/${year}/${month}/week_${week}/${exam_date}/block_subject.json`
                        } else {
                            fileName = `${dataSource}/${year}/${month}/week_${week}/${exam_date}/block_grade.json`
                        }

                    } else if (month && week && exam_date && grade && !subject_name) {
                        if (isSubjAvailable) {
                            fileName = `${dataSource}/${year}/${month}/week_${week}/${exam_date}/block_subject.json`
                        } else {
                            fileName = `${dataSource}/${year}/${month}/week_${week}/${exam_date}/block_grade.json`
                        }

                    } else if (month && week && exam_date && grade && subject_name) {
                        if (isSubjAvailable) {
                            fileName = `${dataSource}/${year}/${month}/week_${week}/${exam_date}/block_subject.json`
                        } else {
                            fileName = `${dataSource}/${year}/${month}/week_${week}/${exam_date}/block_grade.json`
                        }

                    }
                }
            }
        } else if (reportType == "Map") {
            if (category == 'overall') {
                if (period === "overall") {
                    if (grade && !subject_name) {

                        fileName = `${dataSource}/overall/block/${grade}.json`;
                    } else if (grade && subject_name) {
                        if (isSubjAvailable) {
                            fileName = `${dataSource}/overall/block_subject.json`;
                        } else {
                            fileName = `${dataSource}/overall/block_grade.json`;
                        }

                    } else if (!grade && !subject_name) {
                        fileName = `${dataSource}/overall/block.json`;
                    }
                } else if (period === "last 30 days") {
                    if (grade && !subject_name) {

                        fileName = `${dataSource}/last_30_day/block/${grade}.json`;
                    } else if (grade && subject_name) {
                        if (isSubjAvailable) {
                            fileName = `${dataSource}/last_30_day/block_subject.json`;
                        } else {
                            fileName = `${dataSource}/last_30_day/block_grade.json`;
                        }

                    } else if (!grade && !subject_name) {

                        fileName = `${dataSource}/last_30_day/block.json`;
                    }
                } else if (period === "last 7 days") {
                    if (grade && !subject_name) {

                        fileName = `${dataSource}/last_7_day/block/${grade}.json`;
                    } else if (grade && subject_name) {
                        if (isSubjAvailable) {
                            fileName = `${dataSource}/last_7_day/block_subject.json`;
                        } else {
                            fileName = `${dataSource}/last_7_day/block_grade.json`;
                        }

                    } else if (!grade && !subject_name) {

                        fileName = `${dataSource}/last_7_day/block.json`;
                    }
                } else if (period === "last day") {
                    if (grade && !subject_name) {

                        fileName = `${dataSource}/last_day/block/${grade}.json`;
                    } else if (grade && subject_name) {
                        if (isSubjAvailable) {
                            fileName = `${dataSource}/last_day/block_subject.json`;
                        } else {
                            fileName = `${dataSource}/last_day/block_grade.json`;
                        }

                    } else if (!grade && !subject_name) {

                        fileName = `${dataSource}/last_day/block.json`;
                    }
                } else if (period === "year and month") {
                    if (month && !week && !exam_date && !grade && !subject_name) {

                        fileName = `${dataSource}/${year}/${month}/block.json`
                    } else if (month && !week && !exam_date && grade && !subject_name) {

                        fileName = `${dataSource}/${year}/${month}/block/${grade}.json`
                    } else if (month && !week && !exam_date && grade && subject_name) {
                        if (isSubjAvailable) {
                            fileName = `${dataSource}/${year}/${month}/block_subject.json`
                        } else {
                            fileName = `${dataSource}/${year}/${month}/block_grade.json`
                        }

                    } else if (month && week && !exam_date && !grade && !subject_name) {

                        fileName = `${dataSource}/${year}/${month}/week_${week}/block.json`
                    } else if (month && week && exam_date && !grade && !subject_name) {

                        fileName = `${dataSource}/${year}/${month}/week_${week}/${exam_date}/block.json`
                    } else if (month && week && !exam_date && grade && !subject_name) {
                        if (isSubjAvailable) {
                            fileName = `${dataSource}/${year}/${month}/week_${week}/block_subject.json`
                        } else {
                            fileName = `${dataSource}/${year}/${month}/week_${week}/block_grade.json`
                        }

                    } else if (month && week && !exam_date && grade && subject_name) {
                        if (isSubjAvailable) {
                            fileName = `${dataSource}/${year}/${month}/week_${week}/block_subject.json`
                        } else {
                            fileName = `${dataSource}/${year}/${month}/week_${week}/block_grade.json`
                        }

                    } else if (month && week && exam_date && grade && !subject_name) {
                        fileName = `${dataSource}/${year}/${month}/week_${week}/${exam_date}/block/${grade}.json`
                    } else if (month && week && exam_date && grade && subject_name) {
                        if (isSubjAvailable) {
                            fileName = `${dataSource}/${year}/${month}/week_${week}/${exam_date}/block_subject.json`
                        } else {
                            fileName = `${dataSource}/${year}/${month}/week_${week}/${exam_date}/block_grade.json`
                        }

                    } else if (!month && !week && !exam_date && !grade && !subject_name) {
                        // if (grade) {

                        fileName = `${dataSource}/overall/block.json`;
                        // }
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
        let footer
        if (districtId) {
            footer = data['footer']
            footer = footer[districtId.toString()]
        } else {
            footer = data['allDistrictsFooter']
        }

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

        if (exam_date) {
            data = data.filter(val => {
                return val[`${date.trim()}`] == exam_date
            })
        }

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

        if (reportType === "Map") {
            data = data.map(({
                block_latitude: lat,
                block_longitude: long,

                ...rest
            }) => ({
                lat, long,
                ...rest
            }));
            res.status(200).send({ data, blockDetails, footer })
        }

        if (reportType === "lotable") {
            Promise.all(data.map(item => {

                if (week && !exam_date) {
                    label =
                        item.grade + "/" +
                        item.subject + "/" + item.week.split("_")[1]
                    arr[label] = arr.hasOwnProperty(label) ? [...arr[label], ...[item]] : [item];
                } else if (week && exam_date) {
                    label = item.distribution_date + "/" + item.grade + "/" + item.subject + "/" + item.week.split("_")[1]
                    arr[label] = arr.hasOwnProperty(label) ? [...arr[label], ...[item]] : [item];
                } else {
                    label =
                        item.grade + "/" +
                        item.subject
                    arr[label] = arr.hasOwnProperty(label) ? [...arr[label], ...[item]] : [item];
                }
            })).then(() => {
                let keys = Object.keys(arr)

                let val = []
                for (let i = 0; i < keys.length; i++) {
                    let z = arr[keys[i]].sort((a, b) => (a.block_name) > (b.block_name) ? 1 : -1)
                    let splitVal = keys[i].split('/')

                    if (week && !exam_date) {
                        var x = {
                            grade: splitVal[0],
                            subject: splitVal[1],
                            week: splitVal[3],

                        }
                    } else if (week && exam_date) {
                        var x = {

                            grade: splitVal[1],
                            subject: splitVal[2],
                            week: splitVal[3],
                            date: splitVal[0]

                        }
                    } else {
                        var x = {
                            grade: splitVal[0],
                            subject: splitVal[1],
                        }
                    }
                    z.map(val1 => {

                        let y = {
                            [`${val1.block_name}`]: { percentage: val1[`${sourceName.trim()}`] }
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
                    logger.info('--- common blockWise response sent ---');
                    res.status(200).send({ blockDetails, tableData });
                } else {
                    logger.info('--- common table blockWise response no records ---');
                    res.status(500).send({ errMsg: "No record found" });
                }

            })
        }


    } catch (e) {
        logger.error(`Error :: ${e}`)
        res.status(500).json({ errMessage: "Internal error. Please try again!!" });
    }
});


router.post('/AllBlockWise', auth.authController, async (req, res) => {
    try {
        logger.info('---Common table blockWise api ---');

        let { year, grade, month, dataSource, subject_name, exam_date, viewBy, districtId, management, category } = req.body
        let fileName;

        if (category == 'overall') {
            fileName = `${dataSource}/overall/block.json`;
        }

        let data = await s3File.readFileConfig(fileName);
        footer = data['allDistrictsFooter']
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
            block_latitude: lat,
            block_longitude: long,

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