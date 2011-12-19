require 'test_helper'

class WorkEntriesControllerTest < ActionController::TestCase
  setup do
    @work_entry = work_entries(:one)
    session[:user_id] = users(:one).id
  end

  test "should convert minutes" do
    c = WorkEntriesController.new
    params = {minutes: '1:23', foo: 3}
    p2 = c.duration_to_minutes(params)
    assert_equal({:foo => 3, :minutes => 83}, p2)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:work_entries)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create work_entry" do
    assert_difference('WorkEntry.count') do
      post :create, work_entry: @work_entry.attributes
    end

    assert_redirected_to work_entry_path(assigns(:work_entry))
  end

  test "should convert duration on create" do
    post :create, work_entry: @work_entry.attributes.merge({:minutes => '1:23', :note => 'xyzzy'})
    w = WorkEntry.where("note = 'xyzzy'").first
    assert_equal 83, w.minutes
  end

  test "should show work_entry" do
    get :show, id: @work_entry.to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @work_entry.to_param
    assert_response :success
  end

  test "should update work_entry" do
    put :update, id: @work_entry.to_param, work_entry: @work_entry.attributes
    assert_redirected_to work_entry_path(assigns(:work_entry))
  end

  test "should convert duration on edit" do
    put :update, id: @work_entry.to_param, work_entry: @work_entry.attributes.merge({:minutes => '1:23', :note => 'xyzzy'})
    w = WorkEntry.where("note = 'xyzzy'").first
    assert_equal 83, w.minutes
  end

  test "should destroy work_entry" do
    assert_difference('WorkEntry.count', -1) do
      delete :destroy, id: @work_entry.to_param
    end

    assert_redirected_to work_entries_path
  end
end
