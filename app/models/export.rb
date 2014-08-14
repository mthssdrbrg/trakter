# encoding: utf-8

class Export < ActiveRecord::Base
  include Tokenable

  attr_accessor :username, :password

  before_validation do
    username.present? && password.present?
  end
end
