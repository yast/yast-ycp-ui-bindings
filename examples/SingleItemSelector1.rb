# encoding: utf-8

module Yast
  class ExampleClient < Client
    def main
      Yast.import "UI"

      UI.OpenDialog(
        VBox(
          SingleItemSelector(
           Id(:pizza),
           [
             Item(Id(:margherita),   "Pizza Margherita",       "Very basic with just tomatoes and cheese"),
             Item(Id(:cappricciosa), "Pizza Capricciosa",      "Ham and vegetables"                      ),
             Item(Id(:funghi),       "Pizza Funghi",           "Mushrooms"                               ),
             Item(Id(:prosciutto),   "Pizza Prosciutto",       "Ham"                                     ),
             Item(Id(:quattro),      "Pizza Quattro Stagioni", "Different toppings in each quarter"      ),
             Item(Id(:calzone),      "Calzone",                "Folded over"                             )
           ]
          ),
          PushButton("&OK")
        )
      )
      UI.UserInput
      result = UI.QueryWidget(:pizza, :Value)
      UI.CloseDialog

      # Show result in pop-up dialog
      UI.OpenDialog(
        VBox(
          Label("Selected:\n#{result}"),
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
