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

  if (httpMethod === "POST" && event.path === "/register") {
    try {
      const { email, password } = JSON.parse(event.body);

      // Check if the email already exists
      const checkQuery = 'SELECT * FROM users WHERE email = ?';
      const existingUser = await new Promise((resolve, reject) => {
        db.query(checkQuery, [email], (err, results) => {
          if (err) {
            console.error('Database error:', err);
            return reject({
              statusCode: 500,
              body: JSON.stringify({ message: 'Internal server error' }),
            });
          }
          resolve(results);
        });
      });

      if (existingUser.length > 0) {
        return {
          statusCode: 400,
          body: JSON.stringify({ message: 'Email already exists' }),
        };
      }

      // Hash the password
      const hashedPassword = await bcrypt.hash(password, 10);

      // Insert the new user into the database
      const insertQuery = 'INSERT INTO users (email, password) VALUES (?, ?)';
      await new Promise((resolve, reject) => {
        db.query(insertQuery, [email, hashedPassword], (err, results) => {
          if (err) {
            console.error('Error inserting user:', err);
            return reject({
              statusCode: 500,
              body: JSON.stringify({ message: 'Internal server error' }),
            });
          }
          resolve(results);
        });
      });

      // Generate JWT token
      const token = jwt.sign({ email: email }, process.env.JWT_SECRET, { expiresIn: '1h' });

      return {
        statusCode: 201,
        body: JSON.stringify({ message: 'Registration successful', token }),
      };
    } catch (err) {
      console.error('Error during registration:', err);
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
