class LtiControllerTest < ActionController::TestCase

  test 'should get configuration as XML' do
    get :configuration, format: :xml
    assert_response :success
    assert_equal 'application/xml', @response.content_type
  end

  test 'launch page should not verify authenticity token' do
    skip('To be implemented')
  end

  test 'launch page should validate the OAuth request' do
    skip('To be implemented')
  end

  test 'launch page should redirect to error page if unable to validate the OAuth request' do
    skip('To be implemented')
  end

  test 'launch page should redirect to error page if unable to resolve user identity' do
    skip('To be implemented')
  end

  test 'launch page should create new user based on info given' do
    skip('To be implemented')
  end

  test 'launch page should identify returning users' do
    skip('To be implemented')
  end

  test 'launch page should sign users in automatically' do
    skip('To be implemented')
  end

  test 'launch page should redirect user to room if it exists' do
    skip('To be implemented')
  end

  test 'launch page should create room for only teachers and if it does not exist' do
    skip('To be implemented')
  end

  test 'launch page should redirect user to home page with alert if the room cannot be created' do
    skip('To be implemented')
  end

  test 'launch page should enroll the current user as teacher if user is an LTI instructor' do
    skip('To be implemented')
  end

  test 'launch page should redirect teacher post-creation to the import participants page if supported' do
    skip('To be implemented')
  end

  test 'launch page should redirect teacher post-creation to the room if import participants not supported' do
    skip('To be implemented')
  end

  test 'launch page should redirect students to error page if the room does not exist' do
    skip('To be implemented')
  end

  test 'get_url_root should return the scheme + host + port portions properly' do
    @controller.params['launch_presentation_return_url'] = 'https://example.com:8080/test'
    result = @controller.send(:get_url_root)
    assert_equal 'https://example.com:8080', result

    @controller.params['launch_presentation_return_url'] = 'http://example.com/test'
    result = @controller.send(:get_url_root)
    assert_equal 'http://example.com', result
  end

  test 'get_url_root should still work if launch_presentation_return_url is incomplete' do
    @controller.params['launch_presentation_return_url'] = '/test'
    @controller.params['custom_canvas_api_domain'] = 'example.com:8080'
    result = @controller.send(:get_url_root)
    assert_equal 'https://example.com:8080', result
  end

  test 'get_url_root should return nil if required params are unavailable or incomplete' do
    result = @controller.send(:get_url_root)
    assert_nil result

    @controller.params['launch_presentation_return_url'] = '/test'
    result = @controller.send(:get_url_root)
    assert_nil result
  end

end