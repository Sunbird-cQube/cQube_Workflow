const router = require('express').Router();
const { logger } = require('../../lib/logger');
const auth = require('../../middleware/check-auth');
const s3File = require('../../lib/reads3File');
const inputDir = `${process.env.EMISSION_DIRECTORY}`;
const writeFile = require('../../lib/uploadFile');
const storageType = `${process.env.STORAGE_TYPE}`;
const containerName = process.env.AZURE_OUTPUT_STORAGE;

router.post('/', auth.authController, async (req, res) => {
    try {
        logger.info('--- set telemetry api ---');
        let year = req.body.date.year;
        let month = req.body.date.month;
        let date = req.body.date.date;
        let hour = req.body.date.hour;
        let fileName = `telemetry/telemetry_view/telemetry_views_${year}_${month}_${date}_${hour}.csv`;
        var localPath = inputDir + fileName;
        // var response = await storageType == "s3" ? await writeFile.saveToS3(fileName, req.body.telemetryData) : await writeFile.saveToLocal(localPath, req.body.telemetryData, 'views');
        var response = await writeFile.uploadFiles(containerName, fileName, req.body.telemetryData, 'views');
        // console.log(response);
        logger.info('--- response sent for set telemetry api ---');
        res.status(200).json(response);
    } catch (e) {
        logger.error(`Error :: ${e}`);
        res.status(500).json({ errMsg: "Internal error. Please try again!!" });
    }
});

router.post('/sar', auth.authController, async (req, res) => {
    try {
        logger.info('---set SAR telemetry api ---');
        let year = req.body.date.year;
        let month = req.body.date.month;
        let date = req.body.date.date;
        let hour = req.body.date.hour;
        let fileName = `telemetry/telemetry_${year}_${month}_${date}_${hour}.csv`;
        var localPath = inputDir + fileName;
        // var response = await storageType == "s3" ? await writeFile.saveToS3(fileName, req.body.telemetryData) : await writeFile.saveToLocal(localPath, req.body.telemetryData, 'sar');
        var response = await writeFile.uploadFiles(containerName, fileName, req.body.telemetryData, 'sar');
        logger.info('--- response sent for set SAR telemetry api ---');
        res.status(200).json(response);

    } catch (e) {
        logger.error(`Error :: ${e}`);
        res.status(500).json({ errMsg: "Internal error. Please try again!!" });
    }
});

router.post('/data', async (req, res) => {
    try {
        logger.info('---get telemetry api ---');
        var period = req.body.period;
        let fileName = `cqube_telemetry_views/${period}/telemetry_views_data.json`;
        let telemetryData = await s3File.readFileConfig(fileName);
        logger.info('--- get telemetry api response sent ---');
        res.status(200).send({ telemetryData });
    } catch (e) {
        logger.error(`Error :: ${e}`)
        res.status(500).json({ errMessage: "Internal error. Please try again!!" });
    }
})

module.exports = router