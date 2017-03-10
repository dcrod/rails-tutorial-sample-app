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
  
  test "email validation should accept valid emails" do
    valid_addresses = %w[user@example.com mr-USEr@blah.CC us.e_r@exam.ple.com 
                         first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end
  
  test "email validation should reject invalid emails" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                           foo@bar_baz.com foo@bar+baz.com  foo@bar..com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end
end
