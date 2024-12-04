// Utility function to get the token from localStorage
function getToken() {
    const token = localStorage.getItem('token');
    if (!token) {
        alert('Please login to continue');
        window.location.href = './login.html'; // Redirect to login if no token
    }
    return token;
}

// Handle login form submission
const loginForm = document.getElementById('loginForm');
if (loginForm) {
    loginForm.addEventListener('submit', function (event) {
        event.preventDefault(); // Prevent the form from submitting normally

        const email = document.getElementById('email').value;
        const password = document.getElementById('password').value;

        console.log("Login Attempted with email:", email); // Debug log

        // Send login request
        fetch('https://8ykfzzmh46.execute-api.us-west-1.amazonaws.com/test/login', { // Updated URL
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ email, password }),
            mode: 'cors'
        })
            .then(response => {
                console.log("Response Status:", response.status); // Debug log for status
                if (!response.ok) {
                    throw new Error('Failed to login: ' + response.statusText);
                }
                return response.json(); // Parse the JSON response
            })
            .then(data => {
                console.log("Login Response Data:", data); // Debug log for the response data
                if (data.token) {
                    alert(data.message || 'Login successful!');
                    localStorage.setItem('token', data.token);
                    document.getElementById('loginStatus').style.display = 'block';
                    // Redirect to the dashboard after success
                    setTimeout(() => {
                        window.location.href = './dashboard.html'; // Adjust path if needed
                    }, 1500); // 1.5 seconds delay
                } else {
                    alert('Invalid email or password');
                }
            })
            .catch(error => {
                console.error('Error:', error); // Log any errors in the network request
                alert('An error occurred: ' + error.message);
            });
    });
}

//Handle registration form submission
const registerForm = document.getElementById('registerForm');
if (registerForm) {
    registerForm.addEventListener('submit', function (event) {
        event.preventDefault(); // Prevent the form from submitting normally

        const email = document.getElementById('email').value;
        const password = document.getElementById('password').value;

        console.log("Registration Attempted with email:", email); // Debug log

        // Send registration request
        fetch('https://8ykfzzmh46.execute-api.us-west-1.amazonaws.com/test/register', { // Updated URL
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ email, password })
        })
            .then(response => response.json())
            .then(data => {
                console.log("Registration Response:", data); // Debug log
                alert(data.message || 'Registration successful');
            })
            .catch(error => {
                console.error('Error:', error); // Log any errors in the network request
                alert('An error occurred during registration: ' + error.message);
            });
    });
}

// // Fetch user profile using token from localStorage
// function getProfile() {
//     const token = getToken();

//     fetch('https://lgk5vhgc96.execute-api.us-west-1.amazonaws.com/test/profile', { // Updated URL
//         method: 'GET',
//         headers: {
//             'Authorization': `Bearer ${token}` // Send token as authorization header
//         }
//     })
//         .then(response => {
//             if (!response.ok) {
//                 throw new Error('Failed to fetch profile: ' + response.statusText);
//             }
//             return response.json();
//         })
//         .then(data => {
//             console.log('User Profile:', data); // Debug log for user profile
//             // Display user profile or other dashboard content
//         })
//         .catch(error => {
//             console.error('Error:', error);
//             alert('Failed to fetch profile');
//         });
// }

// Check if the user is logged in on page load
window.onload = function () {
    const token = localStorage.getItem('token');
    if (token) {
        getProfile(); // Fetch user profile if token is found
    }
};

// Logout functionality
const logoutButton = document.getElementById('logoutBtn');
if (logoutButton) {
    logoutButton.addEventListener('click', function () {
        // Remove the token from localStorage on logout
        localStorage.removeItem('token');
        alert('You have been logged out');
        window.location.href = './login.html'; // Redirect to login page
    });
}
