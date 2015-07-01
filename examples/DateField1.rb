# encoding: utf-8

# Simple example for DateField
module Yast
  class DateField1Client < Client
    def main
      Yast.import "UI"

      @ini_date = "1989-11-09"
      @ini_time = "20:15:00"

      UI.OpenDialog(
        MinSize(
        25,
        7,
          VBox(
            Left(DateField(Id(:date), Opt(:hstretch, :notify), "Date:", @ini_date)),
            Left(TimeField(Id(:time), Opt(:hstretch, :notify), "Time:", @ini_time)),
            HBox(InputField(Id(:date_set), Opt(:hstretch), "Date: ", @ini_date),
                  InputField(Id(:time_set), Opt(:hstretch), "Time: ", @ini_time)),
            PushButton(Id(:ok), "&OK")
          )
        )
      )

      begin
        @id = UI.UserInput
        UI.ChangeWidget(Id(:date_set), :Value, UI.QueryWidget(Id(:date), :Value))
        UI.ChangeWidget(Id(:time_set), :Value, UI.QueryWidget(Id(:time), :Value))
        Builtins.y2milestone("Date: %1", UI.QueryWidget(Id(:date), :Value))
        Builtins.y2milestone("Time: %1", UI.QueryWidget(Id(:time), :Value))
      end until @id == :ok || @id == :cancel

      UI.CloseDialog

      nil
    end
  end
end

Yast::DateField1Client.new.main
