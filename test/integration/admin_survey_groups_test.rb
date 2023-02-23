require "test_helper"

class AdminSurveyGroupsTest < ActionDispatch::IntegrationTest
  DatabaseCleaner.clean

  test "Admin page for survey with no groups" do
    DatabaseCleaner.cleaning do
      user = create_authorized_user
      set_authorization_cookie

      survey = create_survey

      get admin_survey_path(survey.id)
      assert_response :success

      assert_select "h1", "Emergent Commons Volunteer App"
      assert_select "h5", "Survey Groups and Questions"
      assert_select "table.survey-group", count: 0
      assert_select "a", "New Group"
      assert_select "a", "Back"
      assert_select "a", "edit", count: 1
      assert_select "a", "del", count: 1
    end
  end

  test "Admin page for survey with groups and questions" do
    DatabaseCleaner.cleaning do
      user = create_authorized_user
      set_authorization_cookie

      survey = create_survey
      group_1 = create_survey_group(survey: survey)
      group_2 = create_survey_group(survey: survey)
      question_1_1 = create_survey_question(survey_group: group_1)
      question_1_2 = create_survey_question(survey_group: group_1)
      question_2_1 = create_survey_question(survey_group: group_2)
      question_2_1 = create_survey_question(survey_group: group_2)


      get admin_survey_path(survey.id)
      assert_response :success

      assert_select "table.survey-group", count: 2
      assert_select "a", "New Question", count: 2
      assert_select "a", "edit", count: 3
      assert_select "a", "del", count: 3
    end
  end

  test "Admin new page for survey group" do
    DatabaseCleaner.cleaning do
      user = create_authorized_user
      set_authorization_cookie

      survey = create_survey
      get new_admin_survey_survey_group_path(survey.id)
      assert_response :success

      assert_select "h1", "Emergent Commons Volunteer App"
      assert_select "h5", "New Survey Group"
      assert_select '#survey_group_name'
      assert_select '#survey_group_description'
      assert_select '#survey_group_votes_max'
      assert_select "input[type='submit'][value=?]", "Create Group"
      assert_select "a", "Cancel"
    end
  end

  test "Admin edit page for survey group" do
    DatabaseCleaner.cleaning do
      user = create_authorized_user
      set_authorization_cookie

      survey = create_survey
      group = create_survey_group(survey: survey, votes_max: 3)
      get edit_admin_survey_survey_group_path(group.id, survey_id: survey.id)
      assert_response :success

      assert_select "h1", "Emergent Commons Volunteer App"
      assert_select "h5", "Edit Survey Group"
      assert_select "#survey_group_name[value=?]", group.name
      assert_select "#survey_group_description[value=?]", group.description
      assert_select "#survey_group_votes_max[value=?]", group.votes_max.to_s
      assert_select "input[type='submit'][value=?]", "Update Group"
      assert_select "a", "Cancel"
    end
  end
end