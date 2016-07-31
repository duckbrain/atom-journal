module.exports =
  class Notebook
    constructor: (c, name)->
      @name = c.name || name
      @folder = c.folder || @name
      if c.weekOffset
        @weekOffset = c.weekOffset
        @getFileTag = @weekGetFileTag
        @isAllowed = @weekIsAllowed
      if c.template == true
        c.template = '.' + @name + '-template.md'
      @template = c.template if c.template
      if c.weekdays
        @weekdays = c.weekdays
        @addIsAllowedRequirement(@weekdayIsAllowed)

    getFileTag: (date)->date.format('YYYY-MM-DD')
    isAllowed: (date)->true

    weekGetFileTag: (date)=>
      offset = date.week() - @weekOffset
      offset = '0' + offset if offset < 10
    weekIsAllowed: (date)=> date.week() >= @weekOffset

    weekdayIsAllowed: (date)=>
      @weekdays.indexOf(date.weekday()) != -1

    addIsAllowedRequirement: (requirement)->
      oldAllowed = @isAllowed
      @isAllowed = (date)->
        oldAllowed(date) && requirement(date)
