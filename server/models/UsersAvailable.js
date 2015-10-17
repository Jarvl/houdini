var mongoose = require('mongoose')
    , Schema = mongoose.Schema;
var random = require('mongoose-simple-random');

var usersAvailableSchema = new Schema({
    sessionId: String,
    phoneNumber: String,
    firstName: String
}, { collections: 'usersAvailable' });

// Set random plugin
usersAvailableSchema.plugin(random);

var UsersAvailable = mongoose.model('usersAvailable', usersAvailableSchema);
module.exports = UsersAvailable;
