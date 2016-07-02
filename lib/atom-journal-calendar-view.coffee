moment = require 'moment'

module.exports =
class AtomJournalView
  constructor: (serializedState) ->
    # Create root element
    @element = document.createElement 'div'
    @element.classList.add 'atom-journal'

    @dates = []
    dows = ['S', 'M', 'T', 'W', 'R', 'F', 'S']

    # Create calendar element
    calendarCol = document.createElement 'div'
    controls = document.createElement 'div'
    @monthDisplay = document.createElement 'span'
    previousMonth = document.createElement 'a'
    nextMonth = document.createElement 'a'
    previousMonthIcon = document.createElement 'span'
    nextMonthIcon = document.createElement 'span'
    calendar = document.createElement 'div'
    dowsRow = document.createElement 'div'

    calendarCol.classList.add 'atom-journal-calendar-container'
    calendar.classList.add 'atom-journal-calendar'
    dowsRow.classList.add 'atom-journal-calendar-row'
    dowsRow.classList.add 'atom-journal-calendar-header'
    controls.classList.add 'atom-journal-calendar-controls'
    previousMonthIcon.classList.add 'icon', 'icon-chevron-left'
    nextMonthIcon.classList.add 'icon', 'icon-chevron-right'

    previousMonth.addEventListener 'click', @onPreviousMonthClick
    nextMonth.addEventListener 'click', @onNextMonthClick

    previousMonth.appendChild previousMonthIcon
    nextMonth.appendChild nextMonthIcon
    controls.appendChild previousMonth
    controls.appendChild @monthDisplay
    controls.appendChild nextMonth
    calendarCol.appendChild controls
    calendarCol.appendChild calendar

    for i in [0..6]
      header = document.createElement 'span'
      header.classList.add 'atom-journal-calendar-dow'
      header.textContent = dows[i]
      dowsRow.appendChild header
    calendar.appendChild dowsRow

    for i in [0..5]
      row = document.createElement 'div'
      row.classList.add 'atom-journal-calendar-row'
      for j in [0..6]
        date = document.createElement 'a'
        date.classList.add 'atom-journal-calendar-date'
        date.textContent = i * 7 + j
        @dates[i * 7 + j] = date
        date.addEventListener 'click', @onDateClick
        row.appendChild date
      calendar.appendChild row

    @element.appendChild calendarCol

    if serializedState
      @setDate moment serializedState.date
      @setMonth moment serializedState.month

  onDateClick: (e)=>
    date = moment e.target.dataset.date
    @setDate date

  onNextMonthClick: (e)=>
    c = moment @month
    c.add 1, 'month'
    @setMonth c

  onPreviousMonthClick: (e)=>
    c = moment @month
    c.add -1, 'month'
    @setMonth c

  # Returns an object that can be retrieved when package is activated
  serialize: ->
    return {
      date: @getDate()
      month: @getMonth()
    }

  # Tear down any state and detach
  destroy: ->
    @element.remove()

  getElement: ->
    @element

  getDate: ->
    moment(@date)

  setDate: (date) ->
    if @date
      c = moment([@date.year(), @date.month()])
      c.day(0)
      index = @date.diff c, 'days'
      @dates[index].classList.remove 'atom-journal-calendar-day-today'

    date = moment(date)
    @onDateChange(date) if @onDateChange

    if !@date || @date.month() != date.month() || @date.year() != date.year()
      @setMonth date
    @date = date

    c = moment [date.year(), date.month()]
    c.day(0)
    index = date.diff c, 'days'
    @dates[index].classList.add 'atom-journal-calendar-day-today'

  getMonth: ->
    @month

  setMonth: (dayInMonth) ->
    c = moment dayInMonth
    c = moment [c.year(), c.month()]
    @month = moment c
    @monthDisplay.textContent = c.format 'MMMM YYYY'
    c.day(0)

    for i in [0..41]
      date = @dates[i]
      date.textContent = c.format 'D'
      date.dataset.date = c
      out = c.month() != dayInMonth.month()
      date.classList.toggle 'atom-journal-calendar-day-different-month', out
      date.classList.remove 'atom-journal-calendar-day-today'
      c.add 1, 'day'

  setOnDateChange: (cb) ->
    @onDateChange = cb
