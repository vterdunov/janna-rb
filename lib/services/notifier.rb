require 'slack-notifier'

# Provides notifications
class Notifier
  def initialize
    @slack = Slack::Notifier.new ENV['SLACK_WEBHOOK_URL'],
                                 channel: ENV['SLACK_CHANNEL'],
                                 username: ENV['SLACK_BOT_USERNAME'],
                                 icon_url: 'http://vignette1.wikia.nocookie.net/leagueoflegends/images/b/b0/JannaSquare_old2.png'
  end

  # Sends notification to slack
  def slack(msg)
    @slack.ping(msg)
  end
end
