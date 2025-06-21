require "test_helper"

class Admin::TransfersControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get admin_transfers_new_url
    assert_response :success
  end

  test "should get create" do
    get admin_transfers_create_url
    assert_response :success
  end
end
