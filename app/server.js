'use strict';

var express = require('express');
var mongoose = require('mongoose');
var passport = require('passport');
var bodyParser = require('body-parser');
var beerController = require('./controllers/beer');
var userController = require('./controllers/user');
var authController = require('./controllers/auth');

var port = process.env.PORT || 3000;
var router = express.Router();

// Create our Express application
var app = express();

// Use the passport package in our application
app.use(passport.initialize());

// Use the body-parser package in our application
app.use(bodyParser.urlencoded({
  extended: true
}));

//mongoose.connect('mongodb://mongo-beers-api:27017/beerlocker');
mongoose.connect('mongodb://localhost:27017/beerlocker');

//Initial dummmy route for testing
router.get('/', function (req, res) {
  res.json({ message: 'You are running down on beer !' })
});

//creating the beers base route
var beersRoute = router.route('/beers');
var singleBeerRoute = router.route('/beers/:beer_id');

//create endpoint /api/beers for POSTS
beersRoute.post(authController.isAuthenticated,beerController.addNewBeers);

//create endpoint /api/beers for GET
beersRoute.get(authController.isAuthenticated,beerController.getBeers);

// Get a single beer /api/beers/:beer_id for GET
singleBeerRoute.get(authController.isAuthenticated,beerController.getBeer);

// Update a single beer /api/beers/:beer_id for PUT
singleBeerRoute.put(authController.isAuthenticated,beerController.updateBeer);

// Delete a single beer /api/beers/:beer_id for DELETE
singleBeerRoute.delete(authController.isAuthenticated,beerController.removeBeer);

// ************** Creating the routing for the users **************
var usersRoute = router.route('/users');
usersRoute.post(userController.createNewUsers);
usersRoute.get(authController.isAuthenticated,userController.getUsers);

// Register all our routes with /api
app.use('/api', router);

app.listen(port);
console.log('Insert beer on port' + port);
