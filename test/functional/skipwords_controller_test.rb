require 'test_helper'

class SkipwordsControllerTest < ActionController::TestCase
  setup do
    @skipword = skipwords(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:skipwords)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create skipword" do
    assert_difference('Skipword.count') do
      post :create, :skipword => @skipword.attributes
    end

    assert_redirected_to skipword_path(assigns(:skipword))
  end

  test "should show skipword" do
    get :show, :id => @skipword.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @skipword.to_param
    assert_response :success
  end

  test "should update skipword" do
    put :update, :id => @skipword.to_param, :skipword => @skipword.attributes
    assert_redirected_to skipword_path(assigns(:skipword))
  end

  test "should destroy skipword" do
    assert_difference('Skipword.count', -1) do
      delete :destroy, :id => @skipword.to_param
    end

    assert_redirected_to skipwords_path
  end
end
