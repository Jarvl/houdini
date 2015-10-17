var express = require('express');
var router = express.Router();
var mongoose = require('mongoose');
var bodyParser = require('body-parser');

var helpers = require('../utils/helpers');
var secrets = require('../config/secrets');

var stripe = require('stripe')(secrets.stripeApiKey);

var WaitingForCall = require('../models/WaitingForCall');
var Users = require('../models/Users');

/* GET home page. */
router.get('/', function(req, res, next) {
  res.render('index', { title: 'Express' });
});

router.get('/api', function(req, res) {
    res.send('api');
});

// Sent by the phone who requested the phone call to end a call
router.post('/api/endPhoneCall', function(req, res) {
    var sessionId = req.body.sessionId;
    var username, stripeEmail, stripeCode;

    // Find and remove the current session
    var wfcQuery = WaitingForCall.findOne({
        sessionId: sessionId
    }).exec();

    wfcQuery.then(function(err, wfc) {
        helpers.logError(err)
        username = wfc.username;
        stripeCode = wfc.stripeCode;
        stripeEmail = wfc.stripeEmail;
        wfc.remove().exec(helpers.logError(err));
    });

    // Charge their account down here

});

// Sent by the phone that's requesting the phone call
router.post('/api/requestPhoneCall', function(req, res) {
    // Session id from requesting phone
    var sessionId = req.body.sessionId;
    var username = req.body.username;

    // Store the session information
    WaitingForCall.create({
        sessionId: sessionId,
        phoneNumber: phoneNumber,
        username: username,
    }, helpers.logError(err));

    // use setInterval here to find other people. Implement last

    // Find 10 available users and send then push notifications
    Users.findRandom({available: true}, {}, {limit: 10}, function(err, usersData) {
        helpers.logError(err);
        // Loop through each user
        for (var i = 0; i < usersData.length; i++) {
            // Send them a push notification
        }
        res.json(usersData);
    });
});

// When a user is called, update their status as called
router.post('/api/called', function(req, res) {
    // Session id from requesting phone
    var sessionId = req.body.sessionId;

    WaitingForCall.findOneAndUpdate({
        sessionId: sessionId
    }, {
        $set: {
            called: true
        }
    },
    {}, helpers.logError(err));
});

// When a user is made available to call
router.post('/api/setAvailable', function(req, res) {
    // Session Id from receiving phone
    var sessionId = req.body.sessionId;

    // Find and set available
    Users.findOneAndUpdate({
        sessionId: sessionId
    }, {
        $set: {
            available: true
        }
    },
    {}, helpers.logError(err));
});

// When a user is made unavailable to call
router.post('/api/setUnavailable', function(req, res) {
    // Session Id from receiving phone
    var sessionId = req.body.sessionId;

    // Find and set unavailable
    Users.findOneAndUpdate({
        sessionId: sessionId
    }, {
        $set: {
            available: false
        }
    }, helpers.logError(err));
});

// sign up form handling
router.post('/signup', function(req, res) {
    Users.create({
        username: username,
        sessionId: sessionId, // Probably created here
        phoneNumber: phoneNumber,
        firstName: firstName,
        lastName: lastName
    }, function(err) {
        helpers.logError(err);
        res.send('registered!');
    });
});

// Connecting a stripe account
router.post('/connectStripe', function(req, res) {
    var stripeEmail = req.body.stripeEmail;
    // Maybe use sessions to store the email

    // Redirect user so they can connect their stripe account
    res.redirect('https://connect.stripe.com/oauth/authorize?response_type=code&client_id=' + secrets.stripeClientKey + '&scope=read_write');
});

router.get('/stripeConfirmation', function(req, res) {
    if (req.query.error) {
        var errorDescription = req.query.error_description;
        res.send(errorDescription);
    }
    else if (req.query.code) {
        var stripeCode = req.query.code;
        //var stripeEmail = req.session.stripeEmail;

        // Store user code
        Users.findOneAndUpdate({
            stripeEmail: stripeEmail
        }, {
            $set: {
                stripeCode: stripeCode,
                stripeEmail: stripeEmail
            }
        }, function(err) {
            helpers.logError(err);
            res.send('Account connected!');
        });
    }
});

module.exports = router;
