const express = require('express');


const PORT = 3000;
const HOST ='localhost'
const app = express();

app.use(express.static(__dirname + '/public'));

app.listen(PORT);
console.log(`Running on http://${HOST}:${PORT}`);
