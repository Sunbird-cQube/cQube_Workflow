const router = require('express').Router();
const { logger } = require('../../lib/logger');
const auth = require('../../middleware/check-auth');
const fs = require('fs');
const csv = require('csvtojson')
const shell = require('shelljs');
const baseDir = process.env.BASE_DIR;

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
            })
        })
        var pyth1 = shell.exec(`sudo ${process.env.BASE_DIR}/cqube/emission_app/flaskenv/bin/python ${baseDir}/cqube/emission_app/python/configure_load_property_values.py ${dataSource} `, function (stdout, stderr, code) {
            console.log('code', code)
        })
    } catch (e) {
        logger.error(`Error :: ${e}`)
        res.status(500).json({ errMessage: "Internal error. Please try again!!" });
    }
});


module.exports = router;