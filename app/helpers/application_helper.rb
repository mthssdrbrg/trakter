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

  def input_options(item, placeholder)
    opts = {required: true}
    opts[:placeholder] = placeholder if placeholder
    opts[:class] = 'error' if item.errors.any?
    opts
  end
end
