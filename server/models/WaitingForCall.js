var mongoose = require('mongoose')
    , Schema = mongoose.Schema;
var random = require('mongoose-simple-random');

var waitingForCallSchema = new Schema({
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
}, { collections: 'waitingForCall' });

// Set random plugin
waitingForCallSchema.plugin(random);

var WaitingForCall = mongoose.model('waitingForCall', waitingForCallSchema);
module.exports = WaitingForCall;
