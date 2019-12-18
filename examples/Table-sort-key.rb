# encoding: utf-8

module Yast
  class TableSortingClient < Client
    def main
      Yast.import "UI"
      UI.OpenDialog(
        VBox(
          Label("Disk"),
          MinSize(
            30,
            10,
            Table(
              Header("Device", Right("Size")),
              [
                Item(Id(1),
                     term(:cell, term(:sortKey, "sd0a001"), "sda1"),
                     term(:cell, term(:sortKey, "10240"), "10.00 MiB")),
                Item(Id(2),
                     term(:cell, term(:sortKey, "sd0a010"), "sda10"),
                     term(:cell, term(:sortKey, "2"), "2.00 KiB")),
                Item(Id(3),
                     term(:cell, term(:sortKey, "sd0a002"), "sda2"),
                     term(:cell, term(:sortKey, "256"), "0.25 MiB")),
                Item(Id(4),
                     term(:cell, term(:sortKey, "sd0b"), "sdb"),
                     term(:cell, term(:sortKey, "32"), "32.00 KiB")),
                Item(Id(5),
                     term(:cell, term(:sortKey, "sd0b2"), "sdb2"),
                     term(:cell, term(:sortKey, "4"), "4.00 KiB")),
                Item(Id(6),
                     term(:cell, term(:sortKey, "sdaa"), "sdaa"),
                     term(:cell, term(:sortKey, "512"), "0.50 MiB"))
              ]
            )
          ),
          PushButton("&OK")
        )
      )
      UI.UserInput
      UI.CloseDialog
    end
  end
end

Yast::TableSortingClient.new.main
