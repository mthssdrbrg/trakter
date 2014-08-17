# encoding: utf-8

class Import < EphemeralModel
  attr_accessor :api_key, :username, :password
  attr_accessor :csv_file, :created_at
  attr_reader :token, :job_id

  before_validation :hash_password

  validates_presence_of :csv_file
  validates_presence_of :api_key, :username, :password
  validate :validate_credentials

  after_save :generate_token
  after_save :save_csv_file
  after_save :dispatch_import

  def self.path_for_token(t)
    File.join('public', 'imports', %(#{t}.csv))
  end

  def initialize(attrs={})
    self.fileutils = attrs.delete(:fileutils) { FileUtils }
    super
    self.created_at ||= Time.now
  end

  def to_h
    {
      job_id: job_id,
      created_at: created_at,
    }
  end

  private

  attr_writer :fileutils, :token, :job_id

  def hash_password
    self.password = Digest::SHA1.hexdigest(password) if password.present?
  end

  def generate_token
    self.token = Digest::MD5.hexdigest(username + created_at.to_s)
  end

  def validate_credentials
    if api_key.present? && username.present? && password.present?
      if (data = client.account.test) && data.status == 'success'
        true
      else
        errors[:credentials] << 'invalid credentials: ' + data['error'].inspect
        false
      end
    else
      errors.add_on_blank([:api_key, :username, :password])
      false
    end
  rescue HTTParty::ResponseError => e
    data = e.response.parsed_response
    errors[:credentials] << data['error']
    false
  end

  def save_csv_file
    @fileutils.copy_file(csv_file.path, self.class.path_for_token(token))
  end

  def dispatch_import
    self.job_id = ImportWorker.perform_async(*work_params)
  end

  def client
    @client ||= Traktr::Client.new(api_key, username, password, true)
  end

  def work_params
    [token, api_key, username, password]
  end
end
