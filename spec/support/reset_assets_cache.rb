require 'fileutils'

RSpec.configure do |config|
  config.before(:suite) do
    FileUtils.rmtree(Rails.root.join('tmp/cache/assets').to_s)
    TestAppAssets.clobber!
    TestAppAssets.build!
  end

  config.after(:suite) do
    TestAppAssets.clobber!
  end
end
