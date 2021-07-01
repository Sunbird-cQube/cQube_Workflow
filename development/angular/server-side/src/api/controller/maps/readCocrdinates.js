const router = require('express').Router();
const { logger } = require('../../lib/logger');
const fs = require('fs')
var baseDir = `${process.env.BASE_DIR}/cqube/dashboard/maps`;

router.post('/', async function (req, res) {
    try {
        logger.info('--- map coordinates api ---');
        var stateName = req.body.stateName
        var fileName = baseDir + `/states_for_cQube.json`;
        var mapData = (JSON.parse(fs.readFileSync(fileName).toString()))[stateName];
        logger.info('--- map coordinates api response sent ---');
        res.status(200).send(mapData);
    } catch (e) {
        logger.error(`Error :: ${e}`)
        res.status(500).json({ errMessage: "Internal error. Please try again!!" });
    }
});

module.exports = router;