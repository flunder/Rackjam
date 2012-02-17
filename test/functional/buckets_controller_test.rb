require 'test_helper'

class BucketsControllerTest < ActionController::TestCase
  setup do
    @bucket = buckets(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:buckets)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create bucket" do
    assert_difference('Bucket.count') do
      post :create, bucket: @bucket.attributes
    end

    assert_redirected_to bucket_path(assigns(:bucket))
  end

  test "should show bucket" do
    get :show, id: @bucket.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @bucket.to_param
    assert_response :success
  end

  test "should update bucket" do
    put :update, id: @bucket.to_param, bucket: @bucket.attributes
    assert_redirected_to bucket_path(assigns(:bucket))
  end

  test "should destroy bucket" do
    assert_difference('Bucket.count', -1) do
      delete :destroy, id: @bucket.to_param
    end

    assert_redirected_to buckets_path
  end
end
