require "redis"
class City < ActiveRecord::Base
 belongs_to :user

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
   get_queuearm_count


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

end
