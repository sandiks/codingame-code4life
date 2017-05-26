STDOUT.sync = true # DO NOT REMOVE

SONG = %q(
)

class Player
  attr_accessor :target, :eta, :score, :storage, :expertise
  def storage_sum
    @storage.reduce(:+)
  end
  def expertise_sum
    @expertise.reduce(:+)
  end
end

class Sample
  attr_accessor :id, :carried_by, :rank, :health, :expertise_gain, :cost, :enable
  def cost_sum
    cost.reduce(:+)
  end
  def cost_max
    cost.max
  end
end

class Game
  attr_accessor :players, :samples, :debug, :avail_store, :science_projects

  def initialize()
    @debug = false
  end

  def  parse_data

    @players =[]

    2.times do |indx|
      target, eta, score, str_a, str_b, str_c, str_d, str_e, exp_a, exp_b, exp_c, exp_d, exp_e = gets.split(" ")

      pp = Player.new
      pp.target =target
      pp.eta  =eta.to_i
      pp.score  =score.to_i
      pp.storage  =[str_a.to_i, str_b.to_i, str_c.to_i, str_d.to_i, str_e.to_i]
      pp.expertise  =[exp_a.to_i, exp_b.to_i, exp_c.to_i, exp_d.to_i, exp_e.to_i]
      @players <<pp
    end

    @avail_store = gets.split(" ").map{|x| x.to_i}

    sample_count = gets.to_i
    @samples=[]

    sample_count.times do
      sample_id, carried_by, rank, expertise_gain, health, cost_a, cost_b, cost_c, cost_d, cost_e = gets.split(" ")

      ss = Sample.new
      ss.id = sample_id.to_i
      ss.carried_by = carried_by.to_i
      ss.rank = rank.to_i
      ss.expertise_gain = expertise_gain
      ss.health = health.to_i
      ss.cost=[cost_a.to_i,cost_b.to_i,cost_c.to_i,cost_d.to_i,cost_e.to_i]

      @samples<<ss
    end


  end
  def parse_proj
    project_count = gets.to_i
    @science_projects=[]

    project_count.times do
      @science_projects << gets.split(" ").map {|x| x.to_i}
    end
  end

  def my_storage_sum ;    @players[0].storage_sum; end
  def my_expert_sum ;     @players[0].expertise_sum; end
  def my_samples;       @samples.select{|ss| ss.carried_by ==0}; end
  def opp_samples;      @samples.select{|ss| ss.carried_by ==1}; end
  def free_samples;     @samples.select{|ss| ss.carried_by ==-1}; end

  def print_bag(bag); bag.inject("") { |acc, el| acc<<"_#{el[1]}"  }; end
  def print_sample_cost(store); store.inject("") { |acc, el| acc<<"#{el}_"  }; end
  def print_sample(ss)
    return "nil" unless ss
    res = ss.cost.inject("") { |acc, el| acc<<"#{el}_"}
    res+="_id:#{ss.id}_r:#{ss.rank}_h:#{ss.health}"
  end

  def char_to_index(molecule); "ABCDE".index(molecule) end

  def trg_0(pl); pl.target == "SAMPLES";  end
  def trg_1(pl); pl.target == "DIAGNOSIS";  end
  def trg_2(pl); pl.target == "MOLECULES"  end
  def trg_3(pl); pl.target == "LABORATORY"  end

  def goto_sample(action="");     printf("GOTO SAMPLES #{action} SAMPLES #{@inf}\n");end
  def goto_diag(events=[],mes="");  @diag_operation = events; printf("GOTO DIAGNOSIS #{mes} #{@inf}\n");end
  def goto_molec(action="");      printf("GOTO MOLECULES #{action} #{@inf}\n");end
  def goto_lab(action="");        printf("GOTO LABORATORY #{action} #{@inf} \n");end
  def is_disabled_mol(mol_idx);     @mol_intercepted_ids.include? mol_idx;end

  def song_line; @song_text_id %= @song_text.size;  mes = @song_text[@song_text_id+=1]; end

  def detect_opp_last_mol
    indx = (0..4).find{|cc| @opp.storage[cc]-@prev_opp_store[cc]>0 } if @prev_opp_store
    if indx
      @opp_connected_mols << indx
    else
      @opp_connected_mols=[]
    end
  end

  def parse_input_data_and_init_some_variables
    @my = @players[0]
    @opp = @players[1]

    @my_store  = @my.storage
    @my_expert = @my.expertise
    @my_samples = my_samples

    @opp_store = @opp.storage
    @opp_expert = @opp.storage
    @opp_samples = opp_samples
    @mol_names = ['A','B','C','D','E']

  end

  def run
    @show_info = true
    first_round = !@debug
    @tactics=nil
    @song_text = SONG.split("\n")
    @song_text_id = 0

    parse_proj unless @debug


    @last_pos=0
    @opp_connected_mols=[]
    @diag_operation =[]

    @insamples=[]
    @diag_samples_id=[]
    @mol_intercepted_ids=[]

    @sample_num_r1=0
    @sample_num_r2=0
    @sample_num_r3=0

    turn =0
    loop do
      turn+=1

      @prev_opp_store = @opp.storage if @opp

      @debug ? parse_data_f : parse_data

      parse_input_data_and_init_some_variables

      detect_opp_last_mol

      my_sampl_inf = @my_samples.map { |ss|  print_sample_cost(ss.cost) }


      song_line=""

      @inf =  @show_info ? "trg:#{@my.target} #{song_line} my samples:#{my_sampl_inf}**#{@my.target} "
      : "#{song_line}"


      if  @my.eta>0
        printf("#{@inf}\n")

      elsif first_round
        #@tactics="all_with_one"
        goto_sample
        first_round=false

      elsif @my.target == "SAMPLES"
        process_samples

      elsif @my.target == "DIAGNOSIS"
        @last_pos =1
        process_diag

      elsif @my.target == "MOLECULES"

        process_mol if !check_tactics

      elsif @my.target== "LABORATORY"
        process_labor

      end

    end #end loop
  end #end run

  def check_tactics
    if @tactics=="all_with_one"
      arr = [2,2,1,1,1]
      i = 5.times.find{|i| @my_store[i]<arr[i] }

      if i && @avail_store[i]>0 && @my.storage_sum<10
        printf("CONNECT #{@mol_names[i]} запасаемся веществами\n")
      else
        @tactics = nil
      end
      goto_sample
      return true
    elsif @tactics=="intercept_opp_samples2"
      opp_cost_ = @opp_samples.map(&:cost).sort_by(&:max)

    end
    false
  end

  def process_samples
    @last_pos =0
    set_insamples if @insamples.size==0
    rank  = @insamples.shift
    @my_samples.size < 3 ? printf("CONNECT #{rank} #{@science_projects}\n") : goto_diag
  end

  def load_to_cloud(ss)
    printf("CONNECT #{ss.id} возращаем в облако фуфло id#{ss.id}\n") ##load to cloud
  end

  def process_diag(level=0)

    undiag = @my_samples.select{|ss| !@diag_samples_id.include?(ss.id) }
    if undiag.any?
      ff = undiag.first
      printf("CONNECT #{ff.id}\n")
      @diag_samples_id<<ff.id
      return
    end


    ##return 7B with my exp 1B
    ss = @my_samples.select{|ss|ss.cost.max >6}.first
    inf="sample max_cost:7 #{print_sample(ss)}" if ss
    if ss
      idx = ss.cost.index(ss.cost.max)
      if @my_expert[idx]<2
        load_to_cloud(ss);return
      end
    end

    ###go to lab
    lab_samples = samples_myfit_store(@my_samples)
    if  lab_samples.any?

      @curr_mol_sample = lab_samples.shift
      goto_lab("бежим в лабу втюхивать рецепт #{@curr_mol_sample.cost}")
      return
    end

    ###events: tocloud fromcloud tosample
    curr_event = @diag_operation.shift

    if curr_event =="tocloud"

      worst = @my_samples.select{|ss| need_throw_away(ss)}
      worst = @my_samples.sort_by{|ss| ss.cost_sum } if worst.empty?
      if ww=worst.last
        printf("CONNECT #{ww.id} возращаем в облако фуфло id#{ww.id}\n") ##load to cloud
      end
      return

    elsif curr_event =="tosample"
      goto_sample("го к бабке за рецептами")
      return

    elsif curr_event =="fromcloud"
      frees = samples_myfit_store_avail(free_samples)
      if frees.any? && @my_samples.size<3
        sid = frees.first.id
        printf("CONNECT #{sid} опа, ништяк, заныкаю\n")
        return
      end
    end

    #mys=samples_myfit_store_avail(@my_samples)

    #if @my_samples.size>0 && mys.any?
    if @my_samples.size>1
      inf2 = @my_samples.map { |ss| print_sample(ss)  }
      goto_molec("#{inf}")

    elsif @my_samples.size<1
      goto_sample("го к бабке за рецептами")

    elsif level<3
      @diag_operation<<"tocloud"
      process_diag(level+1)
    else
      printf("WAIT #{@inf}\n")

    end

  end

  def need_throw_away(sample)
    idx = @mol_intercepted_ids.first
    return false unless idx
    return false if sample.cost[idx]<=@avail_store[idx]
    return true if sample.cost[idx]>0
  end

  def process_labor
    @last_pos =3

    fitted=samples_myfit_store(@my_samples)
    arr = fitted.map(&:cost)

    curr = fitted.first
    printed_samples = arr.map { |aa| print_sample_cost(aa)}

    if curr
      @mol_intercepted_ids =[]
      if trg_2(@opp) && false #@opp_connected_mols.empty?
        printf("WAIT ну что ты одноклеточное, покури\n")
      else
        printf("CONNECT #{curr.id} #{printed_samples}  Сдали!!! #{@inf}\n")
      end
    else
      sampl_size = @my_samples.size
      my_rank_max= @my_samples.map(&:rank).max||0
      opp_rank= @opp_samples.map(&:rank)
      opp_smpl_max_cost = @opp_samples.map(&:cost).sort_by(&:max).last

      first=@my_samples.first
      rank1 =sampl_size==2 && is_fit_two_store(first.cost, @my_store, @avail_store, @my_expert )
      #rank2 =sampl_size>0 && first.rank>=2 && is_fit( first.cost, @avail_store, @my_expert)
      go_sampl = opp_rank.max && opp_rank.max>2 && sampl_size==1
      go_sampl1 = opp_rank.max && opp_rank.max==1 && sampl_size==1
      go_mol1 = (trg_2(@opp)||trg_3(@opp)) &&  sampl_size==2
      go_mol2 = my_rank_max==3 #&& is_fit_two_store(first.cost, @my_store, @avail_store, @my_expert )
      go_attack_mol3 = my_storage_sum<3 && trg_3(@opp) #&& opp_smpl_max_cost>3

      if  rank1 || go_mol1 || go_mol2
        goto_molec("#{[go_mol1,go_mol2]} бежим за таблетками")
      elsif go_sampl || go_sampl1
        goto_sample("вперед к бабке за рецептами")
      elsif sampl_size>=0
        goto_sample("вперед к бабке за рецептами")
      else
        printf("WAIT криво #{printed_samples}\n")
      end
    end
  end

  def set_insamples
    if @sample_num_r1<6
      @sample_num_r1+=1
      @insamples+=[1]

    elsif @sample_num_r2<8
      @sample_num_r2+=1
      @insamples+=[2]

    else
      @insamples+=[3,3]
    end

  end

  def set_insamples2
    exp_sum = my_expert_sum
    exp_min = @my_expert.min
    exp_max = @my_expert.max
    maxrank = @my_samples.map(&:rank).max || 0
    scoremy = @my.score
    scoreop = @opp.score
    arr=[1,1,1,2,2,2,3,3,3]

    @insamples+= if exp_min>=2;[3,3,3]
    elsif exp_sum>7 && exp_max>2; [3]
    elsif exp_sum>7 && exp_min>0 ; [3]
    elsif exp_sum>5 && exp_min==0 ;  [2]
    elsif exp_sum>1; [1]
    elsif exp_sum==0; [1]
    else
      [1]
    end
  end

  def sub_a(arr1,arr2); 5.times.map { |e| dd = arr1[e]-arr2[e]; dd<0 ? 0 : dd }; end
  def add_a(arr1,arr2); 5.times.map { |e| arr1[e]+arr2[e] }; end
  def a_le_b(arr1,arr2); 5.times.all? { |e| arr1[e]<=arr2[e] }; end
  def sum_a(arr1); arr1.reduce(:+);  end
  def calc_weight(pair, avail);   end

  def print_mol(idx,samples)
    printf("CONNECT #{@mol_names[idx]} index:#{idx} samples:#{samples} берем таблетку\n")
  end

  def process_mol()
    @last_pos =2

    #return if intercept_when_opp_trg1

    fitted_samples = samples_myfit_store_avail(@my_samples).sort_by{|ss|ss.cost_max}
    arr = fitted_samples.map(&:cost)
    printed_arr = arr.map { |aa| print_sample_cost(aa)}

    diff = fitted_samples.map.with_index{|ss,idx| sub_a(ss.cost,@my_expert) }
    mystore_avail = add_a(@my_store , @avail_store)

    ids = fitted_samples.map { |e| e.id  }

    pair_indices = if fitted_samples.size==3; [[0,1],[0,2],[1,2]]
    elsif fitted_samples.size==2; [[0,1]]
    elsif fitted_samples.size==1; nil
    end

    if pair_indices
      pairs = pair_indices.map{|p| [ [ ids[p[0]], ids[p[1]] ], add_a( diff[p[0]], diff[p[1]] )] }

      avail_pairs = pairs.select{|pp| a_le_b(pp[1], mystore_avail) && sub_a(pp[1], @my_store).reduce(:+)+my_storage_sum<11}

    end

    @samples_to_lab=nil
    need_connect_mol =nil
    take_another_sample = nil

    if avail_pairs && avail_pairs.any? ##collect 2 prescription
      ff = avail_pairs.first
      if a_le_b(ff[1], @my_store)
        @samples_to_lab= ff[0]
      else
        need_collect_mol= ff[1]
      end

    else ##collect only one
      ff = diff.find{|cost| a_le_b(cost, mystore_avail)}
      if ff
        if a_le_b(ff,@my_store)
          idx = diff.index(ff)
          @samples_to_lab=ids[idx]
        else
          #p idx = diff.index(ff)
          need_collect_mol=ff
        end
      else
        if diff.size>0 && diff.size<3
          pp = diff.first
          sum = sub_a(pp,mystore_avail).reduce(:+)
          take_another_sample = sum||100
        else
          take_another_sample = 2

        end
      end
    end
    inf = "diff.size #{diff.size} avail #{@avail_store} @samples_to_lab #{@samples_to_lab} need_collect_mol #{need_collect_mol} take_another_sample #{take_another_sample}"

    #p "avail_pairs: #{avail_pairs}" if avail_pairs
    #p "diffs:#{diff} @my_store:#{@my_store} my_expert:#{@my_expert} avail_store:#{@avail_store} mystore_avail:#{mystore_avail}"
    #p "samples_to_lab #{@samples_to_lab} need_collect_mol:#{need_collect_mol} goto_DIAGNOSIS:#{take_another_sample}"

    if !take_another_sample

      if need_collect_mol
        res = sub_a(need_collect_mol,@my_store)
        idx = res.index(res.max)
        if @avail_store[idx]>0 && my_storage_sum<10
          printf("CONNECT #{@mol_names[idx]} #{inf} берем таблетку\n")
        end
      else
        if @samples_to_lab ##finished
          @count=nil
          goto_lab("ids:#{@samples_to_lab} я побежало с таблетками на базу")
          return
        else
          @count||=0
          mstore_mexp = add_a(@my_store, @my_expert)
          min = mstore_mexp.min
          idx = mstore_mexp.index(min)
          need_collect_opp_mol= @count<2 && @avail_store[idx]>0 && my_storage_sum<10 && my_expert_sum>3
          if  need_collect_opp_mol
            @count+=1
            printf("CONNECT #{@mol_names[idx]} #{inf} про запас \n")
          else
            @count=nil
            printf("WAIT ждем таблетки\n")
            return
          end
        end
      end #if offset

    else ##go to DIAGNOSIS
      if (trg_2(@opp) || trg_3(@opp)) && take_another_sample<3
        printf("WAIT ждем таблетки #{inf}\n")
      elsif @my_samples.size<2
        goto_sample("заказ новых рецептов")
      else
        min = @my_store.min
        idx = @my_store.index(min)
        @count||=0
        if @avail_store[idx]>0 && my_storage_sum<10 && my_expert_sum>3 && @count<3
          printf("CONNECT #{@mol_names[idx]} #{inf} про запас \n")
          @count+=1
        else
          @count=nil
          goto_diag(["tocloud","tosample"], "нет рецептов, бежим в облако #{inf}")
        end

      end
    end
  end

  def intercept_when_opp_trg1
    #p ff =  @opp_samples.map { |ss| conv_store_to_bag(ss.cost)}.flatten(1).sort_by{|ss| -ss[1]}
    return false if !trg_2(@opp)

    unless @intercept_mol
      bag_ss =  @opp_samples.map { |ss| conv_store_to_bag(ss.cost)}
      min_pairs = 5.times.map{ |i| bag_ss.map{|ss| ss[i]}.select{|mm| mm[1]>0}.min }.select{|mm| mm}
      @intercept_mol = min_pairs.map { |mm| i=mm[0]; [@opp.storage[i]+@opp.expertise[i]+@avail_store[i],mm] }.min_by{|mm| mm[0]-mm[1][1]}

    end

    all_mm = @intercept_mol
    count=all_mm[0]-all_mm[1][1]+1
    @need_intercept = count>0 && count<4 && count+@my.storage_sum<10

    idx =all_mm[1][0]
    inf = @show_info ? "тырим вещества m#{idx}" : ""

    if @need_intercept && @avail_store[idx]>0
      @mol_intercepted_ids<<idx unless  @mol_intercepted_ids.include? idx

      printf("CONNECT #{@mol_names[idx]} #{inf}\n")
      @intercept_mol = nil
      return true
    end
    false
  end

  def calc_sum_mymols_and_samplemols(sample,pl)
    sum=5.times.map { |i| ss = sample.cost[i]-pl.storage[i]-pl.expertise[i]; (ss>0 ? ss :0) }.reduce(0){|sum,el| sum+el}
    sum+pl.storage_sum
  end

  def conv_store_to_bag(store)
    (0..4).map {|idx| [idx,store[idx]]}
  end

  def sort_fitted_samples(samples)
    samples.sort_by { |ss| -ss.health  }
  end

  def samples_myfit_store_avail(samples)

    ff = samples.select { |ss| calc_sum_mymols_and_samplemols(ss,@my)<11 && is_fit_two_store(ss.cost,@my_store, @avail_store, @my_expert )  }
    sort_fitted_samples(ff)
  end

  def samples_myfit_store(samples)
    ff = samples.select { |ss| calc_sum_mymols_and_samplemols(ss,@my)<11 && is_fit_my(ss.cost)  }
    sort_fitted_samples(ff)
  end

  def samples_oppfit_store_avail(samples)
    ff = samples.select { |ss| is_fit_two_store(ss.cost, @avail_store, @opp_expert )  }
    sort_fitted_samples(ff)
  end
  def samples_oppfit_store(samples)
    ff = samples.select { |ss| is_fit(ss.cost, @opp_store, @opp_expert)  }
    sort_fitted_samples(ff)
  end

  def is_fit_two_store(sample_cost, store1, store2,player_expert)
    5.times.all? {|idx| sample_cost[idx]<=store1[idx]+store2[idx]+player_expert[idx] }
  end

  def is_fit(sample_cost, player_storage, player_expert)
    5.times.all? {|idx| sample_cost[idx]<=player_storage[idx]+player_expert[idx] }
  end
  def is_fit_my(sample_cost)
    5.times.all? {|idx| sample_cost[idx]<=@my_store[idx]+@my_expert[idx] }
  end


end

def run_game
  gg = Game.new
  gg.debug = false
  gg.run
end
run_game
