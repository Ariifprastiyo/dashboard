# README

## How to run this project

### Suppported OS for development

- MacOS
- Linux
- Windows using WSL2. **Running directly on Windows is not supported.**

### Ruby and Rails

- To install Ruby, we recommend using rbenv or asdf.
- Rails 8.0.1. Please refer to [Rails 8.0.1](https://guides.rubyonrails.org/v8.0.1.html) for more details.


### Required Software

1. PostgreSQL (WITH vector extension)
2. Redis (no-longer required as we moved to Good Job)
3. Libreoffice (brew install libreoffice)
4. libvips
5. Firefox or chromium driver(for headless testing)

```
bundle install
yarn install
rails db:create
rails db:migrate
rails db:seed
bin/dev
```

## Test

1. Rspec : Unit test
2. Capybara : Feature test using firefox headless

```
bundle exec rspec spec
```

## How to update ERD

```
bundle exec rake erd polymorphism=true notation=bachman filename='erd' exclude='ApplicationRecord,Record,Searchable,PgSearch::Document,ActiveStorage::Attachment,ActiveStorage::Blob,ActiveStorage::VariantRecord,ActiveStorage::Record,ActionMailbox::Record,ActionText::Record'
```

## Asynchronous Job Processing and Job Scheduling

Good Job is used for background job and cron job. Please refer to [Good Job](https://github.com/bensheldon/good_job) for more details.




### Notes for PostgreSQL Vector Extension

1. Install the vector extension:

```
CREATE EXTENSION vector;
```


### Notes for WSL2 development enviroment

1. Use Ubuntu
2. Install firefox from mozilla ppa team :

```
sudo add-apt-repository ppa:mozillateam/ppa

# Create a new file, it should be empty as it opens:
sudo gedit /etc/apt/preferences.d/mozillateamppa

# Insert these lines, then save and exit
Package: firefox*
Pin: release o=LP-PPA-mozillateam
Pin-Priority: 501

# after saving, do
sudo apt update
sudo apt install firefox # or firefox-esr

# install geckodriver
sudo apt install wget
wget https://github.com/mozilla/geckodriver/releases/download/v0.29.1/geckodriver-v0.29.1-linux64.tar.gz
tar -xf geckodriver-v0.29.1-linux64.tar.gz
sudo mv geckodriver /usr/local/bin/

```

# How to deploy

We are using fly.io and deploy it to multiple env. 

* MediaRumu => this is the main environment
`fly deploy`

# How manage the database in fly.io

* Check the [fly.io](https://fly.io/docs/postgres/managing/attach-detach/) postgres docs for more details.

* How to create postgres cluster in fly.io using using pgvector
`fly postgres create --volume-size 50 --image-ref flyjason/fly-pg-pgvector --name mediarumu-pgvector-cluster`

# How to dump the db
* create proxy to localhost `fly proxy 15432:5432 -a mediarumu-pgvector-cluster`
* then run `pg_dump -h localhost -p 15432 -U postgres -W -d mediarumu_dashboard_production -f "mediarumu_21_12_2024.sql"`

# How to clone the db

* Fork using fly commands https://fly.io/docs/postgres/managing/forking/. DO NOT FORGET TO Include the volume ID, otherwise data will not be copied.
* Detach old db if exisits and Attach to the app https://fly.io/docs/postgres/managing/attach-detach/
* Redploy the app
* Database backup is being done with the help of `fly pg backup` commands, and it stored to tigris.

# About Roles and Organizations

Initially we don't have organizations. But since we wan't to make it as some kind of Saas, we need to have organizations. So now `User` belongs to `Organization` and `Organization` has many `User`. We also have `Role` to manage the access control.

Basically MediaRumu is the owner of the systems. Therefore we assign MediaRumu admin as `super_admin`. The only difference between `super_admin` and `admin` is that `super_admin` can see all the resources from all the organizations. `admin` can only see the resources from the organization they belong to.

Along with that basic roles, we have another roles like `bd`, `finance` etc. For MediaRumu admins to work, they need `super_admin` role and other roles like `bd`, `finance` etc. Otherwise they can't visit a page they need to go.

For other organizations, they can have `admin` role and other roles like `bd`, `finance` etc.

All customer users need to be assigned to an organization. Otherwise they can't go anywhere.
Only `super_admin` can have no organization.