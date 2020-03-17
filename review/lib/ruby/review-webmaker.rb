# -*- coding: utf-8 -*-

###
### ReVIEW::WEBMakerクラスを拡張する
###

require 'review/webmaker'


module ReVIEW

  defined?(WEBMaker)  or raise "internal error: WEBMaker not found."


  ##
  ## Webページ用（HTMLMakerとは違うことに注意）
  ##
  class WEBMaker

    def copy_stylesheet(basetmpdir)
      cssdir = File.join(basetmpdir, "css")
      Dir.mkdir(cssdir) unless File.directory?(cssdir)
      [@config['stylesheet']].flatten.compact.each do |x|
        FileUtils.cp("css/#{x}", cssdir)
      end
    end

    def template_name
      #if @config['htmlversion'].to_i == 5
      #  'web/html/layout-html5.html.erb'
      #else
      #  'web/html/layout-xhtml1.html.erb'
      #end
      "layout.html5.erb"
    end

    def find_template(filename)
      filepath = File.join(@basedir, 'layouts', File.basename(filename))
      return filepath if File.exist?(filepath)
      return File.expand_path(filename, ReVIEW::Template::TEMPLATE_DIR)
    end

    def render_template(filepath)
      return ReVIEW::Template.load(filepath).result(binding())
    end

    def generate_file_with_template(filepath, filename=nil)
      tmpl_filename ||= template_name()
      tmpl_filepath = find_template(tmpl_filename)
      content = render_template(tmpl_filepath)
      File.open(filepath, 'w') {|f| f.write(content) }
      return content
    end

    def _i18n(*args)
      ReVIEW::I18n.t(*args)
    end

    def _join_names(names)
      return join_with_separator(names, _i18n('names_splitter'))
    end

    def _escape(s)
      return CGI.escapeHTML(s)
    end

    def build_part(part, basetmpdir, htmlfile)
      part_name = part.name.strip
      #
      sb = ""
      sb << "<div class=\"part\">\n"
      sb << "<h1 class=\"part-number\">#{_i18n('part', part.number)}</h1>\n"
      sb << "<h2 class=\"part-title\">#{part_name}</h2>\n" if part_name.present?
      sb << "</div>\n"
      @body = sb
      @language = @config['language']
      @stylesheets = @config['stylesheet']
      #
      generate_file_with_template("#{basetmpdir}/#{htmlfile}")
    end

    def build_indexpage(basetmpdir)
      if @config['coverimage']
        imgfile = File.join(@config['imagedir'], @config['coverimage'])
      else
        imgfile = nil
      end
      #
      sb = ""
      if imgfile
        sb << "  <div id=\"cover-image\" class=\"cover-image\">\n"
        sb << "    <img src=\"#{imgfile}\" class=\"max\"/>\n"
        sb << "  </div>\n"
      end
      @body = sb
      @language = @config['language']
      @stylesheets = @config['stylesheet']
      @toc = ReVIEW::WEBTOCPrinter.book_to_html(@book, nil)
      @next = @book.chapters[0]
      @next_title = @next ? @next.title : ''
      #
      generate_file_with_template("#{basetmpdir}/index.html")
    end

    def build_titlepage(basetmpdir, htmlfile)
      author    = @config['aut'] ? _join_names(@config.names_of('aut')) : nil
      publisher = @config['pbl'] ? _join_names(@config.names_of('pbl')) : nil
      #
      sb = ""
      sb << "<div class=\"titlepage\">\n"
      sb << "<h1 class=\"tp-title\">#{_escape(@config.name_of('booktitle'))}</h1>\n"
      sb << "<h2 class=\"tp-author\">#{author}</h2>\n"        if author
      sb << "<h3 class=\"tp-publisher\">#{publisher}</h3>\n"  if publisher
      sb << "</div>\n"
      @body = sb
      @language = @config['language']
      @stylesheets = @config['stylesheet']
      #
      generate_file_with_template("#{basetmpdir}/#{htmlfile}")
    end

  end


  class WEBTOCPrinter

    def self.book_to_html(book, current_chapter)
      printer = self.new(nil, nil, nil)
      arr = printer.handle_book(book, current_chapter)
      html = printer.render_html(arr)
      return html
    end

    def render_html(arr)
      tag, attr, children = arr
      tag == "book"  or raise "internal error: tag=#{tag.inspect}"
      buf = "<ul class=\"toc toc-1\">\n"
      children.each do |child|
        _render_li(child, buf, 1)
      end
      buf << "</ul>\n"
      return buf
    end

    def parse_inline(str)
      builder = HTMLBuilder.new
      builder.instance_variable_set('@book', @_book)
      @compiler ||= Compiler.new(builder)
      return @compiler.text(str)
    end

    def _render_li(arr, buf, n)
      tag, attr, children = arr
      case tag
      when "part"
        buf << "<li class=\"toc-part\">#{parse_inline(attr[:label])}\n"
        buf << "  <ul class=\"toc toc-#{n+1}\">\n"
        children.each {|child| _render_li(child, buf, n+1) }
        buf << "  </ul>\n"
        buf << "</li>\n"
      when "chapter"
        buf << "    <li class=\"toc-chapter\"><a href=\"#{h attr[:path]}\">#{parse_inline(attr[:label])}</a>"
        if children && !children.empty?
          buf << "\n      <ul class=\"toc toc-#{n+1}\">\n"
          children.each {|child| _render_li(child, buf, n+1) }
          buf << "      </ul>\n"
          buf << "    </li>\n"
        else
          buf << "</li>\n"
        end
      when "section"
        buf << "        <li class=\"toc-section\"><a href=\"##{attr[:anchor]}\">#{parse_inline(attr[:label])}</a></li>\n"
      end
      buf
    end

    def handle_book(book, current_chapter)
      @_book = book
      children = []
      book.each_part do |part|
        if part.number
          children << handle_part(part, current_chapter)
        else
          part.each_chapter do |chap|
            children << handle_chapter(chap, current_chapter)
          end
        end
      end
      #
      attrs = {
        title: book.config['booktitle'],
        subtitle: book.config['subtitle'],
      }
      return ["book", attrs, children]
    end

    def handle_part(part, current_chapter)
      children = []
      part.each_chapter do |chap|
        children << handle_chapter(chap, current_chapter)
      end
      #
      attrs = {
        number: part.number,
        title:  part.title,
        #label:  "#{I18n.t('part_short', part.number)} #{part.title}",
        label:  "#{I18n.t('part', part.number)} #{part.title}",
      }
      return ["part", attrs, children]
    end

    def handle_chapter(chap, current_chapter)
      children = []
      if current_chapter.nil? || chap == current_chapter
        chap.headline_index.each do |sec|
          next if sec.number.present? && sec.number.length >= 2
          children << handle_section(sec, chap)
        end
      end
      #
      chap_node = TOCParser.chapter_node(chap)
      ext   = chap.book.config['htmlext'] || 'html'
      path  = chap.path.sub(/\.re\z/, ".#{ext}")
      label = if chap_node.number && chap.on_chaps?
                "#{I18n.t('chapter_short', chap.number)} #{chap.title}"
              else
                chap.title
              end
      #
      attrs = {
        number: chap_node.number,
        title:  chap.title,
        label:  label,
        path:   path,
      }
      return ["chapter", attrs, children]
    end

    def handle_section(sec, chap)
      if chap.number && sec.number.length > 0
        number = [chap.number] + sec.number
        label  = "#{number.join('.')} #{sec.caption}"
      else
        number = nil
        label  = sec.caption
      end
      attrs = {
        number: number,
        title:  sec.caption,
        label:  label,
        anchor: "h#{number ? number.join('-') : ''}",
      }
      return ["section", attrs, []]
    end

  end


end
