const router = require('express').Router();
const { logger } = require('../../lib/logger');
const baseDir = process.env.BASE_DIR;
const storageType = process.env.STORAGE_TYPE;
var shell = require('shelljs');

router.post('/', async (req, res) => {
    try {
        logger.info('--- diksha TPD ETB method api ---');
        let method = req.body.method;
        let dataSet = req.body.dataSet;

        shell.exec(`sudo ${process.env.BASE_DIR}/cqube/emission_app/flaskenv/bin/python ${baseDir}/cqube/emission_app/python/nifi_disable_processor.py diksha_transformer ${storageType} ${dataSet} ${method}`, code=> {
            if (code) {
                logger.error("Something went wrong");
                res.status(406).send({ errMsg: "Something went wrong" });
            } else {
                logger.info('--- diksha TPD ETB method api response sent---');
                res.status(200).send({ msg: `Successfully Changed the Diksha ${dataSet} Method to ${method}` });
            }
        });

    } catch (e) {
        logger.error('--- Internal Server Error ---');
        res.status(500).send({ errMsg: "Internal Server Error" });
    }
})

module.exports = router;