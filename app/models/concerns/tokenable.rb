# encoding: utf-8

module Tokenable
  extend ActiveSupport::Concern

  included do
    before_create :generate_token
  end

  protected

  def generate_token
    self.token = Digest::MD5.hexdigest(self.username + self.created_at.to_s)
  end
end
