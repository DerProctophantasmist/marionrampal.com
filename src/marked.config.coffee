module.exports = 'markedConfig'
Config = window.config

require('angular').module('markedConfig', [require('angular-marked'), require('angular-ui-bootstrap'), require('./oEmbed'), require('./config'), require('./resource.file')])
.config(['markedProvider', 'OEmbedUrl', 'ResourceFile', (markedProvider, OEmbedUrl, ResourceFile) ->  
  
  marked = require('marked')
  oldRenderer = new marked.Renderer()


  renderer = {
    link :  ( href, title, text) ->
      if  res = ResourceFile(href,title,text,false) #last param is embed=true/false
        return res.html;
      else 
        return oldRenderer.link(href,title,text)
    ,
    # heading: (text, level,raw,slugger) ->
    #   if level > 3 then return oldRenderer.heading(text,level,raw,slugger)
    #   escapedText = text.toLowerCase().replace(/[^\w]+/g, '-')
    #   return '<h' + level + ' class="special-font" ><a name="' +
    #     escapedText +
    #     '" class="anchor" href="#' +
    #     escapedText +
    #     '"><span class="header-link"></span></a>' +
    #     text + '</h' + level + '>';
      
    # ,
    image : ( href, title, text) ->
      if (res = OEmbedUrl(href) || res = ResourceFile(href, title, text, true) )
        # if res.provider &&res.provider != text.toLowerCase() then console.error('embeding failed for: ' + href + 'service ('+text+') doesn\'t match the one in the url ('+res.provider+')')
        return res.html;
      else 
        return '<img class="image centered half" src="'+href+'" alt="'+text+'" title="'+title+'" >'
    ,  
    code:  (code,  infostring,  escaped) ->
        console.log code
        console.log infostring
        console.log escaped
        
        if infostring && infostring.toLowerCase() == "carousel"
          # result =  marked(code, optionsCarousel) 
          result = lexer.lex(code);
          console.log "carousel code:"
          # console.log code
          # console.log result
          result = carouselParserFactory()(result)
          # console.log result
          # console.log options 
          # console.log marked(result, options)
          console.log result
          return result 

    # list : (body,ordered, start) ->
    #   console.log "list:"
    #   console.log body
    #   console.log ordered
    #   console.log start
    #   return oldRenderer.list(body,ordered,start)
    # ,
      
  } 
  options = {gfm: true, breaks: false}
    
  
  markedProvider.setOptions(options)
  markedProvider.setRenderer(renderer)

  #for rendering the markdown inside the carousel code block, we start from our default options,
  genRenderer = new marked.Renderer
  genRenderer.link = renderer.link
  genRenderer.image = renderer.image
  genRenderer.code = renderer.code
  console.log "genRenderer"
  options = { options..., renderer: genRenderer}
  console.log options
  lexer = new marked.Lexer(options)

  carouselParserFactory = ()->
    that = carouselParserFactory
    token = null
    tokens = null
    curIndex = 0

    parse = (src) ->
      tokens = src.reverse()

      out = '';
      while next()
        out += tok()

      return out 
    
    # * Next Token
    
    next = ()->
      token = tokens.pop()
      return token

    
    #  Preview Next Token
    peek = () ->
      tokens[tokens.length - 1] || 0

    # * Parse Text Tokens
    parseText = () ->
      body = token.text
      while (peek().type == 'text')
        body += '\n' + next().text

      return body

    
    # Parse Current Token

    tok = () ->
      switch token.type
        when 'space'
          return ''
        # when 'hr': 
        #   return renderer.hr();
        
        # when 'heading': 
        #   return renderer.heading(
        #     inline.output(token.text),
        #     token.depth,
        #     unescape(inlineText.output(token.text)),
        #     slugger);
        
        # when 'code': 
        #   return renderer.code(token.text,
        #     token.lang,
        #     token.escaped);
        
        # when 'table': 
        #   header = ''
        #   body = ''

        #   // header
        #   cell = '';
        #   for (i = 0; i < token.header.length; i++) 
        #     cell += renderer.tablecell(
        #       inline.output(token.header[i]),
        #       { header: true, align: token.align[i] 
        #     );
          
        #   header += renderer.tablerow(cell);

        #   for (i = 0; i < token.cells.length; i++) {
        #     row = token.cells[i];

        #     cell = '';
        #     for (j = 0; j < row.length; j++) {
        #       cell += renderer.tablecell(
        #         inline.output(row[j]),
        #         { header: false, align: token.align[j] 
        #       );
            

        #     body += renderer.tablerow(cell);
          
        #   return renderer.table(header, body);
        
        # when 'blockquote_start': 
        #   body = '';

        #   while (next().type !== 'blockquote_end') 
        #     body += tok();
          

        #   return renderer.blockquote(body);
        
        when 'list_start'
          curIndex = 0 
          body = ''
          ordered = token.ordered
          start = token.start

          while (next().type != 'list_end') 
            body += tok();
          

          return '<div uib-carousel active="active" interval="website.getCarouselInterval()">  \n' +  body + '  \n</div>  \n'
        
        when 'list_item_start'
          body = ''
          console.log 'list item:'
          console.log token
          loose = token.loose
          checked = token.checked
          task = token.task

          # if (token.task) 
          #   body += renderer.checkbox(checked);
          

          # while (next().type !== 'list_item_end') 
          #   body += !loose && token.type === 'text'
          #     ? parseText()
          #     : tok();

          while next().type != 'list_item_end'
            body += if !loose && token.type == 'text' then  parseText() else tok()
          
          return '<div uib-slide index="' + (curIndex++) + '" >  \n' + marked(body,options) + '  \n</div>  \n'
        
        # when 'html': 
        #   // TODO parse inline content if parameter markdown=1
        #   return renderer.html(token.text);
        
        # when 'paragraph': 
        #   return renderer.paragraph(inline.output(token.text));
        
        # when 'text': 
        #   return renderer.paragraph(parseText());
        
        else 
          errMsg = 'Token with "' + token.type + '" type was not found.'
          console.log errMsg
          return ''
          
       
    return parse
  
])
.directive('carouselCtrl', () ->
    template: "<div ng-transclude></div>"
    transclude: true
    scope:{}
    controller: [() ->        
      this.active = 0;
      return;      
    ]
    controllerAs: 'cc'
    link: (scope,element, attrs) ->
      elt = element[0]
      slides = elt.querySelectorAll("div[uib-slide]")
      console.log elt
      console.log slides
      for i in [0..(slides.length-1)]
        listitem = slides[i]        
        listitem.setAttribute("index",i)
        console.log "item" + i
        console.log listitem
      
)
    
