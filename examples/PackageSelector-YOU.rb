# encoding: utf-8
#
# PackageSelector in YOU (YaST Online Update) mode example
#
# This will load the configured repos and their content.
# No root permissions are needed.
#
module Yast
  class PackageSelectorYOUClient < Client
    def main
      Yast.import "UI"
      Yast.import "Pkg"

      Pkg.TargetInitialize("/")
      Pkg.TargetLoad
      Pkg.SourceRestore
      Pkg.SourceLoad

      UI.OpenDialog(
        Opt(:defaultsize),
        PackageSelector(Id(:selector), Opt(:testMode, :youMode))
      )

      UI.RunPkgSelection(Id(:selector))
      UI.CloseDialog

      Builtins.y2milestone("Input: %1", @input)

      nil
    end
  end
end

Yast::PackageSelectorYOUClient.new.main
