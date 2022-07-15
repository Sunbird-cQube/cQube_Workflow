const router = require('express').Router();
const { logger } = require('../../lib/logger');
const auth = require('../../middleware/check-auth');
const s3File = require('../../lib/reads3File');


router.post('/blockWise', auth.authController, async (req, res) => {
    try {
        logger.info('---Common table blockWise api ---');

        let { year, grade, month, dataSource, reportType, subject_name, exam_date, week, period, districtId, management, category } = req.body
        console.log('body', req.body)
        let fileName;
        if (reportType == "loTable") {
            if (category == 'overall') {
                fileName = `${dataSource}/overall/block_subject_footer.json`;
            }
        } else {
            if (category == 'overall') {
                if (period === "overall") {
                    if (grade && !subject_name) {
                        console.log('grade')
                        fileName = `${dataSource}/overall/block/${grade}.json`;
                    } else if (grade && subject_name) {
                        console.log('grade and subject')
                        fileName = `${dataSource}/overall/block_subject_footer.json`;
                    } else if (!grade && !subject_name) {
                        console.log('overall')
                        fileName = `${dataSource}/overall/block.json`;
                    }
                } else if (period === "Last 30 Days") {
                    if (grade && !subject_name) {
                        console.log('grade')
                        fileName = `${dataSource}/last_30_day/block/${grade}.json`;
                    } else if (grade && subject_name) {
                        console.log('grade and subject')
                        fileName = `${dataSource}/last_30_day/block_subject_footer.json`;
                    } else if (!grade && !subject_name) {
                        console.log('overall')
                        fileName = `${dataSource}/last_30_day/block.json`;
                    }
                } else if (period === "Last 7 Days") {
                    if (grade && !subject_name) {
                        console.log('grade')
                        fileName = `${dataSource}/last_7_day/block/${grade}.json`;
                    } else if (grade && subject_name) {
                        console.log('grade and subject')
                        fileName = `${dataSource}/last_7_day/block_subject_footer.json`;
                    } else if (!grade && !subject_name) {
                        console.log('overall')
                        fileName = `${dataSource}/last_7_day/block.json`;
                    }
                } else if (period === "Year and Month") {
                    if (month && !week && !exam_date && !grade && !subject_name) {
                        console.log('month+++++++++++')
                        fileName = `${dataSource}/${year}/${month}/block.json`
                    } else if (month && week && !exam_date && !grade && !subject_name) {
                        console.log('month && week')
                        fileName = `${dataSource}/${year}/${month}/week_${week}/block.json`
                    } else if (month && week && exam_date && !grade && !subject_name) {
                        console.log('month && week && day')
                        fileName = `${dataSource}/${year}/${month}/week_${week}/${exam_date}/block.json`
                    } else if (month && week && exam_date && grade && !subject_name) {
                        fileName = `${dataSource}/${year}/${month}/week_${week}/${exam_date}/block/${grade}.json`
                    } else if (month && week && exam_date && grade && subject_name) {
                        fileName = `${dataSource}/${year}/${month}/week_${week}/${exam_date}/block_subject_footer.json`
                    } else if (!month && !week && !exam_date && !grade && !subject_name) {
                        // if (grade) {

                        fileName = `${dataSource}/overall/block.json`;
                        // }
                    }
                } else if (period === "Last 30 Days") {

                }
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
      
        if (exam_date) {
            data = data.filter(val => {
                return val.distribution_date == exam_date
            })
        }
        console.log('subject', data)
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
            res.status(200).send({ data, blockDetails })
        }

        if (reportType === "loTable") {
            Promise.all(data.map(item => {
               
                let label =
                    "grade" + item.grade + "/" +
                    item.subject + "/" + item.no_of_books_distributed
                // label += viewBy == "indicator" ? item.indicator : item.question_id

                arr[label] = arr.hasOwnProperty(label) ? [...arr[label], ...[item]] : [item];

            })).then(() => {
                let keys = Object.keys(arr)
                console.log('arr', keys)
                let val = []
                for (let i = 0; i < keys.length; i++) {
                    let z = arr[keys[i]].sort((a, b) => (a.block_name) > (b.block_name) ? 1 : -1)
                    let splitVal = keys[i].split('/')
                    var x = {
                        // date: splitVal[0],
                        grade: splitVal[0],
                        subject: splitVal[1],
                        // [`${ viewBy } `]: splitVal[2],
                    }
                    z.map(val1 => {
                        let y = {
                            [`${val1.block_name}`]: { percentage: val1.no_of_books_distributed, mark: val1.marks }
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
        console.log('fileName', fileName)
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
        // console.log('Grae', `Grade ${grade}`)
        // if (grade) {

        //     data = data.filter(val => {
        //         return val.grade == `Grade ${grade}`
        //     })
        // }
        // console.log('data', data)
        // if (subject_name) {
        //     data = data.filter(val => {
        //         return val.subject == subject_name
        //     })
        // }
        // if (exam_date) {
        //     data = data.filter(val => {
        //         return val.exam_date == day
        //     })
        // }

        res.status(200).send({ data });


    } catch (e) {
        logger.error(`Error :: ${e}`)
        res.status(500).json({ errMessage: "Internal error. Please try again!!" });
    }
});

module.exports = router;