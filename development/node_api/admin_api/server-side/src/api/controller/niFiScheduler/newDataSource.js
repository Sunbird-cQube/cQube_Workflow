const router = require('express').Router();
const { logger } = require('../../lib/logger');
const auth = require('../../middleware/check-auth');
const axios = require('axios');
var schedule = require('node-schedule');
const fs = require('fs');
var shell = require('shelljs');
const db = require('../../lib/db')

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
        let dataSource = req.body.data.report_name

        var pyth1 = shell.exec(`sudo ${process.env.BASE_DIR}/cqube/emission_app/flaskenv/bin/python ${baseDir}/cqube/emission_app/python/configure_load_property_values.py ${dataSource} `, function (stdout, stderr, code) {
            if (code) {
                logger.error("Something went wrong");
                res.status(406).send({ errMsg: "Something went wrong" });
            } else {
                logger.info('--- diksha TPD ETB method api response sent---');
                res.status(200).send({ msg: `Successfully Changed the Diksha ${dataSet} Method to ${method}` });
            }
        })

    } catch (e) {
        logger.error(`Error :: ${e}`)
        res.status(500).json({ errMessage: "Internal error. Please try again!!" });
    }
});

module.exports = router;