require "redis"
class City < ActiveRecord::Base
 belongs_to :user
 has_many :arms
 def get_food_num()
  init_time
  less_hour_food = (self.pfinterval*@interval_second).to_i
  hour_food = self.capital ? @interval_hour*10000 : @interval_hour*1000
  @food_num= hour_food + less_hour_food
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

 def join_training(armtype,soldiers)
   init_redis
   if get_queuearm_count>=5
     return false   
   else
      @redis.sadd "queuearm#{self.id.to_s}","#{armtype},#{soldiers},#{Time.now.to_i}"
      return true
   end
=begin
//查看是否多于5批次
  If($redis->get($queuearm)>=5){
    Exit(‘同时训练不能大于5批次’);
}
  Switch($armtype){
    Case 1 :
      //长枪兵
      If($city_gold>=1){
      $city_gold = $city_gold-1;
      //更新数据库的city_gold
      $key = “queue_1_$user_id_$city_id_time”
$redis->hMset($key,array(‘num’=>$num));
$redis->incr($queuearm);
}else{
  Exit(‘金钱不够’)
}
    Break;
    Case 2 :
      //弓箭手
      If($city_gold>=3){
      $city_gold = $city_gold-3;
      //更新数据库的city_gold
      $key = “queue_2_$user_id_$city_id_time”;
$redis->hMset($key,array(‘num’=>$num));
$redis->incr($queuearm);
}else{
  Exit(‘金钱不够’)
}
    Break;

    Case 3 :
      //骑兵
      If($city_gold>=10){
      $city_gold = $city_gold-10;
      //更新数据库的city_gold
      $key = queue_3_$user_id_$city_id_time;
$redis->hMset($key,array(‘num’=>$num));
$redis->incr($queuearm);
}else{
  Exit(‘金钱不够’)
}
    Break;
    
}
Return $key;
=end
 
 end

 def get_training_status
   init_redis
   @queue_set = @redis.smembers "queuearm#{self.id.to_s}"
   @queue_set.map do |train|
    arr_arm = train.split(',')
    train_second=(Time.now-Time.at(arr_arm[2].to_i)).to_i
    {:armtype=>arr_arm[0],
     :num=>arr_arm[1],
     :created_at=>arr_arm[2],
     :train_time=>train_less_time(arr_arm[0],train_second),
     :finished=>train_finish?(arr_arm[0],train_second)}
   end
 end

 #完成训练
 def finished_train_arm(status)
   arr_arm = status.split(',')
   train_second=(Time.now-Time.at(arr_arm[2].to_i)).to_i
   #写入arm表中
   @arm=self.arms.where("armtype=#{arr_arm[0]}").first
   if @arm.nil?
      @arm=Arm.new :armtype=>arr_arm[0],:num=>arr_arm[1],:user_id=>self.user.id
      self.arms<<@arm
      
   else
      @arm.num+=arr_arm[1].to_i
      @arm.save
   end
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


 private
   
   def init_time
      @interval_time = Time.now-self.created_at;
      @interval_hour = (@interval_time/3600).to_i
      @interval_second = (@interval_time%3600).to_i
   end

   def init_redis
      @redis = Redis.new if @redis.nil?
   end

   def get_queuearm_count
     @queue_set = @redis.smembers "queuearm#{self.id.to_s}" 
      @queue_set.length 
   end

   def train_finish?(armtype,train_second)
      case armtype
      when "1"
        return train_second >=  3*60
      when "2"
       return train_second >=  12*60
      when "3"
       return train_second >=  50*60
      end
   end

   def train_less_time(armtype,train_second)
      case armtype
      when "1"
        return train_second - 3*60
      when "2"
       return train_second - 12*60
      when "3"
       return train_second - 50*60
      end
   end

   def delete_queue_arm(status)
     init_redis
     @redis.srem "queuearm#{self.id.to_s}",status 
   end
end
