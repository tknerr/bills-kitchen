#!/usr/bin/env ruby

# based on https://gist.github.com/1919161

require 'rubygems'
require 'redcarpet'
require 'albino'

class SyntaxRenderer < Redcarpet::Render::HTML
  def initialize(options)
    super options
	@style  = options[:style]
    @otoc   = options[:toc]
    @toc    = ""
    @rlevel = nil
  end

  def doc_header
    <<-HTML.gsub /^\s+/, ""
    <!DOCTYPE HTML>
    <html lang="en-US">
    <head>
    <meta charset="UTF-8">
    --TITLE
    <link rel="stylesheet" href="#{@style}">
    </head>
    <body>
    <header>
    --TOC
    </header>
    HTML
  end

  def doc_footer
    <<-HTML.gsub /^\s+/, ""
	</body>
    </html>
    HTML
  end
  
  def header(text, level)
    header = ""
    if (@rlevel == nil)
      @title  = text
      @rlevel = level
      header << "<section id=\"title\">\n"
      header << "<h1>#{text}</h1>\n"
    else
      if (@rlevel - level >= 0)
        header << "</section>\n" * (@rlevel - level + 1)
        @toc << "</li>\n" + "</ul>\n</li>\n" * (@rlevel - level) unless @toc.empty?
      else
        @toc << "<ul>\n" + "<li>\n<ul>\n" * (level - @rlevel - 1)
      end

      id = text.downcase.gsub(/\ /, '-')
      header << "<section id=\"#{id}\">\n"
      header << "<h#{level}>#{text}</h#{level}>\n"

      @toc << "<li>\n"
      @toc << "<a href=\"\##{id}\">#{text}</a>"

      @rlevel  = level
    end
    header
  end

  def block_code(code, language)
    if language && !language.empty?
      Albino.colorize(code, language)
    else
      "<pre><code>#{code}</code></pre>"
    end
  end

  def preprocess(full_document)
    @text = full_document
  end

  def postprocess(full_document)
    full_document.gsub(/--TITLE/, self.title)
                 .gsub(/--TOC/, self.toc)
  end

  def toc
    @otoc ? "<nav id=\"toc\"><ul>\n#{@toc}\n</ul></nav>" : ""
  end

  def title
    "<title>#{@title}</title>"
  end
end

class MarkIt
  def self.to_html(text)
    renderer = SyntaxRenderer.new(
      :style         => "http://tknerr.github.com/bills-kitchen/stylesheets/docs_stylesheet.css",
      :toc           => false,
      :hard_wrap     => true,
      :xhtml         => true
    )
    markdown = Redcarpet::Markdown.new(renderer,
      :fenced_code_blocks  => true,
      :no_intra_emphasis   => true,
      :tables              => true,
      :autolink            => true,
      :strikethrough       => true,
      :space_after_headers => true
    )
    markdown.render(text);
  end
end
