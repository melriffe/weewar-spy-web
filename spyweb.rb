# WeewarSpy Web
%w{
  rubygems
  sinatra
  haml
  yaml
}.each {|dependency| require dependency}

# Load the vendor'ed weewar-spy library.
require File.dirname(__FILE__) + '/vendor/weewar-spy/lib/weewar-spy'

# Load the Operative.
require File.dirname(__FILE__) + '/lib/operative'

configure do
  Title = 'WeewarSpy Web'

  # Load the Weewar configuration.
  config_file = File.dirname(__FILE__) + '/config.yml'
  unless File.exists?(config_file)
    puts 'Cannot find config.yml!'
    puts '$ cp config.yml.example config.yml'
    puts 'Then edit config.yml.'
    exit
  end
  SpyConfig = YAML.load_file(config_file)

  # Create an operative.
  options = {:server   => SpyConfig['server'],
             :username => SpyConfig['username'],
             :api_key  => SpyConfig['api_key'] }
  Spy = Operative.new(options)
end

get '/' do
  @games = Spy.games.sort
  haml :index
end

get '/stylesheets/styles.css' do
  content_type 'text/css', :charset => 'utf-8'
  sass :stylesheet
end

get '/game/:id' do
  @game = Spy.infiltrate(params[:id].to_i)
  @report = Spy.debrief(@game, false) # Don't print the output, just return it.
  @game_button_label = 'View Game'
  unless @game.current_player.nil?
    @game_button_label = 'Play Game' if @game.current_player.name == Spy.director.name
  end
  haml :game
end
