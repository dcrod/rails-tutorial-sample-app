require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest

  def setup
    @non_admin = users(:michael)
    @admin = users(:malory)
    @unactivated = users(:lana)
  end

  test "index includes pagination and delete links, but no unactivated users" do
    log_in_as(@admin)
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination', count: 2
    assert_select 'a[href=?]', user_path(@unactivated), count: 0
    User.where(activated: true).paginate(page: 1).each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
      unless user == @admin
        assert_select 'a[href=?]', user_path(user), text: 'delete'
      end
    end
    assert_difference 'User.count', -1 do
      delete user_path(@non_admin)
    end
  end
  
  test "index as non-admin contains no delete links" do
    log_in_as(@non_admin)
    get users_path
    assert_select 'a', text: 'delete', count: 0
  end
  
  test "user show redirects to root for unactivated user" do
    get user_path(@unactivated)
    assert_redirected_to root_url
  end

end
