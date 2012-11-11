require "redis"
require "json"
class City < ActiveRecord::Base
 belongs_to :user
 has_many :arms
 def get_food_num()
  init_time
  less_hour_food = (self.pfinterval*@interval_second).to_i
  hour_food = self.capital ? @interval_hour*10000 : @interval_hour*1000
  @food_num= hour_food + less_hour_food
  @food_num = yield(@food_num) if block_given? 
  @food_num = 0  if @food_num < 0
  if @food_num ==0 && self.food ==0
     #消耗各兵种10%
     desc1 = (count_solider("1")*0.1).to_i
     desc2 = (count_solider("2")*0.1).to_i
     desc3 = (count_solider("3")*0.1).to_i
     waste_arm("1",desc1) if desc1>0    
     waste_arm("2",desc2) if desc2>0     
     waste_arm("3",desc3) if desc3>0     
  end
  #更新食物的数量
  self.food=@food_num 
  self.save
  #返回食物的数量
  @food_num
 end

 def get_population()
   init_time
   @population = 100
   if @interval_hour>0
     @interval_hour.times do |hour|
       changepopulation =  @population * 0.05 > 1000 ? 1000 :  (@population * 0.05).to_i
       if @population < (1000*(self.taxrate.to_f/100)).to_i
          #增加人口
          @population += changepopulation
       else
          #减少人口
          @population -= changepopulation
       end
     end
   end
   #更新人口数目
   self.population=@population
   self.save
   #返回人口数目
   @population
 end

 def get_gold_num
   init_time
   @gold=(@interval_hour*(self.taxrate.to_f/100*self.population)).to_i
   self.gold= @gold
   self.save
   @gold
 end

 #训练士兵
 def join_training(armtype,soldiers)
    #格式："兵种,数量,开始时间"
   init_redis
   @len = get_queuearm_count
   @now= Time.now
   if @len>=5
     return false   
   else
     return false if !levy(armtype,soldiers.to_i) || !waste_population(soldiers.to_i)

     arr_pre_arm = @len == 0 ? nil : @redis.lindex("queuearm#{self.id.to_s}",@len-1).split(',')
     pre_train_second = (@now-Time.at(arr_pre_arm[2].to_i)).to_i unless arr_pre_arm.nil?
     #当前时间-开始训练时间
     #<没有开始
     #>=0 已经开始，但未确定是否完成
     if @len==0 || train_finish?(arr_pre_arm[0],pre_train_second)
      @redis.rpush "queuearm#{self.id.to_s}","#{armtype},#{soldiers},#{@now.to_i}"
     else
      if !train_finish?(arr_pre_arm[0],pre_train_second)
         if pre_train_second<0
            #还未开始
            @redis.rpush "queuearm#{self.id.to_s}","#{armtype},#{soldiers},#{arr_pre_arm[2].to_i+train_waste_time(armtype)}"
         else
            #已经开始
            @redis.rpush "queuearm#{self.id.to_s}","#{armtype},#{soldiers},#{@now.to_i+train_less_time(arr_pre_arm[0],pre_train_second) }"
         end
      end
     end
     return true
   end
 
 end
  
 #获取训练情况
 def get_training_status
   init_redis
   return nil unless @redis.exists("queuearm#{self.id.to_s}")
   @queue_len = get_queuearm_count 
   @queue_len.times.map do |i|
    arr_arm = @redis.lindex("queuearm#{self.id.to_s}",i).split(',')
    arr_pre_arm = i>0 ? @redis.lindex("queuearm#{self.id.to_s}",i-1).split(',') : nil
    train_second = (Time.now-Time.at(arr_arm[2].to_i)).to_i
    pre_train_second = (Time.now-Time.at(arr_pre_arm[2].to_i)).to_i unless arr_pre_arm.nil?
   #p "arr_arm:"+arr_arm.to_s
   #p "arr_pre_arm:"+arr_pre_arm.to_s unless arr_pre_arm.nil?
    {:armtype=>arr_arm[0],
     :num=>arr_arm[1],
     :created_at=>arr_arm[2],
     :train_time=>train_less_time(arr_arm[0],train_second),
     :started=> (i==0 ? true : train_second >= 0),
     :finished=>train_finish?(arr_arm[0],train_second)}
   end
 end

 #完成训练
 def finished_train_arm(status)
   arr_arm = status.split(',')
   train_second=(Time.now-Time.at(arr_arm[2].to_i)).to_i
   #写入arm表中
    arr_arm[1].to_i.times do |i|
        @arm=Arm.new :armtype=>arr_arm[0],:user_id=>self.user.id
        self.arms<<@arm
    end
  #更新缓存
    update_arm_cache
   #删除缓存
   if train_finish?(arr_arm[0],train_second)
     delete_queue_arm(status)
     return true
   else
     return false
   end
 end 
 
 #取消训练
 def cancel_train_arm(status)
   #删除缓存
   arr_arm = status.split(',')
   train_second=(Time.now-Time.at(arr_arm[2].to_i)).to_i
   if train_finish?(arr_arm[0],train_second)
        return false
   else
        delete_queue_arm(status) 
        return true
   end
 
 end

 #获取部队缓存
 def get_arm_cache
     init_redis
     return nil unless  @redis.exists "armlist#{self.id.to_s}"
     len= @redis.llen "armlist#{self.id.to_s}"
     @armcache = len.times.map do |i|
       arr_arm =  @redis.lindex("armlist#{self.id.to_s}",i).split(",")
       {:armtype=>arr_arm[1],
        :id=>arr_arm[0],
        :created_at=>arr_arm[2],
        :armstatus=>arr_arm[3]} 
     end
     @armcache 
  end

   #更新军队缓存
   def update_arm_cache
      init_redis
      @redis.del "armlist#{self.id.to_s}"
      arms.order("created_at").each do |arm| 
       @redis.rpush "armlist#{self.id.to_s}","#{arm.id.to_s},#{arm.armtype},#{arm.created_at.to_i},#{arm.armstatus}"
      end
   end

   #部队消耗食物
   def arm_waste_food
     food=0
     armcache = get_arm_cache
     armcache.each do |arm|
       food += Arm.waste_food(Time.at(arm[:created_at].to_i),arm[:armtype])
     end unless armcache.nil?
     food
   end

  #减少各兵种个数
  def waste_arm(armtype,num)
     self.arms.where(["armtype=?",armtype]).order("created_at").limit(num).destroy_all()
     update_arm_cache
  end

  #进攻时间
  def attack_time(city_id,arm_ids)
    return   Time.at Time.now.to_i+waste_second_to_city(city_id,arm_ids)
  end

  #参战
  def start_war(user_id,city_id,arm_ids)
    init_redis
    hkey = "attack_#{self.id.to_s}"
   #>5不能参战
   return false if @redis.exists(hkey)&&@redis.hkeys(hkey).length>=5
   start_time = Time.now.to_i
   attack_time = start_time + waste_second_to_city(city_id,arm_ids)
   attack_status="attack"
   back_time=0
   attack=Hash.new
   attack[:user_id] = user_id
   attack[:city_id] = city_id
   attack[:start_time] = start_time
   attack[:attack_time] = attack_time
   attack[:arm_ids] = arm_ids
   attack[:status] = attack_status
   attack[:back_time] = back_time
   return @redis.hmset hkey,"#{city_id}_#{start_time}",attack.to_json
  end

  #获取战争状况
  def get_war_list
     init_redis
     hkey = "attack_#{self.id.to_s}"
     return nil if !@redis.exists hkey
     j = ActiveSupport::JSON
     @attacks = @redis.hkeys(hkey)
     @task = []
     @attacks.each do |attack|
        attack_str =  @redis.hget(hkey,attack)
        attack = j.decode(attack_str)
        @task <<  {:user_id => attack["user_id"],
                   :city_id => attack["city_id"],
                   :start_time => Time.at(attack["start_time"].to_i).to_s(:db),
                   :attack_time => Time.at(attack["attack_time"].to_i).to_s(:db),
                   :arm_ids => attack["arm_ids"],
                   :status =>  attack["status"],
                   :back_time =>  attack["back_time"]}
     end 
     @task
  end


 private
   
   def init_time
      @interval_time = Time.now-self.created_at;
      @interval_hour = (@interval_time/3600).to_i
      @interval_second = (@interval_time%3600).to_i
   end

   def init_redis
      @redis = Redis.new if @redis.nil?
   end
   
   #获取训练士兵批次
   def get_queuearm_count
      @redis.llen "queuearm#{self.id.to_s}" 
   end

   #征兵
   def levy(armtype,num)
      case armtype
       when "1"
        return waste_gold(num*1)
       when "2"
        return waste_gold(num*3)
       when "3"
        return waste_gold(num*10)
       end
   end


   #各兵种训练需要花费的时间
   def train_waste_time(armtype)
      case armtype
      when "1"
        return 3*60
      when "2"
       return  12*60
      when "3"
       return  50*60
      end
   end


   #判断训练是否完成
   def train_finish?(armtype,train_second)
      return false if train_second<=0
      case armtype
      when "1"
        return train_second >=  3*60
      when "2"
       return train_second >=  12*60
      when "3"
       return train_second >=  50*60
      end
   end
    
   #获取训练剩余时间
   def train_less_time(armtype,train_second)
      case armtype
      when "1"
        return  3*60 - train_second
      when "2"
       return  12*60 - train_second
      when "3"
       return  50*60 - train_second
      end
   end
   
   #删除训练队列
   def delete_queue_arm(status)
     init_redis
     @redis.lrem "queuearm#{self.id.to_s}",0,status 
   end


   #消耗城市金子
   def waste_gold(wastegold)
       if gold >= wastegold
         self.gold = self.gold - wastegold 
         self.save
         return true
        else
         return false
        end
   end
   
  #消耗城市人口
  def waste_population(peoples)
     if population >= peoples
        self.population -= peoples 
       self.save
       return true
     else
       return false
     end
  end

  #获取军队中各兵种的个数
  def count_solider(armtype)
    count=0
    get_arm_cache.each do |arm|
       count+=1 if arm[:armtype]==armtype
    end
  end

  #计算去另一个城市的距离
  def distance_city(city_id)
    @city=City.find city_id
    return (coordinate.to_i-@city.coordinate.to_i).abs
  end

  #计算去另一个城市的花费时间（秒）
  def waste_second_to_city(city_id,arm_ids)
    return ((distance_city(city_id)/ Arm.lowst_speed(self.id,arm_ids))*60).to_i
  end


end
