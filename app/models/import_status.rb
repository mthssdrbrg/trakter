# encoding: utf-8

class ImportStatus
  include ActiveModel::Validations
  include ActiveModel::Validations::Callbacks
  include ActiveModel::Conversion

  attr_reader :id, :status, :progress

  validates :id, presence: true
  before_validation :fetch_status

  def initialize(attrs={})
    @id = attrs[:id]
    @status_registry = attrs[:status_registry] || Sidekiq::Status
  end

  def to_h
    {
      id: id,
      status: status,
      progress: progress,
    }
  end

  def to_json(options={})
    to_h.to_json
  end

  def persisted?
    false
  end

  protected

  def fetch_status
    data = @status_registry.get_all(id)
    if data && data.any?
      @status = data['status']
      @progress = pct_complete(data)
      true
    else
      errors[:import] << 'id ("%s") doesn\'t exist' % id
      false
    end
  end

  private

  def pct_complete(data)
    if data['at'] && data['total']
      vs = data.values_at('at', 'total').map(&:to_i)
      vs = vs.first.fdiv(vs.last) * 100
      vs.round
    else
      0
    end
  end
end
