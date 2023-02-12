module SurveyQuestion::Contract
  class Create < Reform::Form
    include Dry

    property :survey_id
    property :question_type
    property :question
    property :answer_type
    property :has_scale
    property :scale_label_left
    property :scale_label_right

    validation do
      params do
        required(:survey_id).filled.value(:integer)
        required(:question_type).filled.value(:string)
        required(:question).filled.value(:string)
        required(:answer_type).filled.value(:string)
        required(:has_scale)
        required(:scale_label_left)
        required(:scale_label_right)
      end

      rule(:scale_label_left, :has_scale) do
        key.failure('must be filled') if values[:has_scale] && values[:scale_label_left].blank?
      end
      rule(:scale_label_right, :has_scale) do
        key.failure('must be filled') if values[:has_scale] && values[:scale_label_right].blank?
      end
    end
  end
end