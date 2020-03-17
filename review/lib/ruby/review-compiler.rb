# -*- coding: utf-8 -*-

###
### ReVIEW::Compilerクラスとその関連クラスを拡張する
###

require 'set'
require 'review/compiler'


module ReVIEW

  defined?(Compiler)  or raise "internal error: Compiler not found."


  class Compiler

    ## ブロック命令
    defblock :program, 0..3      ## プログラム
    defblock :terminal, 0..3     ## ターミナル
    defblock :sideimage, 2..3    ## テキストの横に画像を表示
    defblock :abstract, 0        ## 章の概要
    defblock :makechaptitlepage, 0..1, true ## 章タイトルを独立したページに
    defblock :list, 0..3         ## （上書き）
    defblock :listnum, 0..3      ## （上書き）
    defblock :note, 0..2         ## （上書き）

    ## インライン命令
    definline :balloon           ## コード内でのふきだし説明（Re:VIEW3から追加）
    definline :secref            ## 節(Section)や項(Subsection)を参照
    definline :noteref           ## ノートを参照
    definline :nop               ## 引数をそのまま表示 (No Operation)
    definline :letitgo           ## （nopのエイリアス名）
    definline :foldhere          ## 折り返し箇所を手動で指定
    definline :cursor            ## ターミナルでのカーソル
    definline :weak              ## 目立たせない（@<strong>{} の反対）
    definline :small             ## 文字サイズを小さく
    definline :xsmall            ## 文字サイズをもっと小さく
    definline :xxsmall           ## 文字サイズをもっともっと小さく
    definline :large             ## 文字サイズを大きく
    definline :xlarge            ## 文字サイズをもっと大きく
    definline :xxlarge           ## 文字サイズをもっともっと大きく
    definline :xstrong           ## 文字を大きくした@<strong>{}
    definline :xxstrong          ## 文字をもっと大きくした@<strong>{}

    private

    ## パーサを再帰呼び出しに対応させる

    def do_compile
      f = LineInput.new(StringIO.new(@chapter.content))
      @strategy.bind self, @chapter, Location.new(@chapter.basename, f)
      tagged_section_init
      parse_document(f, false)
      close_all_tagged_section
    end

    def parse_document(f, block_cmd)
      while f.next?
        case f.peek
        when /\A\#@/
          f.gets # Nothing to do
        when /\A=+[\[\s\{]/
          if block_cmd                      #+
            line = f.gets                   #+
            error "'#{line.strip}': should close '//#{block_cmd}' block before sectioning." #+
          end                               #+
          compile_headline f.gets
        #when /\A\s+\*/                     #-
        #  compile_ulist f                  #-
        when LIST_ITEM_REXP                 #+
          compile_list(f)                   #+
        when /\A\s+\d+\./
          compile_olist f
        when /\A\s*:\s/
          compile_dlist f
        when %r{\A//\}}
          return if block_cmd               #+
          f.gets
          #error 'block end seen but not opened'                   #-
          error "'//}': block-end found, but no block command opened."  #+
        #when %r{\A//[a-z]+}                       #-
        #  name, args, lines = read_command(f)     #-
        #  syntax = syntax_descriptor(name)        #-
        #  unless syntax                           #-
        #    error "unknown command: //#{name}"    #-
        #    compile_unknown_command args, lines   #-
        #    next                                  #-
        #  end                                     #-
        #  compile_command syntax, args, lines     #-
        when /\A\/\/\w+/                           #+
          parse_block_command(f)                   #+
        when %r{\A//}
          line = f.gets
          warn "`//' seen but is not valid command: #{line.strip.inspect}"
          if block_open?(line)
            warn 'skipping block...'
            read_block(f, false)
          end
        else
          if f.peek.strip.empty?
            f.gets
            next
          end
          compile_paragraph f
        end
      end
    end

    ## コードブロックのタブ展開を、LaTeXコマンドの展開より先に行うよう変更。
    ##
    ## ・たとえば '\\' を '\\textbackslash{}' に展開してからタブを空白文字に
    ##   展開しても、正しい展開にはならないことは明らか。先にタブを空白文字に
    ##   置き換えてから、'\\' を '\\textbackslash{}' に展開すべき。
    ## ・またタブ文字の展開は、本来はBuilderではなくCompilerで行うべきだが、
    ##   Re:VIEWの設計がまずいのでそうなっていない。
    ## ・'//table' と '//embed' ではタブ文字の展開は行わない。
    def read_block_for(cmdname, f)   # 追加
      disable_comment = cmdname == :embed    # '//embed' では行コメントを読み飛ばさない
      ignore_inline   = cmdname == :embed    # '//embed' ではインライン命令を解釈しない
      enable_detab    = cmdname !~ /\A(?:em)?table\z/  # '//table' ではタブ展開しない
      f.enable_comment(false) if disable_comment
      lines = read_block(f, ignore_inline, enable_detab)
      f.enable_comment(true)  if disable_comment
      return lines
    end
    def read_block(f, ignore_inline, enable_detab=true)   # 上書き
      head = f.lineno
      buf = []
      builder = @strategy                            #+
      f.until_match(%r{\A//\}}) do |line|
        if ignore_inline
          buf.push line
        elsif line !~ /\A\#@/
          #buf.push text(line.rstrip)                #-
          line = line.rstrip                         #+
          line = builder.detab(line) if enable_detab #+
          buf << text(line)                          #+
        end
      end
      unless %r{\A//\}} =~ f.peek
        error "unexpected EOF (block begins at: #{head})"
        return buf
      end
      f.gets # discard terminator
      buf
    end

    ## ブロック命令を入れ子可能に変更（'//note' と '//quote'）

    def parse_block_command(f)
      line = f.gets()
      lineno = f.lineno
      line =~ /\A\/\/(\w+)(\[.*\])?(\{)?$/  or
        error "'#{line.strip}': invalid block command format."
      cmdname = $1.intern; argstr = $2; curly = $3
      ##
      prev = @strategy.doc_status[cmdname]
      @strategy.doc_status[cmdname] = true
      ## 引数を取り出す
      syntax = syntax_descriptor(cmdname)  or
        error "'//#{cmdname}': unknown command"
      args = parse_args(argstr || "", cmdname)
      begin
        syntax.check_args args
      rescue CompileError => err
        error err.message
      end
      ## ブロックをとらないコマンドにブロックが指定されていたらエラー
      if curly && !syntax.block_allowed?
        error "'//#{cmdname}': this command should not take block (but given)."
      end
      ## ブロックの入れ子をサポートしてあれば、再帰的にパースする
      handler = "on_#{cmdname}_block"
      builder = @strategy
      if builder.respond_to?(handler)
        if curly
          builder.__send__(handler, *args) do
            parse_document(f, cmdname)
          end
          s = f.peek()
          f.peek() =~ /\A\/\/}/  or
            error "'//#{cmdname}': not closed (reached to EOF)"
          f.gets()   ## '//}' を読み捨てる
        else
          builder.__send__(handler, *args)
        end
      ## そうでなければ、従来と同じようにパースする
      elsif builder.respond_to?(cmdname)
        if !syntax.block_allowed?
          builder.__send__(cmdname, *args)
        elsif curly
          lines = read_block_for(cmdname, f)
          builder.__send__(cmdname, lines, *args)
        else
          lines = default_block(syntax)
          builder.__send__(cmdname, lines, *args)
        end
      else
        error "'//#{cmdname}': #{builder.class.name} not support this command"
      end
      ##
      @strategy.doc_status[cmdname] = prev
    end

    ## 箇条書きの文法を拡張

    LIST_ITEM_REXP = /\A( +)(\*+|\-+) +/    # '*' は unordred list、'-' は ordered list

    def compile_list(f)
      line = f.gets()
      line =~ LIST_ITEM_REXP
      indent = $1
      char = $2[0]
      $2.length == 1  or
        error "#{$2[0]=='*'?'un':''}ordered list should start with level 1"
      line = parse_list(f, line, indent, char, 1)
      f.ungets(line)
    end

    def parse_list(f, line, indent, char, level)
      if char != '*' && line =~ LIST_ITEM_REXP
        start_num, _ = $'.lstrip().split(/\s+/, 2)
      end
      st = @strategy
      char == '*' ? st.ul_begin { level } : st.ol_begin(start_num) { level }
      while line =~ LIST_ITEM_REXP  # /\A( +)(\*+|\-+) +/
        $1 == indent  or
          error "mismatched indentation of #{$2[0]=='*'?'un':''}ordered list"
        mark = $2
        text = $'
        if mark.length == level
          break unless mark[0] == char
          line = parse_item(f, text.lstrip(), indent, char, level)
        elsif mark.length < level
          break
        else
          raise "internal error"
        end
      end
      char == '*' ? st.ul_end { level } : st.ol_end { level }
      return line
    end

    def parse_item(f, text, indent, char, level)
      if char != '*'
        num, text = text.split(/\s+/, 2)
        text ||= ''
      end
      #
      buf = [parse_text(text)]
      while (line = f.gets()) && line =~ /\A( +)/ && $1.length > indent.length
        buf << parse_text(line)
      end
      #
      st = @strategy
      char == '*' ? st.ul_item_begin(buf) : st.ol_item_begin(buf, num)
      rexp = LIST_ITEM_REXP  # /\A( +)(\*+|\-+) +/
      while line =~ rexp && $2.length > level
        $2.length == level + 1  or
          error "invalid indentation level of (un)ordred list"
        line = parse_list(f, line, indent, $2[0], $2.length)
      end
      char == '*' ? st.ul_item_end() : st.ol_item_end()
      #
      return line
    end

    public

    ## 入れ子のインライン命令をパースできるよう上書き
    def parse_text(line)
      stack      = []
      tag_name   = nil
      close_char = nil
      items      = [""]
      nestable   = true
      scan_inline_command(line) do |text, s1, s2, s3|
        if s1     # ex: '@<code>{', '@<b>{', '@<m>$'
          if nestable
            items << text
            stack.push([tag_name, close_char, items])
            s1 =~ /\A@<(\w+)>([{$|])\z/  or raise "internal error"
            tag_name   = $1
            close_char = $2 == '{' ? '}' : $2
            items      = [""]
            nestable   = false if ignore_nested_inline_command?(tag_name)
          else
            items[-1] << text << s1
          end
        elsif s2  # '\}' or '\\' (not '\$' nor '\|')
          text << (close_char == '}' ? s2[1] : s2)
          items[-1] << text
        elsif s3  # '}', '$', or '|'
          items[-1] << text
          if close_char == s3
            items.delete_if {|x| x.empty? }
            elem = [tag_name, {}, items]
            tag_name, close_char, items = stack.pop()
            items << elem << ""
            nestable = true
          else
            items[-1] << s3
          end
        else
          if items.length == 1 && items[-1].empty?
            items[-1] = text
          else
            items[-1] << text
          end
        end
      end
      if tag_name
        error "inline command '@<#{tag_name}>' not closed."
      end
      items.delete_if {|x| x.empty? }
      #
      return compile_inline_command(items)
    end

    alias text parse_text

    private

    def scan_inline_command(line)
      pos = 0
      line.scan(/(\@<\w+>[{$|])|(\\[\\}])|([}$|])/) do
        m = Regexp.last_match
        text = line[pos, m.begin(0)-pos]
        pos = m.end(0)
        yield text, $1, $2, $3
      end
      remained = pos == 0 ? line : line[pos..-1]
      yield remained, nil, nil, nil
    end

    def compile_inline_command(items)
      buf = ""
      strategy = @strategy
      items.each do |x|
        case x
        when String
          buf << strategy.nofunc_text(x)
        when Array
          tag_name, attrs, children = x
          op = tag_name
          inline_defined?(op)  or
            raise CompileError, "no such inline op: #{op}"
          if strategy.respond_to?("on_inline_#{op}")
            buf << strategy.__send__("on_inline_#{op}") {|both_p|
              if !both_p
                compile_inline_command(children)
              else
                [compile_inline_command(children), children]
              end
            }
          elsif strategy.respond_to?("inline_#{op}")
            children.empty? || children.all? {|x| x.is_a?(String) }  or
              error "'@<#{op}>' does not support nested inline commands."

            buf << strategy.__send__("inline_#{op}", children[0])
          else
            error "strategy does not support inline op: @<#{op}>"
          end
        else
          raise "internal error: x=#{x.inspect}"
        end
      end
      buf
    end

    def ignore_nested_inline_command?(tag_name)
      return IGNORE_NESTED_INLINE_COMMANDS.include?(tag_name)
    end

    IGNORE_NESTED_INLINE_COMMANDS = Set.new(['m', 'raw', 'embed'])

  end


  ## コメント「#@#」を読み飛ばす（ただし //embed では読み飛ばさない）
  class LineInput

    def initialize(f)
      super
      @enable_comment = true
    end

    def enable_comment(flag)
      @enable_comment = flag
    end

    def gets
      line = super
      if @enable_comment
        while line && line =~ /\A\#\@\#/
          line = super
        end
      end
      return line
    end

  end


  class Catalog

    def parts_with_chaps
      ## catalog.ymlの「CHAPS:」がnullのときエラーになるのを防ぐ
      (@yaml['CHAPS'] || []).flatten.compact
    end

  end


  class Book::ListIndex

    ## '//program' と '//terminal' をサポートするよう拡張
    def self.item_type  # override
      #'(list|listnum)'            # original
      '(list|listnum|program|terminal)'
    end

    ## '//list' や '//terminal' のラベル（第1引数）を省略できるよう拡張
    def self.parse(src, *args)  # override
      items = []
      seq = 1
      src.grep(%r{\A//#{item_type}}) do |line|
        if id = line.slice(/\[(.*?)\]/, 1)
          next if id.empty?                     # 追加
          items.push item_class.new(id, seq)
          seq += 1
          ReVIEW.logger.warn "warning: no ID of #{item_type} in #{line}" if id.empty?
        end
      end
      new(items, *args)
    end

  end


  ## ノートブロック（//note）のラベル用
  class Book::NoteIndex < Book::Index   # create new class for '//note'
    Item = Struct.new(:id, :caption)

    def self.parse(src_lines)
      rexp = /\A\/\/note\[([^\]]+)\]\[(.*?[^\\])\]/ # $1: label, $2: caption
      items = src_lines.grep(rexp) {|line|
        label = $1.strip(); caption = $2.gsub(/\\\]/, ']')
        next if label.empty?
        label =~ /\A[-_a-zA-Z0-9]+\z/  or
          error "'#{line}': invalid label (only alphabet, number, '_' or '-' available)"
        Item.new(label, caption)
      }.compact()
      self.new(items)
    end

  end


  module Book::Compilable

    def note(id)
      note_index()[id]
    end

    def note_index
      @note_index ||= Book::NoteIndex.parse(lines())
      @note_index
    end

    def content   # override
      ## //list[?] や //terminal[?] の '?' をランダム文字列に置き換える。
      ## こうすると、重複しないラベルをいちいち指定しなくても、ソースコードや
      ## ターミナルにリスト番号がつく。ただし @<list>{} での参照はできない。
      unless @_done
        pat = Book::ListIndex.item_type  # == '(list|listnum|program|terminal)'
        @content = @content.gsub(/^\/\/#{pat}\[\?\]/) { "//#{$1}[#{_random_label()}]" }
        ## 改行コードを「\n」に統一する
        @content = @content.gsub(/\r\n/, "\n")
        ## (experimental) 範囲コメント（'#@+++' '#@---'）を行コメント（'#@#'）に変換
        @content = @content.gsub(/^\#\@\+\+\+$.*?^\#\@\-\-\-$/m) { $&.gsub(/^/, '#@#') }
        @_done = true
      end
      @content
    end

    module_function

    def _random_label
      "_" + rand().to_s[2..10]
    end

  end


end
