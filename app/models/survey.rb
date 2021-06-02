class Survey < ApplicationRecord
  belongs_to :user
  has_many :questions
  accepts_nested_attributes_for :questions


  has_many :answers, through: :questions
  accepts_nested_attributes_for :answers

  has_many :user_answers, through: :answers


  validates :content, presence: true
  validates :name, presence: true

  def response_number
    responses =  self.user_answers.distinct.count("user_id")
    return responses
  end

  def response_rate
    responses = self.response_number
    rate = responses.to_f / User.all.count * 100
    rate.to_i
  end

  def average_response(category)
    responses = self.user_answers.all
    total = 0
    count = 0
      responses.each do |response|
        if response.answer.question.category == category
          total += response.content.to_i
          count += 1
        end
      end
      (total.to_f / count).round(2)
  end
end
