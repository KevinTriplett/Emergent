module SurveyQuestion::Contract
  class Update < Reform::Form
    include Dry

    property :id
    property :survey_group_id
    property :question_type
    property :question
    property :answer_type
    property :has_scale
    property :position
    property :answer_labels
    property :scale_labels
    property :scale_question

    validation do
      params do
        required(:id).filled.value(:integer)
        required(:survey_group_id).filled.value(:integer)
        required(:question_type).filled.value(:string)
        required(:question)
        required(:answer_type)
        required(:has_scale)
        required(:position).filled.value(:integer)
        required(:answer_labels)
        required(:scale_labels)
        required(:scale_question)
      end

      rule(:question, :question_type) do
        unless ["New Page","Instructions","Group Name","Branch"].index(values[:question_type])
          key.failure('must be filled') if values[:question].blank?
          key.failure('must be a string') unless values[:question].blank? || values[:question].is_a?(String)
        end
      end
      rule(:scale_question, :has_scale) do
        if "1" == values[:has_scale]
          key.failure('must be filled') if values[:scale_question].blank?
          key.failure('must be a string') unless values[:scale_question].blank? || values[:scale_question].is_a?(String)
        end
      end
    end
  end
end