A wrapper around the Yast API, targeted at analytics. As such, only part of the
API is covered: mutating functions are excluded.

## Install

```
npm install yast
```

## Usage example:

```javascript
var yast = require('yast');

yast.login('<yast username>', '<yast password>', function(err, user) {
	if (err) {
		return console.log(err);
	}

	yast.folders(user, function(err, folders) {
		console.log(err, folders);
    // a list of your folders
	})
})
```

## Core functions

* yast.login(user, password, callback) -> (err, userObject)
* yast.folders(user, callback) -> (err, foldersArray)
* yast.projects(user, callback) -> (err, projectsArray)
* yast.records(user, params, callback) -> (err, recordsArray) — see the
  [yast API docs](http://www.yast.com/wiki/index.php/API:data.getRecords) for
  valid params
* yast.user(user, callback) -> (err, userInfo)
* yast.projectTree(user, callback) -> (err, projectTree)

## Multiple Login

Since yast doesn't provide any ability to request records for an entire
organization, some primitive multi-user support is available. To use it, supply
an array of users to yast.login. For example:

```yast.login([{ user: 'username1',
                 password: 'password1' },
               { user: 'username2',
                 password: 'password2' }], callback);
```

This will return an array of the hashes for these users. If you then supply this
array to the API functions (excluding 'yast.user'), you will be return an array
of results (one for each user) rather than a single set of results. 

## Analytics functions

Note: when an `analytics` object is required for any of these functions, it
is expected to be an object containing functions which perform an operation on 
an array of records and return a single value. The returned result will be the
the result of these functions being executed upon the requested record set. An 
example might be:

```javascript
var analytics = {
  billableSeconds: function(records) {
    return records.reduce(function(sum, record) {
      return sum + (record.billable ? record.finish - record.start : 0);
    }, 0);
  }
}
```

Which would return an object such as this:

```javascript
{ billableSeconds: 5900 }
```

* yast.analytics.ts(date) -> timestamp
* yast.analytics.startOfWeek(date) -> date object of start of week containing
  `date`
* yast.analytics.timeSpentInPeriod(user, from, to, callback) -> (err, seconds,
  billableSeconds)
* yast.analytics.timeSpentInWeek(user, dateInWeek, callback) -> (err, seconds,
  billableSeconds)
* yast.analytics.analyticsInPeriod(user, from, to, analytics, callback) -> (err,
  analyticsResult)
* yast.analytics.analyticsForProjectInPeriod(user, projectId, from, to,
  analytics, callback) -> (err, analyticsResult)
* yast.analytics.analyticsForRecordQuery(user, params, analytics, callback) ->
  (err, analyticsResult) — see the
  [yast API docs](http://www.yast.com/wiki/index.php/API:data.getRecords) for
  valid params
* yast.analytics.analyticsForRecords(records, analytics) -> analyticsResult

## License

MIT

**This project is sponsored by [BRIK Teknologier AS](http://www.brik.no)**
