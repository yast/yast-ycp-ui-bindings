# encoding: utf-8

module Yast
  class ExampleClient < Client
    def main
      Yast.import "UI"

      UI.OpenDialog(
        VBox(
          MultiItemSelector(
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
      selected = UI.QueryWidget(:pizza, :SelectedItems)
      UI.CloseDialog

      # Show result in pop-up dialog
      result = selected.join(", ")
      result = "<nothing>" if result.empty?
      
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
