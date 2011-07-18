module SelectionsHelper
  def compare_selected_link(selections)
    href = '/journals/' << @selections.collect{|s| s.id }.join(';') unless @selections.blank?
    "<a id='compare_selected' href='#{href}'>Explore Selected</a>"
  end
end
