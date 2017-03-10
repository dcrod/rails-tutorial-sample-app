require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # create example user
  def setup
    @user = User.new(name: "Example User", email: "user@example.com")  
  end
  
  # assert that user is valid
  test "user should be valid" do
    assert @user.valid?
  end
  
  test "name should be present" do
    @user.name = '  '
    assert_not @user.valid?
  end
  
  test "email should be present" do
    @user.email = ' '
    assert_not @user.valid?
  end
  
  test "name should be less than 51 characters" do
    @user.name = "x" * 51
    assert_not @user.valid?
  end
  
  test "email should be less than 256 characters" do
    @user.email = "x" * 244 + "@example.com"
    assert_not @user.valid?
  end
end
