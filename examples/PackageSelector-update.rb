# encoding: utf-8
#
# PackageSelector in system update mode example
#
# This will load the configured repos and their content.
# No root permissions are needed.
#
module Yast
  class PackageSelectorUpdateClient < Client
    def main
      Yast.import "UI"
      Yast.import "Pkg"

      Pkg.TargetInitialize("/")
      Pkg.TargetLoad
      Pkg.SourceRestore
      Pkg.SourceLoad

      UI.OpenDialog(
        Opt(:defaultsize),
        PackageSelector(Id(:selector), Opt(:testMode, :updateMode))
      )
      @input = UI.RunPkgSelection(Id(:selector))
      UI.CloseDialog

      Builtins.y2milestone("Input: %1", @input)

      nil
    end
  end
end

Yast::PackageSelectorUpdateClient.new.main
