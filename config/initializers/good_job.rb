# config/initializers/good_job.rb OR config/application.rb OR config/environments/{RAILS_ENV}.rb

Rails.application.configure do
  config.good_job = {
    preserve_job_records: true,
    retry_on_unhandled_error: false,
    on_thread_error: -> (exception) { Rails.error.report(exception) },
    execution_mode: :external,
    queues: '*',
    max_threads: 5,
    poll_interval: 30,
    shutdown_timeout: 25,
    enable_cron: true,
    cron: {
      publication_daily_updater: {
        cron: '0 3 * * *',
        class: 'SocialMediaPublicationsDailyUpdaterJob',
        description: 'Update individually, will spawn another job'
      },
      social_media_account_updater: {
        cron: '0 0 1 1 *',
        class: 'SocialMediaAccountUpdaterJob',
        description: 'Update individually, will spawn another job'
      },
    },
    dashboard_default_locale: :en,
  }
end

# From sidekiq schedule
# social_media_account_updater:
#   cron: "0 1 * * *"
#   class: "SocialMediaAccountUpdaterJob"
#   queue: default
#   status: "disabled"
#   description: "Track social media account performance"
# publication_daily_batch_updater:
#   cron: "0 3 * * *"
#   class: SocialMediaPublicationUpdaterJob
#   queue: default
#   status: "disabled"
#   description: "Update in batch"
# publication_daily_updater:
#   cron: "0 3 * * *"
#   class: "SocialMediaPublicationsDailyUpdaterJob"
#   queue: default
#   description: "Update individually, will spawn another job"
