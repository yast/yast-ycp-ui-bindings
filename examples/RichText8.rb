# encoding: utf-8

# Example for a RichText widget with hyperlinks

module Yast
  class RichText8Client < Client

    @firewall = true
    @settings = false
    @sshd = true

    def text
      r = '<h3>RichText Example</h3>'

      if @firewall
        r += '<p>Firewall enabled <a href="firewall">(disable)</a></p>'
      else
        r += '<p>Firewall disabled <a href="firewall">(enable)</a></p>'
      end

      r += '<p>Some advanced <a href="settings">firewall settings</a></p>'

      if @settings
        for n in 1..20 do
          r += "<p>Port #{n} is open.</p>\n"
        end
      end

      if @sshd
        r += '<p>sshd enabled <a href="sshd">(disable)</a></p>'
      else
        r += '<p>sshd disabled <a href="sshd">(enable)</a></p>'
      end

      return r
    end

    def main
      Yast.import 'UI'

      UI.OpenDialog(
        Opt(:defaultsize),
        VBox(
          RichText(Id(:text), text),
          PushButton(Id(:close), Opt(:default), 'Close')
        )
      )

      input = nil
      begin
        input = UI.UserInput

        case input

        when 'firewall'
          @firewall ^= true

          vertical_scroll_value = UI.QueryWidget(Id(:text), :VScrollValue)
          horizontal_scroll_value = UI.QueryWidget(Id(:text), :HScrollValue)
          UI.ChangeWidget(Id(:text), :Value, text)
          UI.ChangeWidget(Id(:text), :VScrollValue, vertical_scroll_value)
          UI.ChangeWidget(Id(:text), :HScrollValue, horizontal_scroll_value)

        when 'settings'
          @settings ^= true

          vertical_scroll_value = UI.QueryWidget(Id(:text), :VScrollValue)
          horizontal_scroll_value = UI.QueryWidget(Id(:text), :HScrollValue)
          UI.ChangeWidget(Id(:text), :Value, text)
          UI.ChangeWidget(Id(:text), :VScrollValue, vertical_scroll_value)
          UI.ChangeWidget(Id(:text), :HScrollValue, horizontal_scroll_value)

        when 'sshd'
          @sshd ^= true

          vertical_scroll_value = UI.QueryWidget(Id(:text), :VScrollValue)
          horizontal_scroll_value = UI.QueryWidget(Id(:text), :HScrollValue)
          UI.ChangeWidget(Id(:text), :Value, text)
          UI.ChangeWidget(Id(:text), :VScrollValue, vertical_scroll_value)
          UI.ChangeWidget(Id(:text), :HScrollValue, horizontal_scroll_value)

        end
      end until input == :close

      UI.CloseDialog
    end

  end
end

Yast::RichText8Client.new.main
