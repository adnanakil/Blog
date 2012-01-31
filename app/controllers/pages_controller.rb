class PagesController < ApplicationController
  def home
    @page_title = 'Home'
    
    if signed_in?
      @micropost = Micropost.new 
      @feed_items = current_user.feed.limit(2)
    end
  end
end
