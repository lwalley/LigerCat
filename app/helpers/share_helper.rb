module ShareHelper
  def auto_select_text_field_tag(name, value = nil, options = {})
    text_field_tag(name, 
                   value, 
                   { :onclick => "this.select()", 
                     :readonly => "true" }.merge(options))
  end
end