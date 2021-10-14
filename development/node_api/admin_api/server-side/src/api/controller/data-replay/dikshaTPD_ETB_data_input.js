const router = require('express').Router();
const PythonShell = require('python-shell').PythonShell;

router.post('/', async (req, res) => {
    let arg1 = req.body.method;
    let fileName = '/nifi_disable_processor.py';

    let options = {
        mode: 'text',
        pythonOptions: ['-u'], // get print results in real-time
        scriptPath: '/opt/cqube/emission_app/python', //If you are having python_test.py script in same folder, then it's optional.
        args: [arg1] //An argument which can be accessed in the script using sys.argv[1]
    };

    PythonShell.run(fileName, options, function (err, result) {
        if (err) throw err;
        res.send({ msg: "succesfully envoked python script" });
    });
})

module.exports = router;