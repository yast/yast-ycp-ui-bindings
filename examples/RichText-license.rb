# encoding: utf-8

# Example for a RichText widget
# Purpose: Have a possibility to see whether files (.txt, .rtf)
#          such as licenses, release-notes are displayed correctly
#          in text mode (ncurses) or graphical UI (qt).
module Yast
  class RichTextLicenseClient < Client
    def main
      Yast.import "UI"
      Yast.import "String"

      UI.OpenDialog(
        Opt(:defaultsize),
        VBox(
          Label("HTML text or text in <pre>...</pre> tags"),
          RichText(Id(:text), ""),
          Label("Plain text (`opt(`plainText))"),
          RichText(Id(:plaintext), Opt(:plainText), ""),
          HBox(
            PushButton(Id(:load), "&Load File"),
            PushButton(Id(:close), "&Close")
          )
        )
      )
      @button = nil
      @name = ""
      @text = ""
      if UI.TextMode()
        @file_ext = "*.txt *orig"
      else
        @file_ext = "*.txt *orig *rtf"
      end

      begin
        @button = UI.UserInput

        if @button == :load
          @name = UI.AskForExistingFile(".", @file_ext, "Select text file")
          @text2 = Convert.to_string(SCR.Read(path(".target.string"), @name))

          @text2 = "" if @text2 == nil

          if Builtins.regexpmatch(@text2, "</.*>")
            # HTML text (or RichText)
            UI.ChangeWidget(Id(:text), :Value, @text2)
          else
            # plain text
            UI.ChangeWidget(
              Id(:text),
              :Value,
              Ops.add(Ops.add("<pre>", String.EscapeTags(@text2)), "</pre>")
            )
          end

          UI.ChangeWidget(Id(:plaintext), :Value, @text2)
        end
      end until @button == :close

      UI.CloseDialog

      nil
    end
  end
end

Yast::RichTextLicenseClient.new.main
