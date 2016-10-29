require 'sinatra/base'

module ApplicationHelper
  def send_slack_notify(msg)
    notifier = Slack::Notifier.new settings.slack_webhook_url,
                                   channel: settings.slack_channel,
                                   username: settings.slack_bot_username,
                                   icon_url: 'http://vignette1.wikia.nocookie.net/leagueoflegends/images/b/b0/JannaSquare_old2.png'

    notifier.ping msg
  end
end
