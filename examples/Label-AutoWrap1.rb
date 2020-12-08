# encoding: utf-8


module Yast
  class LabelAutoWrap1Client < Client

    def content
      MinWidth(40, Label(Opt(:autoWrap), message))
    end

    def content2
        VBox(
          content,
          VStretch(),
        )
    end

    def message
      text  = "This is an example of a lengthy text that needs to be auto-wrapped to make it fit. \n\n "
      text += "The widget has to find appropriate places to break that long text into lines.\n"
    end

    def main
      Yast.import "UI"
      Yast.import "Popup"

      UI.OpenDialog(
        content2
      )
      UI.UserInput
      UI.CloseDialog

      nil
    end
  end
end

Yast::LabelAutoWrap1Client.new.main
