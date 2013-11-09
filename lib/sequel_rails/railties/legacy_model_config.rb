require 'sequel_rails/sequel/plugins/rails_extensions'

::Sequel::Model.plugin :active_model
::Sequel::Model.plugin :validation_helpers
::Sequel::Model.plugin :rails_extensions
::Sequel::Model.raise_on_save_failure = false
