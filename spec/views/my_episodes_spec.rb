# encoding: utf-8

require 'rails_helper'


RSpec.describe 'my_episodes/index', type: :view do
  before do
    render
  end

  it 'has a form for exporting purposes' do
    expect(rendered).to have_css('form')
  end

  it 'asks for the user\'s MyEpisode\'s username' do
    expect(rendered).to have_field('username', type: 'text')
  end

  it 'asks for the user\'s MyEpisode\'s password' do
    expect(rendered).to have_field('password', type: 'password')
  end
end
