desc "run the tests"
task "test" do
  $LOAD_PATH.unshift('lib', 'test')

  require 'factory_girl'
  Dir['./test/factories/*.rb'].each do |path|
    require path
  end

  Dir['./test/{unit,functional}/*.rb'].each do |path|
    require path
  end
end
