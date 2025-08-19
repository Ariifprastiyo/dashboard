# Job Scheduler Documentation

## Overview

The Mediarumu Dashboard uses **GoodJob** as its background job processing system, replacing the previous Sidekiq implementation. GoodJob is a multithreaded, Postgres-based job backend for Ruby on Rails that provides reliable job execution with built-in scheduling capabilities.

## Architecture

### GoodJob Configuration

The job scheduler is configured in `config/initializers/good_job.rb` with the following key settings:

```ruby
config.good_job = {
  preserve_job_records: true,        # Keep job records in database
  retry_on_unhandled_error: false,   # Don't retry on unhandled errors
  on_thread_error: -> (exception) { Rails.error.report(exception) },
  execution_mode: :external,         # Run jobs in external process
  queues: '*',                       # Process all queues
  max_threads: 5,                    # Maximum 5 concurrent threads
  poll_interval: 30,                 # Poll for new jobs every 30 seconds
  shutdown_timeout: 25,              # Graceful shutdown timeout
  enable_cron: true,                 # Enable cron-based scheduling
  # ... cron configuration
}
```

### Fly.io Deployment

The application runs on Fly.io with two main processes:

1. **Web Process**: `bundle exec puma -C config/puma.rb`
2. **Worker Process**: `bundle exec good_job --max-threads=3`

The worker process is configured in `fly.toml`:
```toml
[processes]
  web = "bundle exec puma -C config/puma.rb"
  worker = "bundle exec good_job --max-threads=3"
```

## Scheduled Jobs

### 1. Publication Daily Updater (`publication_daily_updater`)

**Schedule**: `0 3 * * *` (Daily at 3:00 AM)
**Class**: `SocialMediaPublicationsDailyUpdaterJob`

**Purpose**: Updates social media publication metrics on a daily basis.

**How it works**:
- Finds all social media publications that need daily sync updates
- Spawns individual `SocialMediaPublicationDailySyncJob` for each publication
- Uses individual processing to avoid overwhelming external APIs

**Key Features**:
- Rate limiting: 2 jobs per second to respect API limits
- Individual processing for better error isolation
- Automatic retry mechanism for failed publications

### 2. Social Media Account Updater (`social_media_account_updater`)

**Schedule**: `0 0 1 1 *` (Yearly on January 1st at midnight)
**Class**: `SocialMediaAccountUpdaterJob`

**Purpose**: Updates social media account data and metrics.

**How it works**:
- Finds accounts that haven't been synced in the last 24 hours
- Processes accounts in batches of 500
- Spawns individual `SingleSocialMediaAccountUpdaterJob` for each account
- Optionally recalculates media plan metrics

**Key Features**:
- Batch processing for efficiency
- Individual job spawning for better error handling
- Automatic metric recalculation

## Job Categories

### Social Media Publication Jobs

#### `SocialMediaPublicationsDailyUpdaterJob`
- **Purpose**: Orchestrates daily updates for all publications
- **Queue**: `default`
- **Behavior**: Spawns individual sync jobs for each publication

#### `SocialMediaPublicationDailySyncJob`
- **Purpose**: Syncs individual publication daily metrics
- **Queue**: `default`
- **Concurrency**: Rate limited to 2 jobs per second
- **Features**: Uses GoodJob concurrency control to respect API limits

#### `SocialMediaPublicationUpdaterJob`
- **Purpose**: Batch updates publications (alternative to individual processing)
- **Queue**: `default`
- **Note**: Only one of this or `SocialMediaPublicationsDailyUpdaterJob` should be active

#### `SingleSocialMediaPublicationUpdaterJob`
- **Purpose**: Updates a single publication with force flag
- **Queue**: `default`
- **Use Case**: Manual updates or retry scenarios

### Social Media Account Jobs

#### `SocialMediaAccountUpdaterJob`
- **Purpose**: Orchestrates account updates
- **Queue**: `default`
- **Behavior**: Finds stale accounts and spawns individual updater jobs

#### `SingleSocialMediaAccountUpdaterJob`
- **Purpose**: Updates individual social media account data
- **Queue**: `default`
- **Features**: Fetches and populates social media data, optionally recalculates metrics

### Comment Processing Jobs

#### `CreateMediaCommentsAndPublicationHistoryForInstagramJob`
- **Purpose**: Fetches and stores Instagram comments and publication history
- **Queue**: `default`
- **Features**:
  - Fetches up to 50 comments per publication
  - Uses cursor-based pagination
  - Creates publication history records
  - Handles rate limiting with max 5 attempts

#### `CreateMediaCommentsAndPublicationHistoryForTiktokJob`
- **Purpose**: Fetches and stores TikTok comments and publication history
- **Queue**: `default`
- **Concurrency**: Rate limited to 2 jobs per second
- **Features**:
  - Fetches up to 300 comments per publication
  - Handles duplicate comment detection
  - Creates publication history records
  - Supports reply comment processing

#### `CreateMediaCommentsFromReplyForTikTokJob`
- **Purpose**: Fetches reply comments for TikTok posts
- **Queue**: `default`
- **Features**: Uses TikapiCommentReplyService for reply processing

### Analytics and AI Jobs


#### `GenerateMediaCommentEmbeddingJob`
- **Purpose**: Generates AI embedding for individual media comments
- **Queue**: `default`
- **Features**: Single comment embedding generation

#### `ProcessSocialMediaAccountAnalyticJob`
- **Purpose**: Processes analytics for social media accounts
- **Queue**: `default`
- **Features**: Fetches comments and clusters them for analysis

### Bulk Processing Jobs

#### `BulkInfluencerJob`
- **Purpose**: Processes bulk influencer imports from Excel files
- **Queue**: `default`
- **Features**:
  - Reads Excel files with 'MASTER' sheet
  - Uses BulkInfluencerService for processing
  - Discards on StandardError

#### `BulkPublicationJob`
- **Purpose**: Processes bulk publication imports from Excel files
- **Queue**: `default`
- **Features**:
  - Reads Excel files with 'template' sheet
  - Uses BulkPublicationService for processing
  - Campaign-specific processing

#### `BulkMarkupSellPriceJob`
- **Purpose**: Calculates sell prices with markup percentages
- **Queue**: `default`
- **Features**: Processes scope of work items with percentage-based markup

### Cancellation Jobs

#### `CancelBulkInfluencerJob`
- **Purpose**: Handles cancellation of bulk influencer jobs
- **Queue**: `default`
- **Features**: Marks bulk influencer as cancelled

#### `CancelBulkPublicationJob`
- **Purpose**: Handles cancellation of bulk publication jobs
- **Queue**: `default`
- **Features**: Marks bulk publication as cancelled

### Utility Jobs

#### `RecalculateMediaPlanMetricJob`
- **Purpose**: Recalculates metrics for media plans
- **Queue**: `default`
- **Features**: Triggers metric recalculation for specific media plans

#### `ManualSyncMediaCommentCounterJob`
- **Purpose**: Manually syncs media comment counters
- **Queue**: `manual_sync_media_comments_counter`
- **Features**:
  - Fixes counter culture counts
  - Updates publication history with current counts

#### `ManuallySyncCampaignCrbMetricJob`
- **Purpose**: Manually syncs campaign CRB (Comment Related to Brand) metrics
- **Queue**: `manual_sync_media_comments_counter`
- **Features**:
  - Syncs brand-related flags for unreviewed comments
  - Fixes counter culture counts

## Job Execution Flow

### Daily Publication Updates
1. `SocialMediaPublicationsDailyUpdaterJob` runs at 3:00 AM
2. Finds publications needing daily sync
3. Spawns `SocialMediaPublicationDailySyncJob` for each publication
4. Each sync job updates metrics with rate limiting (2/sec)

### Account Updates
1. `SocialMediaAccountUpdaterJob` runs yearly on January 1st
2. Finds accounts not synced in 24 hours
3. Spawns `SingleSocialMediaAccountUpdaterJob` for each account
4. Each account job fetches fresh data and optionally recalculates metrics

### Comment Processing
1. Triggered manually or by other jobs
2. `CreateMediaCommentsAndPublicationHistoryForInstagramJob` or `CreateMediaCommentsAndPublicationHistoryForTiktokJob`
3. Fetches comments with pagination and rate limiting
4. Creates publication history records
5. Optionally triggers embedding generation

## Monitoring and Error Handling

### Error Reporting
- All unhandled errors are reported to Sentry via `Rails.error.report`
- Jobs can capture specific errors and report them to Sentry
- Failed jobs are preserved in the database for inspection

### Concurrency Control
- Rate limiting prevents API abuse (2 jobs/second for TikTok/Instagram)
- Max 5 threads in development, 3 threads in production
- GoodJob handles thread management and job distribution

### Job Persistence
- All job records are preserved in the database
- Failed jobs can be inspected and retried
- Job history is maintained for debugging

## Deployment Considerations

### Fly.io Configuration
- Worker process runs with 3 threads maximum
- Separate from web process for better resource isolation
- Automatic scaling based on load

### Database Requirements
- GoodJob requires PostgreSQL
- Job tables are automatically created via migrations
- Job records are preserved for monitoring

### Environment Variables
- All API keys and endpoints are configured via environment variables
- Sentry DSN for error reporting
- New Relic for performance monitoring

## Best Practices

1. **Rate Limiting**: Always respect external API limits
2. **Error Handling**: Capture and report errors appropriately
3. **Resource Management**: Use batch processing for large datasets
4. **Monitoring**: Monitor job queues and failure rates
5. **Testing**: Test jobs in isolation before deployment

## Troubleshooting

### Common Issues
1. **Job Failures**: Check Sentry for error details
2. **Rate Limiting**: Monitor API response codes
3. **Memory Issues**: Adjust thread count if needed
4. **Database Locks**: Monitor for deadlock situations

### Debugging Commands
```bash
# Check job status
bundle exec rails good_job:status

# View job dashboard
bundle exec rails good_job:install

# Retry failed jobs
bundle exec rails good_job:retry
```

This documentation provides a comprehensive overview of the job scheduling system used in the Mediarumu Dashboard application. 