module.exports = {

  db: process.env.MONGOLAB_URI || process.env.MONGODB || 'mongodb://localhost:27017/houdini'

  //sessionSecret: process.env.SESSION_SECRET || 'f29b78a386a8a0b9fb2868c4fcf95a41343a0175865c591cbca910a48524dde9',

  // bcrypt password seed
  //passwordSeed: '$2a$10$gHwYF/h8hADr5p1PPQPNfO'
};
