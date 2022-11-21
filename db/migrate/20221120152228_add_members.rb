class AddMembers < ActiveRecord::Migration[7.0]
  def change
    create_table :members do |t|
      t.string :name
      t.string :email
      t.string :profile_url
      t.string :chat_url
      t.datetime :request_timestamp
      t.datetime :join_timestamp
      t.string :status
      t.string :location
      t.text :questions_responses
      t.text :notes
      t.references :greeter
      t.references :referral

      t.timestamps
    end
  end
end
