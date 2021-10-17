var express = require('express'),
    path = require('path'),
    favicon = require('serve-favicon'),
    logger = require('morgan'),
    cookieParser = require('cookie-parser'),
    bodyParser = require('body-parser'),
    consolidate = require("consolidate");

var app = express();

// view engine setup
app.engine('html', consolidate.handlebars);
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'html');

// uncomment after placing your favicon in /public
app.use(favicon(__dirname + '/public/favicon.ico'));
app.use(logger('dev'));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));

//get all routes from routes/routes.js
routes = require('./routes/routes.js')(app);

// error handlers
error = require('./routes/error.js')(app);
app.set('port', process.env.PORT || 3000);
var server = app.listen(app.get('port'), () => {
    console.log('Express server listening on port ' + server.address().port);
    //debug('Express server listening on port ' + server.address().port);
});

