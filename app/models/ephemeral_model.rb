# encoding: utf-8

class EphemeralModel
  extend ActiveModel::Callbacks
  include ActiveModel::Model
  include ActiveModel::Validations::Callbacks

  define_model_callbacks :save

  def save
    if valid?
      run_callbacks(:save) { true }
    else
      false
    end
  end

  def to_json(options={})
    to_h.to_json
  end
end
