# encoding: utf-8

# Example for table with multi-selection and nested items

module Yast
  class TableNestedMultiSel < Client
    Yast.import "UI"

    def main
      UI.OpenDialog(main_dialog)
      update_selected(selected_items)
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
        disk_items
      )
    end

    def disk_items
      [
        Item(Id(:sda), "/dev/sda", "931.5G", "", "", sda_items, :open),
        Item(Id(:sdb), "/dev/sdb", "931.5G", "", "", sdb_items, :closed),
        Item(Id(:sdc), "/dev/sdc", "232.9G", "", "", sdc_items, :open)
      ]
    end

    def sda_items
      [
        Item(Id(:sda1), "/dev/sda1",  "97.7G", "ntfs", "/win/boot" ),
        Item(Id(:sda2), "/dev/sda2", "833.9G", "ntfs", "/win/app"  )
      ]
    end

    def sdb_items
      [
        Item(Id(:sdb1), "/dev/sdb1",   "2.0G", "swap" ),
        Item(Id(:sdb2), "/dev/sdb2",  "29.4G", "ext4", "/hd-root-leap-42"   ),
        Item(Id(:sdb3), "/dev/sdb3",  "29.4G", "ext4", "/hd-root-leap-15-0" ),
        Item(Id(:sdb4), "/dev/sdb4", "855.8G", "xfs",  "/work" )
      ]
    end

    def sdc_items
      [
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
          update_selected(selected_items)
        end
        id
      end
    end

    def selected_items
      UI.QueryWidget(Id(:table), :SelectedItems)
    end

    def update_selected(ids)
      UI.ChangeWidget(Id(:selected), :Value, ids.join(", "))
    end
  end
end

Yast::TableNestedMultiSel.new.main
