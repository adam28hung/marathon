module ContestsHelper
  
  def initial_loading_link
    render partial: 'loading_link' if @initial_photos_set.count > 0
  end

  def initial_simple_searh_form
    render(partial: 'simple_search_form' ) if @initial_photos_set.count > 0
  end

  def photo_alt(photo)
    photo['tags'].blank?? "#{photo['objectId']} | #{@contest.name}" : "#{photo['objectId']} | #{photo['tags'] * ","} | #{@contest.name}" 
  end

  def show_share_photo
    unless @photo.blank?
      render 'share_photo_part'
    else
      render 'photo_not_found'
    end
  end

  def render_contest_rearch_result
    if @contests.count > 0
      render 'contest_list'
    else
      render 'no_contest'
    end
  end

  def show_share_title
    if @contest.blank?
      "圖片不存在 或 已刪除"
    else
      return_title = ""
      return_title = "##{@contest.name}" unless @contest.blank?
    end
  end

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
