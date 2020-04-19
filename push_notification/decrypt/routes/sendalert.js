const express = require('express');
const router = express.Router();
const AlertController = require('../contoller/sendalert')


router.post('/home', AlertController.saveAndSendAlert)

module.exports = router;


