require './lib/scorecard'
require './lib/user_interface'


def bowl_ball(game) #bowls a ball
  bowl = UserInterface.bowl
  game.add_roll(bowl)
  game.update_attributes
  last_roll = [game.roll, game.roll_score]
  return game
end

def game_session(game) #starts a game session with 10 frames
  while game.frame <= 10 do
    print("Frame:#{game.frame}; Roll: #{game.roll}\n")
    game = bowl_ball(game)
  end
  game
end

def bonus_bowl(game) #special roll for 3rd roll in frame 10
  game.frame =  10
  game.roll = 3
  bowl = UserInterface.last_bowl
  game.add_roll(bowl)
  game.update_attributes
  return game
end

def check_last_roll(game, last_roll) #performs a check to see if player earnt a bonus roll
  if last_roll == [1, 10] 
    game.frame = 10
    game.roll = 2
    game = bowl_ball(game)
    game = bonus_bowl(game)
  elsif game.earned_bonus == 'spare'
    game = bonus_bowl(game)
  end
  game
end

def tally_bonuses(game) #adds the bonuses from the spares and stikes
  game.find_spares
  game.find_strikes
  game
end

def final_result(game) #prints the player's score 
  print("#{game.total_score}\n")
  if game.total_score.to_i == 300
    print("Well done a Perfect Game\n")
  elsif
    game.total_score.to_i == 0
    print("You Suck. Gutter Game!\n") 
  end
end




def run_game
    game = ScoreCard.new_game("Roshan")
    game = game_session(game)
    last_roll = [game.roll, game.roll_score]
    print("#{last_roll}\n")
    game = check_last_roll(game, last_roll)
    game = tally_bonuses(game)
    final_result(game)
end

run_game

