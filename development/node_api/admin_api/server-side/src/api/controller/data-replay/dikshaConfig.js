const router = require('express').Router();
const { logger } = require('../../lib/logger');
const baseDir = process.env.BASE_DIR;
var shell = require('shelljs');

router.post('/', async (req, res) => {
    try {
        logger.info('--- diksha configuration api ---');
        let fromDate = req.body.fromDate;
        let toDate = req.body.toDate;
        let selectedHour = req.body.hourSelected;

        if (shell.exec(`sudo ${process.env.BASE_DIR}/cqube/emission_app/flaskenv/bin/python ${baseDir}/cqube/emission_app/python/update_processor_property.py diksha_transformer_custom  ${fromDate} ${toDate} ${selectedHour}`).code == 1) {
            logger.error("Something went wrong");
            res.status(406).send({ errMsg: "Something went wrong" });
        }
        return false;
    } catch (e) {
        logger.error('--- Internal Server Error ---');
        res.status(500).send({ errMsg: "Internal Server Error" });
    }
})

module.exports = router;