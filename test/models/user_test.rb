require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # create example user
  def setup
    @user = User.new(name: "Example User", email: "user@example.com",
                     password: "foobar12", password_confirmation: "foobar12")  
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
  
  test "email addresses should be unique" do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase
    @user.save
    assert_not duplicate_user.valid?
  end
  
  test "email addresses should be saved lowercase" do
    @user.email = 'mIxEd@cA.sE'
    user_email = @user.email
    @user.save
    @user.reload
    assert_equal @user.email, user_email.downcase
  end
  
   test "password should be present" do
    @user.password = @user.password_confirmation = ' ' * 8
    assert_not @user.valid?
  end
  
  test "password should have minimum length (8)" do
    @user.password = @user.password_confirmation = 'x' * 7
    assert_not @user.valid?
  end
 
  test "authenticated? should return false for user with nil remember_digest" do
    # Since no remember_digest was assigned to @user in setup, 
    # nil is passed to BCrypt::Password.new
    assert_not @user.authenticated?(:remember, '')
  end
  
  test "associated microposts should be destroyed when user is destroyed" do
    @user.save
    @user.microposts.create!(content: "Lorem ipsum")
    assert_difference 'Micropost.count', -1 do
      @user.destroy
    end
  end
  
  test "should follow and unfollow a user" do
    michael = users(:michael)
    archer = users(:archer)
    assert_not michael.following?(archer)
    michael.follow(archer)
    assert michael.following?(archer)
    assert archer.followers.include?(michael)
    michael.unfollow(archer)
    assert_not michael.following?(archer)
  end
  
  test "feed should have the right posts" do
    michael = users(:michael)
    archer  = users(:archer)
    lana    = users(:lana)
    # Posts from a followed user
    lana.microposts.each do |post_following|
      assert michael.feed.include?(post_following)
    end
    # Posts from self
    michael.microposts.each do |post_self|
      assert michael.feed.include?(post_self)
    end
    # Posts from unfollowed user
    archer.microposts.each do |post_unfollowed|
      assert_not michael.feed.include?(post_unfollowed)
    end
  end
end
