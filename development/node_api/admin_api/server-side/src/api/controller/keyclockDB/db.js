const dotenv = require('dotenv');
dotenv.config();

const { Pool, Client } = require("pg");

const pool = new Pool({
    user: "cqube_db_user",
    host: "localhost",
    database: "cqube_db",
    password: "Tibil@123",
    port: "5434"
});




module.exports = pool

