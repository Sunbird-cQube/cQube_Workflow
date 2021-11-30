const router = require('express').Router();
const { logger } = require('../../../lib/logger');
const auth = require('../../../middleware/check-auth');
const s3File = require('../../../lib/reads3File');

router.post('/stateWise', auth.authController, async (req, res) => {
    try {
        logger.info('---Trends state wise api ---');
        var year = req.body.year;
        var management = req.body.management;
        var category = req.body.category;
        var grade = req.body.grade;
        let fileName;
        if (management != 'overall' && category == 'overall') {
            fileName = `sat/trend_line_chart/school_management_category/overall_category/overall/${management}/state_${year}.json`;
        } else {
            fileName = `sat/trend_line_chart/state_${year}.json`;
        }
        let stateData = await s3File.readFileConfig(fileName);
        var mydata = [];
        if (stateData[year]) {
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
                stateData[year].performance.map(data => {
                    stdPerformance.map(item => {
                        if (item.semesterId == data.semester) {
                            item.performance = data.state_performance;
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

                let data1 = stateData[year].Grades && stateData[year].Grades['1'] && stateData[year].Grades['1'][grade] ? stateData[year].Grades['1'][grade] : sem1;
                let data2 = stateData[year].Grades && stateData[year].Grades['2'] && stateData[year].Grades['2'][grade] ? stateData[year].Grades['2'][grade] : sem2;
                let statePerformance = [data1, data2];
                statePerformance.map(data => {
                    if (data.percentage) {
                        stdPerformance.map(item => {
                            if (item.semesterId == data.semester) {
                                item.performance = data.percentage ? data.percentage : "";
                                item.studentCount = data.total_students ? data.total_students : "";
                                item.studentAttended = data.students_attended ? data.students_attended : "";
                                item.schoolCount = data.total_schools ? data.total_schools : "";
                            }
                        })
                    }
                });
            }
            if (stdPerformance[0].performance || stdPerformance[1].performance) {
                let obj2 = {
                    performance: stdPerformance
                }
                mydata.push(obj2);
                logger.info('--- Trends state wise api response sent ---');
                res.status(200).send({ data: mydata });
            } else {
                logger.info('--- Trends state wise api response sent ---');
                res.status(403).send({ errMsg: "Something went wrong" });
            }
        } else {
            res.status(403).send({ errMsg: "Something went wrong" });
        }
    } catch (e) {
        logger.error(`Error :: ${e}`)
        res.status(500).json({ errMessage: "Internal error. Please try again!!" });
    }
});

router.post('/distWise', auth.authController, async (req, res) => {
    try {
        logger.info('---Trends dist wise api ---');
        var year = req.body.year;
        var management = req.body.management;
        var category = req.body.category;
        var grade = req.body.grade;
        let fileName;
        if (management != 'overall' && category == 'overall') {
            fileName = `sat/trend_line_chart/school_management_category/overall_category/overall/${management}/district/district_${year}.json`;
        } else {
            fileName = `sat/trend_line_chart/district/district_${year}.json`;
        }
        let districtData = await s3File.readFileConfig(fileName);
        var keys = Object.keys(districtData);
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
                districtData[key].performance.map(data => {
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
                let data1 = districtData[key].Grades && districtData[key].Grades['1'] && districtData[key].Grades['1'][grade] ? districtData[key].Grades['1'][grade] : sem1;
                let data2 = districtData[key].Grades && districtData[key].Grades['2'] && districtData[key].Grades['2'][grade] ? districtData[key].Grades['2'][grade] : sem2;
                let distPerformance = [data1, data2];
                distPerformance.map(data => {
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
                districtId: key,
                districtName: districtData[key].district_name[0],
                performance: stdPerformance
            }
            mydata.push(obj2);
        });

        logger.info('--- Trends dist wise api response sent ---');
        res.status(200).send({ data: mydata });
    } catch (e) {
        logger.error(`Error :: ${e}`)
        res.status(500).json({ errMessage: "Internal error. Please try again!!" });
    }
});


router.get('/getDateRange', auth.authController, async (req, res) => {
    try {
        logger.info('---getDateRange api ---');
        var fileName = `sat/metaData.json`;
        let data = await s3File.readFileConfig(fileName);
        let years = [];
        data.map(a => {
            years.push(a.academic_year);
        })
        logger.info('--- getDateRange response sent ---');
        res.status(200).send({ years: years });
    } catch (e) {
        logger.error(`Error :: ${e}`)
        res.status(500).json({ errMessage: "Internal error. Please try again!!" });
    }
});

module.exports = router;