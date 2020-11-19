# encoding: utf-8

# Example for combo box
#
# This is also used in the NCurses UI test suite.
# When changing this example, make sure that test suite does not fail!

module Yast
  class ComboBoxItemIds < Client
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
        50, 12,
        MarginBox(
          1, 0.4,
          VBox(
            Left(
              Heading("Pizza Selector")
            ),
            VSpacing(0.2),
            HCenter(
              HSquash(
                MinWidth(30, pizza_combo_box)
              )
            ),
            VSpacing(1),
            pizza_buttons,
            VSpacing(1),
            output_fields,
            VSpacing(0.3),
            VStretch(),
            Right(
              PushButton(Id(:close), "&Close")
            )
          )
        )
      )
    end

    def pizza_combo_box
      ComboBox(
        Id(:cb_pizza),
        Opt(:notify, :editable),
        "Pizza:",
        pizza_items
      )
    end

    def pizza_items
      [
        Item(Id(:margherita), "Margherita"),
        Item(Id(:salami), "Salami"),
        Item(Id(:prosciutto), "Prosciutto"),
        Item(Id(:quattro), "Quattro Stagioni"),
        Item(Id(:speciale), "Speciale"),
        Item(Id(:casa), "Della Casa")
      ]
    end

    def pizza_buttons
      HBox(
        PushButton(Id(:speciale), "&Speciale"),
        PushButton(Id(:casa), "Della C&asa"),
        PushButton(Id(:salami), "&Daily Special"),
        PushButton(Id(:custom), "C&ustom")
      )
    end

    def output_fields
      VBox(
        HBox(
          # Putting both in one line to enable grepping for NCurses UI tests
          Label("Selected: "),
          Label(Id(:selected_pizza), Opt(:outputField, :hstretch), "...")
        )
      )
    end

    def handle_events
      while true
        id = UI.UserInput
        case id

        when :close, :cancel # :cancel is WM_CLOSE
          break # leave event loop
        when :cb_pizza
          update_output_fields
        when :speciale, :casa, :salami
          select_pizza(id)
          update_output_fields
        when :custom
          select_pizza("Pizza with ham and onions")
          update_output_fields
        end
        id
      end
    end

    def cb_value
      UI.QueryWidget(Id(:cb_pizza), :Value)
    end

    def select_pizza(pizza)
      UI.ChangeWidget(Id(:cb_pizza), :Value, pizza)
    end

    def update_selected_pizza(value)
      UI.ChangeWidget(Id(:selected_pizza), :Value, value.inspect)
    end

    def update_output_fields
      update_selected_pizza(cb_value)
    end
  end
end

Yast::ComboBoxItemIds.new.main
