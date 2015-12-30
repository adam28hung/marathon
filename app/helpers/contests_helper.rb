module ContestsHelper

  def initial_loading_link
    render partial: 'loading_link' if @initial_photos_set.count > 0
  end

  def initial_searh_form(options={})
    show_dropdown = options[:dropdown]
    render(partial: 'search_form', locals: {show_dropdown: show_dropdown})
  end

  def render_dropdown(contests, contest, f)
    select_tag = f.select :objectid, options_from_collection_for_select(contests ,
            "objectid", "name" , contest.blank?? '' : contest.objectid ) ,{ prompt: '-- 請選擇 --'}, { class: 'form-control', id: 'contestname' , required: true}
    form_group = content_tag(:div, select_tag ,class: 'form-group')
  end

  def photo_alt(photo)
    photo['tags'].blank?? "#{photo['objectId']} | #{@contest.name}" : "#{photo['objectId']} | #{photo['tags'] * ","} | #{@contest.name}"
  end

  def show_share_photo
    unless @photo_share.blank?
      render 'share_photo_part'
    else
      render 'photo_not_found'
    end
  end

  def show_share_title
    title = ""
    if @contest.blank?
      title = "圖片不存在 或 已刪除"
    else
      title = "##{@contest.name}" unless @contest.blank?
    end
    return title
  end

  def render_contest_sort_result(result_count)
    if result_count > 0
      render 'contest_sort_list'
    else
      render 'contest_sort_empty'
    end
  end

  def render_search_result(result_count, photo_set)
    if result_count > 0
      search_title = content_tag(:h1, show_search_title, class:'page-header')
      title_container = content_tag(:div, search_title, class:'col-lg-12')
      photo_set = render(partial: 'photo_set', collection: photo_set, as: :photo )
      photos_container = content_tag(:div, photo_set , class:'row', id: 'photos_container')
    elsif result_count == -1
      suggestion = link_to "看其他照片", contests_path.html_safe
      message = content_tag(:h4, "輸入查詢號碼 或 #{suggestion}".html_safe  )
      container = content_tag(:div, message, class: 'col-lg-12 text-center')
    else
        render(partial: 'search_result_empty' )
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
