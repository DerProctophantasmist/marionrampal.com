module.exports = 'dataFile'

require('angular').module('dataFile', [
    require('./config'), require('./markdownEditor'), require('./states')
  ])
  .factory('DataFile', ['$http', 'Config', 'State', ($http, Config, State ) ->
    
    files = {}
    cache = {}
    
    loadDataFile = (filename, callbacks, scope) -> 
      ref = (files[filename] = {callbacks: [callbacks]})
      scope[filename + "-watcher"] = 0
      if cache[filename] # the server sent us the data in the first package, we cached it
        ref.data = cache[filename]
        #this is a synchronous call, we don't need to check for other callbacks (we will if we have to fetch the data from the server)
        callbacks.onSuccess(ref.data)
        return
      #else we fetch the data file from the server:
      $http({method: 'get', url: Config.dataPath + '/' +  filename, headers: {'Cache-Control': 'no-cache'}})
      .then (response) ->
          ref.data = response.data
          # we could have asked for the file numerous times between the call to $http and the response
          # hence the loop on the callback list
          for key, callbacks of files[filename].callbacks
            callbacks.onSuccess(response.data) if callbacks.onSuccess 
          return 
        ,(err) -> 
          if err.status == 404 #file doesn't exist. Beware, subsequent calls for the same file will be treated as success    
            for key, callbacks of files[filename].callbacks
              if callbacks.on404 then callbacks.on404('')              
          else #pbm, beware subsequent calls for the same file will be treated as success               
            for key, callbacks of files[filename].callbacks
              if callbacks.onError then callbacks.onError(err)       
              State.showEditors = false #disable editors, so that we don't wipe our files      
          console.log 'Could not load '+filename+' : ' + JSON.stringify(err)
          ref.data = ''
      return
    
 
    dataFile = 
      #callbacks: {onChange, on404, onError, onSuccess }
      read: (filename, callbacks, scope) ->
        ref = files[filename]
        if !ref # we haven't yet asked for this file
          loadDataFile(filename, callbacks, scope)
        else 

          if ref.data? # already loaded
            callbacks.onSuccess(ref.data)

          ref.callbacks.push(callbacks)
          scope[filename+"-watcher"] = ref.callbacks.length  - 1
        
          scope.$on '$destroy', ()-> 
            delete callbacks[scope[filename+"-watcher"]]
            return
        return
      onChange: (filename, content) ->
        ref = files[filename]
        # console.log ref
        ref.data = content
        for own key, callbacks of ref.callbacks
          # console.log callbacks
          callbacks.onChange(content)
        return
      
      cache: (filename,content) ->
        ref = files[filename]
        if !ref # we haven't yet asked for this file
          cache[filename] = content
          return
        #hum we probably shouldn't be here: if we have already asked for it, why are we caching it only now?
        console.log "Error: shouldn't be here, caching of #{filename} is too late. content was: #{content}."

    return dataFile
    
  ])