# -*- coding: utf-8 -*-

##
## ReVIEW::LATEXBuilderクラスを拡張する
##

require 'review/latexbuilder'


module ReVIEW

  defined?(LATEXBuilder)  or raise "internal error: LATEXBuilder not found."


  class LATEXBuilder

    ## 章や節や項や目のタイトル
    alias __original_headline headline
    def headline(level, label, caption)
      return with_context(:headline) do
        __original_headline(level, label, caption)
      end
    end

    ## テーブルヘッダー
    alias __original_table_header table_header
    def table_header(id, caption)
      return with_context(:caption) do
        __original_table_header(id, caption)
      end
    end

    ## 改行命令「\\」のあとに改行文字「\n」を置かない。
    ##
    ## 「\n」が置かれると、たとえば
    ##
    ##     foo@<br>{}
    ##     bar
    ##
    ## が
    ##
    ##     foo\\
    ##
    ##     bar
    ##
    ## に展開されてしまう。
    ## つまり改行のつもりが改段落になってしまう。
    def inline_br(_str)
      #"\\\\\n"   # original
      "\\\\{}"
    end


    ## コードブロック（//program, //terminal）

    def program(lines, id=nil, caption=nil, optionstr=nil)
      _codeblock('program', lines, id, caption, optionstr)
    end

    def terminal(lines, id=nil, caption=nil, optionstr=nil)
      _codeblock('terminal', lines, id, caption, optionstr)
    end

    protected

    FONTSIZES = {
      "small"    => "small",
      "x-small"  => "footnotesize",
      "xx-small" => "scriptsize",
      "large"    => "large",
      "x-large"  => "Large",
      "xx-large" => "LARGE",
    }

    ## コードブロック（//program, //terminal）
    def _codeblock(blockname, lines, id, caption, optionstr)
      ## ブロックコマンドのオプション引数はCompilerクラスでパースすべき。
      ## しかしCompilerクラスがそのような設計になってないので、
      ## 仕方ないのでBuilderクラスでパースする。
      opts = _parse_codeblock_optionstr(optionstr, blockname)
      CODEBLOCK_OPTIONS.each {|k, v| opts[k] = v unless opts.key?(k) }
      #
      if opts['eolmark']
        lines = lines.map {|line| "#{detab(line)}\\startereolmark{}" }
      else
        lines = lines.map {|line| detab(line) }
      end
      #
      if opts['indentwidth'] && opts['indentwidth'] > 0
        indent_w   = opts['indentwidth']
        indent_str = " " * (indent_w - 1) + "{\\starterindentchar}"
        lines = lines.map {|line|
          line.sub(/\A( +)/) {
            m, n = ($1.length - 1).divmod indent_w
            " " << indent_str * m << " " * n
          }
        }
      end
      #
      if id.present? || caption.present?
        caption_str = _build_caption_str(id, caption)
      else
        caption_str = nil
      end
      #
      fontsize = FONTSIZES[opts['fontsize']]
      print "\\def\\startercodeblockfontsize{#{fontsize}}\n"
      #
      environ = "starter#{blockname}"
      print "\\begin{#{environ}}[#{id}]{#{caption_str}}"
      print "\\startersetfoldmark{}" unless opts['foldmark']
      if opts['eolmark']
        print "\\startereolmarkdark{}"  if blockname == 'terminal'
        print "\\startereolmarklight{}" if blockname != 'terminal'
      end
      if opts['lineno']
        gen = LineNumberGenerator.new(opts['lineno'])
        width = opts['linenowidth']
        if width && width >= 0
          if width == 0
            last_lineno = gen.each.take(lines.length).compact.last
            width = last_lineno.to_s.length
          end
          print "\\startersetfoldindentwidth{#{'9'*(width+2)}}"
          format = "\\textcolor{gray}{%#{width}s:} "
        else
          format = "\\starterlineno{%s}"
        end
        buf = []
        opt_fold = opts['fold']
        lines.zip(gen).each do |x, n|
          buf << ( opt_fold \
                   ? "#{format % n.to_s}\\seqsplit{#{x}}" \
                   : "#{format % n.to_s}#{x}" )
        end
        print buf.join("\n")
      else
        print "\\seqsplit{"       if opts['fold']
        print lines.join("\n")
        print "}"                 if opts['fold']
      end
      puts "\\end{#{environ}}"
      nil
    end

    public

    ## ・\caption{} のかわりに \reviewimagecaption{} を使うよう修正
    ## ・「scale=X」に加えて「pos=X」も受け付けるように拡張
    def image_image(id, caption, option_str)
      pos = nil; border = nil; arr = []
      _each_block_option(option_str) do |k, v|
        case k
        when 'pos'
          v =~ /\A[Hhtb]+\z/  or  # H: Here, h: here, t: top, b: bottom
            raise "//image[][][pos=#{v}]: expected 'pos=H' or 'pos=h'."
          pos = v     # detect 'pos=H' or 'pos=h'
        when 'border', 'draft'
          case v
          when nil  ; flag = true
          when 'on' ; flag = true
          when 'off'; flag = false
          else
            raise "//image[][][#{k}=#{v}]: expected '#{k}=on' or '#{k}=off'"
          end
          border = flag          if k == 'border'
          arr << "draft=#{flag}" if k == 'draft'
        else
          arr << (v.nil? ? k : "#{k}=#{v}")
        end
      end
      #
      metrics = parse_metric('latex', arr.join(","))
      puts "\\begin{reviewimage}[#{pos}]%%#{id}" if pos
      puts "\\begin{reviewimage}%%#{id}"     unless pos
      metrics = "width=\\maxwidth" unless metrics.present?
      puts "\\starterimageframe{%" if border
      puts "\\includegraphics[#{metrics}]{#{@chapter.image(id).path}}%"
      puts "}%"                    if border
      with_context(:caption) do
        #puts macro('caption', compile_inline(caption)) if caption.present?  # original
        puts macro('reviewimagecaption', compile_inline(caption)) if caption.present?
      end
      puts macro('label', image_label(id))
      puts "\\end{reviewimage}"
    end

    def _build_secref(chap, num, title, parent_title)
      s = ""
      ## 親セクションのタイトルがあれば使う
      if parent_title && @book.config['starter']['secref_parenttitle']
        s << "「%s」内の" % parent_title   # TODO: I18n化
      end
      ## 対象セクションへのリンクを作成する
      if @book.config['chapterlink']
        label = "sec:" + num.gsub('.', '-')
        level = num.split('.').length
        case level
        when 2 ; s << "\\startersecref{#{title}}{#{label}}"
        when 3 ; s << "\\startersubsecref{#{title}}{#{label}}"
        when 4 ; s << "\\startersubsubsecref{#{title}}{#{label}}"
        else
          raise "#{num}: unexpected section level (expected: 2~4)."
        end
      else
        s << title
      end
      return s
    end

    ###

    public

    def ul_begin
      blank
      puts '\begin{starteritemize}'    # instead of 'itemize'
    end

    def ul_end
      puts '\end{starteritemize}'      # instead of 'itemize'
      blank
    end

    def ol_begin(start_num=nil)
      blank
      puts '\begin{starterenumerate}'  # instead of 'enumerate'
      if start_num.nil?
        return true unless @ol_num
        puts "\\setcounter{enumi}{#{@ol_num - 1}}"
        @ol_num = nil
      end
    end

    def ol_end
      puts '\end{starterenumerate}'    # instead of 'enumerate'
      blank
    end

    def ol_item_begin(lines, num)
      str = lines.join
      num = escape(num).sub(']', '\rbrack{}')
      puts "\\item[#{num}] #{str}"
    end

    def ol_item_end()
    end

    ## コラム

    def column_begin(level, label, caption)
      blank
      @doc_status[:column] = true
      puts "\\begin{reviewcolumn}\n"
      puts "\\phantomsection   % for hyperref"   #+
      if label
        puts "\\hypertarget{#{column_label(label)}}{}"
      else
        puts "\\hypertarget{#{column_label(caption)}}{}"
      end
      @doc_status[:caption] = true
      puts macro('reviewcolumnhead', nil, compile_inline(caption))
      @doc_status[:caption] = nil
      if level <= @book.config['toclevel'].to_i
        #puts "\\addcontentsline{toc}{#{HEADLINE[level]}}{#{compile_inline(caption)}}" #-
        puts "\\addcontentsline{toc}{#{HEADLINE[level]}}{\\numberline{#{toc_column()}}#{compile_inline(caption)}}" #+
      end
    end

    def toc_column
      #escape('コラム:')
      escape('[コラム]')
    end

    #### ブロック命令

    ## 導入文（//lead{ ... //}）のデザインをLaTeXのスタイルファイルで
    ## 変更できるよう、マクロを使う。
    def lead(lines)
      puts '\begin{starterlead}'   # オリジナルは \begin{quotation}
      puts lines
      puts '\end{starterlead}'
    end

    ## 章 (Chapter) の概要
    ## （導入文 //lead{ ... //} と似ているが、導入文では詩や物語を
    ##   引用するのが普通らしく、概要 (abstract) とは違うみたいなので、
    ##   概要を表すブロックを用意した。）
    def abstract(lines)
      puts '\begin{starterabstract}'
      puts lines
      puts '\end{starterabstract}'
    end

    ## 章タイトルを独立したページに
    def makechaptitlepage(lines, option)
      case option
      when nil, ""  ;
      when 'toc=section', 'toc=subsection' ;
      when 'toc'
      else
        raise ArgumentError.new("//makechaptitlepage[#{option}]: unknown option (expected 'toc=section' or 'toc=subsection').")
      end
      puts "\\makechaptitlepage{#{option}}"
    end

    ## 引用（複数段落に対応）
    ## （入れ子対応なので、中に箇条書きや別のブロックを入れられる）
    def on_quote_block()
      puts '\begin{starterquote}'
      yield
      puts '\end{starterquote}'
    end
    def quote(lines)
      on_quote_block() do
        puts lines
      end
    end

    ## 引用 (====[quote] ... ====[/quote])
    ## （ブロック構文ではないので、中に箇条書きや別のブロックを入れられる）
    def quote_begin(level, label, caption)
      puts '\begin{starterquote}'
    end
    def quote_end(level)
      puts '\end{starterquote}'
    end

    ## ノート（//note[caption]{ ... //}）
    ## （入れ子対応なので、中に箇条書きや別のブロックを入れられる）
    def on_note_block(label=nil, caption=nil)
      caption, label = label, nil if caption.nil?
      s = compile_inline(caption || "")
      puts "\\begin{starternote}[#{label}]{#{s}}"
      yield
      puts "\\end{starternote}"
    end
    def note(lines, label=nil, caption=nil)
      on_note_block(label, caption) do
        puts lines
      end
    end

    ## ノート (====[note] ... ====[/note])
    ## （ブロック構文ではないので、中に箇条書きや別のブロックを入れられる）
    def note_begin(level, label, caption)
      enter_context(:note)
      s = compile_inline(caption || "")
      puts "\\begin{starternote}[#{label}]{#{s}}"
    end
    def note_end(level)
      puts "\\end{starternote}"
      exit_context(:note)
    end

    ## コードリスト（//list, //emlist, //listnum, //emlistnum, //cmd, //source）
    ## TODO: code highlight support
    def list(lines, id=nil, caption=nil, lang=nil)
      program(lines, id, caption, _codeblock_optstr(lang, false))
    end
    def listnum(lines, id=nil, caption=nil, lang=nil)
      program(lines, id, caption, _codeblock_optstr(lang, true))
    end
    def emlist(lines, caption=nil, lang=nil)
      program(lines, nil, caption, _codeblock_optstr(lang, false))
    end
    def emlistnum(lines, caption=nil, lang=nil)
      program(lines, nil, caption, _codeblock_optstr(lang, true))
    end
    def source(lines, caption=nil, lang=nil)
      program(lines, nil, caption, _codeblock_optstr(lang, false))
    end
    def cmd(lines, caption=nil, lang=nil)
      terminal(lines, nil, caption, _codeblock_optstr(lang, false))
    end
    def _codeblock_optstr(lang, lineno_flag)
      arr = []
      arr << lang if lang
      if lineno_flag
        first_line_num = line_num
        arr << "lineno=#{first_line_num}"
        arr << "linenowidth=0"
      end
      return arr.join(",")
    end
    private :_codeblock_optstr


    ## 入れ子可能なブロック命令

    def on_minicolumn(type, caption, &b)
      puts "\\begin{reviewminicolumn}\n"
      if caption.present?
        @doc_status[:caption] = true
        puts "\\reviewminicolumntitle{#{compile_inline(caption)}}\n"
        @doc_status[:caption] = nil
      end
      yield
      puts "\\end{reviewminicolumn}\n"
    end
    protected :on_minicolumn

    def on_sideimage_block(imagefile, imagewidth, option_str=nil, &b)
      imagefile, imagewidth, opts = validate_sideimage_args(imagefile, imagewidth, option_str)
      filepath = find_image_filepath(imagefile)
      side     = opts['side'] || 'L'
      normalize = proc {|s|
        s =~ /\A(\d+(?:\.\d+)?)(%|mm|cm)\z/
        if    $2.nil?   ; s
        elsif $2 == '%' ; "#{$1.to_f/100.0}\\textwidth"
        else            ; "#{$1}true#{$2}"
        end
      }
      imgwidth = normalize.call(imagewidth)
      boxwidth = normalize.call(opts['boxwidth']) || imgwidth
      sepwidth = normalize.call(opts['sep'] || "0pt")
      puts "{\n"
      puts "  \\def\\starterminiimageframe{Y}\n" if opts['border']
      puts "  \\begin{startersideimage}{#{side}}{#{filepath}}{#{imgwidth}}{#{boxwidth}}{#{sepwidth}}{}\n"
      yield
      puts "  \\end{startersideimage}\n"
      puts "}\n"
    end

    #### インライン命令

    ## 引数をそのまま表示
    ## 例：
    ##   //emlist{
    ##     @<b>{ABC}             ← 太字の「ABC」が表示される
    ##     @<nop>$@<b>{ABC}$ ← 「@<b>{ABC}」がそのまま表示される
    ##   //}
    def inline_nop(str)
      escape(str || "")
    end
    alias inline_letitgo inline_nop

    ## 目立たせない（@<strong>{} の反対）
    def inline_weak(str)
      inline_weak { escape(str) }
    end
    def on_inline_weak
      if within_codeblock?()
        "{\\starterweak{\\seqsplit{#{yield}}}}"
      else
        "\\starterweak{#{yield}}"
      end
    end

    ## 文字を小さくする
    def inline_small(str)   ; on_inline_small { escape(str) }  ; end
    def inline_xsmall(str)  ; on_inline_xsmall { escape(str) } ; end
    def inline_xxsmall(str) ; on_inline_xxsmall { escape(str) }; end
    def on_inline_small()   ; "{\\small{}#{yield}}"       ; end
    def on_inline_xsmall()  ; "{\\footnotesize{}#{yield}}"; end
    def on_inline_xxsmall() ; "{\\scriptsize{}#{yield}}"  ; end

    ## 文字を大きくする
    def inline_large(str)   ; on_inline_large { escape(str) }  ; end
    def inline_xlarge(str)  ; on_inline_xlarge { escape(str) } ; end
    def inline_xxlarge(str) ; on_inline_xxlarge { escape(str) }; end
    def on_inline_large()   ; "{\\large{}#{yield}}" ; end
    def on_inline_xlarge()  ; "{\\Large{}#{yield}}" ; end
    def on_inline_xxlarge() ; "{\\LARGE{}#{yield}}" ; end

    ## 文字を大きくした@<strong>{}
    def inline_xstrong(str) ; on_inline_xstring { escape(str) } ; end
    def inline_xxstrong(str); on_inline_xxstring { escape(str) }; end
    def on_inline_xstrong(&b) ; "{\\Large{}#{on_inline_strong(&b)}}" ; end
    def on_inline_xxstrong(&b); "{\\LARGE{}#{on_inline_strong(&b)}}" ; end

    ## コードブロック中で折り返し箇所を手動で指定する
    ## （\seqsplit による自動折り返し機能が日本語には効かないので、
    ##   長い行を日本語の箇所で折り返したいときは @<foldhere>{} を使う）
    def inline_foldhere(arg)
      return '\starterfoldhere{}'
    end

    ## ターミナルでのカーソル（背景が白、文字が黒）
    def inline_cursor(str)
      "{\\startercursor{#{escape(str)}}}"
    end

    ## 脚注（「//footnote」の脚注テキストを「@<fn>{}」でパースすることに注意）
    def inline_fn(id)
      if @book.config['footnotetext']
        macro("footnotemark[#{@chapter.footnote(id).number}]", '')
      else
        with_context(:footnote) { #+
          macro('footnote', compile_inline(@chapter.footnote(id).content.strip))
        }                         #+
      end
    end

    ## nestable inline commands

    def on_inline_i()     ; "{\\reviewit{#{yield}}}"       ; end
    #def on_inline_b()     ; "{\\reviewbold{#{yield}}}"     ; end
    #def on_inline_tt()    ; "{\\reviewtt{#{yield}}}"       ; end
    def on_inline_tti()   ; "{\\reviewtti{#{yield}}}"      ; end
    def on_inline_ttb()   ; "{\\reviewttb{#{yield}}}"      ; end
    #def on_inline_code()  ; "{\\reviewcode{#{yield}}}"     ; end
    #def on_inline_del()   ; "{\\reviewstrike{#{yield}}}"   ; end
    def on_inline_sub()   ; "{\\textsubscript{#{yield}}}"  ; end
    def on_inline_sup()   ; "{\\textsuperscript{#{yield}}}"; end
    def on_inline_em()    ; "{\\reviewem{#{yield}}}"       ; end
    def on_inline_strong(); "{\\reviewstrong{#{yield}}}"   ; end
    def on_inline_u()     ; "{\\reviewunderline{#{yield}}}"; end
    def on_inline_ami()   ; "{\\reviewami{#{yield}}}"      ; end
    def on_inline_balloon(); "{\\reviewballoon{#{yield}}}" ; end

    def on_inline_tt()
      ## LaTeXでは、'\texttt{}' 中の '!?:.' の直後の空白が2文字分で表示される。
      ## その問題を回避するために、' ' を '\ ' にする。
      s = yield
      s = s.gsub(/([!?:.]) /, '\\1\\ ')
      return "{\\reviewtt{#{s}}}"
    end

    def on_inline_code()
      with_context(:inline_code) {
        ## LaTeXでは、'\texttt{}' 中の '!?:.' の直後の空白が2文字分で表示される。
        ## その問題を回避するために、' ' を '\ ' にする。
        s = yield
        s = s.gsub(/([!?:.]) /, '\\1\\ ')
        ## コンテキストによって、背景色をつけないことがある
        if false
        elsif within_context?(:headline)       # 章タイトルや節タイトルでは
          "{\\reviewcode[headline]{#{s}}}"     #   背景色をつけない（かも）
        elsif within_context?(:caption)        # リストや画像のキャプションでも
          "{\\reviewcode[caption]{#{s}}}"      #   背景色をつけない（かも）
        else                                   # それ以外では
          "{\\reviewcode{#{s}}}"               #   背景色をつける（かも）
        end
      }
    end

    ## @<b>{} が //terminal{ ... //} で効くように上書き
    def inline_b(str)
      on_inline_b { escape(str) }
    end
    def on_inline_b()  # nestable
      if within_codeblock?()
        #"{\\bfseries #{yield}}"            # \seqsplit{} 内では余計な空白が入る
        #"{\\bfseries{}#{yield}}"           # \seqsplit{} 内では後続も太字化する
        "\\bfseries{}#{yield}\\mdseries{}"  # \seqsplit{} 内でうまく効く
      else
        macro('reviewbold', yield)
      end
    end

    ## @<del>{} が //list や //terminal で効くように上書き
    def inline_del(str)
      on_inline_del { escape(str) }
    end
    def on_inline_del()
      if within_codeblock?()
        #"\\reviewstrike{#{yield}}"    # \seqsplit{} 内でエラーになる
        #"{\\reviewstrike{#{yield}}}"  # \seqsplit{} 内でもエラーにならないが折り返しされない
        "{\\reviewstrike{\\seqsplit{#{yield}}}}"  # エラーにならないし、折り返しもされる
      else
        macro('reviewstrike', yield)
      end
    end

    def build_inline_href(url, escaped_label)  # compile_href()をベースに改造
      if /\A[a-z]+:/ !~ url
        "\\ref{#{url}}"
      elsif ! escaped_label.present?
        "\\url{#{escape_url(url)}}"
      elsif ! @book.config['starter']['linkurl_footnote']
        "\\href{#{escape_url(url)}}{#{escaped_label}}"
      elsif within_context?(:footnote)
        "#{escaped_label}(\\url{#{escape_url(url)}})"
      else
        "#{escaped_label}\\footnote{\\url{#{escape_url(url)}}}"
      end
    end

    def build_inline_ruby(escaped_word, escaped_yomi)  # compile_ruby()をベースに改造
      "\\ruby{#{escaped_word}}{#{escaped_yomi}}"
    end

    def inline_bou(str)
      ## original
      #str.split(//).map { |c| macro('ruby', escape(c), macro('textgt', BOUTEN)) }.join('\allowbreak')
      ## work well with XeLaTeX as well as upLaTeX
      str.split(//).map {|c| "\\ruby{#{escape(c)}}{#{BOUTEN}}" }.join('\allowbreak')
    end

    protected

    ## ノートを参照する
    def build_noteref(chapter, label, caption)
      "\\starternoteref{#{label}}{#{escape(caption)}}"
    end

  end


end
