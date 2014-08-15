# encoding: utf-8

module ExportHelper
  def input_options(placeholder=nil)
    opts = {required: true}
    opts[:placeholder] = placeholder if placeholder
    opts[:class] = 'error' if @export.errors.any?
    opts
  end
end
