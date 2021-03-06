module.exports = 'markdownEditor'

require('angular').module('markdownEditor', [require('./sendToServer'), require('./language.picker'),  require('./states')])
  .factory('MarkdownEditor',['SendToServer' , 'Locale' , 'State', 'DataFile', (SendToServer, Locale, State, DataFile ) ->
    Locale.get().language
    stackedit = new Stackedit();
    curContent = null
    originalContent = null
    name = null

    editor =
      open : (filename, markdown) ->
        originalContent = markdown
        name  = filename
        # Open the iframe
        stackedit.openFile(
          name: filename, # with an optional filename
          content: 
            text: markdown # and the Markdown content.
        )

        # Listen to StackEdit events and apply the changes to the textarea.
        stackedit.on('fileChange', (file) => 
          DataFile.onChange(filename, file.content.text)
          curContent = file.content.text 
        )
        stackedit.on('close', () => 
          delete stackedit.$listeners['close']
          delete stackedit.$listeners['fileChange']
          if curContent != originalContent 
            SendToServer.textFile(name,curContent)

        )
        return stackedit
    
    return editor
    
  ]) 