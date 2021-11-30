const router = require('express').Router();
const { logger } = require('../../../lib/logger');
const auth = require('../../../middleware/check-auth');
const s3File = require('../../../lib/reads3File');

router.post('/blockWise', auth.authController, async (req, res) => {
    try {
        logger.info('---Trends block wise api ---');
        var year = req.body.year;
        var districtId = req.body.districtId;
        var management = req.body.management;
        var category = req.body.category;
        var grade = req.body.grade;

        let fileName;
        if (management != 'overall' && category == 'overall') {
            fileName = `sat/trend_line_chart/school_management_category/overall_category/overall/${management}/block/${districtId}_${year}.json`;
        } else {
            fileName = `sat/trend_line_chart/block/${districtId}_${year}.json`;
        }
        let blockData = await s3File.readFileConfig(fileName);;
        var keys = Object.keys(blockData);
        var mydata = [];

        keys.map(key => {
            var stdPerformance = [{
                semesterId: 1,
                year: year,
                studentCount: undefined,
                studentAttended: undefined,
                schoolCount: undefined,
                performance: ""
            }, {
                semesterId: 2,
                year: year,
                studentCount: undefined,
                studentAttended: undefined,
                schoolCount: undefined,
                performance: ""
            }]

            if (grade == "") {
                blockData[key].performance.map(data => {
                    stdPerformance.map(item => {
                        if (item.semesterId == data.semester) {
                            item.performance = data.district_performance;
                            item.studentCount = data.total_students;
                            item.studentAttended = data.students_attended
                            item.schoolCount = data.total_schools;
                        }
                    })
                });
            } else {
                let sem1 = {
                    semester: 1,
                    percentage: "",
                    total_schools: undefined,
                    total_students: undefined,
                    students_attended: undefined
                }
                let sem2 = {
                    semester: 2,
                    percentage: "",
                    total_schools: undefined,
                    total_students: undefined,
                    students_attended: undefined
                }
                let data1 = blockData[key].Grades && blockData[key].Grades['1'] && blockData[key].Grades['1'][grade] ? blockData[key].Grades['1'][grade] : sem1;
                let data2 = blockData[key].Grades && blockData[key].Grades['2'] && blockData[key].Grades['2'][grade] ? blockData[key].Grades['2'][grade] : sem2;
                let blockPerformance = [data1, data2];
                blockPerformance.map(data => {
                    stdPerformance.map(item => {
                        if (item.semesterId == data.semester) {
                            item.performance = data.percentage;
                            item.studentCount = data.total_students;
                            item.studentAttended = data.students_attended
                            item.schoolCount = data.total_schools;
                        }
                    })
                });
            }

            let obj2 = {
                blockId: key,
                blockName: blockData[key].block_name[0],
                performance: stdPerformance
            }
            mydata.push(obj2);
        });
        logger.info('--- Trends block wise api response sent ---');
        res.status(200).send({ data: mydata });
    } catch (e) {
        logger.error(`Error :: ${e}`)
        res.status(500).json({ errMessage: "Internal error. Please try again!!" });
    }
});

module.exports = router;