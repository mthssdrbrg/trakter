# encoding: utf-8

require 'my_episodes'


class Export < ActiveRecord::Base
  include Tokenable

  attr_accessor :username, :password

  before_validation :validate_credentials

  protected

  def validate_credentials
    if username.present? && password.present?
      client.login(username, password)
      true
    else
      false
    end
  rescue MyEpisodes::AuthenticationError
    errors[:base] << 'invalid username and/or password'
    false
  end

  private

  def client
    @client ||= MyEpisodes::Client.new
  end
end
