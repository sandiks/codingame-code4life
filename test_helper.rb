
def  parse_data_f
  lines = File.readlines("data_test.txt")

  @players =[]

  2.times do |idx|
    target, eta, score, str_a, str_b, str_c, str_d, str_e, exp_a, exp_b, exp_c, exp_d, exp_e = lines[idx].split(" ")
    pp = Player.new
    pp.target =target
    pp.eta  =eta.to_i
    pp.score  =score.to_i
    pp.storage  =[str_a.to_i, str_b.to_i, str_c.to_i, str_d.to_i, str_e.to_i]
    pp.expertise  =[exp_a.to_i, exp_b.to_i, exp_c.to_i, exp_d.to_i, exp_e.to_i]
    @players <<pp
  end

  @avail_store = lines[2].split(" ").map{|x| x.to_i}

  sample_count = lines[3].to_i
  @samples=[]

  sample_count.times do |idx|
    sample_id, carried_by, rank, expertise_gain, health, cost_a, cost_b, cost_c, cost_d, cost_e = lines[4+idx].split(" ")

    ss = Sample.new
    ss.id = sample_id.to_i
    ss.carried_by = carried_by.to_i
    ss.rank = rank.to_i
    ss.expertise_gain = expertise_gain
    ss.health = health.to_i
    ss.cost=[cost_a.to_i,cost_b.to_i,cost_c.to_i,cost_d.to_i,cost_e.to_i]

    @samples<<ss
  end

  {players: @players, samples: @samples, avail_store: @avail_store}
end


SONG2 = %q(
Ты играешь, ты считаешь
Что тебе нельзя дружить с сестрой
Убегаешь, улетаешь
Каждый вечер ты теперь с другой
Не могу тебя совсем забыть
Не могу совсем тебя простить
Каждый вечер жду тебя домой

Но ты уже взрослый
У нас в квартире другие пластинки
Другие вопросы
Твои девчонки как с картинки
Но ты уже взрослый
Ты просто не будешь слушать сказки
Все очень непросто
Ты больше не любишь группу "Краски"

Сто вопросов, сто ответов
Что же в жизни для тебя важней
Убегаешь и не знаешь
Сколько мама не спала ночей
Кто сейчас с тобой, где ты сейчас
Может ты совсем забыл о нас
Каждый вечер ждем тебя домой

Но ты уже взрослый
У нас в квартире другие пластинки
Другие вопросы
Твои девчонки как с картинки
Но ты уже взрослый
Ты просто не будешь слушать сказки
Все очень непросто
Ты больше не любишь группу "Краски"

Я сама не понимаю
Что с тобой случилось, старший брат
Стала жизнь твоя другая
Кто же в этом, кто же виноват
Ничего поделать нам нельзя
Не враги мы, но и не друзья
Только все же жду тебя домой

Но ты уже взрослый
У нас в квартире другие пластинки
Другие вопросы
Твои девчонки как с картинки
Но ты уже взрослый
Ты просто не будешь слушать сказки
Все очень непросто
Ты больше не любишь группу "Краски"
)