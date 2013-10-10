#!/usr/bin/env ruby

# file: html-to-css.rb

require 'rexle'


class HtmlToCss

  def initialize(filename=nil)

    if filename then

      @doc = Rexle.new File.read(filename)

    else

      a = Dir.glob("*.html")
      @doc = Rexle.new File.read(a.pop)
      a.each {|file| merge(@doc, Rexle.new(File.read(file)).root ) }
    end

    @selectors = []
    @nocss = ['head', 'ul li ul', 'p a', 'div div \w+']
    @css = []

    @elements = {
      a:    "background-color: :color; ",
      body: "background-color: :color;
             align: center;",
      div:  "background-color: :color;",
      h1:   "background-color: :color; 
             color: #fff;
             font-family: Verdana, Arial, Helvetica, sans-serif; 
             font-size: 1.3em;",
      h2:   "background-color: :color; 
             color: #fff;
             font-family: Verdana, Arial, Helvetica, sans-serif; 
             font-size: 1.3em;",
      html: "background-color: :color;",
      li:   "background-color: :color;",
      p:    "background-color: :color;",
      ul:   "background-color: :color;"
    }
  end

  def to_css()
    scan_to_css @doc.root
    @css.join "\n"
  end

  def to_layout()
    select_layout_elements()
    to_css()
  end

  private

  def merge(mdoc, e, axpath=[], prev_tally=[])

    i = (e.parent.parent and prev_tally.last) ? 
        (prev_tally.last + [e.name]).grep(e.name).length: 1
    i = 1 if i == 0

    index = "[%s]" % (i)
    axpath << e.name + index
    tally = [e.name]

    # does the xpath match with the master doc?
    node = mdoc.element axpath.join('/')

    unless node then

      xpath = axpath[0..-2].join('/')
      mdoc.element(xpath).add e

    else

      tally << [] if e.elements.to_a.length > 0
      e.elements.each do |x| 
        tally.last.concat merge(mdoc, x, axpath.clone, tally.clone)
      end

    end

    tally
  end

  def scan_to_css(e, indent='', parent_selector='')

    return if @nocss.include? e.name
    attr = e.attributes

    if attr.has_key?(:id) then
      selector = '#' + attr[:id]
    else
      selector = (parent_selector + ' ' + e.name).strip
    end
    
    return if @nocss.detect {|x| selector =~ /#{x}/ }

    unless @selectors.include? selector then

      @selectors << selector

      if @elements.has_key?(e.name.to_sym) then
        attributes = @elements[e.name.to_sym].strip.sub(':color','#a4f')
          .gsub(/\n/,'').split(/;\s*/).join(";\n" + indent + '  ')
      else
        attributes = ''
      end

      @css << indent + selector + " {\n#{indent}  #{attributes}\n#{indent}}"

    end

    parent_selector = selector unless selector == 'html'

    indent += '  '
    e.elements.each do |x|
      scan_to_css x, indent, parent_selector
    end
  end

  def select_layout_elements()

    a = @doc.root.xpath '//div'
    a.reverse.each do |e|

      if not e.attributes[:id] then

        li_inline = e.xpath('//ul/li/@style').grep(/display:\s*inline/).any?
        div_float = e.xpath('//div/@style').grep(/float:\s*(?:left|right)/).any?
        next if li_inline or div_float      
        e.delete
      elsif e.attributes[:id] == 'sitemap'
        e.delete    
      end

    end
  end

end

if __FILE__ == $0 then
  css = HtmlToCss.new('index.html').to_css
end
