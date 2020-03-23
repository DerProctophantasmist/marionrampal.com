module.exports = 'sendToServer'
path = require('path')

require('angular').module('sendToServer', ['config', require('./language.picker'),  require('./states')])
  .factory('SendToServer',['Config', '$http' , 'Locale' , 'State', (Config, $http, Locale, State ) ->

    send =
      textFile : (filepath, content) ->
        file = new File([content], path.basename(filepath), { type: "text/plain",});
        formData = new FormData()
        formData.append("file", file)
        $http.post("editfile/"+filepath,formData, 
          headers:
            'Content-Type': undefined
        )
  
    return send
    
  ]) 