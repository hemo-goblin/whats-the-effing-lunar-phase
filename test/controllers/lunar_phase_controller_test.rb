require 'test_helper'

class LunarPhaseControllerTest < ActionController::TestCase
  test "should get lunarPhase" do
    get :lunarPhase
    assert_response :success
  end

end
