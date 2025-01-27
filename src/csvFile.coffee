module.exports = 'csvFile'
{createObjectCsvStringifier} = require('csv-writer')
{saveAs} = require('file-saver')

require('angular').module('csvFile', ['config', require('./language.picker'), ])
  .factory('CsvFile',['Config', '$http' , 'Locale' , '$q', (Config, $http, Locale, $q) ->

    headers ={}
    stringifier = {}

    loadFileStructure = (filename) =>
      if stringifier[filename]?
        return $q (r) -> r(stringifier[filename]) #we already have a stringifier[filename]
      headers[filename] = []
      return $http.get(Config.privatePath + '/' +  filename)
      .then( (response) ->
        console.log "loaded " + filename
        headerLine = response.data.split('\n')[0]
        headerLine.split(',').forEach((column)=>
          headers[filename].push(
            id: column.replace(/\*.*$/,'').trim().toLowerCase()
            title:column          
          )
          console.log 
        )
        console.log headers[filename]
        stringifier[filename] = createObjectCsvStringifier({header: headers[filename]})
        return stringifier[filename]
      )
      .catch( (response) ->         
        console.log "error: could not load " + filename
        console.log response
        return "error"
      )


    return (headerFile)=>
      loadFileStructure(headerFile).then( (s) -> 
        return (records) ->
          blob = new Blob([s.getHeaderString() + s.stringifyRecords(records)], {type: "text/csv;charset=utf-8;"});
          console.log s.getHeaderString()
          saveAs(blob, headerFile );        
          return
      )
  ]) 