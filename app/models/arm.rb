class Arm < ActiveRecord::Base
  belongs_to :city
  belongs_to :user
  PIKEMENFOOD = 10.to_f/3600
  BOWMANFOOD = 13.to_f/3600
  CAVALRYMANFOOD = 30.to_f/3600
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

end
