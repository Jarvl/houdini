module.exports = {

  db: process.env.MONGOLAB_URI || process.env.MONGODB || 'mongodb://localhost:27017/houdini',

  //sessionSecret: process.env.SESSION_SECRET || 'mySeed',

  // bcrypt password seed
  //passwordSeed: 'mySeed'

  stripeApiKey: 'api_key',
  stripeClientKey: 'client_key',

  // apn key passphrase
  apnPass: "myPassphrase"
};
