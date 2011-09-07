require 'mongoid'

module Mongoid
  module Tag
    class MetaTag
      include Mongoid::Document
      field :name, :type => String
      field :count, :type => Integer, :default => 0
      field :context
      field :meta, :type => Hash, :default => {}
      embedded_in :meta_tagable, :polymorphic => true
    end
  end
end