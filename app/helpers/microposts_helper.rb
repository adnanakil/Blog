module MicropostsHelper
  def wrap(content)
    res = content.split.map { |s| wrap_long_string(s) }
    raw res.join(' ')
  end

  private
    def wrap_long_string(text, max_width = 560)
      zero_width_space = "&#8203;"
      regex = /.{1,#{max_width}}/
      (text.length < max_width) ? 
        text : text.scan(regex).join(zero_width_space)
    end
end