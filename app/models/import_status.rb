# encoding: utf-8

class ImportStatus < EphemeralModel
  attr_accessor :id
  attr_reader :status, :progress

  validates :id, presence: true
  before_validation :fetch_status

  def initialize(attrs={})
    self.status_registry = attrs.delete(:status_registry) { Sidekiq::Status }
    super
  end

  def to_h
    {
      id: id,
      status: status,
      progress: progress,
    }
  end

  private

  attr_accessor :status_registry
  attr_writer :status, :progress

  def fetch_status
    data = status_registry.get_all(id)
    if data && data.any?
      self.status = data['status']
      self.progress = pct_complete(data)
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
