AtomJournalCalendarView = require './atom-journal-calendar-view'

module.exports =
class AtomJournalView
  constructor: (serializedState) ->
    @calendar = new AtomJournalCalendarView(serializedState)

    @base = document.createElement('div')
    @base.appendChild(@calendar.getElement())

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @base.remove()

  getElement: ->
    @base

  getDate: ->
    @calendar.getDate()

  setDate: (date) ->
    @calendar.setDate(date)

  setOnDateChange: (cb) ->
    @calendar.setOnDateChange(cb)
