module SequelRails
  module I18nSupport
    # Set the i18n scope to overwrite ActiveModel.
    def i18n_scope #:nodoc:
      :sequel
    end

    def lookup_ancestors
      # ActiveModel uses the name of ancestors. Exclude unnamed classes, like
      # those returned by Sequel::Model(...).
      super.reject { |x| x.name.nil? }
    end
  end
end
