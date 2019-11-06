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
      UI.UserInput

      # Fetch the result as long as the widget still exists, i.e. BEFORE UI.CloseDialog
      # For a SingleItemSelector, use :Value (i.e. the first selected item);
      # for a MultiItemSelector,  use :SelectedItems
      #
      # :SelectedItems returns an array of the the ID (or the label string if
      # there is no ID) of each selected item, not the complete item.

      result = UI.QueryWidget(:pizza, :Value)
      UI.CloseDialog

      # Show the result in a pop-up dialog
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
