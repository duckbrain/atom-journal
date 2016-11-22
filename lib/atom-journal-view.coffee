AtomJournalCalendarView = require './atom-journal-calendar-view'
AtomJournalToolbarView = require './atom-journal-toolbar-view'

module.exports = class AtomJournalView
  constructor: (state) ->
    calendarState = state && state.calendar || null
    @calendar = new AtomJournalCalendarView calendarState
    @toolbar = new AtomJournalToolbarView
    @notebookList = new AtomJournalToolbarView

    @base = document.createElement 'div'
    toolarea = document.createElement 'div'
    toolarea.classList.add 'atom-journal-toolarea'

    @toolbar.addButton {name: 'Today'}, ()=>@setDate new Date
    @toolbar.addButton {name: 'Template'}, ()=>@onTemplateClick @getNotebook()

    toolarea.appendChild @toolbar.getElement()
    toolarea.appendChild @notebookList.getElement()
    @base.appendChild @calendar.getElement()
    @base.appendChild toolarea

  # Returns an object that can be retrieved when package is activated
  serialize: -> calendar: @calendar.serialize()

  # Tear down any state and detach
  destroy: -> @base.remove()

  getElement: -> @base

  getDate: -> @calendar.getDate()
  setDate: (date) -> @calendar.setDate date

  setNotebooks: (notebooks)->
    @notebookList.clear()
    for name, notebook of notebooks
      first = notebook if !first
      @notebookList.addButton notebook, (e, notebook)=>@setNotebook notebook
    @notebooks = notebooks
    @setNotebook(first) if first

  getNotebook: -> @notebook
  setNotebook: (notebook)->
    @notebookList.setSelected notebook
    @notebook = notebook
    @onNotebookChange notebook if @onNotebookChange

  setOnNotebookChange: (cb)-> @onNotebookChange = cb
  setOnDateChange: (cb)-> @calendar.setOnDateChange cb
  setOnTemplateClick: (cb)-> @onTemplateClick = cb
  setOverlay: (overlay)-> @calendar.setOverlay overlay
