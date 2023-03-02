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
      return false unless group = SurveyHelper::create_new_survey_group({
        survey: model,
        name: "Contact Info",
        description: "Your contact information is needed if you want a link to your survey answers (and any votes you cast)."
      })
      return false unless SurveyHelper::create_new_survey_question({
        survey_group: group,
        question: "How would you like to receive a link to your survey response?",
        answer_type: "Multiple Choice",
        answer_lables: "No Thanks|Private Message|Email"
      })
      SurveyHelper::create_new_survey_question({
        survey_group: group,
        question: "If by email, what is your email address?",
        answer_type: "Email"
      })
    end
  end
end