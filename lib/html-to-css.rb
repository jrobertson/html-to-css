#!/usr/bin/env ruby

# file: html-to-css.rb

require 'rexle'

class String

  def to_h()    
    Hash[self.gsub(/\n/,'').split(/;\s*/).map{|x| x.split(/:/,2).map(&:strip)}]
  end
end

class HtmlToCss

  attr_accessor :elements

  def initialize(filename=nil)

    if filename then

      @doc = Rexle.new File.read(filename)

    else

      a = Dir.glob("*.html")
      @doc = Rexle.new File.read(a.pop)
      a.each {|file| merge(@doc, Rexle.new(File.read(file)).root ) }
    end

    @selectors = []
    @nocss = ['head']
    @nolayoutcss = ['ul li ul', 'p a', 'div div \w+']
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
    apply_css
  end

  def to_layout()

    css = apply_css(:layout) {|doc| select_layout_elements(doc) }
    @layout_selectors = @selectors.clone
    css
  end

  def to_style()
    apply_css :style
  end

  private

  def apply_css(type=:default)

    @css, @selectors = [], []
    doc = @doc.root.deep_clone

    yield(doc) if block_given?

    scan_to_css(type, doc.root) 
    @layout_selectors = @selectors.clone
    @css.join "\n"    
  end

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

  def scan_to_css(type, e, indent='', parent_selector='', &blk)

    return if @nocss.include? e.name
    h = e.attributes

    if h.has_key?(:id) then
      selector = '#' + h[:id]
    else
      selector = (parent_selector + ' ' + e.name).strip
    end

    return if @nolayoutcss.detect {|x| selector =~ /#{x}/ } and type == :layout

    unless @selectors.include? selector then

      @selectors << selector

      if @elements.has_key?(e.name.to_sym) then
        attributes = @elements[e.name.to_sym].strip.sub(':color','#a5f').to_h
      else
        attributes = {}
      end

      h_attributes = attributes.merge! h[:style].to_h

      if type == :layout then

        %w(font color font-family font-size background-image border line-height
          list-style-type font-weight font-style)\
        .each {|x| h_attributes.delete x if h_attributes.has_key? x}
      elsif type == :style and @layout_selectors.include? selector

        %w(float margin padding clear align width height display overflow)\
        .each {|x| h_attributes.delete x if h_attributes.has_key? x}
      end

      attr =  h_attributes.map{|x| x.join(': ')}.join(";\n" + indent + '  ')

      @css << indent + selector + " {\n#{indent}  #{attr}\n#{indent}}"

    end

    parent_selector = selector unless selector == 'html'

    indent += '  '
    e.elements.each do |x|
      scan_to_css type, x, indent, parent_selector
    end
  end

  def select_layout_elements(doc)

    a = doc.root.xpath '//div'
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