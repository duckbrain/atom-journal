AtomJournalView = require './atom-journal-view'
{CompositeDisposable} = require 'atom'

module.exports = AtomJournal =
  atomJournalView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    @atomJournalView = new AtomJournalView(state.atomJournalViewState)
    @atomJournalView.setDate(new Date())
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

  toggle: ->
    console.log 'AtomJournal was toggled!'

    if @modalPanel.isVisible()
      @modalPanel.hide()
    else
      @modalPanel.show()
