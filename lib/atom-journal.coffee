fs = require 'fs'
AtomJournalView = require './atom-journal-view'
{CompositeDisposable} = require 'atom'

module.exports = AtomJournal =
  view: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @view = new AtomJournalView state.viewState
    @view.setDate new Date
    @view.setOnDateChange (date)=> @onDateChange date
    @view.setOnNotebookChange (notebook)=> @onNotebookChange notebook
    atom.config.observe "journal.notebooks", (notebooks)=>
      if !notebooks
        throw new Error "You must configure your notebooks in atom.cson"
      @view.setNotebooks @parseNotebooks notebooks
    @modalPanel = atom.workspace.addTopPanel(
      item: @view.getElement()
      visible: false
    )

    # Events subscribed to in atom's system can be easily cleaned up with a this
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace',
      'atom-journal:toggle': => @toggle()

  onDateChange: (date)-> @openEntry date, @view.getNotebook()
  onNotebookChange: (notebook)->
    @view.setOverlay {
      notebook: notebook
      isAllowed: -> @notebook.isAllowed()
      isFilled: (date)=>
        filename = @fullFilename date, notebook
        new Promise (resolve)->
          fs.stat filename, (err)-> resolve(!err)
    
    @openEntry @view.getDate(), notebook

  parseNotebooks: (notebooks)->
    for name, n of notebooks
      n.name = name if !n.name
      n.folder = name if !n.folder
      n.getFileTag = (date)-> date.format('YYYY-MM-DD')
      n.isAllowed = (date)-> return true
    notebooks

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @view.destroy()

  serialize: ->
    viewState: @view.serialize()

  fullFilename: (date, n)->
    f = atom.config.get 'journal.baseDir'
    f += '/' + n.folder + '/' + n.folder + '-' + n.getFileTag(date) + '.md'

  openEntry: (date, notebook)->
    return if !notebook || !date
    filename = @fullFilename date, notebook
    atom.workspace.open filename, pending: true

  toggle: ->
    console.log 'AtomJournal was toggled!'

    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()
