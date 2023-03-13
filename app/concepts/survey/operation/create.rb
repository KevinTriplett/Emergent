module Survey::Operation
  class Create < Trailblazer::Operation
    include SurveyHelper

    class Present < Trailblazer::Operation
      step Model(Survey, :new)
      step Contract::Build(constant: Survey::Contract::Create)
    end
    
    step Subprocess(Present)
    step Contract::Validate(key: :survey)
    step Contract::Persist()
    step :create_initial_survey_group_questions

    def create_initial_survey_group_questions(ctx, model:, params:, **)
      return true unless params[:create_initial_questions]
      # CONTACT INFO --------------------------------
      return false unless group = SurveyHelper::create_new_survey_group({
        survey: model,
        name: "Contact Info",
        description: "Your contact information is needed if you want a link to your survey answers (and any votes you cast)."
      })
      return false unless SurveyHelper::create_new_survey_question({
        survey_group: group,
        question_type: "Question",
        question: "How would you like to receive a link to your survey response?",
        answer_type: "Multiple Choice",
        answer_labels: "No Thanks|Private Message|Email"
      })
      return false unless SurveyHelper::create_new_survey_question({
        survey_group: group,
        question_type: "Question",
        question: "If by email, what is your email address?",
        answer_type: "Email"
      })
      # FEEDBACK INFO --------------------------------
      return false unless group = SurveyHelper::create_new_survey_group({
        survey: model,
        name: "Feedback",
        description: "That's it! Thank you for taking our survey!"
      })
      SurveyHelper::create_new_survey_question({
        survey_group: group,
        question_type: "Question",
        question: "If you want, we would love to receive your constructive feedback. Thanks!",
        answer_type: "Essay",
        has_scale: true,
        scale_question: "How useful do you feel this survey was?",
        scale_labels: "Not Useful|Very Useful"
      })
    end
  end
end