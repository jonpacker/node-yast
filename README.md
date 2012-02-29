This is a wrapper around the Yast API written in CoffeeScript. It is not complete as yet. Functionality is implemented as I need it.

**This is an extremely immature project. There's not package.json, it's not listen in NPM. That's up to you, if you want to use it.**

Usage example:

CoffeeScript
```coffeescript
yast = require './yast'
yast.login '<yast username>', '<password>', (err, user) ->
  return console.log err if err
  yast.folders user, (err, folders) ->
    console.log err, folders
```

JavaScript
```javascript
require('coffee-script')
var yast = require('./yast');

yast.login('<yast username>', '<yast password>', function(err, user) {
	if (err) {
		return console.log(err);
	}

	yast.folders(user, function(err, folders) {
		console.log(err, folders);
	})
})
```