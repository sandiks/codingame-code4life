require_relative 'test_helper'
require_relative 'main2'

@mol_names = "ABCDE"


def test
  @show_info = true

  gg = Game.new
  data = parse_data_f
  gg.players = data[:players]
  gg.samples = data[:samples]
  gg.avail_store = data[:avail_store]
  @my = gg.players[0]
  @opp = gg.players[1]


  #p sorted_samples = @opp_samples.map(&:cost).sort_by(&:max)
  gg.parse_input_data_and_init_some_variables
  opp_connect = [0,0,0,-1,-1,-1]
  
  3.times do |ind|
  	p "------------------"
  
  	gg.avail_store[opp_connect[ind]]-=1 if opp_connect[ind]>=0 
    gg.process_mol()

  end
end
test
