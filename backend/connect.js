const mysql = require('mysql');

// MySQL connection pool
const db = mysql.createPool({
  host: 'terraform-20241201234308855000000001.c700kuumy2en.us-west-1.rds.amazonaws.com',
  user: 'admin',
  password: 'strongpassword123',
  database: 'app_database',
});

exports.handler = async (event) => {
  const { httpMethod } = event;

  const headers = {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': 'http://linkedin-app.s3-website-us-west-1.amazonaws.com',
    'Access-Control-Allow-Methods': 'POST, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization',
  };

  if (httpMethod === "POST" && event.path === "/connect") {
    try {
      const { requesterEmail, recipientEmail } = JSON.parse(event.body);

      // Get IDs of both users
      const [requester, recipient] = await Promise.all([
        getUserByEmail(requesterEmail),
        getUserByEmail(recipientEmail),
      ]);

      if (!requester || !recipient) {
        return {
          statusCode: 404,
          headers,
          body: JSON.stringify({ message: "One or both users not found" }),
        };
      }

      // Insert connection request into the database
      const result = await new Promise((resolve, reject) => {
        const query = 'INSERT INTO connections (requester_id, recipient_id) VALUES (?, ?)';
        db.query(query, [requester.id, recipient.id], (err, results) => {
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

      return {
        statusCode: 200,
        headers,
        body: JSON.stringify({ message: "Connection request sent successfully", requestId: result.insertId }),
      };
    } catch (err) {
      console.error('Error sending connection request:', err);
      return {
        statusCode: 500,
        headers,
        body: JSON.stringify({ message: 'Internal server error' }),
      };
    }
  }

  return {
    statusCode: 400,
    headers,
    body: JSON.stringify({ message: 'Unsupported HTTP method or path' }),
  };
};

// Helper function to get user by email
const getUserByEmail = (email) => {
  return new Promise((resolve, reject) => {
    const query = 'SELECT id FROM users WHERE email = ?';
    db.query(query, [email], (err, results) => {
      if (err) {
        console.error('Database error:', err);
        return reject(null);
      }
      resolve(results.length ? results[0] : null);
    });
  });
};
