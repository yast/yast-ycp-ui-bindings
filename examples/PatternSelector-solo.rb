# encoding: utf-8
#
# Simple example for PatternSelector
#
# This will load the configured repos and their content.
# No root permissions are needed.
#
module Yast
  class PatternSelectorSoloClient < Client
    def main
      Yast.import "Pkg"
      Yast.import "UI"

      if !UI.HasSpecialWidget(:PatternSelector)
        not_supported_warning
        return
      end

      Pkg.TargetInitialize("/")
      Pkg.TargetLoad
      Pkg.SourceRestore
      Pkg.SourceLoad

      UI.OpenDialog(Opt(:defaultsize), PatternSelector(Id(:selector)))
      @input = UI.RunPkgSelection(Id(:selector))
      UI.CloseDialog

      Builtins.y2milestone("Input: %1", @input)

      nil
    end

    def not_supported_warning
      UI.OpenDialog(
        VBox(
          Label("Error: This UI doesn't support the PatternSelector widget!"),
          PushButton(Opt(:default), "&OK")
        )
      )
      UI.UserInput
      UI.CloseDialog
    end
  end
end

Yast::PatternSelectorSoloClient.new.main
