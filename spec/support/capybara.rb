RSpec.configure do |config|
  # JS使わないなら rack_test、使うときは :selenium_chrome_headless に切替
  config.before(:each, type: :system) do
    driven_by(:rack_test)
  end
end