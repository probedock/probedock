var _ = require('underscore'),
    bodyParser = require('body-parser'),
    compress = require('compression'),
    config = require('./config'),
    cookieParser = require('cookie-parser'),
    express = require('express'),
    templateLocals = require('../lib/templateLocals'),
    favicon = require('serve-favicon'),
    fs = require('fs'),
    glob = require('glob'),
    logger = require('morgan'),
    methodOverride = require('method-override'),
    proxy = require('express-http-proxy');

module.exports = function(app, config) {

  _.extend(app.locals, templateLocals);

  app.set('views', config.root);
  app.set('view engine', 'slm');

  var backendProxy = proxy(config.backendProxyHost, {
    forwardPath: function(req, res) {
      return '/api/' + require('url').parse(req.url).path;
    }
  });

  app.use('/api', backendProxy);
  app.use('/api/*', backendProxy);

  //app.use(favicon(config.root + '/public/favicon.ico'));
  app.use(logger('dev'));
  app.use(bodyParser.json());
  app.use(bodyParser.urlencoded({
    extended: true
  }));
  app.use(cookieParser());
  app.use(compress());

  app.use('/', express.static(config.root + '/public'));
  app.use('/templates', express.static(config.root + '/public'));

  app.use(methodOverride());

  var router = express.Router();

  function serveIndex(req, res) {
    res.sendFile('index.html', { root: config.root + '/public' });
  }

  router.all('/api/*', function(req, res) {
    res.sendStatus(404);
  });

  router.get('/', serveIndex);
  router.get('/*', serveIndex);

  app.use('/', router);

  app.use(function (req, res, next) {
    var err = new Error('Not Found');
    err.status = 404;
    next(err);
  });

  if (app.get('env') === 'development') {
    app.use(function (err, req, res, next) {
      res.status(err.status || 500);
      res.render('error', {
        message: err.message,
        error: err,
        title: 'error'
      });
    });
  }

  app.use(function (err, req, res, next) {
    res.status(err.status || 500);
      res.render('error', {
        message: err.message,
        error: {},
        title: 'error'
      });
  });

};
