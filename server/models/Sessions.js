var mongoose = require('mongoose')
    , Schema = mongoose.Schema;
var random = require('mongoose-simple-random');

var sessionsSchema = new Schema({
    sessionId: String,
    phoneNumber: String,
    called: {
        type: Boolean,
        default: false
    }
}, { collections: 'sessions' });

// Set random plugin
sessionsSchema.plugin(random);

var Sessions = mongoose.model('sessions', sessionsSchema);
module.exports = Sessions;
