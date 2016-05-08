'use strict';

var Beer = require('../models/beer');

var addNewBeers = function (req, res) {
  // Create a new instance of Beer model
  var beer = new Beer();
  
  // Set some properties to it  
  beer.name = req.body.name;
  beer.type = req.body.type;
  beer.quantity = req.body.quantity;
  beer.userId = req.user._id;
  
  // Save the beer and check for errors
  beer.save(function (err) {

    if (err) {
      return res.send(err);
    }

    return res.json({ message: 'Beer added to the locker!', data: beer });
  });
};

var getBeers = function (req, res) {
  Beer.find({ userId: req.user._id }, function (err, beers) {
    if (err) {
      return res.send(err);
    }

    return res.json(beers);
  });
};

var getBeer = function (req, res) {
  // Use the Beer model to find a specific beer
  Beer.find({ userId: req.user._id, _id: req.params.beer_id }, function (err, beer) {
    if (err) {
      return res.send(err);
    }

    return res.json(beer);
  });
};

var updateBeer = function (req, res) {
  // Use the Beer model to find a specific beer
  Beer.find({ userId: req.user._id, _id: req.params.beer_id }, function (err, beer) {
    if (err) {
      return res.send(err);
    }
    
    // Update the existing the beer quantity
    beer.quantity = req.body.quantity;
    
    // save the beer and check for errors
    beer.save(function (err) {
      if (err) {
        return res.send(err);
      }

      return res.json(beer);
    });
  });
};

var removeBeer = function (req, res) {
  // Use the Beer model to find a specific beer and remove it
  Beer.remove({ userId: req.user._id, _id: req.params.beer_id }, function (err, beer) {
    if (err) {
      return res.send(err);
    }

    return res.json({ message: 'Beer removed from the locker!' });
  });
};

module.exports = {
  addNewBeers: addNewBeers,
  getBeers: getBeers,
  getBeer: getBeer,
  updateBeer: updateBeer,
  removeBeer: removeBeer
};