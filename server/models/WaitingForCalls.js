var mongoose = require('mongoose')
    , Schema = mongoose.Schema;
var random = require('mongoose-simple-random');

var waitingForCallsSchema = new Schema({
    sessionId: String,
    phoneNumber: String,
    usernameRequesting: String,
    // usernameResponding is populated after the user accepts a call request
    usernameResponding: {
        type: String,
        default: ''
    },
    called: {
        type: Boolean,
        default: false
    },
    usersContacted: [{ username: String }]
}, { collections: 'waitingforcalls' });

// Set random plugin
waitingForCallsSchema.plugin(random);

waitingForCalls.save(function(err, wfc) {
    console.log(wfc);
/*
    // If this is
    if (!wfc.called) {
        var timeout = setTimeout(function() {

        }, 1500);
    }*/
});

var WaitingForCalls = mongoose.model('waitingForCalls', waitingForCallsSchema);
module.exports = WaitingForCalls;
