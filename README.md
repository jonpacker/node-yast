This is a wrapper around the Yast API written in CoffeeScript. It is not complete as yet. Functionality is implemented as I need it.

**This is an extremely immature project. There's no package.json, it's not listed in NPM. Integration is up to you.**

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