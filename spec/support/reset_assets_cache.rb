require 'fileutils'

RSpec.configure do |config|
  config.before(:suite) { FileUtils.rmtree(Rails.root.join('tmp/cache/assets').to_s) }
end
