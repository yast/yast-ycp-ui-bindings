# encoding: utf-8

# Example for controlling scrollbars of a RichText widget
module Yast
  class RichText7Client < Client
    def main
      Yast.import 'UI'

      text = ''
      for n in 1..50 do
        text += "<p>n = #{n}, 2^n = #{2**n}</p>\n"
      end

      UI.OpenDialog(
        Opt(:defaultsize),
        VBox(
          RichText(Id(:text), text),
          HBox(
            PushButton(Id(:reset), 'Reset'),
            PushButton(Id(:append), 'Append')
          ),
          HBox(
            PushButton(Id(:vertical_minimum), 'Vertical Minimum'),
            PushButton(Id(:vertical_maximum), 'Vertical Maximum')
          ),
          HBox(
            PushButton(Id(:horizontal_minimum), 'Horizontal Minimum'),
            PushButton(Id(:horizontal_maximum), 'Horizontal Maximum')
          ),
          PushButton(Id(:close), Opt(:default), 'Close')
        )
      )

      input = nil
      begin
        input = UI.UserInput

        case input

        when :reset
          text = ''
          for n in 1..50 do
            text += "<p>n = #{n}, 2^n = #{2**n}</p>\n"
          end

          vertical_scroll_value = UI.QueryWidget(Id(:text), :VScrollValue)
          horizontal_scroll_value = UI.QueryWidget(Id(:text), :HScrollValue)
          UI.ChangeWidget(Id(:text), :Value, text)
          UI.ChangeWidget(Id(:text), :VScrollValue, vertical_scroll_value)
          UI.ChangeWidget(Id(:text), :HScrollValue, horizontal_scroll_value)

        when :append
          n += 1
          text += "<p>n = #{n}, 2^n = #{2**n}</p>\n"

          vertical_scroll_value = UI.QueryWidget(Id(:text), :VScrollValue)
          horizontal_scroll_value = UI.QueryWidget(Id(:text), :HScrollValue)
          UI.ChangeWidget(Id(:text), :Value, text)
          UI.ChangeWidget(Id(:text), :VScrollValue, vertical_scroll_value)
          UI.ChangeWidget(Id(:text), :HScrollValue, horizontal_scroll_value)

        when :vertical_minimum
          UI.ChangeWidget(Id(:text), :VScrollValue, 'minimum')

        when :vertical_maximum
          UI.ChangeWidget(Id(:text), :VScrollValue, 'maximum')

        when :horizontal_minimum
          UI.ChangeWidget(Id(:text), :HScrollValue, 'minimum')

        when :horizontal_maximum
          UI.ChangeWidget(Id(:text), :HScrollValue, 'maximum')

        end
      end until input == :close

      UI.CloseDialog
    end
  end
end

Yast::RichText7Client.new.main
