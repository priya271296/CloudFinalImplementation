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
    const { httpMethod, path } = event;
  
    const headers = {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': 'http://linkedin-app.s3-website-us-west-1.amazonaws.com',
      'Access-Control-Allow-Methods': 'POST, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization',
    };
  
    if (httpMethod === "DELETE" && path === "/deletePost") {
      try {
        const { postId, userEmail } = JSON.parse(event.body);
  
        if (!postId || !userEmail) {
          return {
            statusCode: 400,
            headers,
            body: JSON.stringify({ message: "Missing required fields: postId or userEmail" }),
          };
        }
  
        // Get the user ID from the email
        const user = await getUserByEmail(userEmail);
  
        if (!user) {
          return {
            statusCode: 404,
            headers,
            body: JSON.stringify({ message: "User not found" }),
          };
        }
  
        // Verify if the post belongs to the user
        const post = await getPostById(postId);
  
        if (!post) {
          return {
            statusCode: 404,
            headers,
            body: JSON.stringify({ message: "Post not found" }),
          };
        }
  
        if (post.user_id !== user.id) {
          return {
            statusCode: 403,
            headers,
            body: JSON.stringify({ message: "Unauthorized to delete this post" }),
          };
        }
  
        // Delete the post
        const result = await new Promise((resolve, reject) => {
          const query = 'DELETE FROM posts WHERE id = ?';
          db.query(query, [postId], (err, results) => {
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
          body: JSON.stringify({ message: "Post deleted successfully" }),
        };
      } catch (err) {
        console.error('Error deleting post:', err);
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
  
  // Helper function to get post by ID
  const getPostById = (postId) => {
    return new Promise((resolve, reject) => {
      const query = 'SELECT id, user_id FROM posts WHERE id = ?';
      db.query(query, [postId], (err, results) => {
        if (err) {
          console.error('Database error:', err);
          return reject(null);
        }
        resolve(results.length ? results[0] : null);
      });
    });
  };
  