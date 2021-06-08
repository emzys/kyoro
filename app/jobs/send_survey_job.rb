class SendSurveyJob < ApplicationJob
  queue_as :default

  # def perform(*args)
  #   puts "I'm starting the fake job"
  #   sleep 3
  #   puts "OK I'm done now"
  # end
  def perform(survey)
    sleep 3
      survey.questions.each do |question|
        answer = Answer.new(
          content: (1..5).to_a,
          category: "Multiple Choice"
        )
        answer.question = question
        answer.save
      end


     SendSlackMessageService.new(
        token: ENV['SLACK_TOKEN'],
        channel: 'C023NB3DQKX',
        message: build_message(survey)
      ).call
    end

  def build_message(survey)
    message = [
      {
        "type": "section",
        "block_id": "survey-#{survey.id}",
        "text": {
          "type": "plain_text",
          "text": survey.name,
          "emoji": true
        }
      }
    ]
    survey.questions.each do |question|
      message << {
        "type": "input",
        "element": {
          "type": "static_select",
          "placeholder": {
            "type": "plain_text",
            "text": "1-5",
            "emoji": true
          },
          "options": [
            {
              "text": {
                "type": "plain_text",
                "text": "1",
                "emoji": true
              },
              "value": { :question_id => question.id, :question_category => question.category, :answer_value => 1 }.to_json
            },
            {
              "text": {
                "type": "plain_text",
                "text": "2",
                "emoji": true
              },
               "value": ({ question_id: question.id, :question_category => question.category, :answer_value => 2}).to_json
            },
            {
              "text": {
                "type": "plain_text",
                "text": "3",
                "emoji": true
              },
              "value": { question_id: question.id, :question_category => question.category, :answer_value => 3}.to_json
            },
            {
              "text": {
                "type": "plain_text",
                "text": "4",
                "emoji": true
              },
              "value": { question_id: question.id, :question_category => question.category, :answer_value => 4}.to_json
            },
            {
              "text": {
                "type": "plain_text",
                "text": "5",
                "emoji": true
              },
              "value": { question_id: question.id, :question_category => question.category, :answer_value => 5}.to_json
            }
          ],
          "action_id": "static_select-action"
        },
        "label": {
          "type": "plain_text",
          "text": question.content,
          "emoji": true
        }
      }
    end
    message << {
      "type": "actions",
      "elements": [
        {
          "type": "button",
          "text": {
            "type": "plain_text",
            "text": "Submit",
            "emoji": true
          },
          "value": "click_me_123",
          "action_id": "actionId-0"
        }
      ]
    }
    return message
  end
end
class SendSlackMessageService
  attr_reader :channel, :message, :token

  def initialize(attributes)
    @channel = attributes[:channel]
    @message = attributes[:message]
    @token = attributes[:token]
  end

  def call
    response = HTTParty.post(
      'https://slack.com/api/chat.postMessage',
      body: {
        channel: channel,
        blocks: message
      }.to_json,
      headers: {
        'Content-Type' => 'application/json',
        'Authorization' => ('Bearer ' + token)
      }
    )
    p response

  end
end