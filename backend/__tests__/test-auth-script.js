const http = require('http');

const email = `testpostman${Date.now()}@example.com`;
const data = JSON.stringify({
  name: "Postman Test User",
  email: email,
  password: "password123",
  profileData: { role: "patient" }
});

const options = {
  hostname: 'localhost',
  port: 5000,
  path: '/api/register',
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Content-Length': data.length
  }
};

const req = http.request(options, res => {
  let responseData = '';
  res.on('data', chunk => { responseData += chunk; });
  res.on('end', () => {
    console.log('--- REGISTER ---');
    console.log(`Status Code: ${res.statusCode}`);
    console.log(`Body: ${responseData}`);
    
    // Now test login
    const loginData = JSON.stringify({
      email: email,
      password: "password123"
    });
    
    const loginOptions = {
      hostname: 'localhost',
      port: 5000,
      path: '/api/login',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': loginData.length
      }
    };
    
    const loginReq = http.request(loginOptions, loginRes => {
      let loginResponseData = '';
      loginRes.on('data', chunk => loginResponseData += chunk);
      loginRes.on('end', () => {
        console.log('\n--- LOGIN ---');
        console.log(`Status Code: ${loginRes.statusCode}`);
        console.log(`Body: ${loginResponseData}`);
      });
    });
    loginReq.write(loginData);
    loginReq.end();
  });
});

req.on('error', error => {
  console.error(error);
});

req.write(data);
req.end();
