AtomJournalCalendarView = require './atom-journal-calendar-view'

module.exports = class AtomJournalView
  constructor: (state) ->
    calendarState = state && state.calendar || null
    @calendar = new AtomJournalCalendarView calendarState

    @base = document.createElement 'div'
    toolarea = document.createElement 'div'
    toolbar = document.createElement 'div'
    @notebookList = document.createElement 'div'
    todayButton = document.createElement 'button'
    templateButton = document.createElement 'button'

    @notebookList.classList.add 'padded', 'btn-group', 'block'
    toolbar.classList.add 'padded', 'btn-group', 'block'
    toolarea.classList.add 'atom-journal-toolarea'
    todayButton.classList.add 'btn'
    templateButton.classList.add 'btn'
    todayButton.textContent = 'Today'
    templateButton.textContent = 'Template'

    todayButton.addEventListener 'click', ()=>@setDate new Date
    templateButton.addEventListener 'click', ()=>@onTemplateClick @getNotebook()


    toolbar.appendChild todayButton
    toolbar.appendChild templateButton
    toolarea.appendChild toolbar
    toolarea.appendChild @notebookList
    @base.appendChild @calendar.getElement()
    @base.appendChild toolarea

  onNotebookClick: (e)-> @setNotebook e.target.dataset.notebook

  # Returns an object that can be retrieved when package is activated
  serialize: -> calendar: @calendar.serialize()

  # Tear down any state and detach
  destroy: -> @base.remove()

  getElement: -> @base

  getDate: -> @calendar.getDate()
  setDate: (date) -> @calendar.setDate date

  setNotebooks: (notebooks)->
    @notebookList.innerHTML = ''
    for name, notebook of notebooks
      first = notebook if !first
      el = document.createElement 'button'
      el.classList.add 'btn'
      el.textContent = name
      el.dataset.notebook = name
      notebook.element = el
      el.addEventListener 'click', (e)=>@onNotebookClick e
      @notebookList.appendChild el
    @notebooks = notebooks
    @setNotebook(first) if first

  getNotebook: -> @notebook
  setNotebook: (notebook)->
    notebook = @notebooks[notebook] if typeof notebook != 'object'
    @notebook.element.classList.remove 'selected' if @notebook
    notebook.element.classList.add 'selected'
    @notebook = notebook
    @onNotebookChange notebook if @onNotebookChange

  setOnNotebookChange: (cb)-> @onNotebookChange = cb
  setOnDateChange: (cb)-> @calendar.setOnDateChange cb
  setOnTemplateClick: (cb)-> @onTemplateClick = cb
  setOverlay: (overlay)-> @calendar.setOverlay overlay
