# Introducing the HTML-to-CSS gem

    require 'hlt'
    require 'html-to-css' 

    s =<<S
    html {lang: 'en'}
      head
        title Example for HTML-to-CSS
        meta {charset: 'utf-8'}

      body
        #wrap
          article
            h1 testing 123
            p Having fun today.      
    S

    File.write 'index2.html', Hlt.new(s).to_html

    htc = HtmlToCss.new(file: 'index2.html')
    puts htc.to_layout

<pre>
html {
  background-color: #d5c832
}
  body {
    background-color: #bf71c3;
    align: center
  }
    #wrap {
      background-color: #53d35c
    }
</pre>

    puts htc.to_style
<pre>
html {
  background-color: #ea4ff5
}
  body {
    background-color: #58e977
  }
    #wrap {
      background-color: #3fdd1e
    }
      #wrap>article {
        background-color: #d25eca
      }
        #wrap>article>h1 {
          background-color: #2c25bb;
          color: #fff;
          font-family: Verdana, Arial, Helvetica, sans-serif;
          font-size: 1.3em
        }
        #wrap>article>p {
          background-color: #51f73b
        }
</pre>

htmltocss gem css css3
