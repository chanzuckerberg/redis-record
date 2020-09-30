# frozen_string_literal: true

# typed: strict

module Redcord::Migration::Index
  extend T::Sig

  sig { params(model: T.class_of(Redcord::Base), index_name: Symbol).void }
  def remove_index(model, index_name)
    model.redis.scan_each(match: "#{model.model_key}:#{index_name}:*") { |key| _del_set(model, key) }

    attr_set = "#{model.model_key}:#{index_name}"
    nil_attr_set = "#{attr_set}:"

    _del_set(model, nil_attr_set)
    _del_zset(model, attr_set)
  end

  sig {
    params(
      model: T.class_of(Redcord::Base),
      attr_set_name: String,
      index_name: Symbol,
    ).void
  }
  def _remove_index_from_attr_set(model:, attr_set_name:, index_name:)
    model.redis.srem("#{model.model_key}:#{attr_set_name}", index_name)
  end

  sig { params(model: T.class_of(Redcord::Base), key: String).void }
  def _del_set(model, key)
    # Use SPOP here to minimize blocking
    loop do
      break unless model.redis.spop(key)
    end

    model.redis.del(key)
  end

  sig { params(model: T.class_of(Redcord::Base), key: String).void }
  def _del_zset(model, key)
    # ZPOPMIN might not be avaliable on old redis servers
    model.redis.zscan_each(match: key) do |id, _|
      model.redis.zrem(key, id)
    end

    model.redis.del(key)
  end
end
