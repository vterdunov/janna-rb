require 'slack-notifier'

# @example
#   Slaker.instance.notify(text)
class Slacker
  include Singleton

  attr_reader :webhook_url, :default_channel, :bot_username, :icon_url

  def initialize
    @webhook_url = ENV['SLACK_WEBHOOK_URL']
    @default_channel = ENV['SLACK_CHANNEL']
    @bot_username = ENV['SLACK_BOT_USERNAME']
    @icon_url = 'http://vignette1.wikia.nocookie.net/leagueoflegends/images/b/b0/JannaSquare_old2.png'
  end

  COLOR = {
    'info' => '#4f8fff',
    'good' => 'good',
    'error' => 'danger'
  }

  # Sends notification to slack
  # @param msg [Hash] The hash of parameters to send
  def notify(text, message_to = nil, message_level = 'info')
    attachment = { color: COLOR[message_level], mrkdwn_in: ['text'] }
    sender.post(text: text, attachments: [attachment])
  end

  private

  def sender(message_to)
    Slack::Notifier.new(webhook_url, channel: message_to || default_channel,
                                     username: bot_username, icon_url: icon_url)
  end
end

$slaker = Slacker.instance
