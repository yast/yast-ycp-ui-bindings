# encoding: utf-8

module Yast
  class MenuBarShortcutsClient < Client
    Yast.import "UI"
    include Yast::Logger

    def main
      UI.OpenDialog(dialog_widgets)
      update_actions
      handle_events
      UI.CloseDialog
      nil
    end

    def dialog_widgets
      MinSize( 50, 20,
        VBox(
          MenuBar(Id(:menu_bar), main_menus),
          MarginBox(1.4, 0,
            HVCenter(
              HVSquash(
                VBox(
                  ReplacePoint(Id(:rp_extra_buttons), Empty()),
                  VSpacing( 0.2 ),
                  Left(CheckBox(Id(:cb_extra_buttons), Opt(:notify), "Extra &Buttons", false)),
                  VSpacing( 1 ),
                  Left(Label("Last Event:")),
                  VSpacing( 0.2 ),
                  MinWidth( 20,
                    Label(Id(:last_event), Opt(:outputField), "<none>")
                  ),
                  VSpacing( 2 ),
                  Left(CheckBox(Id(:read_only), Opt(:notify), "Read &Only", true))
                )
              )
            )
          ),
          Right(PushButton(Id(:cancel), "&Quit"))
        )
      )
    end

    def main_menus
      [
        Menu("&File", file_menu),
        Menu("&Edit", edit_menu),
        Menu("&View", view_menu),
        Menu("&Options", options_menu),
        Menu("&Debug", debug_menu)
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

    def debug_menu
      [
        Item(Id(:dump_status), "Dump enabled / disabled &status"),
        Item(Id(:dump_disabled), "Dump &disabled items")
      ].freeze
    end

    def handle_events
      while true
        id = UI.UserInput

        case id
        when :quit, :cancel # :cancel is WM_CLOSE
          break # leave event loop
        when :read_only
          update_actions
        when :cb_extra_buttons
          toggle_extra_buttons
        when :dump_status
          dump_item_status
        when :dump_disabled
          dump_disabled_ids
        end

        show_event(id)
      end
      id
    end

    def extra_buttons
      # Make sure to use very short labels for the buttons
      # so their shortcuts get priority over menus / menu items
      HSquash(
        HBox(Id(:extra_button_box),
          PushButton("&Fi"),
          PushButton("&Ed"),
          PushButton("&Vi"),
          PushButton("&Opt"),
          PushButton("&Cp")
        )
      )
    end

    def extra_buttons_visible?
      UI.WidgetExists(:extra_button_box)
    end

    def show_extra_buttons?
      UI.QueryWidget(:cb_extra_buttons, :Value)
    end

    def toggle_extra_buttons
      do_show = show_extra_buttons?
      log.info("do_show: #{do_show}")
      log.info("visible: #{extra_buttons_visible?}")
      return if do_show == extra_buttons_visible?

      log.info("Showing extra buttons: #{do_show}")
      UI.ReplaceWidget(:rp_extra_buttons, do_show ? extra_buttons : Empty())
    end

    def show_event(id)
      UI.ChangeWidget(:last_event, :Value, id.to_s)
    end

    # Enable or disable menu items depending on the current content of the
    # "Read Only" check box.
    def update_actions
      read_only = UI.QueryWidget(:read_only, :Value)

      # Enable or disable individual menu entries (actions as well as submenus):
      #
      # Specify a hash of item IDs with a boolean indicating if it should be
      # enabled (true) or disabled (false). Menu items that are not in this hash will
      # not be touched, i.e. they retain their current enabled / disabled status.

      UI.ChangeWidget(:menu_bar, :EnabledItems,
        {
          :save  => !read_only,
          :cut   => !read_only,
          :paste => !read_only
        }
      )
    end

    # Dump the enabled / disabled states of the menu items to the log.
    def dump_item_status
      states = UI.QueryWidget(:menu_bar, :EnabledItems)
      log.info("Enabled/disabled: #{states}")
    end

    # Dump the IDs of all disabled menu items to the log.
    def dump_disabled_ids
      states = UI.QueryWidget(:menu_bar, :EnabledItems)
      states.reject! { |k, v| v }
      log.info("Disabled: #{states.keys}")
    end
  end
end

Yast::MenuBarShortcutsClient.new.main
