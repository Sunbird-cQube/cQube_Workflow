const { logger } = require('../../lib/logger');
var schedule = require('node-schedule');
const fs = require('fs');
const axios = require('axios');
var filePath = `${process.env.BASE_DIR}/cqube/admin_dashboard/schedulers.json`;
var shell = require('shelljs');

exports.restartNifiProcess = async function () {
    try {
        var schedulerTime;
        var schedularData = []
        if (fs.existsSync(filePath)) {
            await changePermission();
             schedularData = JSON.parse(fs.readFileSync(filePath));
            
            schedularData = schedularData.filter(schedular => schedular.groupName !== 'transaction_and_aggregation')
            schedularData = schedularData.filter(schedular => schedular.groupName !== 'validate_datasource')

            schedularData.forEach(async (myJob, index) => {

                if (myJob.groupId !== '') {

                    if (myJob.day && myJob.day != "*") {
                        schedulerTime = `${myJob.mins} ${myJob.hours} * * ${myJob.day}`;
                    } else if (myJob.date && myJob.date != "*") {
                        schedulerTime = `${myJob.mins} ${myJob.hours} ${myJob.date} * *`;
                    } else if (myJob.date && myJob.date != "*" && myJob.month && myJob.month != "*") {
                        schedulerTime = `${myJob.mins} ${myJob.hours} ${myJob.date} ${myJob.month} *`;
                    } else {
                        schedulerTime = `${myJob.mins} ${myJob.hours} * * *`;
                    }

                    logger.info('Rescheduling jobs due to nodejs restart');
                    if (myJob.state == "RUNNING") {
                        await stoppingJob(myJob, schedularData);
                    }
                    await rescheduleJob(myJob, schedulerTime, schedularData);
                    await stoppingJob(myJob, schedularData);
                } else {

                    if (myJob.day && myJob.day != "*") {
                        schedulerTime = `${myJob.mins} ${myJob.hours} * * ${myJob.day}`;
                    } else if (myJob.date && myJob.date != "*") {
                        schedulerTime = `${myJob.mins} ${myJob.hours} ${myJob.date} * *`;
                    } else if (myJob.date && myJob.date != "*" && myJob.month && myJob.month != "*") {
                        schedulerTime = `${myJob.mins} ${myJob.hours} ${myJob.date} ${myJob.month} *`;
                    } else {
                        schedulerTime = `${myJob.mins} ${myJob.hours} * * *`;
                    }

                    logger.info('Rescheduling common jobs due to nodejs restart');
                    await commonSchedular(myJob, schedulerTime, schedularData)
                }

            });
        }
    } catch (e) {
        logger.error(`Error :: ${e}`);
    }
}

const rescheduleJob = (myJob, schedulerTime, schedularData) => {
    return new Promise(async (resolve, reject) => {
        try {

            await schedule.scheduleJob(myJob.groupName + '_start', schedulerTime, async function () {
                var processorsList = await axios.get(`${process.env.NIFI_URL}/process-groups/root/process-groups`);
                let groupId1;
                processorsList.data.processGroups.map(process => {
                    if (myJob.groupName == process.component.name) {
                        myJob.groupId = process.component.id;
                    }
                    if ('cQube_data_storage' == process.component.name) {
                        groupId1 = process.component.id;
                    }
                })
                let url = `${process.env.NIFI_URL}/flow/process-groups/${myJob.groupId}`;
                let url1 = `${process.env.NIFI_URL}/flow/process-groups/${groupId1}`;
                logger.info(`--- ${myJob.groupName} - Nifi processor group scheduling started ---`);
                let response = await startFun(url, myJob.groupId);
                let response1 = await startFun(url1, groupId1);
                myJob.state = "RUNNING";
                myJob.scheduleUpdatedAt = `${new Date()}`;
                await fs.writeFile(filePath, JSON.stringify(schedularData), function (err) {
                    if (err) throw err;
                    logger.info('Restart process - Scheduled RUNNING Job - Restarted successfully');
                    resolve(true);
                });
                logger.info(JSON.stringify(response))
                logger.info(JSON.stringify(response1))
                logger.info(`--- ${myJob.groupName} - Nifi processor group scheduling completed ---`);
                logger.info(`--- cQube_data_storage - Nifi processor group scheduling completed ---`);
            });
        } catch (e) {
            reject(e);
        }
    })
}

const stoppingJob = (myJob, schedularData) => {
    return new Promise(async (resolve, reject) => {
        try {
            var stopTime;
            if (myJob.day && myJob.day != "*") {
                stopTime = `${myJob.mins} ${myJob.timeToStop} * * ${myJob.day}`;
            } else if (myJob.date && myJob.date != "*") {
                stopTime = `${myJob.mins} ${myJob.timeToStop} ${myJob.date} * *`;
            } else if (myJob.date && myJob.date != "*" && myJob.month && myJob.month != "*") {
                stopTime = `${myJob.mins} ${myJob.timeToStop} ${myJob.date} ${myJob.month} *`;
            } else {
                stopTime = `${myJob.mins} ${myJob.timeToStop} * * *`;
            }
            await schedule.scheduleJob(myJob.groupName + '_stop', stopTime, async function () {

                var processorsList = await axios.get(`${process.env.NIFI_URL}/process-groups/root/process-groups`);
                let groupId1;
                processorsList.data.processGroups.map(process => {
                    if (myJob.groupName == process.component.name) {
                        myJob.groupId = process.component.id;
                    }

                    if ('cQube_data_storage' == process.component.name) {
                        groupId1 = process.component.id;
                    }
                })
                let url = `${process.env.NIFI_URL}/flow/process-groups/${myJob.groupId}`;
                let url1 = `${process.env.NIFI_URL}/flow/process-groups/${groupId1}`;
                logger.info(`--- ${myJob.groupName} - Nifi processor group scheduling stopping initiated ---`);
                logger.info(`--- cQube_data_storage - Nifi processor group scheduling stopping initiated ---`);
                let response = await stopFun(url, myJob.groupId);
                let response1 = await stopFun(url1, groupId1);
                myJob.state = "STOPPED";
                myJob.scheduleUpdatedAt = `${new Date()}`;
                await changePermission();
                await fs.writeFile(filePath, JSON.stringify(schedularData), function (err) {
                    if (err) throw err;
                    logger.info('Restart process - Scheduled Job status changed to STOPPED - Stopped Successfully');
                });
                setTimeout(() => {
                    logger.info(' --- executing nifi restart shell command ----');
                    shell.exec(`sudo ${process.env.BASE_DIR}/cqube/nifi/nifi/bin/nifi.sh restart`, function (code, stdout, stderr) {
                        logger.info('Exit code:', code);
                        logger.info('Program output:', stdout);
                        logger.info('Program stderr:', stderr);
                    });
                    resolve("Restart process - Job has been Stopped");
                }, 120000);
                logger.info(JSON.stringify(response))
                logger.info(JSON.stringify(response1))
                logger.info(`--- ${myJob.groupName} - Nifi processor group scheduling stopping completed ---`);
                logger.info(`--- cQube_data_storage - Nifi processor group scheduling stopping completed ---`);
            });

        } catch (e) {
            reject(e);
        }
    })
}

const commonSchedular = (myJob, schedulerTime, schedularData) => {
    return new Promise(async (resolve, reject) => {
        try {
         
            let schedularData1 = schedularData
            schedularData1 = schedularData1.filter(schedular => schedular.groupName !== 'transaction_and_aggregation')
            schedularData1 = schedularData1.filter(schedular => schedular.groupName !== 'validate_datasource')
            await schedule.scheduleJob(myJob.groupName + '_start', schedulerTime, async function () {
                var pyth1 = shell.exec(`sudo ${process.env.BASE_DIR}/cqube/emission_app/flaskenv/bin/python ${process.env.BASE_DIR}/cqube/emission_app/python/configure_load_property_values.py ${myJob.groupName.toLowerCase()} ${myJob.timeToStop} `, function (stdout, stderr, code) {
                    if (code) {
                        logger.error("Something went wrong");
                        res.status(406).send({ errMsg: "Something went wrong" });
                    } else {
                        logger.info('--- diksha TPD ETB method api response sent---');
                        myJob.state = "RUNNING";
                        myJob.scheduleUpdatedAt = `${new Date()}`;
                        fs.writeFile(filePath, JSON.stringify(schedularData1), function (err) {
                            if (err) throw err;
                            logger.info('Restart process - Scheduled RUNNING Job - Restarted successfully');
                            resolve(true);
                        });
                        res.status(200).send({ msg: `Successfully Changed` });
                    }
                })

                logger.info(`--- ${myJob.groupName} - Nifi processor group scheduling completed ---`);
                logger.info(`--- cQube_data_storage - Nifi processor group scheduling completed ---`);
            });
        } catch (e) {
            reject(e);
        }
    })

}

const startFun = (url, groupId) => {
    return new Promise(async (resolve, reject) => {
        try {
            let result = await axios.put(url, {
                id: groupId,
                state: 'RUNNING',
                disconnectedNodeAcknowledged: false
            });
            resolve(result.data)
        } catch (e) {
            reject(e)
        }
    })
}
const stopFun = (url, groupId) => {
    return new Promise(async (resolve, reject) => {
        try {
            let result = await axios.put(url, {
                id: groupId,
                state: 'STOPPED',
                disconnectedNodeAcknowledged: false
            });
            resolve(result.data)
        } catch (e) {
            reject(e)
        }
    })
}

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
