require 'date-utils'
require 'colors'
_ = require 'underscore'

module.exports = (yast) ->
  yanalytics =
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

      yanalytics.analyticsInPeriod user, from, to, analytics, (err, results) ->
        return callback(err) if err
        callback(null, results.seconds, results.billableSeconds)

    timeSpentInWeek: (user, date, callback) ->
      from = yanalytics.startOfWeek new Date date.valueOf()
      to = yanalytics.startOfWeek date.add days: 7

      yanalytics.timeSpentInPeriod(user, from, to, callback)

    analyticsInPeriod: (user, from, to, analytics, callback) ->
      yanalytics.analyticsForRecordQuery user, {
        timeFrom: yanalytics.ts(from)
        timeTo: yanalytics.ts(to)
      }, analytics, callback

    analyticsForProjectInPeriod: (user, prj, from, to, analytics, callback) ->
      yanalytics.analyticsForRecordQuery user, {
        timeFrom: yanalytics.ts(from),
        timeTo: yanalytics.ts(to),
        projectId: prj
      }, analytics, callback

    analyticsForRecordQuery: (user, query, analytics, callback) ->
      yast.records user, query, (err, records) ->
        return callback(err) if err
        callback(null, yanalytics.analyticsForRecords(records, analytics))

    analyticsForRecords: (records, analytics) ->
      results = {}
      for key, analytic of analytics
        results[key] = analytic(records)
      return results
