require 'sinatra/base'

module ApplicationHelper
  def send_slack_notify(msg)
    notifier = Slack::Notifier.new ENV['SLACK_WEBHOOK_URL'],
                                   channel: ENV['SLACK_CHANNEL'],
                                   username: ENV['SLACK_BOT_USERNAME'],
                                   icon_url: 'http://vignette1.wikia.nocookie.net/leagueoflegends/images/b/b0/JannaSquare_old2.png'

    notifier.ping msg
  end
end
