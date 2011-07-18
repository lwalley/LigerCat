module JournalsHelper
  def journal_check_box_tag(journal, options={})
    dom_id = checkbox_dom_id(journal)
    checked = @selected_ids.has_key?(journal.id) rescue false
    options = {:class => 'checkbox'}.merge(options)
    @all_journals_are_selected = false unless checked
    
    check_box_tag(dom_id, '1', checked, options)
  end
  
  def journal_preselections_json
    returning String.new do |output|
      output << '['
      output << @selections.map{|s| "{id:'#{journal_id(s)}',title:'#{s.title}'}"}.join(',') rescue nil
      output << ']'
    end
  end

  def journal_title_join_and_truncate(titles, length=30, join_string = ", ", truncate_string = "and others")
    return if titles.blank?
    l = 0
    within_length = titles.find_all{|t| old_l = l; l += t.mb_chars.length; old_l < length}
    within_length << truncate_string unless within_length.length == titles.length
    within_length.join(join_string)
  end

  
end
