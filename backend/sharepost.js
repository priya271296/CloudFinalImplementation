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

  if (httpMethod === "POST" && event.path === "/sharePost") {
    try {
      const { userEmail, content } = JSON.parse(event.body);

      if (!userEmail || !content) {
        return {
          statusCode: 400,
          headers,
          body: JSON.stringify({ message: "Missing required fields: userEmail or content" }),
        };
      }

      // Check if user exists in the database
      const user = await getUserByEmail(userEmail);

      if (!user) {
        return {
          statusCode: 404,
          headers,
          body: JSON.stringify({ message: "User not found" }),
        };
      }

      // Insert the post into the database
      const result = await new Promise((resolve, reject) => {
        const query = 'INSERT INTO posts (user_id, content, created_at) VALUES (?, ?, NOW())';
        db.query(query, [user.id, content], (err, results) => {
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
        body: JSON.stringify({ message: "Post shared successfully", postId: result.insertId }),
      };
    } catch (err) {
      console.error('Error sharing post:', err);
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
