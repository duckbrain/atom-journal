fs = require 'fs'
AtomJournalView = require './atom-journal-view'
{CompositeDisposable} = require 'atom'
Notebook = require './notebook'
Handlebars = require 'handlebars'

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
      isAllowed: (date)-> @notebook.isAllowed(date)
      isFilled: (date)=>
        filename = @fullFilename date, notebook
        new Promise (resolve)->
          fs.stat filename, (err)-> resolve(!err)
    }
    @openEntry @view.getDate(), notebook

  parseNotebooks: (notebooks)->
    for name, n of notebooks
      notebooks[name] = new Notebook n, name
    notebooks

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @view.destroy()

  serialize: ->
    viewState: @view.serialize()

  fullFilename: (date, n)->
    # TODO: Use node.js path library instead of string concatination
    f = atom.config.get 'journal.baseDir'
    f += '/' + n.folder + '/' + n.folder + '-' + n.getFileTag(date) + '.md'

  fullTemplateFilename: (n)->
    if n.template
      atom.config.get('journal.baseDir') + '/' + n.folder + '/' + n.template
    else null

  openEntry: (date, notebook)->
    return if !notebook || !date
    filename = @fullFilename date, notebook
    p = atom.workspace.open(filename, pending: true)
    return if !notebook.template
    p.then((editor)->
      editor.insertText "Reached editor open"
      return editor if notebook.templateCompiled
      editor.insertText "Reached before read"
      fs.readFile(@fullTemplateFilename(notebook)).then (contents)->
        editor.insertText "Reached file contents"
        notebook.templateCompiled = Handlebars.compile contents
        return editor
    ).then((editor)->
      editor.insertText "Reached insert"
      editor.insertText notebook.templateCompiled date: date
    ).catch (err)-> atom.notifications.addError err

  toggle: ->
    console.log 'AtomJournal was toggled!'

    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()
