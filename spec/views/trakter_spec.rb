# encoding: utf-8

require 'rails_helper'


RSpec.describe 'trakter/index', type: :view do
  before do
    render
  end

  it 'presents three actions' do
    expect(rendered).to have_selector('.grid-item', count: 3)
  end

  it 'includes `export` action' do
    expect(rendered).to have_css('a h1', text: 'Export')
  end

  it 'includes `import` action' do
    expect(rendered).to have_css('a h1', text: 'Import')
  end

  it 'includes `transfer` action' do
    expect(rendered).to have_css('a h1', text: 'Transfer')
  end
end
