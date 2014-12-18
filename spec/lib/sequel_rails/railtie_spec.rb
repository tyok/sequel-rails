require 'spec_helper'

describe SequelRails::Railtie do
  let(:app) { Combustion::Application }

  it 'registers ::Sequel::Railtie::LogSubscriber to receive :sequel notification' do
    expect(
      ActiveSupport::LogSubscriber.log_subscribers.select do |subscriber|
        subscriber.is_a?(SequelRails::Railties::LogSubscriber)
      end.size
    ).to eq 1
  end

  context 'configures generator to use Sequel' do
    it 'as orm' do
      expect(app.config.generators.options[:rails][:orm]).to be(:sequel)
    end

    it 'for migrations' do
      expect(app.config.generators.options[:sequel][:migration]).to be true
    end
  end

  it 'configures rails to use fancy pants logging' do
    expect(app.config.rails_fancy_pants_logging).to be true
  end

  context "configures action dispatch's rescue responses" do
    let(:rescue_responses) do
      app.config.action_dispatch.rescue_responses
    end

    it 'to handle Sequel::Plugins::RailsExtensions::ModelNotFound with :not_found' do
      expect(rescue_responses['Sequel::Plugins::RailsExtensions::ModelNotFound']).to be(:not_found)
    end

    it 'to handle Sequel::NoMatchingRow with :not_found' do
      expect(rescue_responses['Sequel::NoMatchingRow']).to be(:not_found)
    end

    it 'to handle Sequel::ValidationFailed with :unprocessable_entity' do
      expect(rescue_responses['Sequel::ValidationFailed']).to be(:unprocessable_entity)
    end

    it 'to handle Sequel::NoExistingObject with :unprocessable_entity' do
      expect(rescue_responses['Sequel::NoExistingObject']).to be(:unprocessable_entity)
    end
  end

  it "stores it's own config in app.config.sequel" do
    expect(app.config.sequel).to be_instance_of SequelRails::Configuration
  end

  it 'sets Rails.logger as default logger for its configuration' do
    expect(app.config.sequel.logger).to be Rails.logger
  end

  it 'configures Sequel::Model instances for i18n' do
    expect(User.i18n_scope).to be(:sequel)
    expect(User).to respond_to(:lookup_ancestors)
    expect(User.model_name.human).to eq('translated user')
  end

  it 'adds Sequel runtime to controller for logging' do
    expect(ActionController::Base.included_modules).to include(
      SequelRails::Railties::ControllerRuntime
    )
  end

  it 'configures database in Sequel' do
    expect do
      Sequel::Model.db.test_connection
    end.to_not raise_error
  end
end
