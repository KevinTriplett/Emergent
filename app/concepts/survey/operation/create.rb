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
      group = create_survey_group(survey: model)[:model]
      create_survey_question({
        survey_group: group,
        question: "Would you like to receive a link to your survey response, for future reference?",
        answer_type: "Multiple Choice",
        answer_lables: "No|Yes by private message|yes by email"
      })
      create_survey_question({
        survey_group: group,
        question: "If by email, what is your email address?",
        answer_type: "Email"
      })
      create_survey_question({
        survey_group: group,
        question_type: "New Page"
      })
    end
  end
end