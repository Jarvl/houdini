var express = require('express');
var router = express.Router();
var mongoose = require('mongoose');
var bodyParser = require('body-parser');

var Sessions = require('../models/Sessions');
var UsersAvailable = require('../models/UsersAvailable');

/* GET home page. */
router.get('/', function(req, res, next) {
  res.render('index', { title: 'Express' });
});

router.get('/api', function(req, res) {
    res.send('api');
});

// Sent by the phone who requested the phone call to end a call
router.post('api/endPhoneCall', function(req, res) {
    var sessionId = req.body.sessionId;

    // Find and remove the current session
    Sessions.findOne({
        sessionId: sessionId
    })
    .remove()
    .exec(function(err) {
        if (err) console.log(err);
        res.send("removed");
    });
});

// Sent by the phone that's requesting the phone call
router.post('/api/requestPhoneCall', function(req, res) {
    var sessionId = req.body.sessionId;
    var phoneNumber = req.body.phoneNumber;

    // Store the session information
    Sessions.create({
        sessionId: sessionId,
        phoneNumber: phoneNumber
    }, function(err) {
        if (err) console.log(err);
    });

    // use setInterval here to find other people. Implement last

    // Find 10 clients in the available users collection and send then push notifications
    UsersAvailable.findRandom({}, {}, {limit: 10}, function(err, usersData) {
        // Loop through each user
        for (var i = 0; i < usersData.length; i++) {
            // Send them a notification somehow
        }
        res.json(usersData);
    });
});

module.exports = router;
