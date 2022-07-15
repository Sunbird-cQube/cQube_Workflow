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
        console.log('filename', filename)
        let data = await s3File.readFileConfig(filename);
        console.log('data', data)
        logger.info('--- Meta file  api response sent ---');
        res.status(200).send(data);
    } catch (e) {
        logger.error(e);
        res.status(500).json({ errMessage: "Internal error. Please try again!!" });
    }
})

router.post('/timePeriod', auth.authController, async (req, res) => {
    let { dataSource } = req.body
    try {
        logger.info('--- Meta file ---');
        console.log('dataSource', dataSource)
        let filename = `${dataSource}/time_period_meta.json`
        let data = await s3File.readFileConfig(filename);
        console.log('data', data)
        logger.info('--- Meta file  api response sent ---');
        res.status(200).send(data);
    } catch (e) {
        logger.error(e);
        res.status(500).json({ errMessage: "Internal error. Please try again!!" });
    }
})

module.exports = router;