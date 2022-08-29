const router = require('express').Router();
const { logger } = require('../../lib/logger');
var const_data = require('../../lib/config');
const auth = require('../../middleware/check-auth');
const s3File = require('../../lib/reads3File');

router.post('/clusterWise', auth.authController, async (req, res) => {
    try {
        logger.info('---Common table clusterWise api ---');

        let { year, month, grade, dataSource, subject_name, exam_date, week, period, viewBy, blockId, management, category, reportType } = req.body;

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
                        fileName = `${dataSource}/overall/cluster_subject.json`;
                    } else {
                        fileName = `${dataSource}/overall/cluster_grade.json`;
                    }

                } else if (period == "last 30 days") {
                    if (isSubjAvailable) {
                        fileName = `${dataSource}/last_30_day/cluster_subject.json`;
                    } else {
                        fileName = `${dataSource}/last_30_day/cluster_grade.json`;
                    }
                } else if (period == "last 7 days") {
                    if (isSubjAvailable) {
                        fileName = `${dataSource}/last_7_day/cluster_subject.json`;
                    } else {
                        fileName = `${dataSource}/last_7_day/cluster_grade.json`;
                    }
                } else if (period == "last day") {
                    if (isSubjAvailable) {
                        fileName = `${dataSource}/last_day/cluster_subject.json`;
                    } else {
                        fileName = `${dataSource}/last_day/cluster_grade.json`;
                    }

                } else if (period == "year and month") {

                    if (month && !week && !exam_date && !grade && !subject_name) {
                        if (isSubjAvailable) {
                            fileName = `${dataSource}/${year}/${month}/cluster_subject.json`
                        } else {
                            fileName = `${dataSource}/${year}/${month}/cluster_grade.json`
                        }

                    } else if (month && !week && !exam_date && grade && !subject_name) {
                        if (isSubjAvailable) {
                            fileName = `${dataSource}/${year}/${month}/cluster_subject.json`
                        } else {
                            fileName = `${dataSource}/${year}/${month}/cluster_grade.json`
                        }
                    } else if (month && !week && !exam_date && grade && subject_name) {
                        if (isSubjAvailable) {
                            fileName = `${dataSource}/${year}/${month}/cluster_subject.json`
                        } else {
                            fileName = `${dataSource}/${year}/${month}/cluster_grade.json`
                        }

                    } else if (month && week && !exam_date && !grade && !subject_name) {
                        if (isSubjAvailable) {
                            fileName = `${dataSource}/${year}/${month}/week_${week}/cluster_subject.json`
                        } else {
                            fileName = `${dataSource}/${year}/${month}/week_${week}/cluster_grade.json`
                        }

                    } else if ((month && !week && !exam_date && grade && subject_name)) {
                        if (isSubjAvailable) {
                            fileName = `${dataSource}/${year}/${month}/cluster_subject.json`
                        } else {
                            fileName = `${dataSource}/${year}/${month}/cluster_grade.json`
                        }

                    } else if (month && week && !exam_date && grade && !subject_name) {
                        if (isSubjAvailable) {
                            fileName = `${dataSource}/${year}/${month}/week_${week}/cluster_subject.json`
                        } else {
                            fileName = `${dataSource}/${year}/${month}/week_${week}/cluster_grade.json`
                        }

                    } else if (month && week && !exam_date && grade && subject_name) {
                        if (isSubjAvailable) {
                            fileName = `${dataSource}/${year}/${month}/week_${week}/cluster_subject.json`
                        } else {
                            fileName = `${dataSource}/${year}/${month}/week_${week}/cluster_grade.json`
                        }

                    } else if (month && week && exam_date && !grade && !subject_name) {
                        if (isSubjAvailable) {
                            fileName = `${dataSource}/${year}/${month}/week_${week}/${exam_date}/cluster_subject.json`
                        } else {
                            fileName = `${dataSource}/${year}/${month}/week_${week}/${exam_date}/cluster_grade.json`
                        }

                    } else if (month && week && !exam_date && grade && !subject_name) {
                        if (isSubjAvailable) {
                            fileName = `${dataSource}/${year}/${month}/week_${week}/cluster_subject.json`
                        } else {
                            fileName = `${dataSource}/${year}/${month}/week_${week}/cluster_grade.json`
                        }

                    } else if (month && week && exam_date && grade && !subject_name) {
                        if (isSubjAvailable) {
                            fileName = `${dataSource}/${year}/${month}/week_${week}/${exam_date}/cluster_subject.json`
                        } else {
                            fileName = `${dataSource}/${year}/${month}/week_${week}/${exam_date}/cluster_grade.json`
                        }

                    } else if (month && week && exam_date && grade && subject_name) {
                        if (isSubjAvailable) {
                            fileName = `${dataSource}/${year}/${month}/week_${week}/${exam_date}/cluster_subject.json`
                        } else {
                            fileName = `${dataSource}/${year}/${month}/week_${week}/${exam_date}/cluster_grade.json`
                        }

                    }
                }
            }

        } else if (reportType == "Map") {

            if (period === "overall") {

                if (grade && !subject_name) {

                    fileName = `${dataSource}/overall/cluster/${grade}.json`;
                } else if (grade && subject_name) {
                    if (isSubjAvailable) {
                        fileName = `${dataSource}/overall/cluster_subject.json`;
                    } else {
                        fileName = `${dataSource}/overall/cluster_grade.json`;
                    }

                } else if (!grade && !subject_name) {

                    fileName = `${dataSource}/overall/cluster.json`;
                }
            } else if (period === "last 30 days") {

                if (grade && !subject_name) {
                    fileName = `${dataSource}/last_30_day/cluster/${grade}.json`;
                } else if (grade && subject_name) {
                    if (isSubjAvailable) {
                        fileName = `${dataSource}/last_30_day/cluster_subject.json`;
                    } else {
                        fileName = `${dataSource}/last_30_day/cluster_grade.json`;
                    }

                } else {
                    fileName = `${dataSource}/last_30_day/cluster.json`;
                }
            } else if (period === "last 7 days") {

                if (grade && !subject_name) {
                    fileName = `${dataSource}/last_7_day/cluster/${grade}.json`;
                } else if (grade && subject_name) {
                    if (isSubjAvailable) {
                        fileName = `${dataSource}/last_7_day/cluster_subject.json`;
                    } else {
                        fileName = `${dataSource}/last_7_day/cluster_grade.json`;
                    }

                } else {
                    fileName = `${dataSource}/last_7_day/cluster.json`;
                }
            } else if (period === "last day") {

                if (grade && !subject_name) {
                    fileName = `${dataSource}/last_day/cluster/${grade}.json`;
                } else if (grade && subject_name) {
                    if (isSubjAvailable) {
                        fileName = `${dataSource}/last_day/cluster_subject.json`;
                    } else {
                        fileName = `${dataSource}/last_day/cluster_grade.json`;
                    }

                } else {
                    fileName = `${dataSource}/last_day/cluster.json`;
                }
            } else if (period === "year and month") {

                if (month && !week && !exam_date && !grade && !subject_name) {
                    fileName = `${dataSource}/${year}/${month}/cluster.json`
                } else if (month && !week && !exam_date && grade && !subject_name) {

                    fileName = `${dataSource}/${year}/${month}/cluster/${grade}.json`
                } else if (month && !week && !exam_date && grade && subject_name) {
                    if (isSubjAvailable) {
                        fileName = `${dataSource}/${year}/${month}/cluster_subject.json`
                    } else {
                        fileName = `${dataSource}/${year}/${month}/cluster_grade.json`
                    }

                } else if ((month && week && !exam_date && !grade && !subject_name)) {
                    fileName = `${dataSource}/${year}/${month}/week_${week}/cluster.json`
                } else if ((month && week && exam_date && !grade && !subject_name)) {

                    fileName = `${dataSource}/${year}/${month}/week_${week}/${exam_date}/cluster.json`
                } else if ((month && week && !exam_date && grade && !subject_name)) {
                    if (isSubjAvailable) {
                        fileName = `${dataSource}/${year}/${month}/week_${week}/cluster_subject.json`
                    } else {
                        fileName = `${dataSource}/${year}/${month}/week_${week}/cluster_grade.json`
                    }

                } else if ((month && week && !exam_date && grade && subject_name)) {

                    fileName = `${dataSource}/${year}/${month}/week_${week}/cluster_subject.json`
                } else if ((month && week && exam_date && grade && !subject_name)) {
                    fileName = `${dataSource}/${year}/${month}/week_${week}/${exam_date}/cluster/${grade}.json`
                } else if ((month && week && exam_date && grade && subject_name)) {
                    if (isSubjAvailable) {
                        fileName = `${dataSource}/${year}/${month}/week_${week}/${exam_date}/cluster_subject.json`
                    } else {
                        fileName = `${dataSource}/${year}/${month}/week_${week}/${exam_date}/cluster_grade.json`
                    }

                } else {

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
        if (blockId) {
            footer = data['footer']
            footer = footer[blockId.toString()]
        } else {
            footer = data['allDistrictsFooter']
        }
        data = data['data']

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

        if (reportType == "Map") {
            data = data.map(({
                cluster_latitude: lat,
                cluster_longitude: long,

                ...rest
            }) => ({
                lat, long,
                ...rest
            }));
            res.status(200).send({ data, clusterDetails, footer })
        }
        if (reportType == "lotable") {
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
                    let z = arr[keys[i]].sort((a, b) => (a.cluster_name) > (b.cluster_name) ? 1 : -1)
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
                            [`${val1.cluster_name}`]: { percentage: val1[`${sourceName.trim()}`] }
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
        }

    } catch (e) {
        logger.error(`Error :: ${e}`)
        res.status(500).json({ errMessage: "Internal error. Please try again!!" });
    }
});

router.post('/AllClusterWise', auth.authController, async (req, res) => {
    try {
        logger.info('---Common table All cluster api ---');

        let { year, grade, month, dataSource, subject_name, exam_date, viewBy, districtId, management, category } = req.body
        let fileName;

        if (category == 'overall') {
            fileName = `${dataSource}/overall/cluster.json`;
        }

        let data = await s3File.readFileConfig(fileName);
        footer = data['allClustersFooter']
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
            cluster_latitude: lat,
            cluster_longitude: long,

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