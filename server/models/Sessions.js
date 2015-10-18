var mongoose = require('mongoose')
    , Schema = mongoose.Schema;

var sessionsSchema = new Schema({
    session: String,
    username: String
}, { collections: 'sessions' });

var Sessions = mongoose.model('sessions', sessionsSchema);
module.exports = Sessions;
