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
 def get_arm_status(armstatus)
    case armstatus
     when "nor"
       return "正常"
     when "attack"
      return "<span style='color:red'>打仗</span>"
    end
 end
 def get_war_status(warstatus)
   case warstatus
     when "attack"
      return "进攻路上"
    when "fight"
      return "准备战斗" 
    when "back"
      return "回城路上"
   end
 end

end
