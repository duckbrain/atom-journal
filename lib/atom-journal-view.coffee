moment = require 'moment'

module.exports =
class AtomJournalView
  constructor: (serializedState) ->
    # Create root element
    @element = document.createElement('div')
    @element.classList.add('atom-journal')

    @days = [];
    dows = ['S', 'M', 'T', 'W', 'R', 'F', 'S']

    # Create calendar element
    calendar = document.createElement('div')
    calendar.classList.add('atom-journal-calendar')
    dowsRow = document.createElement('div')
    dowsRow.classList.add('atom-journal-calendar-row')
    dowsRow.classList.add('atom-journal-calendar-header')

    calendarCol = document.createElement('div')
    @monthDisplay = document.createElement('span')
    controls = document.createElement('div')

    controls.appendChild(@monthDisplay)
    calendarCol.appendChild(controls)
    calendarCol.appendChild(calendar)

    for i in [0..6]
      header = document.createElement('span')
      header.classList.add('atom-journal-calendar-dow')
      header.textContent = dows[i]
      dowsRow.appendChild(header)
    calendar.appendChild(dowsRow)

    for i in [0..5]
      row = document.createElement('div')
      row.classList.add('atom-journal-calendar-row')
      for j in [0..6]
        day = document.createElement('a')
        day.classList.add('atom-journal-calendar-day')
        day.textContent = i * 7 + j
        @days[i * 7 + j] = day
        row.appendChild(day)
      calendar.appendChild(row)

    @element.appendChild(calendarCol)

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @element.remove()

  getElement: ->
    @element

  getDate: ->
    @date

  setDate: (date) ->
    date = moment(date)
    @setMonth(date.month(), date.year())
    @date = date

  setMonth: (month, year) ->
    c = moment([year, month])
    @monthDisplay.textContent = c.format('MMMM YYYY')
    c.day(0)

    #alert(month + '-' + year)

    for i in [0..41]
      @days[i].textContent = c.format('D')
      @days[i].classList.toggle('atom-journal-calendar-day-different-month', c.month() != month)
      c.add(1, 'day')
