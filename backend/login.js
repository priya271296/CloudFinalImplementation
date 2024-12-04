const mysql = require('mysql');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

// Create MySQL connection pool
const db = mysql.createPool({
  connectionLimit: 10,
  host: 'terraform-20241201234308855000000001.c700kuumy2en.us-west-1.rds.amazonaws.com',
  user: 'admin',
  password: 'strongpassword123',
  database: 'app_database',
});

exports.handler = async (event) => {
  const { httpMethod } = event;

  const headers = {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': 'http://linkedin-app.s3-website-us-west-1.amazonaws.com', // Allow all origins
    'Access-Control-Allow-Methods': 'POST, PATCH, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization',
  };

  if (httpMethod === "POST" && event.path === "/login") {
    try {
      const { email, password } = JSON.parse(event.body);

      const query = 'SELECT * FROM users WHERE email = ?';
      const user = await new Promise((resolve, reject) => {
        db.query(query, [email], async (err, results) => {
          if (err) {
            console.error('Database error:', err);
            return reject({ statusCode: 500, body: JSON.stringify({ message: 'Internal server error' }) });
          }

          if (results.length === 0) {
            return resolve({ statusCode: 400, body: JSON.stringify({ message: 'Invalid email or password' }) });
          }

          const user = results[0];
          const isPasswordValid = await bcrypt.compare(password, user.password);

          if (!isPasswordValid) {
            return resolve({ statusCode: 400, body: JSON.stringify({ message: 'Invalid email or password' }) });
          }

          const token = jwt.sign({ email: user.email }, process.env.JWT_SECRET, { expiresIn: '1h' });

          return resolve({
            statusCode: 200,
            body: JSON.stringify({ message: 'Login successful', token }),
          });
        });
      });

      return user;
    } catch (err) {
      console.error('Error during login:', err);
      return {
        statusCode: 500,
        body: JSON.stringify({ message: 'Internal server error' }),
      };
    }
  }

  return {
    statusCode: 400,
    body: JSON.stringify({ message: 'Unsupported HTTP method or path' }),
  };
};
