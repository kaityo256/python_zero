# -*- coding: utf-8 -*-

##
## Re:VIEWを拡張し、インライン命令とブロック命令を追加する
##


require_relative './lib/ruby/review-monkeypatch'  ## 諸々の修正（モンキーパッチ）


module ReVIEW

  ## インライン命令「@<clearpage>{}」を宣言
  Compiler.definline :clearpage         ## 改ページ
  Compiler.definline :B                 ## @<strong>{}のショートカット
  Compiler.definline :hearts            ## ハートマーク
  Compiler.definline :TeX               ## TeX のロゴマーク
  Compiler.definline :LaTeX             ## LaTeX のロゴマーク

  ## ブロック命令「//textleft{ ... //}」等を宣言
  ## （ここでは第2引数が「0」なので、引数なしのブロック命令になる。
  ##   もし第2引数が「1..3」なら、//listのように必須引数が1つで
  ##   非必須引数が2という意味になる。）
  Compiler.defblock :textleft, 0        ## 左寄せ
  Compiler.defblock :textright, 0       ## 右寄せ
  Compiler.defblock :textcenter, 0      ## 中央揃え
  Compiler.defsingle :clearpage, 0      ## 改ページ (\clearpage)
  Compiler.defsingle :sampleoutputbegin, 0..1 ## （出力結果開始部、Starterドキュメントで使用）
  Compiler.defsingle :sampleoutputend, 0      ## （出力結果終了部、Starterドキュメントで使用）


  ## LaTeX用の定義
  class LATEXBuilder

    ## 改ページ（インライン命令）
    def inline_clearpage(str)
      '\clearpage'
    end

    ## 改ページ（ブロック命令）
    def clearpage()
      puts ''
      puts '\\clearpage'
      puts ''
    end

    ## @<strong>{} のショートカット
    def inline_B(str)
      inline_strong(str)
    end
    def on_inline_B(&b)  # nestable
      on_inline_strong(&b)
    end

    ## ハートマーク
    def inline_hearts(str)
      '$\heartsuit$'
    end

    ## TeXのロゴマーク
    def inline_TeX(str)
      '\TeX{}'
    end

    ## LaTeXのロゴマーク
    def inline_LaTeX(str)
      '\LaTeX{}'
    end

    ## 左寄せ
    def textleft(lines)
      puts '\begin{flushleft}'
      puts lines
      puts '\end{flushleft}'
    end

    ## 右寄せ
    ## （注：Re:VIEWにはすでに //flushright{ ... //} があったので、今後はそちらを推奨）
    def textright(lines)
      puts '\begin{flushright}'
      puts lines
      puts '\end{flushright}'
    end

    ## 中央揃え
    ## （注：Re:VIEWにはすでに //centering{ ... //} があったので、今後はそちらを推奨）
    def textcenter(lines)
      puts '\begin{center}'
      puts lines
      puts '\end{center}'
    end

    ## 出力結果の開始部と終了部（Starterのドキュメントで使用）
    ## （Re:VIEWではブロックの入れ子も「===[xxx]」の入れ子もできないため）
    def sampleoutputbegin(caption=nil)
      #puts "\\begin{startersampleoutput}"   # error in note block
      s = caption ? compile_inline(caption) : nil
      puts "\\startersampleoutput{#{s}}"
    end
    def sampleoutputend()
      #puts "\\end{startersampleoutput}"     # error in note block
      puts "\\endstartersampleoutput"
    end

  end


  ## HTML（ePub）用の定義
  class HTMLBuilder

    ## 改ページはHTMLにはない
    def inline_clearpage(str)   # インライン命令
      puts '<p></p>'
      puts '<hr />'
      puts '<p></p>'
    end

    def clearpage()             # ブロック命令
      puts '<p></p>'
      puts '<hr />'
      puts '<p></p>'
    end

    ## @<strong>{} のショートカット
    def inline_B(str)
      inline_strong(str)
    end

    ## ハートマーク
    def inline_hearts(str)
      #'&hearts;'
      '&#9829;'
    end

    ## TeXのロゴマーク
    def inline_TeX(str)
      'TeX'
    end

    ## LaTeXのロゴマーク
    def inline_LaTeX(str)
      'LaTeX'
    end

    ## 左寄せ
    def textleft(lines)
      puts '<div style="text-align:left">'
      puts lines
      puts '</div>'
    end

    ## 右寄せ
    def textright(lines)
      puts '<div style="text-align:right">'
      puts lines
      puts '</div>'
    end

    ## 中央揃え
    def textcenter(lines)
      puts '<div style="text-align:center">'
      puts lines
      puts '</div>'
    end

    ## 出力結果の開始部と終了部（Starterのドキュメントで使用）
    ## （Re:VIEWではブロックの入れ子も「===[xxx]」の入れ子もできないため）
    def sampleoutputbegin(caption=nil)
      puts "<div class=\"sampleoutput\">"
      if caption
        s = compile_inline(caption)
        puts "<span class=\"caption\">#{caption}</span>"
      end
      puts "<div class=\"sampleoutput-inner\">"
    end
    def sampleoutputend()
      puts "</div></div>"
    end

  end


  class TEXTBuilder

    ## TeXのロゴマーク
    def inline_TeX(str)
      'TeX'
    end

    ## LaTeXのロゴマーク
    def inline_LaTeX(str)
      'LaTeX'
    end

    ## ハートマーク
    def inline_hearts(str)
      '&hearts;'
    end

  end


end
