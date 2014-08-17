# encoding: utf-8

class Import
  include ActiveModel::Validations
  include ActiveModel::Validations::Callbacks
  include ActiveModel::Conversion

  attr_accessor :api_key, :username, :password
  attr_accessor :csv_file, :created_at
  attr_accessor :job_id, :token

  validates_presence_of :csv_file
  validates_presence_of :api_key, :username, :password
  validate :validate_credentials

  before_validation :hash_password
  after_validation :generate_token, unless: :errors?
  after_validation :save_csv_file, unless: :errors?
  after_validation :dispatch_import, unless: :errors?

  def self.path_for_token(t)
    File.join('public', 'imports', %(#{t}.csv))
  end

  def initialize(attrs={})
    attrs.each do |attr, value|
      send(%(#{attr}=), value)
    end
    self.created_at ||= Time.now
  end

  def self.create(attrs={})
    im = new(attrs)
    im.valid?
    im
  end

  def persisted?
    false
  end

  def to_h
    {
      job_id: job_id,
      created_at: created_at,
    }
  end

  def to_json(options={})
    to_h.to_json
  end

  protected

  def hash_password
    self.password = Digest::SHA1.hexdigest(password)
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
    unless e.message.empty?
      errors[:credentials] << e.message
    end
    false
  end

  def save_csv_file
    FileUtils.copy_file(csv_file.path, self.class.path_for_token(token))
  end

  def dispatch_import
    self.job_id = ImportWorker.perform_async(*work_params)
  end

  private

  def client
    @client ||= Traktr::Client.new(api_key, username, password, true)
  end

  def work_params
    [token, api_key, username, password]
  end

  def errors?
    errors.any?
  end
end
