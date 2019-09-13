# encoding: utf-8

module Yast
  class LogView1Client < Client
    def main
      Yast.import "UI"
      @part1 = "They sought it with thimbles, they sought it with care;\n" +
        "They pursued it with forks and hope;\n" +
        "They threatened its life with a railway-share;\n" +
        "They charmed it with smiles and soap. \n" + "\n"

      @part2 = "Then the Butcher contrived an ingenious plan\n" +
        "For making a separate sally;\n" +
        "And fixed on a spot unfrequented by man,\n" +
        "A dismal and desolate valley. \n" + "\n"

      @part3 = "But the very same plan to the Beaver occurred:\n" +
        "It had chosen the very same place:\n" +
        "Yet neither betrayed, by a sign or a word,\n" +
        "The disgust that appeared in his face. \n" + "\n"

      @part4 = "Each thought he was thinking of nothing but \"Snark\"\n" +
        "And the glorious work of the day;\n" +
        "And each tried to pretend that he did not remark\n" +
        "That the other was going that way. \n" + "\n"

      @part5 = "But the valley grew narrow and narrower still,\n" +
        "And the evening got darker and colder,\n" +
        "Till (merely from nervousness, not from goodwill)\n" +
        "They marched along shoulder to shoulder. \n" + "\n"

      @part6 = "Then a scream, shrill and high, rent the shuddering sky,\n" +
        "And they knew that some danger was near:\n" +
        "The Beaver turned pale to the tip of its tail,\n" +
        "And even the Butcher felt queer. \n" + "\n"

      @part7 = "He thought of his childhood, left far far behind--\n" +
        "That blissful and innocent state--\n" +
        "The sound so exactly recalled to his mind\n" +
        "A pencil that squeaks on a slate! \n" + "\n"

      @part8 = "\"'Tis the voice of the Jubjub!\" he suddenly cried.\n" +
        "(This man, that they used to call \"Dunce.\")\n" +
        "\"As the Bellman would tell you,\" he added with pride,\n" +
        "\"I have uttered that sentiment once.\n" + "\n"

      @thats_it = "\n\n*** Press [OK] once more to exit. ***"

      UI.OpenDialog(
        VBox(
          LogView(
            Id(:log),
            "&Excerpt from \"The Hunting Of The Snark\" by Lewis Carroll",
            5, # visible lines
            10
          ), # lines to store
          PushButton(Opt(:default), "&OK")
        )
      )

      UI.ChangeWidget(Id(:log), :LastLine, @part1)
      UI.UserInput
      UI.ChangeWidget(Id(:log), :LastLine, @part2)
      UI.UserInput
      UI.ChangeWidget(Id(:log), :LastLine, @part3)
      UI.UserInput
      UI.ChangeWidget(Id(:log), :LastLine, @part4)
      UI.UserInput
      UI.ChangeWidget(Id(:log), :LastLine, @part5)
      UI.UserInput
      UI.ChangeWidget(Id(:log), :LastLine, @part6)
      UI.UserInput
      UI.ChangeWidget(Id(:log), :LastLine, @part7)
      UI.UserInput
      UI.ChangeWidget(Id(:log), :LastLine, @part8)
      UI.UserInput

      UI.ChangeWidget(Id(:log), :Value, @thats_it)
      UI.UserInput
      UI.CloseDialog

      nil
    end
  end
end

Yast::LogView1Client.new.main
