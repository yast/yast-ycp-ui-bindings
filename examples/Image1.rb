# encoding: utf-8

# Simple image example
module Yast
  class Image1Client < Client
    def main
      Yast.import "UI"

      UI.OpenDialog(
        VBox(
          Image(
            Id("image"),
            "/usr/share/grub2/themes/openSUSE/logo.png",
            "fallback text"
          ),
          PushButton(Opt(:default), "&OK")
        )
      )
      UI.UserInput
      UI.CloseDialog

      nil
    end
  end
end

Yast::Image1Client.new.main
