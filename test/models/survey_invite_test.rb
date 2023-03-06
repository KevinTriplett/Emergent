
require 'test_helper'

class SurveyInviteTest < MiniTest::Spec
  DatabaseCleaner.clean

  it "creates a token on create" do
    DatabaseCleaner.cleaning do
      invite = create_survey_invite
      assert invite.token
    end
  end

  it "reports total votes" do
    DatabaseCleaner.cleaning do
      group_1 = create_survey_group(votes_max: 6)
      survey = group_1.survey
      group_2 = create_survey_group(survey: survey, votes_max: 6)
      question_1_1 = create_survey_question(survey: survey, survey_group: group_1, answer_type: "Vote")
      question_1_2 = create_survey_question(survey: survey, survey_group: group_1, answer_type: "Vote")
      question_2_1 = create_survey_question(survey: survey, survey_group: group_2, answer_type: "Vote")
      question_2_2 = create_survey_question(survey: survey, survey_group: group_2, answer_type: "Vote")
      invite = create_survey_invite(survey: survey)
      answer_1_1 = create_survey_answer(survey_invite: invite, survey_question: question_1_1)
      answer_1_2 = create_survey_answer(survey_invite: invite, survey_question: question_1_2)
      answer_2_1 = create_survey_answer(survey_invite: invite, survey_question: question_2_1)
      answer_2_2 = create_survey_answer(survey_invite: invite, survey_question: question_2_2)

      answer_1_1.update vote_count: 3
      answer_1_2.update vote_count: 1
      answer_2_1.update vote_count: 2
      answer_2_2.update vote_count: 4

      assert_equal 4, invite.reload.votes_total(group_1.id)
      assert_equal 6, invite.votes_total(group_2.id)
    end
  end

  it "updates the state" do
    DatabaseCleaner.cleaning do
      survey_invite = create_survey_invite
      assert_equal SurveyInvite::STATUS[:created], survey_invite.state

      old_timestamp = survey_invite.state_timestamp
      survey_invite.update_state(:invite_sent) # saves to db
      assert_equal SurveyInvite::STATUS[:invite_sent], survey_invite.reload.state
      assert old_timestamp != survey_invite.state_timestamp
      
      old_timestamp = survey_invite.state_timestamp
      survey_invite.update_state(:opened, false) # does not save to db
      assert_equal SurveyInvite::STATUS[:invite_sent], survey_invite.reload.state
      assert_equal old_timestamp, survey_invite.state_timestamp
      
      old_timestamp = survey_invite.state_timestamp
      survey_invite.update_state(:created) # does not go backward
      assert_equal SurveyInvite::STATUS[:invite_sent], survey_invite.reload.state
      assert_equal old_timestamp, survey_invite.state_timestamp
    end
  end

  it "reports the correct state" do
    DatabaseCleaner.cleaning do
      invite = SurveyInvite.new
      assert invite.created?
      assert invite.is_created?
      assert !invite.invite_sent?
      assert !invite.is_invite_sent?
      assert !invite.opened?
      assert !invite.is_opened?
      assert !invite.started?
      assert !invite.is_started?
      assert !invite.finished?
      assert !invite.is_finished?
      assert !invite.finished_link_sent?
      assert !invite.is_finished_link_sent?

      invite.state = SurveyInvite::STATUS[:invite_sent]
      assert invite.created?
      assert !invite.is_created?
      assert invite.invite_sent?
      assert invite.is_invite_sent?
      assert !invite.opened?
      assert !invite.is_opened?
      assert !invite.started?
      assert !invite.is_started?
      assert !invite.finished?
      assert !invite.is_finished?
      assert !invite.finished_link_sent?
      assert !invite.is_finished_link_sent?

      invite.state = SurveyInvite::STATUS[:opened]
      assert invite.created?
      assert !invite.is_created?
      assert invite.invite_sent?
      assert !invite.is_invite_sent?
      assert invite.opened?
      assert invite.is_opened?
      assert !invite.started?
      assert !invite.is_started?
      assert !invite.finished?
      assert !invite.is_finished?
      assert !invite.finished_link_sent?
      assert !invite.is_finished_link_sent?

      invite.state = SurveyInvite::STATUS[:started]
      assert invite.created?
      assert !invite.is_created?
      assert invite.invite_sent?
      assert !invite.is_invite_sent?
      assert invite.opened?
      assert !invite.is_opened?
      assert invite.started?
      assert invite.is_started?
      assert !invite.finished?
      assert !invite.is_finished?
      assert !invite.finished_link_sent?
      assert !invite.is_finished_link_sent?

      invite.state = SurveyInvite::STATUS[:finished]
      assert invite.created?
      assert !invite.is_created?
      assert invite.invite_sent?
      assert !invite.is_invite_sent?
      assert invite.opened?
      assert !invite.is_opened?
      assert invite.started?
      assert !invite.is_started?
      assert invite.finished?
      assert invite.is_finished?
      assert !invite.finished_link_sent?
      assert !invite.is_finished_link_sent?

      invite.state = SurveyInvite::STATUS[:finished_link_sent]
      assert invite.created?
      assert !invite.is_created?
      assert invite.invite_sent?
      assert !invite.is_invite_sent?
      assert invite.opened?
      assert !invite.is_opened?
      assert invite.started?
      assert !invite.is_started?
      assert invite.finished?
      assert !invite.is_finished?
      assert invite.finished_link_sent?
      assert invite.is_finished_link_sent?
    end
  end

  it "finds its survey_answer based on survey_question_id" do
    DatabaseCleaner.cleaning do
      group_1 = create_survey_group
      survey = group_1.survey
      group_2 = create_survey_group(survey: survey)
      question_1_1 = create_survey_question(survey: survey, survey_group: group_1)
      question_1_2 = create_survey_question(survey: survey, survey_group: group_1)
      question_2_1 = create_survey_question(survey: survey, survey_group: group_2)
      question_2_2 = create_survey_question(survey: survey, survey_group: group_2)
      invite = create_survey_invite(survey: survey)
      answers_hash = {}
      survey.ordered_questions.each do |sq|
        answer = create_survey_answer(survey_invite: invite, survey_question: sq)
        answers_hash[answer.id] = sq.id
      end

      survey.ordered_questions.each do |sq|
        answer = invite.survey_answer_for(sq.id)
        assert_equal answers_hash[answer.id], sq.id
      end
    end
  end
end