#coding: utf-8 
module CitiesHelper
 def get_arm_type(armtype)
     case armtype
      when "1"
        return "长枪兵"
      when "2"
       return "弓箭手"
      when "3"
       return "骑兵"
      end
 end
end
