# encoding: utf-8

ActiveRecord::Schema.define(version: 20140814163313) do
  create_table 'exports', force: true do |t|
    t.string   'token'
    t.datetime 'created_at'
  end

  add_index 'exports', ['created_at'], name: 'index_exports_on_created_at'
  add_index 'exports', ['token'], name: 'index_exports_on_token'
end
