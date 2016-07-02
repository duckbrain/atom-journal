AtomJournalCalendarView = require './atom-journal-calendar-view'

module.exports =
class AtomJournalView
  constructor: (state) ->
    calendarState = state && state.calendar || null
    @calendar = new AtomJournalCalendarView calendarState

    @base = document.createElement 'div'
    toolbar = document.createElement 'div'
    @notebookList = document.createElement 'div'
    todayButton = document.createElement 'button'

    @notebookList.classList.add 'padded', 'btn-group'
    toolbar.classList.add 'padded', 'btn-group'
    todayButton.classList.add 'btn'
    todayButton.textContent = 'Today'

    todayButton.addEventListener 'click', ()=>@setDate new Date

    @base.appendChild @calendar.getElement()
    @base.appendChild toolbar
    toolbar.appendChild todayButton
    @base.appendChild @notebookList

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
    @calendar.setDate date

  setNotebooks: (notebooks)->
    @notebookList.innerHTML = ''
    for name, book of notebooks
      el = document.createElement 'button'
      el.classList.add 'btn'
      el.textContent = name
      @notebookList.appendChild el
    @notebooks = notebooks

  getNotebook: ->
    @notebook

  setNotebook: (notebook)->

  setOnNotebookChange: (cb)->
    @onNotebookChange = cb
  setOnDateChange: (cb) ->
    @calendar.setOnDateChange cb
