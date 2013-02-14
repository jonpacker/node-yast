yast = require './yast'
require 'date-utils'
require 'colors'
_ = require 'underscore'

toTimestamp = (date) -> Math.floor(date.valueOf() / 1000)

weekStart = (date = Date.today()) ->
  date.add days: -1 while date.getDay()
  date


yast.analytics =
  timeSpentInPeriod: (user, from, to, callback) ->
    yast.records user, {
      timeFrom: toTimestamp(from)
      timeTo: toTimestamp(to)
    }, (err, records) ->
      return callback(err) if err
      sum = (previous, current) ->
        previous + (current.finish - current.start)
      isBillable = (record) -> record.billable
      seconds = records.reduce sum, 0
      billableSeconds = _.select(records, isBillable).reduce(sum, 0)
      callback(null, seconds, billableSeconds)

  timeSpentInWeek: (user, date, callback) ->
    from = weekStart new Date date.valueOf()
    to = weekStart date.add days: 7

    yast.analytics.timeSpentInPeriod(user, from, to, callback)
  
