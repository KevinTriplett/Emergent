module SurveyQuestion::Contract
  class Update < Reform::Form
    include Dry

    property :id
    property :survey_id
    property :question_type
    property :question
    property :answer_type
    property :has_scale
    property :position
    property :scale_label_left
    property :scale_label_right

    validation do
      params do
        required(:id).filled.value(:integer)
        required(:survey_id).filled.value(:integer)
        required(:question_type).filled.value(:string)
        required(:question).filled.value(:string)
        required(:answer_type).filled.value(:string)
        required(:has_scale)
        required(:position).filled.value(:integer)
        required(:scale_label_left)
        required(:scale_label_right)
      end

      rule(:scale_label_left, :has_scale) do
        return unless values[:has_scale]
        key.failure('must be filled') unless values[:scale_label_left]
      end
      rule(:scale_label_right, :has_scale) do
        return unless values[:has_scale]
        key.failure('must be filled') unless values[:scale_label_right]
      end
    end
  end
end