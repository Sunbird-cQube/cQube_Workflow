const dotenv = require('dotenv');
dotenv.config();

const { Pool, Client } = require("pg");


let user = process.env.DB_USER;
let password = process.env.DB_PASSWORD;
let database = process.env.DB_NAME;
let port = process.env.DB_PORT;


const pool = new Pool({
    user: user,
    host: "localhost",
    database: database,
    password: password,
    port: port
});


module.exports = pool