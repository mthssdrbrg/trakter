# encoding: utf-8

module ApplicationHelper
  def on_index_page?
    current_page?(action: 'index', controller: 'trakter')
  end

  def nav_link(title, path)
    content_tag(:li, class: nav_link_styling(path)) do
      link_to(title, path)
    end
  end

  def nav_link_styling(path)
    classes = %w[nav-link]
    classes << 'active-nav-item' if current_page?(path)
    classes
  end

  def pct_complete(data)
    (data['at'].to_i / data['total'].to_i.to_f) * 100
  end
end
