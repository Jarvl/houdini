module.exports = {

  db: process.env.MONGOLAB_URI || process.env.MONGODB || 'mongodb://localhost:27017/houdini',

  sessionSecret: process.env.SESSION_SECRET || 'CFH4IzHAfn4MziteME7kO4Slavq31o9r1Q647Apripk44e9TZNxoWpX38xUv1Q0N',

  // bcrypt password seed
  passwordSeed: '$2a$10$MEoqtT2UfEKFrLPeudvJ1e',

  stripeApiKey: 'sk_test_2lThadjYTX9nnispMbveUsXU',
  stripeClientKey: 'ca_7BMfR0MUAsxYkvsnBKp6jVYWlZdK5C2n',

  // apn key passphrase
  apnPass: "dickbutt69"
};
