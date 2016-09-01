fs = require "fs"
AtomJournalView = require './atom-journal-view'
{CompositeDisposable} = require 'atom'
Notebook = require './notebook'
Mustache = require 'mustache'

module.exports = AtomJournal =
  view: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @view = new AtomJournalView state.viewState
    @view.setOnDateChange (date)=> @onDateChange date
    @view.setOnNotebookChange (notebook)=> @onNotebookChange notebook
    @view.setOnTemplateClick (notebook)=> @onTemplateClick notebook
    atom.config.observe "journal.notebooks", (notebooks)=>
      if !notebooks
        throw new Error "You must configure your notebooks in atom.cson"
      @view.setNotebooks @parseNotebooks notebooks
      @view.setDate new Date
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

  onTemplateClick: (notebook)->
    templatePath = @fullTemplateFilename notebook
    atom.workspace.open(templatePath)

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
    openTemplate = -> atom.workspace.open(filename, pending: true)

    if notebook.template
      templatePath = @fullTemplateFilename notebook
      fs.readFile templatePath, 'utf-8', (err, templateCode)->
        return openTemplate() if err
        f = 'dddd D MMMM YYYY'
        data = date: date.format f
        for d in [0..6]
          date.weekday(d)
          data['date' + date.format('ddd')] = date.format(f)
        data['json'] = JSON.stringify data

        templateResult = Mustache.render templateCode.toString(), data
        fs.writeFile filename, templateResult, { flag: 'wx' }, (err)->
          return openTemplate() if err
          openTemplate().then (editor)->
            editor.onDidDestroy((callback)->
              if !editor.isModified() || editor.isEmpty()
                fs.unlink(filename, ->)
            )
    else
      return openTemplate()

  toggle: ->
    console.log 'AtomJournal was toggled!'

    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()
