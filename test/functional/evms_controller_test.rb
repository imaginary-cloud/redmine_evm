require File.expand_path('../../test_helper', __FILE__)

class EvmsControllerTest < ActionController::TestCase

	fixtures :projects

  ActiveRecord::Fixtures.create_fixtures(File.dirname(__FILE__) + '/../fixtures/',
    [:baselines])

  def setup
    RedmineEvm::TestCase.prepare

    @controller = EvmsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    User.current = nil
  end

  def test_index
  	@request.session[:user_id] = 1
  	get :index, :project_id => '1'
  	assert_response :success
  end

end
