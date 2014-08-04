desc "run the tests"
task "test" do
  ENV['RACK_ENV'] = 'test'
  $LOAD_PATH.unshift('lib', 'test')

  require 'factory_girl'
  Dir['./test/factories/*.rb'].each do |path|
    require path
  end

  Dir['./test/{unit,functional}/*.rb'].each do |path|
    require path
  end
end
