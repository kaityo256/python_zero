# -*- coding: utf-8 -*-

###
### ReVIEW::HTMLBuilderクラスを拡張する
###

require 'review/htmlbuilder'


module ReVIEW

  defined?(HTMLBuilder)  or raise "internal error: HTMLBuilder not found."


  class HTMLBuilder

    def layoutfile
      ## 'rake web' のときに使うレイアウトファイルを 'layout.html5.erb' へ変更
      if @book.config.maker == 'webmaker'
        htmldir = 'web/html'
        #localfilename = 'layout-web.html.erb'
        localfilename = 'layout.html5.erb'
      else
        htmldir = 'html'
        localfilename = 'layout.html.erb'
      end
      ## 以下はリファクタリングした結果
      basename = @book.htmlversion == 5 ? 'layout-html5.html.erb' : 'layout-xhtml1.html.erb'
      htmlfilename = File.join(htmldir, basename)
      #
      layout_file = File.join(@book.basedir, 'layouts', localfilename)
      if ! File.exist?(layout_file)
        ! File.exist?(File.join(@book.basedir, 'layouts', 'layout.erb'))  or
          raise ReVIEW::ConfigError, 'layout.erb is obsoleted. Please use layout.html.erb.'
        layout_file = nil
      elsif ENV['REVIEW_SAFE_MODE'].to_i & 4 > 0
        warn "user's layout is prohibited in safe mode. ignored."
        layout_file = nil
      end
      layout_file ||= File.expand_path(htmlfilename, ReVIEW::Template::TEMPLATE_DIR)
      return layout_file
    end

    def result
      # default XHTML header/footer
      @title = strip_html(compile_inline(@chapter.title))
      @body = @output.string
      @language = @book.config['language']
      @stylesheets = @book.config['stylesheet']
      @next = @chapter.next_chapter
      @prev = @chapter.prev_chapter
      @next_title = @next ? compile_inline(@next.title) : ''
      @prev_title = @prev ? compile_inline(@prev.title) : ''

      if @book.config.maker == 'webmaker'
        #@toc = ReVIEW::WEBTOCPrinter.book_to_string(@book)          #-
        @toc = ReVIEW::WEBTOCPrinter.book_to_html(@book, @chapter)   #+
      end

      ReVIEW::Template.load(layoutfile).result(binding)
    end

    def headline(level, label, caption)
      prefix, anchor = headline_prefix(level)
      prefix = "<span class=\"secno\">#{prefix}</span> " if prefix
      puts "" if level > 1
      a_id = ""
      a_id = "<a id=\"h#{anchor}\"></a>" if anchor
      #
      if caption.empty?
        puts a_id if label
      else
        attr = label ? " id=\"#{normalize_id(label)}\"" : ""
        puts "<h#{level}#{attr}>#{a_id}#{prefix}#{compile_inline(caption)}</h#{level}>"
      end
    end

    def image_image(id, caption, metric)
      src = @chapter.image(id).path.sub(%r{\A\./}, '')
      alt = escape_html(compile_inline(caption))
      metrics = parse_metric('html', metric)
      metrics = " class=\"img\"" unless metrics.present?
      puts "<div id=\"#{normalize_id(id)}\" class=\"image\">"
      puts "<img src=\"#{src}\" alt=\"#{alt}\"#{metrics} />"
      image_header(id, caption)
      puts "</div>"
    end

    ## コードブロック（//program, //terminal）

    def program(lines, id=nil, caption=nil, optionstr=nil)
      _codeblock('program', 'code', lines, id, caption, optionstr)
    end

    def terminal(lines, id=nil, caption=nil, optionstr=nil)
      _codeblock('terminal', 'cmd-code', lines, id, caption, optionstr)
    end

    protected

    def _codeblock(blockname, classname, lines, id, caption, optionstr)
      ## ブロックコマンドのオプション引数はCompilerクラスでパースすべき。
      ## しかしCompilerクラスがそのような設計になってないので、
      ## 仕方ないのでBuilderクラスでパースする。
      opts = _parse_codeblock_optionstr(optionstr, blockname)
      CODEBLOCK_OPTIONS.each {|k, v| opts[k] = v unless opts.key?(k) }
      #
      if opts['eolmark']
        lines = lines.map {|line| "#{detab(line)}<small class=\"startereolmark\"></small>" }
      else
        lines = lines.map {|line| detab(line) }
      end
      #
      puts "<div id=\"#{normalize_id(id)}\" class=\"#{classname}\">" if id.present?
      puts "<div class=\"#{classname}\">"                        unless id.present?
      #
      if id.present? || caption.present?
        str = _build_caption_str(id, caption)
        print "<span class=\"caption\">#{str}</span>\n"
        classattr = "list"
      else
        classattr = "emlist"
      end
      #
      lang = opts['lang']
      lang = File.extname(id || "").gsub(".", "") if lang.blank?
      classattr << " language-#{lang}" unless lang.blank?
      classattr << " highlight"        if highlight?
      print "<pre class=\"#{classattr}\">"
      #
      gen = opts['lineno'] ? LineNumberGenerator.new(opts['lineno']).each : nil
      if gen
        width = opts['linenowidth']
        if width < 0
          format = "%s"
        elsif width == 0
          last_lineno = gen.each.take(lines.length).compact.last
          width = last_lineno.to_s.length
          format = "%#{width}s"
        else
          format = "%#{width}s"
        end
      end
      buf = []
      start_tag = opts['linenowidth'] >= 0 ? "<em class=\"linenowidth\">" : "<em class=\"lineno\">"
      lines.each_with_index do |line, i|
        buf << start_tag << (format % gen.next) << ": </em>" if gen
        buf << line << "\n"
      end
      puts highlight(body: buf.join(), lexer: lang,
                     format: "html", linenum: !!gen,
                     #options: {linenostart: start}
                     )
      #
      print "</pre>\n"
      print "</div>\n"
    end

    public

    ## コードリスト（//list, //emlist, //listnum, //emlistnum, //cmd, //source）
    def list(lines, id=nil, caption=nil, lang=nil)
      _codeblock("list", "caption-code", lines, id, caption, _codeblock_optstr(lang, false))
    end
    def listnum(lines, id=nil, caption=nil, lang=nil)
      _codeblock("listnum", "code", lines, id, caption, _codeblock_optstr(lang, true))
    end
    def emlist(lines, caption=nil, lang=nil)
      _codeblock("emlist", "emlist-code", lines, nil, caption, _codeblock_optstr(lang, false))
    end
    def emlistnum(lines, caption=nil, lang=nil)
      _codeblock("emlistnum", "emlistnum-code", lines, nil, caption, _codeblock_optstr(lang, true))
    end
    def source(lines, caption=nil, lang=nil)
      _codeblock("source", "source-code", lines, nil, caption, _codeblock_optstr(lang, false))
    end
    def cmd(lines, caption=nil, lang=nil)
      lang ||= "shell-session"
      _codeblock("cmd", "cmd-code", lines, nil, caption, _codeblock_optstr(lang, false))
    end
    def _codeblock_optstr(lang, lineno_flag)
      arr = []
      arr << lang if lang
      if lineno_flag
        first_line_num = line_num()
        arr << "lineno=#{first_line_num}"
        arr << "linenowidth=0"
      end
      return arr.join(",")
    end
    private :_codeblock_optstr

    protected

    ## @<secref>{}

    def _build_secref(chap, num, title, parent_title)
      s = ""
      ## 親セクションのタイトルがあれば使う
      if parent_title
        s << "%s内の" % parent_title   # TODO: I18n化
      end
      ## 対象セクションへのリンクを作成する
      if @book.config['chapterlink']
        filename = "#{chap.id}#{extname()}"
        dom_id = 'h' + num.gsub('.', '-')
        s << "<a href=\"#{filename}##{dom_id}\">#{title}</a>"
      else
        s << title
      end
      return s
    end

    public

    ## 順序つきリスト

    def ol_begin(start_num=nil)
      @_ol_types ||= []    # stack
      case start_num
      when nil
        type = "1"; start = 1
      when /\A(\d+)\.\z/
        type = "1"; start = $1.to_i
      when /\A([A-Z])\.\z/
        type = "A"; start = $1.ord - 'A'.ord + 1
      when /\A([a-z])\.\z/
        type = "a"; start = $1.ord - 'a'.ord + 1
      else
        type = nil; start = nil
      end
      if type
        puts "<ol start=\"#{start}\" type=\"#{type}\">"
      else
        puts "<ol class=\"ol-none\">"
      end
      @_ol_types.push(type)
    end

    def ol_end()
      ol = !! @_ol_types.pop()
      if ol
        puts "</ol>"
      else
        puts "</ol>"
      end
    end

    def ol_item_begin(lines, num)
      ol = !! @_ol_types[-1]
      if ol
        print "<li>#{lines.join}"
      else
        n = escape_html(num)
        print "<li data-mark=\"#{n}\"><span class=\"li-mark\">#{n} </span>#{lines.join}"
      end
    end

    def ol_item_end()
      puts "</li>"
    end

    ## 入れ子可能なブロック命令

    def on_minicolumn(type, caption, &b)
      puts "<div class=\"#{type}\">"
      puts "<p class=\"caption\">#{compile_inline(caption)}</p>" if caption.present?
      yield
      puts '</div>'
    end
    protected :on_minicolumn

    def on_sideimage_block(imagefile, imagewidth, option_str=nil, &b)
      imagefile, imagewidth, opts = validate_sideimage_args(imagefile, imagewidth, option_str)
      filepath = find_image_filepath(imagefile)
      side     = (opts['side'] || 'L') == 'L' ? 'left' : 'right'
      imgclass = opts['border'] ? "image-bordered" : nil
      normalize = proc {|s| s =~ /^\A(\d+(\.\d+))%\z/ ? "#{$1.to_f/100.0}\\textwidth" : s }
      imgwidth = normalize.call(imagewidth)
      boxwidth = normalize.call(opts['boxwidth']) || imgwidth
      sepwidth = normalize.call(opts['sep'] || "0pt")
      #
      puts "<div class=\"sideimage\">\n"
      puts "  <div class=\"sideimage-image\" style=\"float:#{side};text-align:center;width:#{boxwidth}\">\n"
      puts "    <img src=\"#{filepath}\" class=\"#{imgclass}\" style=\"width:#{imgwidth}\"/>\n"
      puts "  </div>\n"
      puts "  <div class=\"sideimage-text\" style=\"margin-#{side}:#{boxwidth}\">\n"
      puts "    <div style=\"padding-#{side}:#{sepwidth}\">\n"
      yield
      puts "    </div>\n"
      puts "  </div>\n"
      puts "</div>\n"
    end

    #### ブロック命令

    def footnote(id, str)
      id_val = "fn-#{normalize_id(id)}"
      href   = "#fnb-#{normalize_id(id)}"
      text   = compile_inline(str)
      chap_num = @chapter.footnote(id).number
      if @book.config['epubversion'].to_i == 3
        attr = " epub:type=\"footnote\""
        mark = "[*#{chap_num}]"
      else
        attr = ""
        mark = "[<a href=\"#{href}\">*#{chap_num}</a>]"
      end
      #
      if truncate_if_endwith?("</div><!--/.footnote-list-->\n")
      else
        puts "<div class=\"footnote-list\">"
      end
      print "<div class=\"footnote\" id=\"#{id_val}\"#{attr}>"
      print "<p class=\"footnote\">"
      print "<span class=\"footnote-mark\">#{mark} </span>"
      print text
      print "</p>"
      puts  "</div>"
      puts  "</div><!--/.footnote-list-->\n"
    end

    ## 章 (Chapter) の概要
    def abstract(lines)
      puts '<div class="abstract">'
      puts lines
      puts '</div>'
    end

    ## 章タイトルを独立したページに
    def makechaptitlepage(lines)
      puts ''   # HTMLでは特に何もしない
    end

    ## 引用（複数段落に対応）
    def blockquote(lines)
      puts '<blockquote class="blockquote">'
      puts lines
      puts '</blockquote>'
    end

    ## 引用（//quote{ ... //}）
    ## （入れ子対応なので、中に箇条書きや別のブロックを入れられる）
    def on_quote_block()
      puts '<blockquote class="blockquote">'
      yield
      puts '</blockquote>'
    end
    def quote(lines)
      on_quote_block() do
        puts lines
      end
    end

    ## 引用 (====[quote] ... ====[/quote])
    ## （ブロック構文ではないので、中に別のブロックや箇条書きを入れられる）
    def quote_begin(level, label, caption)
      puts '<blockquote class="blockquote">'
    end
    def quote_end(level)
      puts '</blockquote>'
    end

    ## ノート（//note{ ... //}）
    ## （入れ子対応なので、中に箇条書きや別のブロックを入れられる）
    def on_note_block(label=nil, caption=nil)
      caption, label = label, nil if caption.nil?
      if label
        puts "<div class=\"note\" id=\"#{label}\">"
      else
        puts "<div class=\"note\">"
      end
      puts "<h5>#{caption}</h5>" if caption.present?
      yield
      puts "</div>"
    end
    def note(lines, label=nil, caption=nil)
      on_quote_block(label, caption) do
        puts lines
      end
    end

    ## ノート (====[note] ... ====[/note])
    ## （ブロック構文ではないので、中に別のブロックや箇条書きを入れられる）
    def note_begin(level, label, caption)
      s = compile_inline(caption || "")
      puts "<div class=\"note\">"
      puts "<h5>#{s}</h5>" if s.present?
    end
    def note_end(level)
      puts "</div>"
    end

    #### インライン命令

    ## 引数をそのまま表示 (No Operation)
    def inline_nop(str)
      escape_html(str || "")
    end
    alias inline_letitgo inline_nop

    ## 目立たせない（@<strong>{} の反対）
    def inline_weak(str)
      "<span class=\"weak\">#{escape_html(str)}</span>"
    end

    ## 文字を小さくする
    def inline_small(str)   ; "<small style=\"font-size:small\">#{escape(str)}</small>"   ; end
    def inline_xsmall(str)  ; "<small style=\"font-size:x-small\">#{escape(str)}</small>" ; end
    def inline_xxsmall(str) ; "<small style=\"font-size:xx-small\">#{escape(str)}</small>"; end

    ## 文字を大きくする
    def inline_large(str)   ; "<span style=\"font-size:large\">#{escape(str)}</span>"   ; end
    def inline_xlarge(str)  ; "<span style=\"font-size:x-large\">#{escape(str)}</span>" ; end
    def inline_xxlarge(str) ; "<span style=\"font-size:xx-large\">#{escape(str)}</span>"; end

    ## 文字を大きくした@<strong>{}
    def inline_xstrong(str) ; "<span style=\"font-size:x-large\">#{inline_strong(str)}</span>"; end
    def inline_xxstrong(str); "<span style=\"font-size:xx-large\">#{inline_strong(str)}</span>"; end

    ## コードブロック中で折り返し箇所を手動で指定する
    def inline_foldhere(arg)
      '<br>'
    end

    ## ターミナルでのカーソル（背景が白、文字が黒）
    def inline_cursor(str)
      "<span class=\"cursor\">#{escape_html(str)}</span>"
    end

    ## nestable inline commands

    def on_inline_i()     ; "<i>#{yield}</i>"           ; end
    def on_inline_b()     ; "<b>#{yield}</b>"           ; end
    def on_inline_code()  ; "<code>#{yield}</code>"     ; end
    def on_inline_tt()    ; "<tt>#{yield}</tt>"         ; end
    def on_inline_del()   ; "<s>#{yield}</s>"           ; end
    def on_inline_sub()   ; "<sub>#{yield}</sub>"       ; end
    def on_inline_sup()   ; "<sup>#{yield}</sup>"       ; end
    def on_inline_em()    ; "<em>#{yield}</em>"         ; end
    def on_inline_strong(); "<strong>#{yield}</strong>" ; end
    def on_inline_u()     ; "<u>#{yield}</u>"           ; end
    def on_inline_ami()   ; "<span class=\"ami\">#{yield}</span>"; end
    def on_inline_balloon(); "<span class=\"balloon\">#{yield}</span>"; end

    def build_inline_href(url, escaped_label)  # compile_href()をベースに改造
      if @book.config['externallink']
        label = escaped_label || escape_html(url)
        "<a href=\"#{escape_html(url)}\" class=\"link\">#{label}</a>"
      elsif escaped_label
        I18n.t('external_link', [escaped_label, escape_html(url)])
      else
        escape_html(url)
      end
    end

    def build_inline_ruby(escaped_word, escaped_yomi)  # compile_ruby()をベースに改造
      pre = I18n.t('ruby_prefix'); post = I18n.t('ruby_postfix')
      if @book.htmlversion == 5
        "<ruby>#{escaped_word}<rp>#{pre}</rp><rt>#{escaped_yomi}</rt><rp>#{post}</rp></ruby>"
      else
        "<ruby><rb>#{escaped_word}</rb><rp>#{pre}</rp><rt>#{escaped_yomi}</rt><rp>#{post}</rp></ruby>"
      end
    end

    protected

    ## ノートを参照する
    def build_noteref(chapter, label, caption)
      href = chapter ? "#{chapter.id}#{extname()}##{label}" : "##{label}"
      %Q`ノート「<a href="#{href}">#{escape(caption)}</a>」`
    end

  end


  class TEXTBuilder

    ## nestable inline commands

    def on_inline_i()     ; "<i>#{yield}</i>"           ; end
    def on_inline_b()     ; "<b>#{yield}</b>"           ; end
    def on_inline_code()  ; "<code>#{yield}</code>"     ; end
    def on_inline_tt()    ; "<tt>#{yield}</tt>"         ; end
    def on_inline_del()   ; "<s>#{yield}</s>"           ; end
    def on_inline_sub()   ; "<sub>#{yield}</sub>"       ; end
    def on_inline_sup()   ; "<sup>#{yield}</sup>"       ; end
    def on_inline_em()    ; "<em>#{yield}</em>"         ; end
    def on_inline_strong(); "<strong>#{yield}</strong>" ; end
    def on_inline_u()     ; "<u>#{yield}</u>"           ; end
    def on_inline_ami()   ; "<span class=\"ami\">#{yield}</span>"; end

    def build_inline_href(url, escaped_label)  # compile_href()をベースに改造
      if @book.config['externallink']
        label = escaped_label || escape_html(url)
        "<a href=\"#{escape_html(url)}\" class=\"link\">#{label}</a>"
      elsif escaped_label
        I18n.t('external_link', [escaped_label, escape_html(url)])
      else
        escape_html(url)
      end
    end

    def build_inline_ruby(escaped_word, escaped_yomi)  # compile_ruby()をベースに改造
      pre = I18n.t('ruby_prefix'); post = I18n.t('ruby_postfix')
      if @book.htmlversion == 5
        "<ruby>#{escaped_word}<rp>#{pre}</rp><rt>#{escaped_yomi}</rt><rp>#{post}</rp></ruby>"
      else
        "<ruby><rb>#{escaped_word}</rb><rp>#{pre}</rp><rt>#{escaped_yomi}</rt><rp>#{post}</rp></ruby>"
      end
    end

    ## その他

    def inline_nop(str)
      str || ''
    end
    alias inline_letitgo inline_nop

  end


end
