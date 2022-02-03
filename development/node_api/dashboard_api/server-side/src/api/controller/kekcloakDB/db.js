const dotenv = require('dotenv');
dotenv.config();

const { Pool, Client } = require("pg");

const pool = new Pool({
    user: "",
    host: "localhost",
    database: "cqube_db",
    password: "",
    port: "5432"
});


module.exports = pool