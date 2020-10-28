# encoding: utf-8

# Example for table with single-selection and nested items
#
# This is also used in the NCurses UI test suite.
# When changing this example, make sure that test suite does not fail!

module Yast
  class MultiSelectionBoxTest < Client
    Yast.import "UI"
    include Yast::Logger

    def main
      UI.OpenDialog(main_dialog)
      update_output_fields
      handle_events
      UI.CloseDialog
    end

    def main_dialog
      MinSize(
        75, 16,
        MarginBox(
          1, 0.4,
          VBox(
            Left(
              Heading("Pizza Selector")
            ),
            VSpacing(0.2),
            multi_selection_box,
            VSpacing(0.2),
            Left(
              CheckBox(Id(:veggie), Opt(:notify), "&Vegetarian", false)
            ),
            VSpacing(1),
            output_fields,
            VSpacing(0.3),
            Right(
              PushButton(Id(:close), "&Close")
            )
          )
        )
      )
    end

    def multi_selection_box
      MultiSelectionBox(
        Id(:multi_sel),
        Opt(:notify),
        "Select toppings:",
        all_toppings
      )
    end

    def all_toppings
      [
        Item(Id(:cheese), "Cheese", true),
        Item(Id(:tomatoes), "Tomatoes", true),
        Item(Id(:mushrooms), "Mushrooms"),
        Item(Id(:onions), "Onions"),
        Item(Id(:salami), "Salami"),
        Item(Id(:ham), "Ham")
      ]
    end

    def veggie_toppings
      [
        Item(Id(:cheese), "Cheese", true),
        Item(Id(:tomatoes), "Tomatoes", true),
        Item(Id(:mushrooms), "Mushrooms"),
        Item(Id(:onions), "Onions")
      ]
    end

    def output_fields
      VBox(
        HBox(
          # Putting both in one line to enable grepping for NCurses UI tests
          HSquash(MinWidth(12, Label("Selected: "))),
          Label(Id(:selected_items), Opt(:outputField, :hstretch), "...")
        ),
        HBox(
          # Putting both in one line to enable grepping for NCurses UI tests
          HSquash(MinWidth(12, Label("Current: "))),
          Label(Id(:current_item), Opt(:outputField, :hstretch), "...")
        )
      )
    end

    def handle_events
      while true
        id = UI.UserInput
        case id

        when :close, :cancel # :cancel is WM_CLOSE
          break # leave event loop
        when :multi_sel
          update_output_fields
        when :veggie
          change_toppings
        end
        id
      end
    end

    def current_item
      UI.QueryWidget(Id(:multi_sel), :CurrentItem)
    end

    def selected_items
      UI.QueryWidget(Id(:multi_sel), :SelectedItems)
    end

    def update_current_item(id)
      UI.ChangeWidget(Id(:current_item), :Value, id.inspect)
    end

    def update_selected_items(ids)
      UI.ChangeWidget(Id(:selected_items), :Value, ids.inspect)
    end

    def update_output_fields
      update_selected_items(selected_items)
      update_current_item(current_item)
    end

    def veggie?
      UI.QueryWidget(Id(:veggie), :Value)
    end

    def change_toppings
      veg = veggie?
      UI.ChangeWidget(Id(:multi_sel), :Items, veg ? veggie_toppings : all_toppings)

      # Select one extra topping and make it the current item
      extra = veg ? :mushrooms : :salami
      UI.ChangeWidget(Id(:multi_sel), :SelectedItems, selected_items << extra )
      UI.ChangeWidget(Id(:multi_sel), :CurrentItem, extra)

      update_output_fields
      UI.SetFocus(Id(:multi_sel))
    end
  end
end

Yast::MultiSelectionBoxTest.new.main
