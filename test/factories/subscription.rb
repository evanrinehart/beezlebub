FactoryGirl.define do

  factory :subscription do
    event_name "blam"
    push_uri "http://example.com/dev/null"
    note "will be totally ignored"
  end

end
