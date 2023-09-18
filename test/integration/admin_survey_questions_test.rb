require "test_helper"

class AdminSurveyQuestionsTest < ActionDispatch::IntegrationTest
  DatabaseCleaner.clean

  test "Admin page with surveys but no questions" do
    DatabaseCleaner.cleaning do
      user = create_authorized_user(:surveyor)
      set_authorization_cookie

      survey = create_survey
      get admin_survey_path(survey.id)

      assert_select "h1", "Emergent Commons Volunteer App"
      assert_select "h5", "Survey Groups and Questions"
      assert_select "p.survey-name", "edit\n|\nnotes\n|\ninvite\n|\nreport\n|\nduplicate\n|\ntest\n|\ndel\n------\nSurvey: #{survey.name}"
      assert_select ".survey-name a", "edit"
      assert_select ".survey-name a", "del"
      assert_select "table.survey-questions a", {count: 0, text: "edit"}
      assert_select "table.survey-questions a", {count: 0, text: "del"}
      assert_select "a.btn", "New Group"
    end
  end

  test "Admin page for survey with question" do
    DatabaseCleaner.cleaning do
      user = create_authorized_user(:surveyor)
      set_authorization_cookie

      question = create_survey_question
      get admin_survey_path(question.survey_id)
      assert_response :success

      assert_select "h1", "Emergent Commons Volunteer App"
      assert_select "h5", "Survey Groups and Questions"
      assert_select "p.survey-name", "edit\n|\nnotes\n|\ninvite\n|\nreport\n|\nduplicate\n|\ntest\n|\ndel\n------\nSurvey: #{question.survey.name}"
      assert_select "tr[data-url=?]", admin_survey_question_patch_path(question.id)
      assert_select "tr[data-id=?]", question.id.to_s
      assert_select "tr[data-position=?]", question.position.to_s
      assert_select "td.question-type", question.question_type
      assert_select "td.question", question.question
      assert_select "td.answer-type", question.answer_type
      assert_select "td.has-scale", question.has_scale? ? "Yes" : "No"
      assert_select "table.survey-questions a", "edit"
      assert_select "table.survey-questions a", "del"
      assert_select "a.btn", "New Question"
      assert_select "a.btn", "New Group"
      assert_select "a[href=?]", admin_surveys_path, "Back"
    end
  end

  test "Admin create page for survey question" do
    DatabaseCleaner.cleaning do
      user = create_authorized_user(:surveyor)
      set_authorization_cookie

      group = create_survey_group
      get new_admin_survey_survey_group_survey_question_path(group.id, survey_id: group.survey_id)
      assert_response :success

      assert_select "h1", "Emergent Commons Volunteer App"
      assert_select "h5", "New Survey Question"
      assert_select "#survey_question_question_type"
      assert_select "#survey_question_answer_type"
      assert_select "#survey_question_question"
      assert_select "#survey_question_has_scale"
      assert_select "#survey_question_has_scale[checked]", false
      assert_select "#survey_question_answer_labels"
      assert_select "#survey_question_scale_labels"
      assert_select "#survey_question_scale_question"
      assert_select "input[type='submit'][value=?]", "Create Question"
      assert_select "a", "Cancel"
    end
  end

  test "Admin edit page for survey question" do
    DatabaseCleaner.cleaning do
      user = create_authorized_user(:surveyor)
      set_authorization_cookie

      question = create_survey_question(has_scale: true)
      get edit_admin_survey_survey_group_survey_question_path(id: question.id, survey_id: question.survey_id, survey_group_id: question.survey_group_id)
      assert_response :success

      assert_select "h1", "Emergent Commons Volunteer App"
      assert_select "h5", "Edit Survey Question"
      assert_select "#survey_question_question_type" do
        assert_select "[value=?]", question.question_type
      end
      assert_select "#survey_question_answer_type" do
        assert_select "[value=?]", question.answer_type
      end
      assert_select "#survey_question_question", question.question
      assert_select "#survey_question_has_scale[checked]"
      assert_select "#survey_question_answer_labels[value=?]", question.answer_labels
      assert_select "#survey_question_scale_labels[value=?]", question.scale_labels
      assert_select "#survey_question_scale_question[value=?]", question.scale_question
      assert_select "input[type='submit'][value=?]", "Update Question"
      assert_select "a", "Cancel"

      question.update(has_scale: true)
      get edit_admin_survey_survey_group_survey_question_path(question.id, survey_id: question.survey_id, survey_group_id: question.survey_group_id)
      assert_select "#survey_question_has_scale[checked]", true
    end
  end
end