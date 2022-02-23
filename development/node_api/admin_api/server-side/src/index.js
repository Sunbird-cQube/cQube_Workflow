const express = require('express');
const compression = require('compression')
const bodyParser = require('body-parser');
const app = express();
const cors = require('cors');
const axios = require('axios');
const env = require('dotenv');
env.config();

global.userSessionDetails = {}

const port = process.env.PORT || 3002;

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(cors());
app.use(compression());

app.use(function (req, res, next) {
    res.setHeader("Content-Security-Policy", "frame-ancestors 'self';");
    next();
});

const router = require('./api/router');
app.use('/api', router);
const sessionRouter = require('./api/sessionRouter');
app.use('/admin_api', sessionRouter);

app.use((err, req, res, next) => {
    if (err instanceof SyntaxError && err.status === 400 && 'body' in err) {
        console.error(err);
        return res.status(400).send({ status: 404, message: err.message }); // Bad request
    }
    next();
});
app.use((req, res, next) => {
    const error = new Error('Not found');
    error.status = 404;
    next(error);
});

const restartSchedular = require('./api/controller/niFiScheduler/restartSchedular');

app.listen(port, '0.0.0.0', () => {
    console.log("Server started at port: ", port);
    restartSchedular.restartNifiProcess();
});