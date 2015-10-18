module.exports = {

    logError: function(err) {
        if (err) console.log(err);
    },

    shuffleArray: function(arrayLength) {
        var rand = Math.floor(Math.random() * arrayLength);
        return rand;
    },

    generateSID: function() {
        var chars = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXTZabcdefghiklmnopqrstuvwxyz";
        var stringLength = 32;
        var randomString = '';
        for (var i = 0; i < stringLength; i++) {
            var rnum = Math.floor(Math.random() * chars.length);
            randomString += chars.substring(rnum,rnum+1);
        }
        return randomString;
    },

    generateMessage: function(reqFirstName, resFirstName) {
        var messages = [
            reqFirstName + " is in some hot shit. You gotta help him " + resFirstName + "!",
            reqFirstName = " needs rescued, " + resFirstName + "!",
            "Get off Snapgram and do your job, " + resFirstName,
            "Hey " + resFirstName + ", do you mind giving " + reqFirstName + " a ring real quick?"
        ];
        var index = shuffleArray(messages.length);
        return messages[index];
    }
};
