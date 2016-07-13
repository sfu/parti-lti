class Oauth2ControllerTest < ActionController::TestCase

  test 'callback page should redirect user to home page if an error occurred' do
    user = create(:user)
    sign_in user
    get :callback, error: 'access_denied'
    assert_redirected_to root_path
  end

  test 'callback page should redirect user to home page if state cannot be parsed' do
    user = create(:user)
    sign_in user
    get :callback, state: 'gibberish'
    assert_redirected_to root_path
  end

  test 'callback page should redirect user to home page if params are missing' do
    user = create(:user)
    sign_in user
    get :callback, state: { key: 'some other JSON content' }.to_json
    assert_redirected_to root_path
  end

  test 'callback page should redirect user to home page if tool consumer is unknown' do
    user = create(:user)
    sign_in user
    get :callback, state: { id: -1, action: root_url }.to_json
    assert_redirected_to root_path
  end

  test 'callback page should redirect user to home page if unable to get token' do
    # TODO: stub out OAuth2::Client#get_token
    skip('To be implemented')
  end

  test 'callback page should create a token for the user if request is valid' do
    skip('To be implemented')
  end

  test 'callback page should redirect user to "action" page on success' do
    skip('To be implemented')
  end

end
