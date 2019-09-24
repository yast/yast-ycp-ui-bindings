# encoding: utf-8

module Yast
  # This is a comprehensive example for both ItemSelector widgets, the
  # SingleItemSelector and the MultiItemSelector. It showcases most of the
  # features of ItemSelector widgets.
  #
  # For much simpler examples, see
  #
  #   - ItemSelector2-minimalistic.rb
  #   - SingleItemSelector1.rb
  #   - MultiItemSelector1.rb
  #
  # This example starts with a pop-up dialog asking for some config values (see
  # below) such as which selection mode to use (single or multi), the notify
  # mode and the number of initially visible items.
  #
  # Then the main dialog opens with those settings applied. Select or deselect
  # items and watch the results fields (if notify mode was selected) or click
  # the respective buttons.
  #
  # After the main dialog is closed, a final pop-up dialog shows the results.
  #
  # This example also shows how to break down UI operation into smaller, better
  # manageable parts.
  #
  class ExampleClient < Client
    Yast.import "UI"

    def initialize
      @notify = true
      @single_selection = false
      @visible_items = 4
    end

    def items
      [
        Item(Id(:margherita),   "Pizza Margherita",       "Very basic with just tomatoes and cheese"),
        Item(Id(:cappricciosa), "Pizza Capricciosa",      "Ham and vegetables"                      ),
        Item(Id(:funghi),       "Pizza Funghi",           "Mushrooms"                               ),
        Item(Id(:prosciutto),   "Pizza Prosciutto",       "Ham"                                     ),
        Item(Id(:quattro),      "Pizza Quattro Stagioni", "Different toppings in each quarter"      ),
        Item(Id(:calzone),      "Calzone",                "Folded over"                             )
      ].freeze
    end

    def item_selector
      args = [Id(:pizza)]
      args << Opt(:notify) if @notify
      args << items

      if @single_selection
        SingleItemSelector(*args)
      else
        MultiItemSelector(*args)
      end
    end

    def main_dialog
      MarginBox(2, 0.4,
        VBox(
          Heading("Pizza Menu"),
          VSpacing(0.2),
          item_selector,
          VSpacing(0.4),
          HBox(
            Label(Id(:value_field), Opt(:outputField, :hstretch), "<unknown>"),
            PushButton(Id(:value_button), "&Value")
          ),
          VSpacing(0.3),
          HBox(
            Label(Id(:result_field), Opt(:outputField, :hstretch), "<selected items>\n\n\n\n\n"),
            PushButton(Id(:result_button), "&Result")
          ),
          VSpacing(0.3),
          Right(
            PushButton(Id(:close), "&Close")
          )
        )
      )
    end

    def set_visible_items
      UI.ChangeWidget(:pizza, :VisibleItems, @visible_items)
      UI.RecalcLayout # needed for the change to have an effect
    end

    def init_main_dialog
      set_visible_items
      UI.ChangeWidget(:value_button, :Enabled, !@notify)
      UI.ChangeWidget(:result_button, :Enabled, !@notify)
    end

    def update_value
      # :Value returns the ID of the first selected item
      value = UI.QueryWidget(:pizza, :Value)
      UI.ChangeWidget(:value_field, :Value, value.to_s)
    end

    def update_result
      selected = UI.QueryWidget(:pizza, :SelectedItems)

      # SelectedItems returns an array of IDs, i.e. in our case symbols:
      # [:funghi, :calzone]
      # Convert each of them to string and join them into multiple lines.
      result = selected.map(&:to_s).join(",\n")
      UI.ChangeWidget(:result_field, :Value, result)
    end

    def handle_events
      while true
        widget = UI.UserInput
        case widget

        when :close, :cancel # :cancel is WM_CLOSE
          break # leave event loop

        when :value_button
          update_value

        when :result_button
          update_result

        when :pizza # this will happen only if Opt(:notify) is set
          update_value
          update_result

        end
      end
      widget
    end

    # Ask the user some configuration values for the main dialog.
    #
    #    +---------------------------+
    #    |   Program Configuration   |
    #    |                           |
    #    |  Selection Mode           |
    #    |  (x) Single Selection     |
    #    |  ( ) Multi-Selection      |
    #    |                           |
    #    |  [x] Notify               |
    #    |                           |
    #    |  Visible Items:           |
    #    |  [ 4          ]           |
    #    |                           |
    #    |   [Continue]  [Cancel]    |
    #    +---------------------------+
    def ask_config_values
      UI.OpenDialog(
        MarginBox( 2, 0.4,
          VBox(
            Heading("Program Configuration"),
            VSpacing(0.2),
            Left(
              RadioButtonGroup(
                Frame("Selection Mode",
                  VBox(
                    Left(RadioButton(Id(:single_selection), "&Single Selection", @single_selection)),
                    Left(RadioButton(Id(:multi_selection), "&Multi-Selection", !@single_selection))
                  )
                )
              )
            ),
            VSpacing(0.6),
            Left(CheckBox(Id(:notify), "&Notify", @notify)),
            VSpacing(0.6),
            Left(IntField(Id(:visible_items), "&Visible Items:", 1, 10, @visible_items)),
            VSpacing(1),
            ButtonBox(
              PushButton(Id(:continue), "C&ontinue"),
              PushButton(Id(:cancel), "&Cancel")
            )
          )
        )
      )

      widget = UI.UserInput
      @notify = UI.QueryWidget(:notify, :Value)
      @single_selection = UI.QueryWidget(:single_selection, :Value)
      @visible_items = UI.QueryWidget(:visible_items, :Value)
      UI.CloseDialog
      widget
    end

    # Show the result in a pop-up dialog
    def show_result(result)
      UI.OpenDialog(
        VBox(
          Label("Selected:\n\n#{result}"),
          PushButton("&OK")
        )
      )
      UI.UserInput
      UI.CloseDialog
    end

    def main
      widget = ask_config_values
      return if widget == :cancel

      UI.OpenDialog(main_dialog)
      init_main_dialog
      handle_events

      # Fetch the result as long as the widget still exists, i.e. BEFORE UI.CloseDialog
      # For a SingleItemSelector, use :Value (i.e. the first selected item);
      # for a MultiItemSelector,  use :SelectedItems
      #
      # :SelectedItems returns an array of the the ID (or the label string if
      # there is no ID) of each selected item, not the complete item.

      result = UI.QueryWidget(:pizza, :SelectedItems)
      UI.CloseDialog

      result = result.map(&:to_s).join(",\n")
      show_result(result)

      nil
    end
  end
end

Yast::ExampleClient.new.main
