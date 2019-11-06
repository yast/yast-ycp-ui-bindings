# encoding: utf-8

module Yast
  class ExampleClient < Client
    Yast.import "UI"
    include Yast::Logger

    def main
      UI.OpenDialog(main_dialog)
      set_visible_items
      handle_events
      UI.CloseDialog
    end

    protected

    VISIBLE_ITEMS    = 6

    # Some constants to make handling the numeric status values better readable.
    # Those constants correspond to the index of the status in the status
    # definition (see custom_states).

    MOD_DONT_INSTALL = 0
    MOD_INSTALL      = 1
    MOD_AUTOINSTALL  = 2

    # The custom status values. Each one has an icon name, a text equivalent to
    # indicate that status in the NCurses UI, and an optional next status.
    #
    # If a next status is specified, a click on that item will automatically
    # cycle to that next status. If not specified (or -1), the application
    # needs to handle status transitions from that status to another one.
    def custom_states
      [
        # icon,          NCurses indicator, next status (optional)
        ["checkbox-off",            "[  ]", MOD_INSTALL     ],
        ["checkbox-on",             "[ +]", MOD_DONT_INSTALL],
        ["checkbox-auto-selected",  "[a+]", MOD_DONT_INSTALL]
      ]
    end

    def items
      [
        #       item ID,      heading label ,     description text (optional)
        Item(Id(:mod_kde   ), "KDE Plasma",      "Full-fledged desktop"             ),
        Item(Id(:mod_xfce  ), "Xfce",            "Lightweight desktop"              ),
        Item(Id(:mod_x11   ), "X Window System", "X11, simple window manager, xterm"),
        Item(Id(:mod_office), "LibreOffice",     "Office suite"                     ),
        Item(Id(:mod_server), "Server Tools",    "Web server, database, file server"),
        Item(Id(:mod_sdk   ), "SDK",             "Development tools"                )
      ]
    end

    def main_dialog
      MarginBox(2, 0.4,
        VBox(
          Heading("Add-on Software"),
          VSpacing(0.2),
          CustomStatusItemSelector(Id(:modules), Opt(:notify), custom_states, items),
          VSpacing(0.4),
          Label(Id(:result_field), Opt(:outputField, :hstretch), "\n\n\n\n\n"),
          VSpacing(0.3),
          Right(
            PushButton(Id(:close), "&Close")
          )
        )
      )
    end

    def set_visible_items
      UI.ChangeWidget(:modules, :VisibleItems, VISIBLE_ITEMS)
      UI.RecalcLayout # needed for the change to have an effect
    end

    def handle_events
      while true
        event = UI.WaitForEvent
        log.info("Event: #{event}")

        break if [:close, :cancel].include?(event["WidgetID"]) # :cancel is WM_CLOSE

        # If Opt(:notify) is set, the CustomStatusItemSelector sends MenuEvents
        # with the ID of the item the user clicked or activated via keyboard.
        handle_item_click(event["ID"]) if event["EventType"] == "MenuEvent"
      end
      nil
    end

    # Handle an item click (or a keyboard action on an item).
    def handle_item_click(item_id)
      return if item_id.nil?
      log.info("Item #{item_id} clicked")

      # The ItemSelector already handled the common status transitions that we
      # defined in the status definition: 0 -> 1, 1 -> 0, 2 -> 0.
      #
      # Now check if we need to change the status of other items because of
      # dependencies to demonstrate sample business logic.
      handle_dependencies
      update_result
    end

    # Example business logic: Change the status of some of the example software
    # modules based on dependencies of other modules.
    def handle_dependencies
      # ItemStatus return a hash ov IDs (in our case symbols) to integers (the status):
      # { :mod_kde => 1, :mod_xfce => 0, :mod_x11 = 2, ... }

      status = UI.QueryWidget(:modules, :ItemStatus) # Fetch current status of all items
      log.info("Old status values: #{status}")

      need_office = true if status[:mod_kde]     == MOD_INSTALL
      need_x11    = true if status[:mod_kde]     == MOD_INSTALL
      need_x11    = true if status[:mod_xfce]    == MOD_INSTALL
      need_x11    = true if status[:mod_office]  == MOD_INSTALL

      need_x11    = false if status[:mod_x11]    == MOD_INSTALL # manually selected
      need_office = false if status[:mod_office] == MOD_INSTALL # manually selected

      old_status = status.select { |k, v| [:mod_x11, :mod_office].include?(k) }
      new_status = old_status.dup
      new_status[:mod_x11]    = auto_select_status(new_status, :mod_x11,    need_x11)
      new_status[:mod_office] = auto_select_status(new_status, :mod_office, need_office)

      log.info("Auto-modules old status: #{old_status}")
      log.info("Auto-modules new status: #{new_status}")

      UI.ChangeWidget(:modules, :ItemStatus, new_status) unless new_status == old_status
    end

    # Example business logic: Return a module's effective status based on its
    # old status and a flag indicating if it is needed because of dependencies
    def auto_select_status(status_map, mod, needed)
      old_status = status_map[mod]
      return MOD_AUTOINSTALL  if needed  && old_status == MOD_DONT_INSTALL
      return MOD_DONT_INSTALL if !needed && old_status == MOD_AUTOINSTALL
      old_status
    end

    # Update the "Result" field
    def update_result
      status = UI.QueryWidget(:modules, :ItemStatus)

      status.reject! { |k, v| v == MOD_DONT_INSTALL }
      actions = [ "", "Install", "Auto-install"]
      result = status.collect{ |mod, stat| actions[stat] + " " + mod.to_s }
      log.info("Result: #{result}")

      UI.ChangeWidget(:result_field, :Value, result.join("\n"))
    end

  end
end

Yast::ExampleClient.new.main
