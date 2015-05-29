module ContestsHelper
  
  def show_search_title
    if @contest_query.blank?
      ""
    else
      return_title = ""
      return_title = "##{@contest_name}" unless @contest_name.blank?
      return_title = return_title + "##{@contest_query.number}" unless @contest_query.number.blank?
    end
  end
  
end
