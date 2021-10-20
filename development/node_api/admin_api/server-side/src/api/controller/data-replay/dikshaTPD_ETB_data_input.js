const router = require('express').Router();
const PythonShell = require('python-shell').PythonShell;
const baseDir = process.env.BASE_DIR;
const storageType = process.env.STORAGE_TYPE;

router.post('/', async (req, res) => {
    let arg1 = req.body.method;
    let dataSet = req.body.dataSet;
    let fileName = '/nifi_disable_processor.py';
    let options = {
        mode: 'text',
        pythonOptions: ['-u'],
        scriptPath: `${baseDir}/cqube/emission_app/python`,
        args: ['diksha_transformer', storageType, dataSet, arg1]
    };

    PythonShell.run(fileName, options, function (err, result) {
        if (err) throw err;
        console.log(result);
        res.send({ msg: "succesfully envoked python script" });
    });
})

module.exports = router;