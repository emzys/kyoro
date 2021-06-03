class UserAnswer < ApplicationRecord
  belongs_to :answer, optional: true
  belongs_to :user, optional: true
  enum status: [:unresolved, :resolved]

  # validates :category, inclusion: { in: ['feedback', 'survey_response'], message: "%{value} is not a valid category" }

    def self.overall(category)
      feeling = 0
      count = 0
      UserAnswer.where("response_date >= ?", (Date.today - 30)).each do |answer|
        if  answer.category != "feedback" && answer.answer.question.category == category
          feeling += answer.answer_score
          count += 1
        end
      end
      ((feeling.to_f/count)*20).to_i
    end
  end


