# encoding: utf-8
#
# Wizard example with steps.
#
# Note: Ruby applications are discouraged from using the Wizard widget directly.
# Use the Wizard module instead.
#

module Yast
  class WizardClient < Client
    include Yast::Logger
    YAST_ICON = "/usr/share/icons/hicolor/scalable/apps/yast.svg".freeze
    
    def main
      Yast.import "UI"
      
      return unless ensure_wizard_widget
      
      UI.OpenDialog(Opt(:defaultsize), wizard_dialog)
      set_up_wizard
      event_loop
      UI.CloseDialog
      nil
    end

    def event_loop
      while true
        event = UI.WaitForEvent
        log.info("Got event: #{event}")
        break if event["ID"] == :abort

        display_event(event)
      end
    end

    def ensure_wizard_widget
      return true if UI.HasSpecialWidget(:Wizard)

      msg = "FATAL: This works only with UIs that provide the wizard widget!"
      log.error(msg)
      puts(msg)
      false
    end

    def wizard_dialog
      Wizard(
        Opt(:stepsEnabled),
        :back, "&Back",
        :abort, "Ab&ort",
        :next, "&Next"
      )
    end

    def set_up_wizard
      UI.WizardCommand(term(:SetDialogIcon, YAST_ICON))
      UI.WizardCommand(term(:SetDialogHeading, "Welcome to the YaST2 installation"))
      UI.WizardCommand(term(:SetHelpText, help_text))
      add_wizard_steps
    end

    def help_text
      "<p>This is a help text.</p>" +
      "<p>It should be helpful.</p>" +
      "<p>If it isn't helpful, it should rather not be called a <i>help text</i>.</p>"
    end

    def add_wizard_steps
      UI.WizardCommand(term(:AddStepHeading, "Base Installation"))
      UI.WizardCommand(term(:AddStep, "Language", "lang"))
      UI.WizardCommand(term(:AddStep, "Installation Settings", "proposal"))
      UI.WizardCommand(term(:AddStep, "Perform Installation", "doit"))

      UI.WizardCommand(term(:AddStepHeading, "Configuration"))
      UI.WizardCommand(term(:AddStep, "Root Password", "root_pw"))
      UI.WizardCommand(term(:AddStep, "Network", "net"))
      UI.WizardCommand(term(:AddStep, "Online Update", "you"))
      UI.WizardCommand(term(:AddStep, "Users", "auth"))
      UI.WizardCommand(term(:AddStep, "Clean Up", "suse_config"))
      UI.WizardCommand(term(:AddStep, "Release Notes", "rel_notes"))
      UI.WizardCommand(term(:AddStep, "Device Configuration", "hw_proposal"))
      UI.WizardCommand(term(:UpdateSteps))
      
      UI.WizardCommand(term(:SetCurrentStep, "net"))
    end
  end

  def display_event(event)
    serial = event["EventSerialNo"]
    type = event["EventType"]
    id = event["ID"]

    UI.ReplaceWidget(
      Id(:contents),
      HVSquash(
        VBox(
          Heading("Caught event:"),
          VSpacing(0.5),
          Left(Label("Type: #{type}")),
          Left(Label("ID: #{id}")),
          Left(Label("Serial No: #{serial}"))
        )
      )
    )
  end
end

Yast::WizardClient.new.main
