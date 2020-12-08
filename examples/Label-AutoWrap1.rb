# encoding: utf-8


module Yast
  class LabelAutoWrap1Client < Client

    def content
        VBox(
          VCenter(MinWidth(40, Label(Opt(:autoWrap), message))),
          VSpacing(0.2),
          Empty()
        )
    end

    def content2
      HBox(
        HSpacing(1),
        VBox(
          VSpacing(0.2),
          content,
          VStretch(),
          PushButton("OK"),
          VStretch(),
          VSpacing(0.2)
        ),
        HSpacing(1)
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
