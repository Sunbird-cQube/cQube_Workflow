const router = require('express').Router();


// user info
const getUser = require('./controller/users/userDetails');
router.use('/', getUser);

module.exports = router;