const http = require('http'), os = require('os');
http.createServer((req, res) => {
  res.end(`Hallo van Node! user=${os.userInfo().username} host=${os.hostname()}\n`);
}).listen(3000, () => console.log('luistert op 3000'));
