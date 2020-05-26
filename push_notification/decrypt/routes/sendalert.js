const express = require('express');
const router = express.Router();
const AlertController = require('../contoller/sendalert')


router.post('/send', AlertController.saveAndSendAlert)

module.exports = router;


