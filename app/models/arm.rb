class Arm < ActiveRecord::Base
  belongs_to :city
  belongs_to :user
  PIKEMENFOOD = 10.to_f/3600
  BOWMANFOOD = 13.to_f/3600
  CAVALRYMANFOOD = 30.to_f/3600

  PIKEMENSPEED = 1.5
  BOWMANSPEED = 2
  CAVALRYMANSPEED = 10

  def self.waste_food(created_at,armtype)
      age = (Time.now - created_at).to_i
      case armtype
      when "1"
        return (age*PIKEMENFOOD).to_i
      when "2"
       return  (age*BOWMANFOOD).to_i
      when "3"
       return  (age*CAVALRYMANFOOD).to_i
      end
  end

  def self.lowst_speed(city,arm_ids)
     @city=City.find city
     lowstarm=3
     arr_arm_ids=arm_ids.split(",")
     @city.get_arm_cache.each do |arm|
         lowstarm  =  arm[:armtype].to_i<lowstarm ? arm[:armtype].to_i : lowstarm if arr_arm_ids.include? arm[:id]
     end 
     case lowstarm.to_s
      when "1"
        return PIKEMENSPEED
      when "2"
       return  BOWMANSPEED
      when "3"
       return  CAVALRYMANSPEED
      end
  end
  
  def self.black_box(arm_ids)


  end

end
