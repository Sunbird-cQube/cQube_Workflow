const router = require('express').Router();
const { logger
} = require('../../lib/logger');
const auth = require('../../middleware/check-auth');
const s3File = require('../../lib/reads3File');

router.post('/meta', auth.authController, async (req, res) => {
    let { dataSource } = req.body
    try {
        logger.info('--- Meta file ---');

        let filename = `${dataSource}/meta.json`

        let data = await s3File.readFileConfig(filename);


        metaData = data[0].data.grades[0]
        let isSubjAvailable = metaData.hasOwnProperty('subjects')
        logger.info('--- Meta file  api response sent ---');
        res.status(200).send({ data, isSubjAvailable });
    } catch (e) {
        logger.error(e);
        res.status(500).json({ errMessage: "Internal error. Please try again!!" });
    }
})

router.post('/timePeriod', auth.authController, async (req, res) => {
    let { dataSource } = req.body
    try {
        logger.info('--- Meta timeperiod file ---');

        let filename = `${dataSource}/time_period_meta.json`
        let data = await s3File.readFileConfig(filename);

        logger.info('--- Meta file  api response sent ---');
        res.status(200).send(data);
    } catch (e) {
        logger.error(e);
        res.status(500).json({ errMessage: "Internal error. Please try again!!" });
    }
})

router.post('/metricname', auth.authController, async (req, res) => {
    let { dataSource } = req.body
    try {
        logger.info('--- Meta metric name file ---');

        let filename = `${dataSource}/meta_tooltip.json`
        let data = await s3File.readFileConfig(filename);

        logger.info('--- Meta metric name  api response sent ---');
        res.status(200).send(data);
    } catch (e) {
        logger.error(e);
        res.status(500).json({ errMessage: "Internal error. Please try again!!" });
    }
})

module.exports = router;