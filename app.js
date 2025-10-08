const express = require('express');
const app = express();
// The port must match the EXPOSE in the Dockerfile
const port = 3000; 

app.get('/', (req, res) => {
  // Use a version tag to easily verify the deployed version
  res.send('Hello from Node.js App - CI/CD Project!');
});

app.listen(port, () => {
  console.log(`App running and listening on port ${port}`);
});
