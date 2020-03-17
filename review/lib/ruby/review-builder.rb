# -*- coding: utf-8 -*-

###
### ReVIEW::Builderクラスを拡張する
###

require 'review/builder'


module ReVIEW

  defined?(Builder)  or raise "internal error: Builder not found."


  class Builder

    ## Re:VIEW3で追加されたもの
    def on_inline_balloon(arg)
      return "← #{yield}"
    end

    ## ul_item_begin() だけあって ol_item_begin() がないのはどうかと思う。
    ## ol の入れ子がないからといって、こういう非対称な設計はやめてほしい。
    def ol_item_begin(lines, _num)
      ol_item(lines, _num)
    end
    def ol_item_end()
    end

    protected

    def truncate_if_endwith?(str)
      sio = @output   # StringIO object
      if sio.string.end_with?(str)
        pos = sio.pos - str.length
        sio.seek(pos)
        sio.truncate(pos)
        true
      else
        false
      end
    end

    def enter_context(key)
      @doc_status[key] = true
    end

    def exit_context(key)
      @doc_status[key] = nil
    end

    def with_context(key)
      enter_context(key)
      return yield
    ensure
      exit_context(key)
    end

    def within_context?(key)
      return @doc_status[key]
    end

    def within_codeblock?
      d = @doc_status
      d[:program] || d[:terminal] \
      || d[:list] || d[:emlist] || d[:listnum] || d[:emlistnum] \
      || d[:cmd] || d[:source]
    end

    ## 入れ子可能なブロック命令

    public

    def on_note_block      caption=nil, &b; on_minicolumn :note     , caption, &b; end
    def on_memo_block      caption=nil, &b; on_minicolumn :memo     , caption, &b; end
    def on_tip_block       caption=nil, &b; on_minicolumn :tip      , caption, &b; end
    def on_info_block      caption=nil, &b; on_minicolumn :info     , caption, &b; end
    def on_warning_block   caption=nil, &b; on_minicolumn :warning  , caption, &b; end
    def on_important_block caption=nil, &b; on_minicolumn :important, caption, &b; end
    def on_caution_block   caption=nil, &b; on_minicolumn :caution  , caption, &b; end
    def on_notice_block    caption=nil, &b; on_minicolumn :notice   , caption, &b; end

    def on_minicolumn(type, caption=nil, &b)
      raise NotImplementedError.new("#{self.class.name}#on_minicolumn(): not implemented yet.")
    end
    protected :on_minicolumn

    def on_sideimage_block(imagefile, imagewidth, option_str=nil, &b)
      raise NotImplementedError.new("#{self.class.name}#on_sideimage_block(): not implemented yet.")
    end

    def validate_sideimage_args(imagefile, imagewidth, option_str)
      opts = {}
      if option_str.present?
        option_str.split(',').each do |kv|
          kv.strip!
          next if kv.empty?
          kv =~ /(\w[-\w]*)=(.*)/  or
            error "//sideimage: [#{option_str}]: invalid option string."
          opts[$1] = $2
        end
      end
      #
      opts.each do |k, v|
        case k
        when 'side'
          v == 'L' || v == 'R'  or
            error "//sideimage: [#{option_str}]: 'side=' should be 'L' or 'R'."
        when 'boxwidth'
          v =~ /\A\d+(\.\d+)?(%|mm|cm|zw)\z/  or
            error "//sideimage: [#{option_str}]: 'boxwidth=' invalid (expected such as 10%, 30mm, 3.0cm, or 5zw)"
        when 'sep'
          v =~ /\A\d+(\.\d+)?(%|mm|cm|zw)\z/  or
            error "//sideimage: [#{option_str}]: 'sep=' invalid (expected such as 2%, 5mm, 0.5cm, or 1zw)"
        when 'border'
          v =~ /\A(on|off)\z/  or
            error "//sideimage: [#{option_str}]: 'border=' should be 'on' or 'off'"
          opts[k] = v == 'on' ? true : false
        else
          error "//sideimage: [#{option_str}]: unknown option '#{k}=#{v}'."
        end
      end
      #
      imagefile.present?  or
        error "//sideimage: 1st option (image file) required."
      imagewidth.present?  or
        error "//sideimage: 2nd option (image width) required."
      imagewidth =~ /\A\d+(\.\d+)?(%|mm|cm|zw|pt)\z/  or
        error "//sideimage: [#{imagewidth}]: invalid image width (expected such as: 30mm, 3.0cm, 5zw, or 100pt)"
      #
      return imagefile, imagewidth, opts
    end
    protected :validate_sideimage_args

    ## コードブロック（//program, //terminal）

    CODEBLOCK_OPTIONS = {
      'fold'   => true,
      'lineno' => false,
      'linenowidth' => -1,
      'eolmark'     => false,
      'foldmark'    => true,
      'lang'        => nil,
    }

    ## プログラム用ブロック命令
    ## ・//list と似ているが、長い行を自動的に折り返す
    ## ・seqsplit.styの「\seqsplit{...}」コマンドを使っている
    def program(lines, id=nil, caption=nil, optionstr=nil)
      _codeblock('program', lines, id, caption, optionstr)
    end

    ## ターミナル用ブロック命令
    ## ・//cmd と似ているが、長い行を自動的に折り返す
    ## ・seqsplit.styの「\seqsplit{...}」コマンドを使っている
    def terminal(lines, id=nil, caption=nil, optionstr=nil)
      _codeblock('terminal', lines, id, caption, optionstr)
    end

    protected

    def _codeblock(blockname, lines, id, caption, optionstr)
      raise NotImplementedError.new("#{self.class.name}#_codeblock(): not implemented yet.")
    end

    def _each_block_option(option_str)
      option_str.split(',').each do |kvs|
        k, v = kvs.split('=', 2)
        yield k, v
      end if option_str && !option_str.empty?
    end

    def _parse_codeblock_optionstr(optionstr, blockname)  # parse 'fold={on|off},...'
      opts = {}
      return opts if optionstr.nil? || optionstr.empty?
      vals = {nil=>true, 'on'=>true, 'off'=>false}
      optionstr.split(',').each_with_index do |x, i|
        x = x.strip()
        ## //list[][][1] は //list[][][lineno=1] とみなす
        if x =~ /\A[0-9]+\z/
          opts['lineno'] = x.to_i
          next
        end
        #
        x =~ /\A([-\w]+)(?:=(.*))?\z/  or
          raise "//#{blockname}[][][#{x}]: invalid option format."
        k, v = $1, $2
        case k
        when 'fold', 'eolmark', 'foldmark'
          if vals.key?(v)
            opts[k] = vals[v]
          else
            raise "//#{blockname}[][][#{x}]: expected 'on' or 'off'."
          end
        when 'lineno'
          if vals.key?(v)
            opts[k] = vals[v]
          elsif v =~ /\A\d+\z/
            opts[k] = v.to_i
          elsif v =~ /\A\d+-?\d*(?:\&+\d+-?\d*)*\z/
            opts[k] = v
          else
            raise "//#{blockname}[][][#{x}]: expected line number pattern."
          end
        when 'linenowidth'
          if v =~ /\A-?\d+\z/
            opts[k] = v.to_i
          else
            raise "//#{blockname}[][][#{x}]: expected integer value."
          end
        when 'fontsize'
          if v =~ /\A((x-|xx-)?small|(x-|xx-)?large)\z/
            opts[k] = v
          else
            raise "//#{blockname}[][][#{x}]: expected small/x-small/xx-small."
          end
        when 'indentwidth'
          if v =~ /\A\d+\z/
            opts[k] = v.to_i
          else
            raise "//#{blockname}[][][#{x}]: expected integer (>=0)."
          end
        when 'lang'
          if v
            opts[k] = v
          else
            raise "//#{blockname}[][][#{x}]: requires option value."
          end
        else
          if i == 0
            opts['lang'] = v
          else
            raise "//#{blockname}[][][#{x}]: unknown option."
          end
        end
      end
      return opts
    end

    def _build_caption_str(id, caption)
      str = ""
      with_context(:caption) do
        str = compile_inline(caption) if caption.present?
      end
      if id.present?
        number = _build_caption_number(id)
        prefix = "#{I18n.t('list')}#{number}#{I18n.t('caption_prefix')}"
        str = "#{prefix}#{str}"
      end
      return str
    end

    def _build_caption_number(id)
      chapter = get_chap()
      number = @chapter.list(id).number
      return chapter.nil? \
           ? I18n.t('format_number_header_without_chapter', [number]) \
           : I18n.t('format_number_header', [chapter, number])
    rescue KeyError
      error "no such list: #{id}"
    end

    public

    ## インライン命令のバグ修正

    def inline_raw(str)
      name = target_name()
      if str =~ /\A\|(.*?)\|/
        str = $'
        return "" unless $1.split(',').any? {|s| s.strip == name }
      end
      return str.gsub('\\n', "\n")
    end

    def inline_embed(str)
      name = target_name()
      if str =~ /\A\|(.*?)\|/
        str = $'
        return "" unless $1.split(',').any? {|s| s.strip == name }
      end
      return str
    end

    ## インライン命令を入れ子に対応させる

    def on_inline_href
      escaped_str, items = yield true
      url = label = nil
      separator1 = /, /
      separator2 = /(?<=[^\\}]),/  # 「\\,」はセパレータと見なさない
      [separator1, separator2].each do |sep|
        pair = items[0].split(sep, 2)
        if pair.length == 2
          url = pair[0]
          label = escaped_str.split(sep, 2)[-1]  # 「,」がエスケープされない前提
          break
        end
      end
      url ||= items[0]
      url = url.gsub(/\\,/, ',')   # 「\\,」を「,」に置換
      return build_inline_href(url, label)
    end

    def on_inline_ruby
      escaped_str = yield
      arr = escaped_str.split(', ')
      if arr.length > 1                 # ex: @<ruby>{小鳥遊, たかなし}
        yomi = arr.pop().strip()
        word = arr.join(', ')
      elsif escaped_str =~ /,([^,]*)\z/ # ex: @<ruby>{小鳥遊,たかなし}
        word, yomi = $`, $1.strip()
      else
        error "@<ruby>: missing yomi, should be '@<ruby>{word, yomi}' style."
      end
      return build_inline_ruby(word, yomi)
    end

    ## 節 (Section) や項 (Subsection) を参照する。
    ## 引数 id が節や項のラベルでないなら、エラー。
    ## 使い方： @<secref>{label}
    def inline_secref(id)  # 参考：ReVIEW::Builder#inline_hd(id)
      ## 本来、こういった処理はParserで行うべきであり、Builderで行うのはおかしい。
      ## しかしRe:VIEWのアーキテクチャがよくないせいで、こうせざるを得ない。無念。
      sec_id = id
      chapter = nil
      if id =~ /\A([^|]+)\|(.+)/
        chap_id = $1; sec_id = $2
        chapter = @book.contents.detect {|chap| chap.id == chap_id }  or
          error "@<secref>{#{id}}: chapter '#{chap_id}' not found."
      end
      begin
        _inline_secref(chapter || @chapter, sec_id)
      rescue KeyError
        error "@<secref>{#{id}}: section (or subsection) not found."
      end
    end

    private

    def _inline_secref(chap, id)
      sec_id = chap.headline(id).id
      num, title = _get_secinfo(chap, sec_id)
      level = num.split('.').length
      #
      secnolevel = @book.config['secnolevel']
      if secnolevel + 1 < level
        error "'secnolevel: #{secnolevel}' should be >= #{level-1} in config.yml"
      ## config.ymlの「secnolevel:」が3以上なら、項 (Subsection) にも
      ## 番号がつく。なので、節 (Section) のタイトルは必要ない。
      elsif secnolevel + 1 > level
        parent_title = nil
      ## そうではない場合は、節 (Section) と項 (Subsection) とを組み合わせる。
      ## たとえば、"「1.1 イントロダクション」内の「はじめに」" のように。
      elsif secnolevel + 1 == level
        parent_id = sec_id.sub(/\|[^|]+\z/, '')
        _, parent_title = _get_secinfo(chap, parent_id)
      else
        raise "not reachable"
      end
      #
      return _build_secref(chap, num, title, parent_title)
    end

    def _get_secinfo(chap, id)  # 参考：ReVIEW::LATEXBuilder#inline_hd_chap()
      num = chap.headline_index.number(id)
      caption = compile_inline(chap.headline(id).caption)
      if chap.number && @book.config['secnolevel'] >= num.split('.').size
        caption = "#{chap.headline_index.number(id)} #{caption}"
      end
      #title = I18n.t('chapter_quote', caption)
      title = caption
      return num, title
    end

    def _build_secref(chap, num, title, parent_title)
      raise NotImplementedError.new("#{self.class.name}#_build_secref(): not implemented yet.")
    end

    ##

    public

    ## ノートを参照する
    def inline_noteref(label)
      begin
        chapter, label = parse_reflabel(label)
      rescue KeyError => ex
        error "@<noteref>{#{label}}: #{ex.message}"
      end
      begin
        item = (chapter || @chapter).note(label)
      rescue KeyError => ex
        error "@<noteref>{#{label}}: note not found."
      end
      build_noteref(chapter, label, item.caption)
    end

    protected

    def build_noteref(chapter, label, caption)
      raise NotImplementedError.new("#{self.class.name}#build_noteref(): not implemented yet.")
    end

    def parse_reflabel(label)
      ## 本来ならParserで行うべきだけど仕方ない。
      chapter = nil
      if label =~ /\A([^|]+)\|(.+)/
        chap_id = $1; label = $2
        chapter = @book.contents.detect {|chap| chap.id == chap_id }  or
          raise KeyError.new("chapter '#{chap_id}' not found.")
        return chapter, label
      end
      return chapter, label
    end

    ##

    protected

    def find_image_filepath(image_id)
      finder = get_image_finder()
      filepath = finder.find_path(image_id)
      return filepath
    end

    def get_image_finder()
      imagedir = "#{@book.basedir}/#{@book.config['imagedir']}"
      types    = @book.image_types
      builder  = @book.config['builder']
      chap_id  = @chapter.id
      return ReVIEW::Book::ImageFinder.new(imagedir, chap_id, builder, types)
    end

  end


  ##
  ## 行番号を生成するクラス。
  ##
  ##   gen = LineNumberGenerator.new("1-3&8-10&15-")
  ##   p gen.each.take(15).to_a
  ##     #=> [1, 2, 3, nil, 8, 9, 10, nil, 15, 16, 17, 18, 19, 20, 21]
  ##
  class LineNumberGenerator

    def initialize(arg)
      @ranges = []
      inf = Float::INFINITY
      case arg
      when true        ; @ranges << (1 .. inf)
      when Integer     ; @ranges << (arg .. inf)
      when /\A(\d+)\z/ ; @ranges << (arg.to_i .. inf)
      else
        arg.split('&', -1).each do |str|
          case str
          when /\A\z/
            @ranges << nil
          when /\A(\d+)\z/
            @ranges << ($1.to_i .. $1.to_i)
          when /\A(\d+)\-(\d+)?\z/
            start = $1.to_i
            end_  = $2 ? $2.to_i : inf
            @ranges << (start..end_)
          else
            raise ArgumentError.new("'#{strpat}': invalid lineno format")
          end
        end
      end
    end

    def each(&block)
      return enum_for(:each) unless block_given?
      for range in @ranges
        range.each(&block) if range
        yield nil
      end
      nil
    end

  end


end
