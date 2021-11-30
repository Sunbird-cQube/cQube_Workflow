const router = require('express').Router();
const { logger } = require('../../../lib/logger');
const auth = require('../../../middleware/check-auth');
const s3File = require('../../../lib/reads3File');

router.post('/schoolWise', auth.authController, async (req, res) => {
    try {
        logger.info('---Trends school wise api ---');
        var year = req.body.year;
        var clusterId = req.body.clusterId;
        var management = req.body.management;
        var category = req.body.category;
        var grade = req.body.grade;

        let fileName;
        if (management != 'overall' && category == 'overall') {
            fileName = `sat/trend_line_chart/school_management_category/overall_category/overall/${management}/school/${clusterId}_${year}.json`;
        } else {
            fileName = `sat/trend_line_chart/school/${clusterId}_${year}.json`;
        }
        let schoolData = await s3File.readFileConfig(fileName);
        var keys = Object.keys(schoolData);
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
                schoolData[key].performance.map(data => {
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
                let data1 = schoolData[key].Grades && schoolData[key].Grades['1'] && schoolData[key].Grades['1'][grade] ? schoolData[key].Grades['1'][grade] : sem1;
                let data2 = schoolData[key].Grades && schoolData[key].Grades['2'] && schoolData[key].Grades['2'][grade] ? schoolData[key].Grades['2'][grade] : sem2;
                let schoolPerformance = [data1, data2];
                schoolPerformance.map(data => {
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
                schoolId: key,
                schoolName: schoolData[key].school_name[0],
                performance: stdPerformance
            }
            mydata.push(obj2);
        });
        logger.info('--- Trends school wise api response sent ---');
        res.status(200).send({ data: mydata });
    } catch (e) {
        logger.error(`Error :: ${e}`)
        res.status(500).json({ errMessage: "Internal error. Please try again!!" });
    }
});

module.exports = router;