#!/usr/bin/env ruby

# file: html-to-css.rb

require 'rexle'


class HtmlToCss

  def initialize(filename)

    @doc = Rexle.new File.read(filename)
    @selectors = []
    @nocss = %w(title link)
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
      head: "background-color: :color;",
      html: "background-color: :color;",
      li:   "background-color: :color;",
      p:    "background-color: :color;",
      ul:   "background-color: :color;"
    }
  end

  def to_css()
    scan @doc.root
    @css.join "\n"
  end

  private

  def scan(e, indent='', parent_selector='')

    return if @nocss.include? e.name
    attr = e.attributes

    if attr.has_key?(:id) then
      selector = '#' + attr[:id]
    else
      selector = (parent_selector + ' ' + e.name).strip
    end

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
      scan x, indent, parent_selector
    end
  end

end

if __FILE__ == $0 then
  css = HtmlToCss.new('index.html').to_css
end

