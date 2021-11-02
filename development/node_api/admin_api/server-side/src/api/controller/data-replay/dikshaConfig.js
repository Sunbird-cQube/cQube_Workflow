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
        
            shell.exec(`sudo ${process.env.BASE_DIR}/cqube/emission_app/flaskenv/bin/python ${baseDir}/cqube/emission_app/python/update_processor_property.py diksha_transformer_custom  ${fromDate} ${toDate} ${selectedHour}`,
           
            function (code, stderr, stdout) {
                if (stderr) {
                    logger.error('Program stderr:', stderr);
                    res.status(403).send({ errMsg: "Something went wrong" });
                } else {
                    logger.info('--- diksha configuration api response sent---');
                    res.status(200).send({ msg: `Diksha ETB Dates Configured Successfully.` });
                }
            });

    } catch (e) {
        logger.error('--- Internal Server Error ---');
        res.status(500).send({ errMsg: "Internal Server Error" });
    }
})

module.exports = router;