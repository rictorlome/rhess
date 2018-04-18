require_relative 'board'
require_relative 'command_line_options'
require_relative 'cursor'
require_relative 'display'
require_relative 'human_player'


class Game
  attr_reader :board, :display
  attr_accessor :turn

  def initialize
    @options = CommandLineOptions.parse()
    @board = Board.new()

    board_lines = File.readlines(@options[:board]).reject { |line| line.strip.empty? }
    @board.set_board(board_lines.slice(0,8).join())
    @turn = (board_lines[-1].downcase.include?('black')) ? :black : :white

    @display = Display.new(@board)
    @player1 = HumanPlayer.new('Sam', self, :white)
    @player2 = HumanPlayer.new('Bob', self, :black)
  end

  def render
    system('clear')
    display.render
    self.check_status
    self.checkmate_status
    puts "The move buffer: #{display.cursor.move_buffer}"
    puts "#{self.turn} to move."
  end

  def check_status
    print "White in check?:  "
    if board.in_check?(:white)
      puts board.in_check?(:white).to_s.colorize(:red)
    else
      puts board.in_check?(:white).to_s.colorize(:green)
    end
    print "Black in check?:  "
    if board.in_check?(:black)
      puts board.in_check?(:black).to_s.colorize(:red)
    else
      puts board.in_check?(:black).to_s.colorize(:green)
    end
  end

  def checkmate_status
    print "White in checkmate?: "
    puts board.checkmate?(:white)
    print "Black in checkmate?: "
    puts board.checkmate?(:black)
  end

  def game_over?
    board.checkmate?(:white) || board.checkmate?(:black)
  end

  def winner
    board.checkmate?(:white) ? "Black wins!" : "White wins!"
  end

  def play
    system("clear")
    render_welcome
    until game_over?
      @player1.make_move
      @player2.make_move
    end
    system('clear')
    display.render
    puts "Checkmate!"
    puts winner
  end

  def save(path)
    puts("Saving game to #{path}")
    sleep(2)
    File.open(path, 'w') { |file|
      file.write(@display.render_to_string())
      file.write("#{self.turn} to move.")
    }
  end

  def render_welcome
    puts "Welcome to..."
    puts".______       __    __   _______     _______.     _______.".colorize(:blue)
    puts"|   _  \\     |  |  |  | |   ____|   /       |    /       |".colorize(:blue)
    puts"|  |_)  |    |  |__|  | |  |__     |   (----`   |   (----`".colorize(:blue)
    puts"|      /     |   __   | |   __|     \\   \\        \\   \\    ".colorize(:blue)
    puts"|  |\\  \\----.|  |  |  | |  |____.----)   |   .----)   |   ".colorize(:blue)
    puts"| _| `._____||__|  |__| |_______|_______/    |_______/  ".colorize(:blue)
    puts ""
    puts "... #{"ruby".colorize(:red)} chess in the console."
    puts ""
    pause(1)
    puts "Gameplay is simple."
    pause(1)
    puts "Play against yourself or a friend by using the space-bar."
    pause(1.5)
    puts ""
    puts "Press #{"SPACE".colorize(:green)} to pick a piece up."
    pause(1.25)
    puts "Use the #{"ARROW KEYS".colorize(:magenta)} to move the cursor around."
    pause(1.25)
    puts "Press #{"SPACE".colorize(:green)} to put the piece down."
    pause(2)
    puts ""
    puts "If you are using a MAC, press #{("\u2318" + " AND +").colorize(:cyan)} to zoom in/enlarge the board."
    puts ""
    pause(1.5)
    puts "Selected pieces are highlighted #{"YELLOW".colorize(:yellow)}."
    pause(1)
    puts "The cursor's position is highlighted #{"RED".colorize(:light_red)}."
    pause(1.5)
    puts "The game should finish automatically when one of you has won."
    pause(1)
    puts ""
    puts "Thats it! Enjoy!"
    pause(1)
    puts "Press #{"ENTER".colorize(:light_magenta)} when you're ready to play."
    input = gets
    until input == "\n"
      input = ""
      input = gets
    end
    system('clear')
  end

  def pause(amount)
    rate = @options[:fast] ? 0 : 1
    sleep(rate * amount)
  end

end



if __FILE__ == $PROGRAM_NAME
  g = Game.new
  g.play
end
