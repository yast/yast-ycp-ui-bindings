# encoding: utf-8

module Yast
  class ExampleClient < Client
    def main
      Yast.import "UI"

      UI.OpenDialog(
        MarginBox(2, 0.4,
          VBox(
            Heading("Desktop Selection"),
            VSpacing(0.6),
            SingleItemSelector(
             Id(:desktop),
             [
               Item(Id(:kde),
                 "KDE Plasma",
                 "A powerful modern desktop with emphasis on features.\n" +
                 "Motto: \"Simple by default, powerful when needed.\"",
                 term(:icon, "pattern-kde")),
               Item(Id(:gnome),
                 "GNOME",
                 "A modern desktop with emphasis on ease of use.\n" +
                 "Motto: \"An easy and elegant way to use your computer.\"",
                 term(:icon, "pattern-gnome")),
               Item(Id(:xfce),
                 "Xfce",
                 "A fast and lightweight desktop that is also (but not only)\n" +
                 "suitable for less powerful machines.",
                 term(:icon, "pattern-xfce"),
                 true)
             ]
            ),
            VSpacing(0.6),
            PushButton("&OK")
          )
        )
      )
      UI.UserInput
      result = UI.QueryWidget(:desktop, :Value)
      UI.CloseDialog

      # Show result in pop-up dialog
      UI.OpenDialog(
        VBox(
          Label("Selected:\n\n#{result}\n"),
          PushButton("&OK")
        )
      )
      UI.UserInput
      UI.CloseDialog

      nil
    end
  end
end

Yast::ExampleClient.new.main
