FactoryGirl.define do

  factory :event do
    name "blam"
    payload "[1,2,3,4,5,6]"
    version 0
    content_type "application/json"
  end

end
