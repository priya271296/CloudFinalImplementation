// const mysql = require('mysql');

// const connection = mysql.createConnection({
//   host     : 'terraform-20241201234308855000000001.c700kuumy2en.us-west-1.rds.amazonaws.com',
//   user     : 'admin',
//   password : 'strongpassword123',
//   database : 'app_database'
// });

// connection.connect((err) => {
//   if (err) {
//     console.error('Error connecting to the database:', err.stack);
//     return;
//   }
//   console.log('Connected to the database!');
// });

// // Test query
// connection.query('SELECT NOW()', (err, results) => {
//   if (err) {
//     console.error('Error during query:', err.stack);
//   } else {
//     console.log('Database time:', results[0]);
//   }
//   connection.end();
// });


// const mysql = require('mysql');
// const jwt = require('jsonwebtoken');
// const bcrypt = require('bcryptjs');

// const db = mysql.createPool({
//   connectionLimit: 10, // Max number of connections that can be created at once
//   host: 'terraform-20241201234308855000000001.c700kuumy2en.us-west-1.rds.amazonaws.com',
//   user: 'admin',
//   password: 'strongpassword123',
//   database: 'app_database',
// });

// exports.handler = async (event) => {
//   try {
//     const { email, password } = JSON.parse(event.body);

//     const query = 'SELECT * FROM users WHERE email = ?';
//     const response = await new Promise((resolve, reject) => {
//       db.query(query, [email], async (err, results) => {
//         if (err) {
//           console.error('Database error:', err);
//           return reject({ statusCode: 500, body: JSON.stringify({ message: 'Internal server error' }) });
//         }

//         if (results.length === 0) {
//           return resolve({ statusCode: 400, body: JSON.stringify({ message: 'Invalid email or password' }) });
//         }

//         const user = results[0];
//         const isPasswordValid = await bcrypt.compare(password, user.password);

//         if (!isPasswordValid) {
//           return resolve({ statusCode: 400, body: JSON.stringify({ message: 'Invalid email or password' }) });
//         }

//         const token = jwt.sign({ email: user.email }, 'your_secret_key', { expiresIn: '1h' });
//         return resolve({
//           statusCode: 200,
//           body: JSON.stringify({ message: 'Login successful', token }),
//         });
//       });
//     });

//     return response;
//   } catch (err) {
//     console.error('Error occurred:', err);
//     return {
//       statusCode: 500,
//       body: JSON.stringify({ message: 'Internal server error' }),
//     };
//   }
// };

// // Test event to simulate an API Gateway request
// const testEvent = {
//   body: JSON.stringify({
//     email: 'root@example.com',  // Replace with a valid email from your users table
//     password: 'root123'     // Replace with a valid password
//   })
// };

// // Invoke the handler locally with the test event
// exports.handler(testEvent).then(response => {
//   console.log('Response:', response);
// }).catch(err => {
//   console.error('Error:', err);
// });

const mysql = require('mysql');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');

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
    'Access-Control-Allow-Origin': 'http://linkedin-app.s3-website-us-west-1.amazonaws.com', // Allow all origins (or replace '*' with your specific domain)
    'Access-Control-Allow-Methods': 'POST, PATCH, OPTIONS', // Allow these methods
    'Access-Control-Allow-Headers': 'Content-Type, Authorization' // Allow these headers in the request
  };

  // Register User
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

  // Login User
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
