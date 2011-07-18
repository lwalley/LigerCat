module Sortable
  protected
  def sortable(name, sort_clause, options={})
    @sortables ||= {}
    @sortables[name.to_sym] ||= sort_clause
    @sortables_default ||= name.to_sym if options[:default]
  end
  
  def sortable_clause
    sort_param = parse_sort_param
    
    logger.debug "DEBUG: @sortables_default is #{@sortables_default}"

    if sort_param.nil? && !@sortables_default.nil?
      sort_param = @sortables_param = @sortables_default
    end
    
    if @sortables && sort_param
      if @sortables.has_key? sort_param
        @sortables[sort_param]
      end
    end
  end

  def parse_sort_param
    @sortables_param = params[:sort].to_sym if params[:sort]
  end
end

module SortableHelpers
  protected
  def sortable_link(sortable_column_name, link_text=nil, html_options={})
    link_text ||= sortable_column_name.to_s.titleize  # Turns :alarm_status into Alarm Status
    sortable_column_name = sortable_column_name.to_sym
    selected_sort = @sortables_param
    
    if sortable_column_name == selected_sort
      h(link_text)
    else
      path = params.merge({:sort => sortable_column_name})
      link_to link_text, path, html_options
    end
  end
end