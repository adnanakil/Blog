module ApplicationHelper
  def page_title
    base_title = 'Microblog'
    if @page_title.nil?
      base_title
    else
      "#{base_title} | #{@page_title}"
    end
  end
  
  def logo_tag
    image_tag 'logo.jpg', :alt => @page_title, :class => 'round'
  end
end
