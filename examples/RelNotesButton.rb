# encoding: utf-8

# Trivial example for Release Notes button
module Yast
  class RelNotesButtonClient < Client
    def main
      Yast.import "UI"

      rel_notes_file = UI.TextMode ? "./RELEASE-NOTES.en.txt" : "./RELEASE-NOTES.en.rtf"
      rel_notes_text = SCR.Read(path(".target.string"), rel_notes_file)
      rel_notes = { "SLES12" => rel_notes_text, "Some-Add-On" => "some text" }

      UI.SetReleaseNotes(rel_notes)

      UI.OpenDialog(
        VBox(
          Right(PushButton(Id(:relNotes), Opt(:relNotesButton), "&Release Notes")),
          VSpacing(2.0),
          Heading("Expert Dialog"),
          VSpacing(2.0),
          MinSize(
            60,
            15,
            MarginBox(
              1.0,
              0.5,
              CheckBoxFrame(
                "E&xpert Settings",
                true,
                VBox(
                  HBox(
                    InputField("&Server"),
                    ComboBox("&Mode", ["Automatic", "Manual", "Debug"])
                  ),
                  Left(CheckBox("&Logging")),
                  InputField("&Connections")
                )
              )
            )
          ),
          PushButton(Id(:ok), "&OK")
        )
      )

      begin
        @id = UI.UserInput
      end until @id == :ok || @id == :cancel

      UI.CloseDialog

      nil
    end
  end
end

Yast::RelNotesButtonClient.new.main
