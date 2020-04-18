const express = require('express');
const http = require('http')
const app = express();
const path = require('path');
const route = require('./routes/sendalert');



var port = normalizePort(process.env.PORT || '3000');
app.set('port', port);

// for body parser. to collect data that sent from the client.
app.use(express.urlencoded( { extended : false}));


// Serve static files. CSS, Images, JS files ... etc
app.use(express.static(path.join(__dirname, 'public')));


var server = http.createServer(app);

server.listen(port);

app.use('/',route)

function normalizePort(val) {
    var port = parseInt(val, 10);
  
    if (isNaN(port)) {
      // named pipe
      return val;
    }
  
    if (port >= 0) {
      // port number
      return port;
    }
  
    return false;
  }