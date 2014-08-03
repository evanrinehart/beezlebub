FactoryGirl.define do

  to_create {|i| i.save}

  factory :app do
    name "pork_volcano"
    secret "7b9192a31ed8f8167737"
  end

end
