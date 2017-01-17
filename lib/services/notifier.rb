require 'slack-notifier'

# Provides notifications
#
# @example
#   connection_options = { message_to: '@Caitlyn' }
#   slack_sender = Notifier.new(slack_connection)
#   slack_sender.slack('I will save you.')
class Notifier
  def initialize(args = {})
    @args = args
  end

  # Sends notification to slack
  # @param msg [Hash] The hash of parameters to send
  def slack(args)
    text  = args[:text]
    case args[:message_level]
    when 'info'
      color = '#4f8fff'
    when 'good'
      color = 'good'
    when 'error'
      color = 'danger'
    else
      color = '#4f8fff'
    end
    slack_defaults.post(attachments: [text: text, color: color, mrkdwn_in: ['text']])
  end

  private

  def slack_defaults
    Slack::Notifier.new ENV['SLACK_WEBHOOK_URL'],
                        channel: @args[:message_to] || ENV['SLACK_CHANNEL'],
                        username: ENV['SLACK_BOT_USERNAME'],
                        icon_url: 'http://vignette1.wikia.nocookie.net/leagueoflegends/images/b/b0/JannaSquare_old2.png'
  end
end
