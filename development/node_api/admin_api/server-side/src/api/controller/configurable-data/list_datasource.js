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

        fs.readdir(csvFilePath, (error, fileNames) => {
            if (error) throw error;
            fileNames.forEach(filename => {
                const ext = path.parse(filename).ext;
                if (ext === ".sql") {

                    let name = filename.substr(0, filename.indexOf('.'))

                    jsonArray.push(name)
                }
            }
            );
            logger.info('---list new dataSource api response send---');
            res.status(200).send(jsonArray);
        });

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

        var output = shell.exec(`fuser -n tcp -k 4200`, function (stdout, stderr, code) {
            var output1 = shell.exec(`cd  ${UIpath} && ng build --prod`, function (stdout, stderr, code) {
                logger.info('---buildUI  success---');

            })
        })

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