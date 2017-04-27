require 'test_helper'

class MicropostsInterfaceTest < ActionDispatch::IntegrationTest
  
  def setup
    @user = users(:michael)
  end
  
  test "micropost interface" do
    log_in_as(@user)
    get root_path
    # Check Pagination
    assert_select 'div.pagination'
    # Invalid Submission
    assert_no_difference 'Micropost.count' do
      post microposts_path, params: { micropost: { content: "" } }
    end
    assert_select 'div#error_explanation'
    # Valid Submission
    valid_content = "This is valid micropost content"
    assert_difference 'Micropost.count', 1 do
      post microposts_path, params: { micropost: { content: valid_content } }
    end
    assert_redirected_to root_url
    follow_redirect!
    assert_match valid_content, response.body
    # Delete Post
    assert_select 'a', text: 'delete'
    first_micropost = @user.microposts.paginate(page: 1).first
    assert_difference 'Micropost.count', -1 do
      delete micropost_path(first_micropost)
    end
    # Visit different user (no delete links)
    get user_path(users(:archer))
    assert_select 'a', text: 'delete', count: 0
  end
  
  test "micropost sidebar count with proper pluralization" do
    log_in_as(@user)
    get root_path
    assert_select '.user_info>span',
                  text: "#{@user.microposts.count} microposts"
    # User with zero microposts (and 1)
    other_user = users(:malory)
    log_in_as(other_user)
    get root_path
    assert_select '.user_info>span', text: '0 microposts'
    other_user.microposts.create(content: "A micropost")
    get root_path
    assert_select '.user_info>span', text: '1 micropost'
  end
end
