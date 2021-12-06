const router = require('express').Router();
const { logger } = require('../../../lib/logger');
const auth = require('../../../middleware/check-auth');
const readFile = require('../../../lib/reads3File');

router.get('/metaData',auth.authController, async (req, res) => {
    try {
        logger.info('--- diksha Total conten play over years api ---');
        // var fileName = `diksha/line/state.json`;
        // let jsonData = await readFile.readFileConfig(fileName);
        // var footer = jsonData['footer'];
        // let mydata = jsonData;

        let myData = {
            data:[{
                district_id : 2401,
                dist_name : "Ahemadabad"
            },
            {
                district_id : 2204,
                dist_name : "Amreli"
            }
        
        ]
        }
        logger.info('--- diksha Total conten play over years api response sent ---');
        res.send({ data: mydata, downloadData: jsonData });
    } catch (e) {
        logger.error(`Error :: ${e}`)
        res.status(500).json({ errMessage: "Internal error. Please try again!!" });
    }
})




module.exports = router;