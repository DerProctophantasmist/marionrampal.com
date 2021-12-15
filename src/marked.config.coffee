module.exports = 'markedConfig'
config = window.config
marked = require('marked')
oldRenderer = new marked.Renderer()
ResourceFile = require('./resourceFile')
EmbedUrl =  require('./resourceUrl').embedUrl

CSON = require('cson-parser')
htmlentities = require('html-entities')

# console.log "marked defaults: "
# console.log marked.defaults
renderer =
  link :  ( href, title, text) ->
    if  res = ResourceFile(href,title,text,false) #last param is embed=true/false
      return res.html;
    else 
      return oldRenderer.link(href,title,text)
  # heading: (text, level,raw,slugger) ->
  #   if level > 3 then return oldRenderer.heading(text,level,raw,slugger)
  #   escapedText = text.toLowerCase().replace(/[^\w]+/g, '-')
  #   return '<h' + level + ' class="special-font" ><a name="' +
  #     escapedText +
  #     '" class="anchor" href="#' +
  #     escapedText +
  #     '"><span class="header-link"></span></a>' +
  #     text + '</h' + level + '>';
    
  image : ( href, title, text) ->
    if (res = EmbedUrl(href) || res = ResourceFile(href, title, text, true) )
      # if res.provider &&res.provider != text.toLowerCase() then console.error('embeding failed for: ' + href + 'service ('+text+') doesn\'t match the one in the url ('+res.provider+')')
      return res.html;
    else 
      return '<img class="image centered half" src="'+href+'" alt="'+text+'" title="'+title+'" >'
  code :  (code,  infostring,  escaped) ->
    res = shorthand(infostring, code)
    return if res then res else oldRenderer.code(code, infostring, escaped) 


    

#for rendering the markdown inside the carousel code block, we start from our default options,
genRenderer = new marked.Renderer
genRenderer.link = renderer.link
genRenderer.image = renderer.image
genRenderer.code = renderer.code 
console.log "genRenderer"
options = { gfm: true, breaks: false, renderer: genRenderer}
marked.setOptions(options)
console.log marked.defaults
lexer = new marked.Lexer(options)


shorthand = (heading, content) ->
  switch heading
    when 'carousel'
      result = lexer.lex(content);
      # console.log "carousel content:"
      result = parserFactory(carouselScheme)(result)
      # console.log result
      return result
    when "figure"
      # result = marked.inlineLexer(content,[],options)
      result = marked(content,options)
      # console.log result
      return result = """
        <figure left-aside class="clickable image half" mdfile="#{params.mdfile}" >
          #{result}                                        
          <figcaption>#{params.caption}</figurecaption>
        </figure>          
        """
    when "imagesLeft"
      result = marked(content,options)
      # console.log result
      return result = """
        <div style="margin: 0" class="force-float-images-left clearfix">
          #{result}                                            
        </div>            
        """
    when 'sections' #section list
      result = lexer.lex(content);
      # console.log "sections content: "
      acc = {nbr:0}
      result = parserFactory(sectionsScheme(acc))(result)
      # console.log result
      config.nbrOfSectionsToLoad(acc.nbr)
      return result

    when 'page' #single page section
      page={} # accumulator, in order to "pass by ref" the data in the list
      result = lexer.lex(content);
      result = parserFactory(pageScheme(page))(result)
      
      #we "fetch" the parent section from the section controller, see section.coffee:
      return """ 
      <page sec-ctrl='$sc' page-data='#{JSON.stringify(page)}'> 
        #{result}
      </page>
      """
    else  
      return false


carouselScheme = 
  list: (body) -> 
    '<div uib-carousel active="active" interval="website.getCarouselInterval()">  \n' +  body + '  \n</div>  \n'
  listItem: (body, curIndex) ->
    '<div uib-slide index="' + curIndex + '" >  \n' + marked(body,options) + '  \n</div>  \n'

sectionsScheme = (acc) -> 
  scheme = 
    text: (text) -> text
    link: ()->{}
    image: ( href, title, text) ->
      section = 
        id:text
      title = htmlentities.decode(title)
      try
        params=CSON.parse title
      catch e
        msg = "section " + text + " not well formed: " + title + " is not a json string. " + e.message
        console.log msg
        return "<section>" + msg + "</section>"
      section={section...,params...}
      acc.nbr++
      return """ 
      <section  ng-if="website.displaySection('#{section.id}')"  id="#{section.id}" section-data='#{JSON.stringify(section)}' class="section-#{section.id}"
      style="{{(website.state.getAllowEdit())?'min-height:6em;':''}}">
        <marked compile=true filename="'#{href}'" editor-button-style="position:absolute;top:3em;left:10em;color:black;z-index:1000;">
        </marked> 
      </section>
      """

  scheme.inlineLexer = new marked.InlineLexer([], {options...,renderer:scheme})
  return scheme


pageScheme = (page)->
  scheme = 
    list: (body) -> ""
    listItem: (body, curIndex) ->
      i = body.indexOf(':')
      if i!=-1
        key = body.substring(0, i).trim()
        value = body.substring(i+1).trim() 
        page[key]=value
      else  
        console.log "malformed data: " + body
        return ""
      return ""
    text: (text) -> text
    link: ()->{}
    image: ( href, title, text) ->
      box = {}
      title = htmlentities.decode(title)
      if title != ""        
        try
          box=CSON.parse title
        catch e
          msg = "box not well formed: " + title + " is not a cson string. " + e.message
          console.log msg
          return "<div>" + msg + "</div>"
      html ="""
        <div ng-controller="BoxCtrl" class="content-sizer box #{text}" ng-hide="website.isMainContentHidden()">
      """
      if box.mobileHeader
        html+="""
          <mobile-header>
          </mobile-header>
        """
      return html + """         
          <marked compile=true filename="'#{href}'" editor-button-style="position:absolute;top:6em;left:10em;color:black;z-index:1000;">
        </div>
      """
  scheme.inlineLexer = new marked.InlineLexer([], {options...,renderer:scheme})
  return scheme


parserFactory = (parserScheme)->
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

  unknownToken = () ->
    errMsg = 'Token with "' + token.type + '" type was not found.'
    console.log errMsg
    return ''
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

      #   return parserScheme.blockquote(body);
      
      when 'list_start'
        if !parserScheme.list then return unknownToken()
        curIndex = 0 
        body = ''
        ordered = token.ordered
        start = token.start

        while (next().type != 'list_end') 
          body += tok();          

        return parserScheme.list(body)
      
      when 'list_item_start'
        if !parserScheme.listItem then return unknownToken()
        body = ''
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
        
        return parserScheme.listItem(body,curIndex++)
      
      # when 'html': 
      #   // TODO parse inline content if parameter markdown=1
      #   return renderer.html(token.text);
      
      when 'paragraph' 
        if !parserScheme.inlineLexer then return unknownToken()
        return parserScheme.inlineLexer.output(token.text)
      
      when 'text'
         return parserFactory(parserScheme)(parseText())
      
      else 
        return unknownToken()
        
      
  return parse



require('angular').module('markedConfig', [require('angular-marked'), require('angular-ui-bootstrap'), require('./oEmbed'), require('./config'), require('./resource.file')])
.config(['markedProvider', 'EmbedUrl', 'ResourceFile', (markedProvider, EmbedUrl, ResourceFile) ->  
  console.log "marked defaults"
  console.log marked.defaults
  markedProvider.setOptions(marked.defaults)
  markedProvider.setRenderer(marked.defaults.renderer)
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
    
