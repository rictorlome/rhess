require "io/console"

KEYMAP = {
  " " => :space,
  "h" => :left,
  "j" => :down,
  "k" => :up,
  "l" => :right,
  "w" => :up,
  "a" => :left,
  "s" => :down,
  "d" => :right,
  "\t" => :tab,
  "\r" => :return,
  "\n" => :newline,
  "\e" => :escape,
  "\e[A" => :up,
  "\e[B" => :down,
  "\e[C" => :right,
  "\e[D" => :left,
  "\177" => :backspace,
  "\004" => :delete,
  "\u0003" => :ctrl_c,
}

MOVES = {
  left: [0, -1],
  right: [0, 1],
  up: [-1, 0],
  down: [1, 0]
}

class Cursor

  attr_reader :board
  attr_accessor :cursor_pos, :move_buffer

  def initialize(cursor_pos, board)
    @cursor_pos = cursor_pos
    @board = board
    @move_buffer = []
  end

  def get_input
    key = KEYMAP[read_char]
    handle_key(key)
  end

  private

  def read_char
    STDIN.echo = false # stops the console from printing return values

    STDIN.raw! # in raw mode data is given as is to the program--the system
                 # doesn't preprocess special characters such as control-c

    input = STDIN.getc.chr # STDIN.getc reads a one-character string as a
                             # numeric keycode. chr returns a string of the
                             # character represented by the keycode.
                             # (e.g. 65.chr => "A")

    if input == "\e" then
      input << STDIN.read_nonblock(3) rescue nil # read_nonblock(maxlen) reads
                                                   # at most maxlen bytes from a
                                                   # data stream; it's nonblocking,
                                                   # meaning the method executes
                                                   # asynchronously; it raises an
                                                   # error if no data is available,
                                                   # hence the need for rescue

      input << STDIN.read_nonblock(2) rescue nil
    end

    STDIN.echo = true # the console prints return values again
    STDIN.cooked! # the opposite of raw mode :)

    return input
  end

  def handle_key(key)
    if [:left, :right, :up, :down].include?(key)
      diff = MOVES[key]
      update_pos(diff)
    elsif key == :space
      move_buffer << @cursor_pos
    elsif key == :ctrl_c
      exit
    end
  end

  def update_pos(diff)
    cX, cY = @cursor_pos
    dX, dY = diff
    nX, nY = cX + dX, cY + dY
    nX, nY = wrap(nX, nY)
    @cursor_pos = [nX, nY]
  end

  def wrap(nX,nY)
    nX = 7 if nX < 0
    nY = 7 if nY < 0
    nX = 0 if nX > 7
    nY = 0 if nY > 7
    return nX, nY
  end
end
