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
    }
}, { collections: 'waitingforcalls' });

// Set random plugin
waitingForCallsSchema.plugin(random);

var WaitingForCalls = mongoose.model('waitingForCalls', waitingForCallsSchema);
module.exports = WaitingForCalls;