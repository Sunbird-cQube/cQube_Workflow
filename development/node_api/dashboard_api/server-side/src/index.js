const express = require('express');
const compression = require('compression')
const bodyParser = require('body-parser');
const app = express();
const cors = require('cors');
const env = require('dotenv');
const xXssProtection = require("x-xss-protection");
const helmet = require("helmet");

env.config();

const port = process.env.PORT || 3001;

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(
    cors({
        methods: ["GET", "POST"] // only allow GET requests
    })
);
app.use(compression());

// Set "X-XSS-Protection: 0"
app.use(xXssProtection());

app.use(helmet());
app.use(function (req, res, next) {
    res.setHeader("Content-Security-Policy", "frame-ancestors 'self';");
    next();
});

app.disable('x-powered-by');

app.use((err, req, res, next) => {
    if (err instanceof SyntaxError && err.status === 400 && 'body' in err) {
        console.error(err);
        return res.status(400).send({ status: 404, message: err.message }); // Bad request
    }
    next();
});
const router = require('./api/router');
app.use('/api', router);

app.listen(port, '0.0.0.0', () => {
    console.log("Server started at port: ", port);
});