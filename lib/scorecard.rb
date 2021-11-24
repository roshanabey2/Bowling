require "pg"

$default_row = {"turn"=>0, "frame"=>1, "roll"=>1, "roll_score"=>0, "added_bonus"=>0, "frame_score"=>0, "total_score"=>0, "earned_bonus"=>"none"} 

class ScoreCard
  attr_accessor :player_name, :turn, :frame, :roll, :roll_score, :added_bonus, :frame_score, :total_score, :earned_bonus 
  
  def initialize(player_name, turn, frame, roll, roll_score, added_bonus, frame_score, total_score, earned_bonus) 
    @player_name = player_name
    @turn = turn.to_i
    @frame = frame.to_i
    @roll = roll
    @roll_score = roll_score.to_i
    @added_bonus = added_bonus.to_i
    @frame_score =  frame_score.to_i
    @total_score = total_score.to_i
    @earned_bonus = earned_bonus
  end
  
  def self.new_game(player_name) #creates blank table for game
    connection = PG.connect(dbname: "bowling")
    connection.exec("TRUNCATE bowling_scorecard RESTART identity")
    game =  ScoreCard.create(player_name, $default_row) #game -> controller expression ->in 
  end

  def self.create(player_name, turn) # screates a new scorecard for the player with default values 
    new_game = ScoreCard.new(player_name, turn['turn'], turn['frame'], turn['roll'],
      turn['roll_score'], turn['added_bonus'], turn['frame_score'], turn['total_score'], turn['earned_bonus'])
    new_game
  end

  def add_roll(roll_value) # <- controller input
    @earned_bonus = $default_row['earned_bonus']
    @frame_score = @roll_score + roll_value
    @roll_score = roll_value
    @total_score += roll_value 
    if (roll_value == 10)
      @earned_bonus = 'strike'
    elsif (@roll == 2) && (@frame_score == 10)
      @earned_bonus = 'spare'
    end
    self.add_to_table(@frame, @roll, @roll_score, @earned_bonus, @frame_score, @total_score)
  end


  def update_attributes() #updates the active scorecard for the player
    if  (@roll == 2) || (@earned_bonus == 'strike')
      @roll = $default_row['roll']
      @frame += 1
    else
      @roll = 2
    end
    if @earned_bonus == 'spare' || @earned_bonus == 'strike'
      print(" Well done a #{@earned_bonus}!\n")
    end
    if @earned_bonus == 'strike' || @roll == 2
      print("Frame Score : #{@frame_score}\n")
    end
    @turn += 1
  end


  def find_spares #checks database for spare
    connection = PG.connect(dbname: "bowling")
    spares = connection.query("SELECT * FROM bowling_scorecard WHERE earned_bonus = 'spare';")
    spares.each { |spare| add_spare_bonus(spare['turn']) }
  end

  

  def find_strikes #checks database for strikes
    connection = PG.connect(dbname: "bowling")
    strikes = connection.query("SELECT * FROM bowling_scorecard WHERE earned_bonus = 'strike';")
    strikes.each { |strike| add_strike_bonus(strike['turn'], strike['frame'], strike['roll']) }
  end

 
 
  private

  def connection
    PG.connect(dbname: "bowling")
  end

  def add_to_table(frame, roll, roll_score, earned_bonus, frame_score, total_score)
   connection.exec_params("INSERT INTO bowling_scorecard (frame,roll,roll_score,earned_bonus,frame_score,total_score) VALUES ($1,$2,$3,$4,$5,$6) RETURNING turn", [frame, roll, roll_score, earned_bonus, frame_score, total_score])
  end

  def add_spare_bonus(turn) #adds the bonus values to the relevant row
    next_turn = turn.to_i + 1
    bonus = connection.query("SELECT * FROM bowling_scorecard WHERE turn = '#{next_turn}'").first
    @turn = turn
    @added_bonus = bonus['roll_score'].to_i 
    @total_score += @added_bonus 
    connection.exec_params("UPDATE bowling_scorecard SET added_bonus = $1 WHERE turn = '#{turn}';", [@added_bonus])
  end
  
  def add_strike_bonus(turn, frame, roll) #adds the bonus values to the relevant row
    @frame = frame.to_i
    @roll = roll.to_i
    @turn = turn.to_i
    unless @frame == 10
      next_turn = turn.to_i + 1
      turn_after = turn.to_i + 2
      first_bonus = connection.query("SELECT * FROM bowling_scorecard WHERE turn = '#{next_turn}'").first
      second_bonus = connection.query("SELECT * FROM bowling_scorecard WHERE turn = '#{next_turn}'").first
      @added_bonus = first_bonus['roll_score'].to_i + second_bonus['roll_score'].to_i
      @total_score += @added_bonus 
      connection.exec_params("UPDATE bowling_scorecard SET added_bonus = $1  WHERE turn = '#{turn}';", [@added_bonus])
    else
    end
  end



end
