class WelcomeController < ApplicationController
  require 'open-uri'
  require 'rubygems'
  require 'httparty'
  require 'json'

  @@retryCount = 0

  def index
    #@graph = Koala::Facebook::API.new(current_user.oauth_token)
    #@friends = @graph.get_connections("me", "feed")
    #puts @friends
  end
  def add

  end
  def parse
    puts params[:uid]
    puts params[:accessToken]
    @display_commment_map = {}
    @display_commment_map_final = {}
    @display_like_map = {}
    @display_like_map_final = {}
    @display_common_map = {}
    @display_common_map_final = {}
    @rowComment = {}
    @rowLike = {}
    @rowRepeat = {}
    @error = ""
    like_hash = {}
    comment_hash = {}
    common_hash = {}
    i = 0
    j = 1
    initUrl = "https://graph.facebook.com/" + params[:uid] + "/feed?limit=600&access_token=" + params[:accessToken]
    #puts initUrl
    initProcess(comment_hash, common_hash, j, like_hash, initUrl)
    #puts "Final Mapppppppppppppppp#################################"
    @display_commment_map = comment_hash.sort_by { |k, v| v }.reverse.take(5)
    @display_like_map = like_hash.sort_by { |k, v| v }.reverse.take(5)
    @display_common_map = common_hash.sort_by { |k, v| v }.reverse.take(5)

    @rowComment = comment_hash
    @rowLike = like_hash
    @rowRepeat = common_hash

    #puts @display_common_map

    @display_commment_map.map do |x, y|
      json = getName(x)
      if json['name'] != nil && json['name'] != ''
        @display_commment_map_final[x +"-"+json['name']] = y
      else
        @display_commment_map_final[x] = y
      end
      #puts @display_commment_map_final
    end

    @display_like_map.map do |x, y|
      json = getName(x)
      @display_like_map_final[x +"-"+json['name']] = y
      #puts @display_like_map_final
    end

    @display_common_map.map do |x, y|
      json = getName(x)
      if json['name'] != nil && json['name'] != ''
        @display_common_map_final[x +"-"+json['name']] = y
      else
        @display_common_map_final[x + "-Photo or Page" ] = y
      end

      puts @display_common_map_final
    end
    @status = "success"
    #puts @display_commment_map
    #puts like_hash
    #puts comment_hash
    #puts common_hash

  end

  def getName(x)
    response = HTTParty.get("http://graph.facebook.com/" +x)
    json = JSON.parse(response.body)
  end

  def initProcess(comment_hash, common_hash, j, like_hash, initUrl)
    #puts "In the init............."
    response = HTTParty.get(initUrl)
    #puts "putting response"
    json = JSON.parse(response.body)
    if json['error'] == nil || json['error'] == ''
      get_common_map(response, common_hash)
      if json['data'] != []
        json['data'].each do |d|
          like_injector(d, j, like_hash)
          comment_injector(comment_hash, d)
        end
        if json['paging']['next']
          initProcess(comment_hash, common_hash, j, like_hash, json['paging']['next'])
        end

      end
    else
      @error = "Provided access token may expired. Please try to regenerate access token."
    end
  end

  def comment_injector(comment_hash, d)
    if d['comments']
      d['comments']['data'].each do |x|
        if comment_hash[x['from']['id']] == nil
          comment_hash[x['from']['id']] =1
        else
          comment_hash[x['from']['id']] = comment_hash[x['from']['id']] + 1
        end
      end
    end
  end

  def like_injector(d, j, like_hash)
    if d['likes']
      d['likes']['data'].each do |x|
        get_likers(x, 0, like_hash)
      end


      d['likes']['paging'].each do |x|
        j = j+1
        next if j.even?
        if x[0] == "next"
          #puts "Outside function"
          likers_page(x[1], like_hash)
        end
      end
    end
  end

  def likers_page(url, like_hash)
    begin
      response1 = HTTParty.get(url)
      if response1
        json = JSON.parse(response1.body)
        json['data'].each do |y|
          y.map do |a, b|
            if b.match(/^\d+$/)
              if like_hash[b] == nil
                like_hash[b] =1
              else
                like_hash[b] = like_hash[b] + 1
              end
            end
          end
        end
        if json['paging']['next']
          likers_page(json['paging']['next'], like_hash)
        else
          #puts "Out from recursion"
        end
      else
        #puts "Failed inside....."
      end
    rescue => ex
      @@retryCount += 1
      if @@retryCount <= 10
        #puts "Exception...count" + @@retryCount.to_s
        likers_page(url, like_hash)
      else
        @error = "Connection died. Please try again."
        puts "Died... :("
        #puts ex.message
      end
    end

  end

  def get_common_map(response, common_hash)
    counter = Hash.new
    counter = response.body.strip.downcase.split(/[^\w']+/).group_by(&:to_s).map { |w| {w[0] => w[1].count} }
    counter.each do |c|
      c.map do |x, y|
        if x.match(/^\d+$/)
          if x.length > 6
            common_hash[x] = y
          end

        end

      end
    end
    #puts common_hash
  end

  def get_likers(x, i, like_hash)
    x.each do |y|
      i = i+1
      next if i.even?
      #puts y[1]
      if like_hash[y[1]] == nil
        like_hash[y[1]] =1
      else
        like_hash[y[1]] = like_hash[y[1]] + 1
      end
    end

  end

  def get_commentors(x, i, comment_hash)
    x.each do |y|
      i = i+1
      next if i.even?
      #puts y[1]
      if comment_hash[y[1]] == nil
        comment_hash[y[1]] =1
      else
        comment_hash[y[1]] = comment_hash[y[1]] + 1
      end
    end

  end

  def connect

  end
  def contact

  end
end
