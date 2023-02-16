module SurveyQuestion::Contract
  class Create < Reform::Form
    include Dry

    property :survey_id
    property :question_type
    property :question
    property :answer_type
    property :has_scale
    property :answer_labels
    property :scale_labels
    property :scale_question

    validation do
      params do
        required(:survey_id).filled.value(:integer)
        required(:question_type).filled.value(:string)
        required(:question)
        required(:answer_type)
        required(:has_scale)
        required(:answer_labels)
        required(:scale_labels)
        required(:scale_question)
      end

      rule(:question, :question_type) do
        unless ["New Page","Instructions","Group Name","Branch"].index(values[:question_type])
          key.failure('must be filled') if values[:question].blank?
          key.failure('must be a string') unless values[:question].is_a?(String)
        end
      end
      rule(:scale_question, :has_scale) do
        if "1" == values[:has_scale]
          key.failure('must be filled') if values[:scale_question].blank?
          key.failure('must be a string') unless values[:scale_question].is_a?(String)
        end
      end
    end
  end
end