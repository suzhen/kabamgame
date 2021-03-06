require "redis"
class User < ActiveRecord::Base
  has_many :cities,:dependent=>:destroy
  has_many :arms,:dependent=>:destroy
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me


  def self.update_user_cache
    @redis = Redis.new if @redis.nil?
    @users = User.all
    @users.each {|user|  @redis.hset "user",user.id.to_s,user.email   } 
  end


 def self.get_name(id)
    @redis = Redis.new if @redis.nil?
    update_user_cache unless @redis.exists "user"
    return @redis.hget "user",id
 end



end
