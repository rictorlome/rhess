require_relative 'board'
require_relative 'piece'
require_relative 'cursor'
require_relative 'display'
require_relative 'human_player'
require 'byebug'


class Game
  attr_reader :board, :display
  attr_accessor :turn

  def initialize
    @board = Board.new
    board.set_board
    @display = Display.new(@board)
    @player1 = HumanPlayer.new('Sam', self, :white)
    @player2 = HumanPlayer.new('Bob', self, :black)
    @turn = :white
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
    until game_over?
      @player1.make_move
      @player2.make_move
    end
    system('clear')
    display.render
    puts "Checkmate!"
    puts winner
  end
end

if __FILE__ == $PROGRAM_NAME
  g = Game.new
  g.play
end
