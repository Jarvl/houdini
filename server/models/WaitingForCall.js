var mongoose = require('mongoose')
    , Schema = mongoose.Schema;
var random = require('mongoose-simple-random');

var waitingForCallSchema = new Schema({
    sessionId: String,
    phoneNumber: String,
    called: {
        type: Boolean,
        default: false
    }
}, { collections: 'waitingForCall' });

// Set random plugin
waitingForCallSchema.plugin(random);

var WaitingForCall = mongoose.model('waitingForCall', waitingForCallSchema);
module.exports = WaitingForCall;
