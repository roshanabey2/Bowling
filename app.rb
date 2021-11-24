require './lib/scorecard'
require './lib/user_interface'


#def bowl_ball(game)
#  bowl = UserInterface.bowl
 # game.add_roll(bowl)
 # game.update_attributes
 # last_roll = [game.roll, game.roll_score]
 # return last_roll
#end






def run_game
    game = ScoreCard.new_game("Roshan")
    while game.frame <= 10 do
      print("Frame:#{game.frame}; Roll: #{game.roll}\n")
      bowl = UserInterface.bowl
      game.add_roll(bowl)
      game.update_attributes
    end
    last_roll = [game.roll, game.roll_score]
    print("#{last_roll}\n")
    if last_roll == [1, 10] 
      game.frame = 10
      game.roll = 2
      bowl = UserInterface.bowl
      game.add_roll(bowl)
      game.update_attributes
      game.frame =  10
      game.roll = 3
      bowl = UserInterface.last_bowl
      game.add_roll(bowl)
      game.update_attributes
    elsif game.earned_bonus == 'spare'
      game.frame = 10
      game.roll = 3
      bowl = UserInterface.last_bowl
      game.add_roll(bowl)
      game.update_attributes
    end
    game.find_spares
    game.find_strikes
    print("#{game.total_score}\n")
    if game.total_score.to_i == 300
      print("Well done a Perfect Game\n")
    elsif
      game.total_score.to_i == 0
      print("You Suck. Gutter Game!\n") 
    end
 end

run_game

