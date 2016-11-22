module.exports = class AtomJournalToolbarView
  constructor: (state) ->
    @base = document.createElement 'div'
    @items = []
    @selected = null
    @base.classList.add 'padded', 'btn-group', 'block'
    @base.classList.add state.class if state && state.class

  addButton: (item, action)->
    btn = document.createElement 'button'
    btn.classList.add 'btn'
    btn.textContent = item.name
    btn.addEventListener 'click', (e)-> action e, item
    @base.appendChild btn
    @items.push item

  clear: ()->
    @base.innerHTML = ''
    @items = []
    @selected = null

  getSelected: ()-> @selected

  setSelected: (item)->
    @base.querySelector('.selected').classList.remove 'selected' if @selected
    index = @items.findIndex((a)=>a == item || a.name == item.name)
    throw new Error 'Attempt to select item not found in list.' if index == -1
    @base.children[index].classList.add 'selected'
    @selected = item

  destroy: -> @base.remove()
  getElement: -> @base
