#require '/home/akash/.rvm/gems/ruby-2.1.2/gems/fb_graph-2.7.15/lib/fb_graph.rb'
class SessionsController < ApplicationController
  def create
    request.env['omniauth.strategy'].options[:scope] = session[:fb_permissions]
    user = User.from_omniauth(env["omniauth.auth"])
    session[:user_id] = user.id
    omniauth = request.env["omniauth.auth"]
    puts "Here it is : " + omniauth['credentials']['token']
    @graph = Koala::Facebook::API.new(omniauth['credentials']['token'])
    feed = @graph.get_connections("me", "feed")
    puts "feeds below"
    puts feed
    redirect_to root_url
  end

  def setup
    session[:fb_permissions] = 'email,user_birthday,read_stream,user_activities,user_status'
    redirect_to '/auth/facebook'
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url
  end
end