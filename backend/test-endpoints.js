const http = require('http');

function testEndpoint(path) {
  return new Promise((resolve, reject) => {
    http.get(`http://localhost:5000${path}`, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        try {
          resolve({ status: res.statusCode, body: JSON.parse(data) });
        } catch (e) {
          resolve({ status: res.statusCode, body: data });
        }
      });
    }).on('error', reject);
  });
}

async function runTests() {
  console.log('Testing GET /api/doctor/appointments/today ...');
  const appts = await testEndpoint('/api/doctor/appointments/today');
  console.log('Status:', appts.status);
  console.log('Response:', JSON.stringify(appts.body, null, 2));

  console.log('\nTesting GET /api/doctor/patients ...');
  const pts = await testEndpoint('/api/doctor/patients');
  console.log('Status:', pts.status);
  console.log('Response:', JSON.stringify(pts.body, null, 2));

  console.log('\nTesting GET /api/appointments ...');
  const allAppts = await testEndpoint('/api/appointments');
  console.log('Status:', allAppts.status);
  console.log('Response:', JSON.stringify(allAppts.body, null, 2));
}

runTests();
