require 'optparse'

# Class for parsing command line options passed to the program using the ruby optparse library.
class CommandLineOptions

  # Returns a map of options for various values configuring the game play.
  def self.parse()
    # initialize the default values of the options map
    options = {
      :fast => FALSE,
      :board => 'data/initial_board.txt'
    }

    # create an options parser with names and descriptions
    parser = OptionParser.new do |opts|
      opts.on('-b', '--board PATH', "Specify the initial board file. (default: #{options[:board]})") { |o| options[:board] = o }
      opts.on('-f', '--fast', 'Don\'t sleep between instructions.') { |o| options[:fast] = TRUE }
      opts.on('-h', '--help', 'Prints this help') {|o| puts(opts); exit }
    end

    # parse the command line options using the parser, which will populate the options map
    parser.parse!

    return options
  end
end
