require 'test_helper'

class UserTest < ActiveSupport::TestCase

  test 'user should be given a password if none is provided' do
    user = build(:user, password: '')
    assert user.save
    assert_not_empty user.password
  end

  test 'user should be given a different password every time if none is provided' do
    user = create(:user, password: '')
    first_password = user.password

    user = create(:user, password: '')
    second_password = user.password

    assert_not_equal first_password, second_password
  end

  test 'self.login_to_email should leave login as-is if it is already an email address' do
    login = 'test@example.com'
    result = User.login_to_email(login)
    assert_equal login, result
  end

  test 'self.login_to_email should add @sfu.ca to login if it is not an email address' do
    login = 'foo'
    result = User.login_to_email(login)
    assert_equal "#{login}@sfu.ca", result
  end

end
