var express = require('express');
var router = express.Router();
var mongoose = require('mongoose');
var bodyParser = require('body-parser');
var session = require('express-session');
var bcrypt = require('bcrypt-nodejs');

var helpers = require('../utils/helpers');
var secrets = require('../config/secrets');
var WaitingForCall = require('../models/WaitingForCall');
var Users = require('../models/Users');

var stripe = require('stripe')(secrets.stripeApiKey);


/* GET home page. */
router.get('/', function(req, res, next) {
  res.render('index', { title: 'Express' });
});


/**
 * GET /api
 * Just a placeholder
**/
router.get('/api', function(req, res) {
    res.sendStatus(200);
});


/**
 * POST /api/endPhoneCall
 * Sent by the requesting user's phone.
 * Triggered by the ending of the phone call.
 * Finds the current call based on the session id.
 * Calculates minutes (rounds up), and charges the requesting user's Stripe account.
 * @response A confirmation that the account was charged and the minutes of the call.
**/
router.post('/api/endPhoneCall', function(req, res) {
    var stripeCode, totalMinutes;
    var sess = req.session;
    var sessionId = sess.sessionId;
    var username = sess.username;

    var date = new Date();
    var timeEnd = date.getTime();

    // Find and remove the current calling session
    var wfcQuery = WaitingForCall.findOne({
        sessionId: sessionId
    }).remove().exec();

    // Get the user so we can find the time
    var userQuery = Users.findOne({
        username: username
    }).exec();

    userQuery.then(function(user) {
        stripeCode = user.stripeCode;

        // Get the difference, round up to nearest minute
        //totalMinutes = Math.ceil((timeEnd - timeStart) / 60);

        // Charge their account down here

    });

});


/**
 * POST /api/requestPhoneCall
 * Sent by the requesting user's phone.
 * Triggered by the request of the phone call from the watch.
 * Creates a call with a unique session id.
 * Finds 10 random available users and sends them a push notification with the session id attached.
 * @response confirmation that users have been notified.
**/
router.post('/api/requestPhoneCall', function(req, res) {
    var randomQuery;
    var phoneNumber = req.body.phoneNumber;
    var sess = req.session;
    var sessionId = helpers.generateSID();

    // Set session id and username
    //sess.sessionId = sessionId;

    // Session id from requesting phone
    //var sessionId = req.body.sessionId;
    var username = sess.username;

    // Store the call information
    var wfcQuery = WaitingForCall.create({
        sessionId: sessionId,
        phoneNumber: phoneNumber,
        usernameRequesting: username
    })

    wfcQuery.then(function(err) {
        helpers.logError(err);
        // use setInterval here to find other people. Implement last
        // Find 10 available users and send then push notifications
        randomQuery = Users.findRandom({available: true}, {}, {limit: 10}).exec();
    });

    randomQuery.then(function(err, usersData) {
        helpers.logError(err);
        // Loop through each user
        for (var i = 0; i < usersData.length; i++) {
            // Send them a push notification with the session id and phone number attached
        }
        res.json(usersData);
    });
});


/**
 * POST /api/called
 * Sent by the responding user's phone.
 * Triggered by pressing the call button on the app.
 * Gets the session id for the call, sets the called status to true, and sets the call time.
 * Sets the calling user's status as not available
 * @response 200 OK - no response needed
**/
router.post('/api/called', function(req, res) {
    // Session id from requesting phone
    var sess = req.session;
    var username = sess.username;

    // Session id passed in as form/json value
    var sessionId = req.body.sessionId;

    var date = new Date();
    var time = date.getTime();

    // Update database - the user has been called
    // Called time is in seconds
    WaitingForCall.findOneAndUpdate({
        sessionId: sessionId
    }, {
        $set: {
            usernameResponding: username,
            called: true
        }
    },
    {}, helpers.logError(err));

    // Update the responding user's status to unavailable
    Users.findOneAndUpdate({
        username: username
    }, {
        $set: {
            available: false
        }
    }, helpers.logError(err));

});


/**
 * POST /signup
 * Sign a user up!
**/
router.post('/signup', function(req, res) {
    var sess = req.session;
    var username = req.body.username;
    var password = req.body.password;
    //var phoneNumber = req.body.phoneNumber;
    var firstName = req.body.firstName;
    var lastName = req.body.lastName;

    Users.findOne({username: username}).exec(function(user) {
        if (user) res.send("You're already signed up bruh.");
    });

    // Hash the password
    var hash = bcrypt.hashSync(password, secrets.passwordSeed);

    // Create a new user and auto-log them in
    Users.create({
        username: username,
        password: hash,
        //phoneNumber: phoneNumber,
        firstName: firstName,
        lastName: lastName
    },
    function(err) {
        helpers.logError(err);
        // Set the session - this will autolog them in
        sess.username = username;
        res.send('registered!');
    });
});


/**
 * POST /login
 * Log a user in!
**/
router.post('/login', function(req, res) {
    var username = req.body.username;
    var password = req.body.password;

    // Check login info
    var userQuery = Users.findOne({username: username}).exec();

    userQuery.then(function(user) {
        var hash = bcrypt.hashSync(password, secrets.passwordSeed);
        // Set session if passwords match
        if (hash == user.password) {
            req.session.username = username;
            res.send("Logged in!");
        }
    });
});


/**
 * GET /connectStripe
 * Redirects to OAuth page for a stripe account
 * Should check if the user is logged in first
**/
router.get('/connectStripe', function(req, res) {
    // If they're not logged in, send a 403 forbidden
    if (!req.session.username) {
        res.sendStatus(403);
    }
    else {
        // Redirect user so they can connect their stripe account
        // We may just want to send back the url and have the app redirect in its own way.
        res.redirect('https://connect.stripe.com/oauth/authorize?response_type=code&client_id=' + secrets.stripeClientKey + '&scope=read_write');
    }
});


/**
 * GET /stripeConfirmation
 * Page the user is taken to after connecting their stripe account
 * Gets their client id and ties it to their account
**/
router.get('/stripeConfirmation', function(req, res) {
    if (req.query.error) {
        var errorDescription = req.query.error_description;
        res.send(errorDescription);
    }
    else if (req.query.code) {
        var stripeCode = req.query.code;
        var sess = req.session;

        // Store user code
        Users.findOneAndUpdate({
            username: sess.username
        }, {
            $set: {
                stripeCode: stripeCode
            }
        }, function(err) {
            helpers.logError(err);
            res.send('Account connected!');
        });
    }
});

module.exports = router;
