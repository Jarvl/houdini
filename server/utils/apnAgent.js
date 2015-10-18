var join = require('path').join
var pfx = join(__dirname, '../config/pfx.p12');


// Create a new agent
var apnagent = require('apnagent')
var agent = module.exports = new apnagent.Agent();

// Set our credentials
agent.set('pfx file', pfx);
// Set the passphrase
agent.set('passphrase', secrets.apnPass);
// our credentials were for development
agent.enable('sandbox');

agent.connect(function (err) {
  // gracefully handle auth problems
  if (err && err.name === 'GatewayAuthorizationError') {
    console.log('Authentication Error: ' + err.message);
    process.exit(1);
  }

  // handle any other err (not likely)
  else if (err) {
    throw err;
  }

  // it worked!
  var env = agent.enabled('sandbox')
    ? 'sandbox'
    : 'production';

  console.log('apnagent [%s] gateway connected', env);
});
