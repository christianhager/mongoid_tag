module Mongoid
  module Tag
    extend ActiveSupport::Concern

    included do
      class_attribute :tagify_options
      self.tagify_options = {}
      after_save :update_meta_model
      after_destroy :decrement_all_in_meta_model
    end

    module ClassMethods
      def tag(*args)
        options = args.extract_options!
        field_name = (options.empty? ? :tags : args.shift).to_sym
        array_field = "#{field_name}_array".to_sym

        #set default options
        options.reverse_merge!({
          :array_field => array_field
        })

        # register / update settings
        class_options = tagify_options || {}
        class_options[field_name] = options
        self.tagify_options = class_options

        #create fields
        field field_name, :type => String, :default => ""
        field array_field, :type => Array, :default => []

        #class methods
        class_eval %(
          class << self
            def with_any_#{field_name}(tags)
              any_in(:#{array_field} => tags.to_a)
            end

            def with_all_#{field_name}(tags)
              all_in(:#{array_field} => tags.to_a)
            end

            def without_#{field_name}(tags)
              not_in(:#{array_field} => tags.to_a)
            end
          end
        )

        #instance methods
        class_eval %(
          def #{field_name}=(s)
            super
            write_attribute(:#{array_field}, convert_string_to_array(s))
          end

          def #{array_field}=(a)
            super
            write_attribute(:#{field_name}, convert_array_to_string(a))
          end
        )

      end
    end

    module InstanceMethods

      attr :current_context

      def convert_string_to_array(s)
        s.split(",").map(&:strip)
      end

      def convert_array_to_string(a)
        a.map(&:strip).join(", ")
      end

      def tag_contexts
        tagify_options.keys
      end

      def tags_for_context
        send("#{@current_context}_array".to_sym)
      end

      def context_has_meta_model?
        !tagify_options[@current_context][:meta_in].blank?
      end

      def context_meta_model
        send(tagify_options[@current_context][:meta_in])
      end

      def context_is_changed?
        !changes[@current_context.to_s].blank?
      end

      def context_added_tags
        tags_for_context - changes[@current_context.to_s][0].split(",").map(&:strip)
      end

      def context_removed_tags
         changes[@current_context.to_s][0].split(",").map(&:strip) - tags_for_context
      end

      def update_meta_model
        tag_contexts.each do |context|
          @current_context = context
          if context_is_changed? && context_has_meta_model?
            context_meta_model.update_meta_tags(context, context_added_tags, context_removed_tags)
          end
        end
      end

      def decrement_all_in_meta_model
        tag_contexts.each do |context|
          context_meta_model.update_meta_tags(context, nil, tags_for_context)
        end
      end
    end
  end
end