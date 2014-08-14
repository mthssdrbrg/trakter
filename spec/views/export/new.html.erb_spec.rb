# encoding: utf-8

require 'rails_helper'


RSpec.describe 'export/new.html.erb', type: :view do
  before do
    assign(:export, Export.new)
    render
  end

  it 'has a form for exporting purposes' do
    expect(rendered).to have_selector('form')
  end

  it 'asks for the user\'s MyEpisode\'s username' do
    expect(rendered).to have_field('export_username', visible: true, type: 'text')
  end

  it 'asks for the user\'s MyEpisode\'s password' do
    expect(rendered).to have_field('export_password', visible: true, type: 'password')
  end
end
