AtomJournalCalendarView = require './atom-journal-calendar-view'

module.exports =
class AtomJournalView
  constructor: (serializedState) ->
    @calendar = new AtomJournalCalendarView(serializedState && serializedState.calendar || null)

    @base = document.createElement('div')
    @notebookEl = document.createElement('div')

    @notebookEl.classList.add('padded', 'btn-group')

    @base.appendChild(@calendar.getElement())
    @base.appendChild(@notebookEl)

  # Returns an object that can be retrieved when package is activated
  serialize: ->
    return calendar: @calendar.serialize()

  # Tear down any state and detach
  destroy: ->
    @base.remove()

  getElement: ->
    @base

  getDate: ->
    @calendar.getDate()

  setDate: (date) ->
    @calendar.setDate(date)

  setNotebooks: (notebooks)->
    @notebookEl.innerHTML = ''
    for name, book of notebooks
      el = document.createElement('button')
      el.classList.add('btn')
      el.textContent = name
      @notebookEl.appendChild(el)
    @notebooks = notebooks

  getNotebook: ->
    @notebook

  setNotebook: (notebook)->

  setOnNotebookChange: (cb)->
    @onNotebookChange = cb
  setOnDateChange: (cb) ->
    @calendar.setOnDateChange(cb)
