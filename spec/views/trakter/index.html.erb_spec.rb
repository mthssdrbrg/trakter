# encoding: utf-8

require 'rails_helper'


RSpec.describe 'trakter/index.html.erb', type: :view do
  before do
    render
  end

  it 'presents three actions' do
    expect(rendered).to have_selector('.block-item', count: 3)
  end

  it 'includes `export` action' do
    expect(rendered).to have_css('a h1', text: 'export')
  end

  it 'includes `import` action' do
    expect(rendered).to have_css('a h1', text: 'import')
  end

  it 'includes `transfer` action' do
    expect(rendered).to have_css('a h1', text: 'transfer')
  end
end
