const router = require('express').Router();
const { logger } = require('../../lib/logger');
const auth = require('../../middleware/check-auth');
const s3File = require('../../lib/reads3File');

router.post('/distWise', auth.authController, async (req, res) => {
    try {
        logger.info('---common table distWise api ---');

        let { year, grade, datasource, month, week, day, subject_name, exam_date, viewBy, management, category } = req.body
        let fileName;
        // if (management != 'overall' && category == 'overall') {
        //     if (viewBy == 'indicator') {
        //         fileName = `pat/school_management_category/heatChart/indicatorIdLevel/${year}/${month}/overall_category/${management}/allData.json`;
        //     } else if (viewBy == 'question_id')
        //         fileName = `pat/school_management_category/heatChart/questionIdLevel/${year}/${month}/overall_category/${management}/allData.json`;
        // } else {
        //     if (viewBy == 'indicator') {
        //         fileName = `pat/heatChart/indicatorIdLevel/${year}/${month}/allData.json`;
        //     } else if (viewBy == 'question_id')
        //         fileName = `pat/heatChart/questionIdLevel/${year}/${month}/allData.json`;
        // }

          filename = `${datasoure}/${management}/${year}/${month}/allData.json`  

        //  let data1
          let data = data1 = await s3File.readFileConfig(fileName);
      


        let districtDetails = data.map(e => {
            return {
                district_id: e.district_id,
                district_name: e.district_name
            }
        })

        districtDetails = districtDetails.reduce((unique, o) => {
            if (!unique.some(obj => obj.district_id === o.district_id)) {
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
        if (week){
            data = data.filter(val => {
                 return val.week == week
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
                let z = arr[keys[i]].sort((a, b) => (a.district_name) > (b.district_name) ? 1 : -1)
                let splitVal = keys[i].split('/')
                var x = {
                    date: splitVal[0],
                    grade: splitVal[1],
                    subject: splitVal[2],
                    [`${viewBy}`]: splitVal[3],
                }
                z.map(val1 => {
                    let y = {
                        [`${val1.district_name}`]: { percentage: val1.percentage, mark: val1.marks },
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
                logger.info('--- PAT LO table distWise response sent ---');
                res.status(200).send({ districtDetails, tableData });
            } else {
                logger.info('--- PAT LO table schoolWise response sent ---');
                res.status(500).send({ errMsg: "No record found" });
            }
        })
    } catch (e) {
        logger.error(`Error :: ${e}`)
        res.status(500).json({ errMessage: "Internal error. Please try again!!" });
    }
});

module.exports = router;