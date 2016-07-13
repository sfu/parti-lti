FactoryGirl.define do

  factory :user do
    sequence(:first_name) { |n| "User #{n}" }
    last_name 'Test'
    sequence(:email) { |n| "user-#{n}@parti.test" }
    password 'password'
  end

  factory :room do
    sequence(:name) { |n| "Test Room #{n}" }
    sequence(:lti_resource_link_id) { |n| "test_resource_id_#{n}" }
    lti_context_type 'course'
    sequence(:lti_context_id)
  end

  factory :lti_tool_consumer do
    sequence(:name) { |n| "Test Consumer #{n}" }
    product_family 'canvas'
    url_root 'http://canvas.dev'
    oauth2_client_id 'canvas_client'
    oauth2_client_secret 'some_juicy_secret'
  end

end
