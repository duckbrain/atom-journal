fs = require 'fs-extra'
gpg = require 'gpg'
mkdirp = require 'mkdirp'
Mustache = require 'mustache'
os = require 'os'
path = require 'path'

module.exports =
  class Notebook
    constructor: (c, name)->
      @name = c.name || name
      @folder = c.folder || @name
      @gpg = c.gpg
      if c.weekOffset
        @weekOffset = c.weekOffset
        @getFileTag = @weekGetFileTag
        @isAllowed = @weekIsAllowed
      if c.tag
        @tag = c.tag
        @getFileTag = @taggedGetFileTag
      if c.template == true
        c.template = '.' + @name + '-template.md'
      @template = c.template if c.template
      if c.weekdays
        @weekdays = c.weekdays
        @addIsAllowedRequirement(@weekdayIsAllowed)
      if c.months
        @months = c.months
        @addIsAllowedRequirement(@monthIsAllowed)
      if c.nthWeeks
        @nthWeeks = c.nthWeeks
        @addIsAllowedRequirement(@nthIsAllowed)

    getFileTag: (date)->
      date.format('YYYY-MM-DD')
    isAllowed: (date)->true

    weekGetFileTag: (date)=>
      offset = date.week() - @weekOffset
      offset = '0' + offset if offset < 10
      offset
    weekIsAllowed: (date)=> date.week() >= @weekOffset

    nthIsAllowed: (date)=>
      nthOfMonth = Math.ceil(date.date() / 7)
      @nthWeeks.indexOf(nthOfMonth) != -1

    taggedGetFileTag: (date)->
      date.format(@tag).toLowerCase()

    weekdayIsAllowed: (date)=>
      @weekdays.indexOf(date.weekday()) != -1

    monthIsAllowed: (date)=>
      @months.indexOf(date.month()) != -1

    addIsAllowedRequirement: (requirement)->
      oldAllowed = @isAllowed
      @isAllowed = (date)->
        oldAllowed(date) && requirement(date)

    fullFilename: (date)->
      path.join @baseDir(), @folder, @filename(date)

    filename: (date)->
      @name + '-' + @getFileTag(date) + '.md'

    fileExists: (filename)->
        new Promise (resolve)->
          fs.stat filename, (err)-> resolve(!err)

    getCompiledTemplateContents: (date)->
      new Promise (resolve)=>
        return resolve("") if not @template
        templateFilename = path.join @baseDir(), @folder, @template
        fs.readFile templateFilename, 'utf-8', (err, template)->
          return resolve("") if err

          f = 'dddd D MMMM YYYY'
          data = date: date.format f
          for d in [0..6]
            date.weekday(d)
            data['date' + date.format('ddd')] = date.format(f)
          data['json'] = JSON.stringify data

          resolve(Mustache.render(template.toString(), data))

    getWorkingFile: (date)->
      new Promise (resolve)=>
        filename = @fullFilename(date)
        if @gpg
          result =
            filename: filename
            save: ()=>
              new Promise (resolve, reject)=>
                fs.readFile(filename, (err, content)=>
                  reject err if err
                  gpg.call(content, ['--encrypt', '--armor', '--recipient', @gpg], (err, cryptContent)->
                    reject err if err
                    fs.writeFile(filename + ".gpg", cryptContent, (err)->
                      resolve()
                    )
                  )
                )
        else
          result =
            filename: filename
            save: ()->
              debugger

        return resolve result if not @template and not @gpg

        @fileExists(filename).then (exists)=>
          if exists
            return resolve result if not @gpg
            # TODO determine which is newer and user that
            return resolve result
          else
            @fileExists(filename + ".gpg").then (exists)=>
              if exists
                # Decrpyt the file
                gpg.decryptToFile({
                    source: filename + ".gpg"
                    dest: filename
                  }, (err)->
                    resolve result
                  )
              else
                # Create the template
                @getCompiledTemplateContents(date).then (c)->
                  return resolve(result) if !c
                  fs.writeFile result.filename, c, (err)->
                    resolve result
