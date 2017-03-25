require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest
  
  def setup
    # User from fixtures
    @user = users(:michael)
  end
  
  test "invalid login information" do
    get login_path
    assert_template 'sessions/new'
    assert_select 'form[action="/login"]'
    post login_path, params: { session: { email: "user@invalid",
                                          password: "foo" } }
    assert_template 'sessions/new'
    assert_not flash.empty?
    get root_path
    assert flash.empty?
  end
  
  test "login with valid information followed by logout" do
    get login_path
    post login_path, params: { session: { email: @user.email,
                                          password: 'password12' } }
    assert is_logged_in? # Assert session[:user_id] is not nil
    assert_redirected_to @user
    follow_redirect!
    assert_template 'users/show'
    # Make sure log in link is gone and profile and logout links are present
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(@user)
    # Log out
    delete logout_path
    assert_not is_logged_in?
    assert_redirected_to root_url
    # Simulate a user clicking 'Log Out' in a second window/tab
    delete logout_path
    follow_redirect!
    assert_template 'static_pages/home'
    # Make sure log in link is present and profile and logout links are gone
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path, count: 0
    assert_select "a[href=?]", user_path(@user), count: 0
  end
end
