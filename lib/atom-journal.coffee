AtomJournalView = require './atom-journal-view'
{CompositeDisposable} = require 'atom'

module.exports = AtomJournal =
  atomJournalView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @atomJournalView = new AtomJournalView(state.atomJournalViewState)
    @atomJournalView.setDate(new Date())
    @atomJournalView.setOnDateChange(@onDateChange)
    atom.config.observe("journal.notebooks", (notebooks)=>
      if !notebooks
        throw Error("You must configure your notebooks in atom.cson")
      @atomJournalView.setNotebooks(notebooks))
    @modalPanel = atom.workspace.addTopPanel(item: @atomJournalView.getElement(), visible: false)

    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable

    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', 'atom-journal:toggle': => @toggle()

  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @atomJournalView.destroy()

  serialize: ->
    atomJournalViewState: @atomJournalView.serialize()

  onDateChange: (date)=>
    @open(date, {})

  open: (date, notebook)->
    atom.workspace.open('journal-' + date.format('YYYY-MM-DD') + '.md', pending: true)

  toggle: ->
    console.log 'AtomJournal was toggled!'

    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()
