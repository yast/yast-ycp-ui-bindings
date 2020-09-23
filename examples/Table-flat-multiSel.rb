# encoding: utf-8

# Example for table with nested items

module Yast
  class TableNestedItems < Client
    Yast.import "UI"

    def main
      UI.OpenDialog(main_dialog)
      update_selected(current_table_item)
      handle_events
      UI.CloseDialog
    end

    def main_dialog
      MinSize(
        74, 17,
        MarginBox(
          1, 0.4,
          VBox(
            Left(
              Heading("Storage Overview")
            ),
            VSpacing(0.2),
            table,
            VSpacing(0.2),
            Left(Label("Selected:")),
            Label(Id(:selected), Opt(:outputField, :hstretch), "..."),
            VSpacing(0.3),
            Right(
              PushButton(Id(:close), "&Close")
            )
          )
        )
      )
    end

    def table
      Table(
        Id(:table),
        Opt(:notify, :immediate, :multiSelection),
        Header("Device", "Size", "Type", "Mount Point"),
        items
      )
    end

    def items
      [
        Item(Id(:sda), "/dev/sda", "931.6G"),
        Item(Id(:sda1), "/dev/sda1",  "97.7G", "ntfs", "/win/boot" ),
        Item(Id(:sda2), "/dev/sda2", "833.9G", "ntfs", "/win/app"  ),
        Item(Id(:sdb), "/dev/sdb", "931.5G"),
        Item(Id(:sdb1), "/dev/sdb1",   "2.0G", "swap" ),
        Item(Id(:sdb2), "/dev/sdb2",  "29.4G", "ext4", "/hd-root-leap-42"   ),
        Item(Id(:sdb3), "/dev/sdb3",  "29.4G", "ext4", "/hd-root-leap-15-0" ),
        Item(Id(:sdb4), "/dev/sdb4", "855.8G", "xfs",  "/work" ),
        Item(Id(:sdc), "/dev/sdc", "232.9G"),
        Item(Id(:sdc1), "/dev/sdc1",   "2.0G", "swap", "[swap]" ),
        Item(Id(:sdc2), "/dev/sdc2",  "29.4G", "ext4", "/ssd-root-leap-15-1" ),
        Item(Id(:sdc3), "/dev/sdc3",  "29.4G", "ext4", "/" ),
        Item(Id(:sdc4), "/dev/sdc4", "167.2G", "ext4", "/ssd-work" )
      ]
    end

    def handle_events
      while true
        id = UI.UserInput
        case id

        when :close, :cancel # :cancel is WM_CLOSE
          break # leave event loop
        when :table
          update_selected(current_table_item)
        end
        id
      end
    end

    def current_table_item
      UI.QueryWidget(Id(:table), :CurrentItem)
    end

    def update_selected(id)
      id ||= "<nil>"
      UI.ChangeWidget(Id(:selected), :Value, id.to_s)
    end
  end
end

Yast::TableNestedItems.new.main
