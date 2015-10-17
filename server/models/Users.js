var mongoose = require('mongoose')
    , Schema = mongoose.Schema;
var random = require('mongoose-simple-random');

var usersSchema = new Schema({
    username: String,
    password: String,
    phoneNumber: String,
    firstName: String,
    lastName: String,
    stripeCode: {
        type: String,
        default: ''
    },
    available: {
        type: Boolean,
        default: false
    }
}, { collections: 'users' });

// Set random plugin
usersSchema.plugin(random);

var Users = mongoose.model('users', usersSchema);
module.exports = Users;
