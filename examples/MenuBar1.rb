# encoding: utf-8

module Yast
  class MenuBar1Client < Client
    Yast.import "UI"
    def main
      UI.OpenDialog(dialog_widgets)
      handle_events
      UI.CloseDialog
      nil
    end

    def dialog_widgets
      MinSize( 50, 20,
        VBox(
          term(:MenuBar, main_menus ),
          HVCenter(
            HVSquash(
              VBox(
                Left(Label( "Last Event:" )),
                VSpacing( 0.2 ),
                MinWidth( 20,
                  Label(Id(:last_event), Opt(:outputField), "<none>")
                )
              )
            )
          )
        )
      )
    end

    def main_menus
      [
        term(:menu, "&File", file_menu),
        term(:menu, "&Edit", edit_menu),
        term(:menu, "&View", view_menu),
        term(:menu, "&Options", options_menu)
      ].freeze
    end

    def file_menu
      [
        Item(Id(:open), "&Open..."),
        Item(Id(:save), "&Save"),
        Item(Id(:save_as), "Save &As..."),
        Item("---"),
        Item(Id(:quit), "&Quit"),
      ].freeze
    end

    def edit_menu
      [
        Item(Id(:cut), "C&ut"),
        Item(Id(:copy), "&Copy"),
        Item(Id(:paste), "&Paste"),
      ].freeze
    end

    def view_menu
      [
        Item(Id(:view_normal), "&Normal"),
        Item(Id(:view_compact), "&Compact"),
        Item(Id(:view_detailed), "&Detailed"),
        Item("---"),
        term(:menu, "&Zoom", zoom_menu),
      ].freeze
    end

    def zoom_menu
      [
        Item(Id(:zoom_in), "Zoom &In" ),
        Item(Id(:zoom_out), "Zoom &Out" ),
        Item(Id(:zoom_default), "Zoom &Default" ),
      ].freeze
    end

    def options_menu
      [
        Item(Id(:settings), "&Settings..."),
      ].freeze
    end

    def handle_events
      while true
        id = UI.UserInput

        case id
        when :quit, :cancel # :cancel is WM_CLOSE
          break # leave event loop
        end

        show_event(id)
      end
      id
    end

    def show_event(id)
      UI.ChangeWidget(:last_event, :Value, id.to_s)
    end
  end
end

Yast::MenuBar1Client.new.main
