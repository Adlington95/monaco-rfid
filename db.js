const { Pool } = require('pg');
const pool = new Pool({
  host: 'db',
  port: 5432,
  user: 'marc',
  password: 'marcpwd',
  database: 'marcdb'
});

module.exports = pool;