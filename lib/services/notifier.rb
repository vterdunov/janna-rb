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
  # @param msg [String] The message to send
  def slack(msg)
    slack = Slack::Notifier.new ENV['SLACK_WEBHOOK_URL'],
                                channel: @args[:message_to] || ENV['SLACK_CHANNEL'],
                                username: ENV['SLACK_BOT_USERNAME'],
                                icon_url: 'http://vignette1.wikia.nocookie.net/leagueoflegends/images/b/b0/JannaSquare_old2.png'

    slack.ping(msg)
  end
end
