const http = require('http');
const fs = require('fs');

const server = http.createServer(function (req, res) {
  if (req.url == '/app.js') {
    res.writeHead(200, { 'Content-Type': 'text/javascript' });
    res.end(fs.readFileSync(__dirname + '/app.js'));
  } else {
    res.writeHead(200, { 'Content-Type': 'text/html' });
    res.end(fs.readFileSync(__dirname + '/index.html'));
  }
});

server.listen(8080);
console.log('App running on http://localhost:8080');
