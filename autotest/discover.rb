Autotest.add_discovery do
  'openidengine' if File.exist? 'spec'
end
