const router = require('express').Router();
const { logger } = require('../../lib/logger');
const auth = require('../../middleware/check-auth');
const s3File = require('../../lib/reads3File');

router.post('/configCardProperties', auth.authController, async (req, res) => {
    try {
        logger.info('--- Configurable card properties ---');

        let filename = `ui_configurable_property/ui_configurable_property.json`
         let data = await s3File.readFileConfig(filename);

        


        
        //     // let program = data
        //     // data = data.map((report, j) => {

        //     //     console.log('report', report)
        //     //     // if (report.report_name === uniqDataSource[i]) {
        //     //     //     // console.log('report', report)
        //     //     //     name = uniqDataSource[i]

        //     //     //     data1.push({
        //     //     //         name: report
        //     //     //     }

        //     //     //     )
        //     //     // }
        //     // })
        // })

        
        data.forEach(data => {
            data.routerLink = `/${data.report_name.replace(/\s+/g, '-').toLowerCase()}/${data.report_type}`;
        });
    

        logger.info('--- Configurable card properties  api response sent ---');
        res.status(200).send({ data: data });
    } catch (e) {
        logger.error(e);
        res.status(500).json({ errMessage: "Internal error. Please try again!!" });
    }
})

module.exports = router;