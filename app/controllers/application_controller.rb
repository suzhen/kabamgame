class ApplicationController < ActionController::Base
   layout :layout_by_resource

 protected                    
  
  def layout_by_resource       
     return "welcome" if controller_name=="sessions"
     return "register" if controller_name == "players"
     "application"  
  end

=begin
  def after_sign_out_path_for(resource_or_scope)
   "/users/sign_in"           
  end
  
  def after_sign_in_path_for(resource)
    #"/manage/enterprises"                   
  end
=end


  protect_from_forgery


end
