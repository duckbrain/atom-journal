AtomJournalView = require './atom-journal-view'
{CompositeDisposable} = require 'atom'

module.exports = AtomJournal =
  atomJournalView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @atomJournalView = new AtomJournalView state.viewState
    @atomJournalView.setDate new Date
    @atomJournalView.setOnDateChange (date)=> @openEntry date, {}
    atom.config.observe "journal.notebooks", (notebooks)=>
      if !notebooks
        throw new Error "You must configure your notebooks in atom.cson"
      @atomJournalView.setNotebooks notebooks
    @modalPanel = atom.workspace.addTopPanel(
      item: @atomJournalView.getElement()
      visible: false
    )

    # Events subscribed to in atom's system can be easily cleaned up with a this
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace',
      'atom-journal:toggle': => @toggle()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @atomJournalView.destroy()

  serialize: ->
    viewState: @atomJournalView.serialize()

  openEntry: (date, notebook)->
    filename = 'journal-' + date.format('YYYY-MM-DD') + '.md'
    atom.workspace.open filename, pending: true

  toggle: ->
    console.log 'AtomJournal was toggled!'

    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()
