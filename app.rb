require './lib/scorecard'
require './lib/user_interface'


def run_game
  choice = UserInterface.welcome
  if choice == 'start'
    player = UserInterface.start_game
    ScoreCard.create(player)
  elsif choice == "quit"
    exit()
  else
    run_game
  end
end

run_game

