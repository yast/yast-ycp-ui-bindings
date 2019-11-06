# encoding: utf-8

module Yast
  class ExampleClient < Client
    def main
      Yast.import "UI"

      UI.OpenDialog(
	VBox(
	  CustomStatusItemSelector(
	    Id(:pizza),
	    [
	      # Icon, NCursesIndicator, NextStatus
	      ["checkbox-off", "[ ]", 1],
	      ["checkbox-on",  "[x]", 0]
	    ],
	    [
	      # Notice no item IDs, so we'll get the item label as the result.
	      # Even the descriptions are optional.
	      Item("Pizza Margherita",	     "Very basic with just tomatoes and cheese"),
	      Item("Pizza Capricciosa",	     "Ham and vegetables"		       ),
	      Item("Pizza Funghi",	     "Mushrooms"			       ),
	      Item("Pizza Prosciutto",	     "Ham"				       ),
	      Item("Pizza Quattro Stagioni", "Different toppings in each quarter"      ),
	      Item("Calzone",		     "Folded over"			       )
	    ]
	   ),
	  PushButton("&OK")
	)
      )

      widget = UI.UserInput

      if widget == :cancel      # WM_CLOSE
        UI.CloseDialog
        return
      end

      # Fetch the result as long as the widget still exists, i.e. BEFORE UI.CloseDialog

      result = UI.QueryWidget(:pizza, :SelectedItems).join(", ")
      result = "(nothing)" if result.empty?
      UI.CloseDialog

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
