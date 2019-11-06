# encoding: utf-8

module Yast
  class ExampleClient < Client
    def main
      Yast.import "UI"

      create_widgets
      handle_events
      result = fetch_result
      UI.CloseDialog
      show_result(result)
    end

    protected

    def custom_states
      [
        # Icon, NCursesIndicator, NextStatus
        ["checkbox-off", "[ ]", 1],
        ["checkbox-on",  "[x]", 0]
      ]
    end
      
    def items
      [
        # Notice no item IDs, so we'll get the item label as the result.
        # Even the descriptions are optional.
        Item("Pizza Margherita",       "Very basic with just tomatoes and cheese"),
        Item("Pizza Capricciosa",      "Ham and vegetables"                      ),
        Item("Pizza Funghi",           "Mushrooms"                               ),
        Item("Pizza Prosciutto",       "Ham"                                     ),
        Item("Pizza Quattro Stagioni", "Different toppings in each quarter"      ),
        Item("Calzone",                "Folded over"                             )
      ]
    end

    def create_widgets
      UI.OpenDialog(
        VBox(
          CustomStatusItemSelector(Id(:pizza), custom_states, items),
          PushButton("&OK")
        )
      )
    end

    def handle_events
      UI.UserInput
    end

    def fetch_result
      UI.QueryWidget(:pizza, :SelectedItems)
    end

    def show_result(result)
      result = result.join(", ")
      result = "(nothing)" if result.empty?

      # Show the result in a pop-up dialog
      UI.OpenDialog(
        VBox(
          Label("\n  Selected:\n\n  #{result}  \n"),
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
