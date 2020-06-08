# encoding: utf-8

module Yast
  class LabelAutoWrap1Client < Client
    def main
      Yast.import "UI"

      width = 40
      text  = "This is an example of a lengthy text that needs to be auto-wrapped to make it fit. "
      text += "And it goes on and on and on; it does not have any newline. "
      text += "It's just one single very long line. "
      text += "The widget has to find appropriate places to break that long text into lines."

      UI.OpenDialog(
        VBox(
          MinWidth( width, Label(Opt(:autoWrap), text) ),
          PushButton("&OK")
        )
      )
      UI.UserInput
      UI.CloseDialog

      nil
    end
  end
end

Yast::LabelAutoWrap1Client.new.main
