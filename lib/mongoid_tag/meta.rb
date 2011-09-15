module Mongoid
  module Tag
    module Meta
      extend ActiveSupport::Concern

      included do
        embeds_many :meta_tags, :as => :meta_tagable, :class_name => "Mongoid::Tag::MetaTag"
      end

      module ClassMethods

        def tagmeta_for(*args)
          field_name = (args.blank? ? :tags : args.shift).to_sym

          class_eval %(
            def #{field_name}_with_weight
              get_weights_for(:#{field_name})
            end

            def #{field_name}_with_meta
              get_meta_for(:#{field_name})
            end

            def add_#{field_name.to_s.chop.to_sym}(tag, meta={})
              add_meta_tag(:#{field_name}, tag, meta)
            end
          )
        end
      end

      module InstanceMethods
        def get_weights_for(context)
          meta_tags.where(:context => context).map{|tag| [tag.name, tag.count]}
        end

        def get_meta_for(context)
          meta_tags.where(:context => context).map{|tag| [tag.name, tag.meta.merge(:count => tag.count)]}
        end

        def update_meta_tags(context, added=nil, removed=nil)
          add_meta_tags(context, added) if added
          remove_meta_tags(context, removed) if removed
          save
        end

        def add_meta_tag(context, tag, meta)
          old_tag = self.meta_tags.where(:name => tag, :context => context).first
          if old_tag
            old_tag.meta.merge!(meta)
          else
            self.meta_tags << MetaTag.new(:name => tag, :count => 1, :context => context, :meta => meta)
          end
        end

        def add_meta_tags(context, tags)
          tags.each do |tag|
            old_tag = self.meta_tags.where(:name => tag, :context => context).first
            if old_tag
              old_tag.count += 1
            else
              self.meta_tags << MetaTag.new(:name => tag, :count => 1, :context => context)
            end
          end
        end

        def remove_meta_tags(context, tags)
          tags.each do |tag|
            old_tag = self.meta_tags.where(:name => tag, :context => context).first
            old_tag.count -= 1 if old_tag && old_tag.count > 0
          end
        end
      end
    end
  end
end