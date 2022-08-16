const router = require('express').Router();
const { logger } = require('../../lib/logger');
const auth = require('../../middleware/check-auth');
const fs = require('fs');
const csv = require('csvtojson')
const shell = require('shelljs');
const baseDir = process.env.BASE_DIR;
const path = require('path');
const db = require('../../lib/db')

router.get('/', async function (req, res) {
    try {
        logger.info('---list new dataSource api ---');
        let csvFilePath = `${process.env.BASE_DIR}/cqube/emission_app/python/postgres/`;
        let jsonArray = [];
        // read directory

        db.query('select distinct report_name,status,state from configurable_datasource_properties ;', (error, results) => {
            if (error) {
                logger.info('--- common schedular api failed ---')
                throw error
            }

            if (results['rowCount']) {
                logger.info('---common schedular api response sent ---')

                let data = results['rows']

                data = data.filter(program => program.status === false)
                data.map(program => jsonArray.push(program.report_name))

                res.status(200).send(jsonArray);
                logger.info('---list new dataSource api response send---');
            } else {
                res.send({ status: "401", err: "somthing went wrong" })
            }

        })


    } catch (e) {
        logger.error(`Error :: ${e}`)
        res.status(500).json({ errMessage: "Internal error. Please try again!!" });
    }
});

router.post('/buildUI', async function (req, res) {
    try {
        let dataSource = req.body.dataSource
        logger.info('---buildUI ---');
        let UIpath = `${process.env.ANGULAR_DIRECTORY}`;
        shell.echo('--shell script started----')
        db.query('update configurable_datasource_properties set status=True where lower(report_name)=$1;', [req.body.dataSource.toLowerCase()], (error, results) => {
            if (error) {
                throw error
            }
            logger.info('---Data source  status changed---');
            res.status(201).json({ msg: "Data source  status changed" });        
        })
    } catch (e) {
        logger.error(`Error :: ${e}`)
        res.status(500).json({ errMessage: "Internal error. Please try again!!" });
    }
});


module.exports = router;