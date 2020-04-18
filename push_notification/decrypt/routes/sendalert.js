var FCM = require('fcm-node');
const express = require('express');
const router = express.Router();
const Alert = require('../contoller/sendalert')
const alert = new Alert();

router.post('/home', (req,res,next) => {
  district = req.body.district
  title = req.body.title
  body = req.body.body
  level = req.body.level
  alert.sendAlert(district,title,body,level, function(response){
    alert.saveAlert(district,title,body,level, function(response){
      res.send(response)
    })
  })
});

module.exports = router;


