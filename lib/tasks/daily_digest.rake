desc 'Launched by crontab -e, send a daily digest of recent activities.'
task :daily_digest => :environment do
  # At 1am every week day, in production mode, for users who have "daily digest" email notification selected
  User.current.each do |user|
    if user.digest_sheets_created.size > 0
      UserMailer.daily_digest(user).deliver if Rails.env.production? and user.email_on?(:daily_digest) and (1..5).include?(Date.today.wday)
    end
  end
end
