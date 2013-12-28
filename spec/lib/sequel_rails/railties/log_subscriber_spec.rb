require 'spec_helper'
require 'active_support/log_subscriber/test_helper'

describe SequelRails::Railties::LogSubscriber do
  include ActiveSupport::LogSubscriber::TestHelper
  def set_logger(logger) # rubocop:disable AccessorMethodName
    SequelRails.configuration.logger = logger
    ActiveSupport::LogSubscriber.logger = logger
  end
  before do
    setup
    described_class.attach_to :sequel
  end
  after { teardown }

  it 'logs queries' do
    User.all
    wait
    expect(@logger.logged(:debug).last).to match(/SELECT \* FROM ("|`)users("|`)/)
  end

  it 'does not log query when logger level is not debug' do
    @logger.level = :info
    User.all
    wait
    expect(@logger.logged(:debug)).to have(:no).line
  end
end
