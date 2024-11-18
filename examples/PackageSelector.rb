# encoding: utf-8
#
# PackageSelector in standard mode example
#
# This will load the configured repos and their content.
# No root permissions are needed.
#
module Yast
  class PackageSelectorClient < Client
    def main
      Yast.import "UI"
      Yast.import "Pkg"

      Pkg.TargetInitialize("/")
      Pkg.TargetLoad
      Pkg.SourceRestore
      Pkg.SourceLoad

      UI.OpenDialog(
        Opt(:defaultsize),
        PackageSelector(Id(:selector))
      )

      @input = UI.RunPkgSelection(Id(:selector))
      UI.CloseDialog

      Builtins.y2milestone("Input: %1", @input)

      nil
    end
  end
end

Yast::PackageSelectorClient.new.main
