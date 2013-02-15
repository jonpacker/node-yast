yast = require './yast'
require 'date-utils'
require 'colors'
_ = require 'underscore'

yast.analytics =
  ts: (date) -> Math.floor(date.valueOf() / 1000)
  startOfWeek: (date = Date.today()) ->
    date.add days: -1 while date.getDay()
    return date

  timeSpentInPeriod: (user, from, to, callback) ->
    sumTime = (previous, current) ->
      previous + (current.finish - current.start)
    analytics =
      seconds: (records) -> records.reduce(sumTime, 0)
      billableSeconds: (records) ->
        billableRecords = (record for record in records when record.billable)
        return billableRecords.reduce(sumTime, 0)

    ya.analyticsInPeriod user, from, to, analytics, (err, results) ->
      return callback(err) if err
      callback(null, results.seconds, results.billableSeconds)

  timeSpentInWeek: (user, date, callback) ->
    from = ya.startOfWeek new Date date.valueOf()
    to = ya.startOfWeek date.add days: 7

    ya.timeSpentInPeriod(user, from, to, callback)

  analyticsInPeriod: (user, from, to, analytics, callback) ->
    ya.analyticsForRecordQuery user, {
      timeFrom: ya.ts(from)
      timeTo: ya.ts(to)
    }, analytics, callback

  analyticsForProjectInPeriod: (user, prj, from, to, analytics, callback) ->
    ya.analyticsForRecordQuery user, {
      timeFrom: ya.ts(from),
      timeTo: ya.ts(to),
      projectId: prj
    }, analytics, callback

  analyticsForRecordQuery: (user, query, analytics, callback) ->
    yast.records user, query, (err, records) ->
      return callback(err) if err
      callback(null, ya.analyticsForRecords(records, analytics))

  analyticsForRecords: (records, analytics) ->
    results = {}
    for key, analytic of analytics
      results[key] = analytic(records)
    return results

ya = yast.analytics
