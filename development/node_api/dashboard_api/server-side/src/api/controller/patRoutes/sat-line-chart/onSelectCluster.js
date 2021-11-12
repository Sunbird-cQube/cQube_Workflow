const router = require('express').Router();
const { logger } = require('../../../lib/logger');
const auth = require('../../../middleware/check-auth');
const s3File = require('../../../lib/reads3File');

router.post('/clusterWise', auth.authController, async (req, res) => {
    try {
        logger.info('---Trends cluster wise api ---');
        var year = req.body.year;
        var blockId = req.body.blockId;
        var management = req.body.management;
        var category = req.body.category;
        var grade = req.body.grade;

        let fileName;
        if (management != 'overall' && category == 'overall') {
            fileName = `sat/trend_line_chart/school_management_category/overall_category/overall/${management}/cluster/${blockId}_${year}.json`;
        } else {
            fileName = `sat/trend_line_chart/cluster/${blockId}_${year}.json`;
        }
        let clusterData = await s3File.readFileConfig(fileName);
        var keys = Object.keys(clusterData);
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
                clusterData[key].performance.map(data => {
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
                let data1 = clusterData[key].Grades && clusterData[key].Grades['1'] && clusterData[key].Grades['1'][grade] ? clusterData[key].Grades['1'][grade] : sem1;
                let data2 = clusterData[key].Grades && clusterData[key].Grades['2'] && clusterData[key].Grades['2'][grade] ? clusterData[key].Grades['2'][grade] : sem2;
                let clusterPerformance = [data1, data2];
                clusterPerformance.map(data => {
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
                clusterId: key,
                clusterName: clusterData[key].cluster_name[0],
                performance: stdPerformance
            }
            mydata.push(obj2);
        });
        logger.info('--- Trends cluster wise api response sent ---');
        res.status(200).send({ data: mydata });
    } catch (e) {
        logger.error(`Error :: ${e}`)
        res.status(500).json({ errMessage: "Internal error. Please try again!!" });
    }
});

module.exports = router;