const router = require('express').Router();
const { logger } = require('../../lib/logger');
const auth = require('../../middleware/check-auth');
const axios = require('axios');
var schedule = require('node-schedule');
const fs = require('fs');
var shell = require('shelljs');
const db = require('../../lib/db')

var filePath = `${process.env.BASE_DIR}/cqube/admin_dashboard/schedulers.json`;
router.get('/commonSchedular', auth.authController, async (req, res) => {
    try {
        logger.info('--- common schedular api start ---')
        db.query('select distinct report_name,status,state from configurable_datasource_properties ;', (error, results) => {
            if (error) {
                logger.info('--- common schedular api failed ---')
                throw error
            }

            if (results['rowCount']) {
                logger.info('---common schedular api response sent ---')

                let data = results['rows']

                data = data.filter(program => program.status === true)

                res.send({ data: data })
            } else {
                res.send({ status: "401", err: "somthing went wrong" })
            }

        })

    } catch (e) {
        logger.error(`Error :: ${e}`);
        res.status(500).json({ errMsg: "Internal error. Please try again!!" });
    }
})

router.post('/scheduleProcessor', async function (req, res) {
    try {
        logger.info('---common scheduler api start---');
       
        let dataSource = req.body.data.reportName
        let stoppingHour = req.body.data.stopTime

        var schedularData = [];
        var schedulerTime;
        var stopTime;
        var timePeriod = "";


        let groupName = dataSource.data.report_name.toLowerCase();
        let state = dataSource.data.state
        let day = '*'
        if (req.body.data.time.day) {
            day = req.body.data.time.day;
        }
        let month = '*'
        if (req.body.data.time.month) {
            month = req.body.data.time.month;
        }
        let date = '*'
        if (req.body.data.time.date) {
            date = req.body.data.time.date;
        }
        let hours = parseInt(req.body.data.time.hours);
        var mins = 0;
        if (req.body.data.time.minutes) {
            mins = parseInt(req.body.data.time.minutes);
        }

        let timeToStop = stoppingHour

        timeToStop = hours + timeToStop
        if (timeToStop >= 24) {
            timeToStop = timeToStop % 24;
            timeToStop = timeToStop < 0 ? 24 + timeToStop : +timeToStop;
        }

        // //::::::::::::::::::::::::::::::::::::::
        if (day != "*") {
            timePeriod = "weekly";
            schedulerTime = `${mins} ${hours} * * ${day}`;
            stopTime = `${mins} ${timeToStop} * * ${day}`;
        } else if (date != "*" && month == "*") {
            timePeriod = "monthly";
            schedulerTime = `${mins} ${hours} ${date} * *`;
            stopTime = `${mins} ${timeToStop} ${date} * *`;
        } else if (date != "*" && month != "*") {
            timePeriod = "yearly";
            schedulerTime = `${mins} ${hours} ${date} ${month} *`;
            stopTime = `${mins} ${timeToStop} ${date} ${month} *`;
        } else {
            timePeriod = "daily";
            schedulerTime = `${mins} ${hours} * * *`;
            stopTime = `${mins} ${timeToStop} * * *`;
        }
        //stopTime = `${mins} ${timeToStop} * * *`;
        let obj = {
            groupId: "",
            groupName: groupName,
            state: state,
            day: day,
            date: date,
            month: month,
            mins: mins,
            hours: hours,
            timeToStop: timeToStop,
            scheduleUpdatedAt: `${new Date()}`
        }
        if (fs.existsSync(filePath)) {
            await changePermission();
            schedularData = JSON.parse(fs.readFileSync(filePath));
        }

        let foundIndex = schedularData.findIndex(x => x.groupName == obj.groupName);

        if (foundIndex != -1) {
            schedularData[foundIndex] = obj;
        } else {
            schedularData.push(obj);
        }
        schedularData = schedularData.filter(schedular => schedular.groupName !== 'transaction_and_aggregation')
        schedularData = schedularData.filter(schedular => schedular.groupName !== 'validate_datasource')
        fs.writeFile(filePath, JSON.stringify(schedularData), function (err) {
            if (err) throw err;
            logger.info('Scheduled RUNNING Job - Updated to file');
            res.status(200).send({ msg: `Job rescheduled successfully at ${hours}: ${mins} ${timePeriod}` });
        });
        var url = '';
        await schedule.scheduleJob(groupName + '_start', schedulerTime, async function () {
            var pyth1 = shell.exec(`sudo ${process.env.BASE_DIR}/cqube/emission_app/flaskenv/bin/python ${process.env.BASE_DIR}/cqube/emission_app/python/configure_load_property_values.py ${dataSource.data.report_name.toLowerCase()} ${stoppingHour} `, function (stdout, stderr, code) {
                if (code) {
                    logger.error("Something went wrong");
                    res.status(406).send({ errMsg: "Something went wrong" });
                } else {
                    logger.info('--- common  shecduler api response sent---');
                    res.status(200).send({ msg: `Job rescheduled successfully at ${hours}: ${mins} ${timePeriod}` });
                }
            })

            logger.info(`--- ${groupName} - Nifi processor group scheduling completed ---`);

        });


    } catch (e) {
        logger.error(`Error :: ${e}`)
        res.status(500).json({ errMessage: "Internal error. Please try again!!" });
    }
});

const changePermission = async () => {
    try {
        let username = process.env.SYSTEM_USERNAME;
        username = username.replace(/\n/g, '');
        shell.exec(`sudo chown ${username}:${username} ${filePath}`);
        logger.info("File permission change succcessful");
    } catch (error) {
        logger.info(error);
    }
};


module.exports = router;