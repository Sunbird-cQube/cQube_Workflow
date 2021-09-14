
const router = require('express').Router();
var const_data = require('../../lib/config');
const { logger } = require('../../lib/logger');
const auth = require('../../middleware/check-auth');
const groupArray = require('group-array');
const s3File = require('../../lib/reads3File');

router.get('/getDateRange', auth.authController, async (req, res) => {
    try {
        logger.info('---getDateRange api ---');
        let fileName = `pat/metaData.json`;
        var jsonData = await s3File.storageType == "s3" ? await s3File.readS3File(fileName) : await s3File.readLocalFile(fileName);
        logger.info('--- getDateRange response sent ---');
        res.status(200).send(jsonData);
    } catch (e) {
        logger.error(`Error :: ${e}`)
        res.status(500).json({ errMessage: "Internal error. Please try again!!" });
    }
});


router.get('/getYears', async (req, res, next) => {
    try {
        logger.info('---years metadata api ---');
        // var fileName =`sat/all/sat_metadata.json`;

        // var data = await s3File.storageType == "s3" ? await s3File.readS3File(fileName) : await s3File.readLocalFile(fileName);;
        let data =
            [
                {
                    "academic_year": "2020-21",
                    "semester": [{ id: "sem_1", name: "Semester 1" }, { id: "sem_2", name: "Semester 2" }]
                },
                {
                    "academic_year": "2021-22",
                    "semester": [{ id: "sem_1", name: "Semester 3" }, { id: "sem_2", name: "Semester 4" }]
                }
            ]

        logger.info('---years metadata api response sent---');
        res.status(200).send({ data: data });
    } catch (e) {
        logger.error(`Error :: ${e}`)
        res.status(500).json({ errMessage: "Internal error. Please try again!!" });
    }
})

module.exports = router;