- Dependecies:
1. PostgreSQL >= 9.3
2. Ruby 2.7.1

## Setup Your Local Environment

*NOTE:* If you wish to setup the project with Docker,
please check [Docker usage](#docker-usage) section

1. First, you need to have Postgres >= 9.3 installed and running.
You can obtain more information about those steps [here](https://www.postgresql.org/docs/12/tutorial-install.html)
2. You also need to have Ruby 2.7.1 installed. You can accomplish this in many ways, but the most famous are: [rbenv](https://github.com/rbenv/rbenv), [rvm](https://rvm.io/) and [asdf](https://github.com/asdf-vm/asdf)
3. Now, clone the project:
    `git clone https://github.com/jeduardo824/organizational_chart_api`
4. Open a Terminal window inside the folder that you downloaded the project.
5. If you don't have `bundler` installed, please do with `gem install bundler`.
6. If you don't have `foreman` installed, please do with `gem install foreman`.
7. Run `bundle install` to install the necessary gems.
8. After this, you can set up your local database with `bundle exec rails db:setup`.
9. You should be ready to run your local server with `foreman start -f Procfile.dev`.

## Docker Usage

1. Clone the project:
    `git clone https://github.com/jeduardo824/organizational_chart_api`
2. Open a Terminal window inside the folder that you downloaded the project.
3. You need to have Docker installed and running to use it.
4. Run `./setup_dev`
5. When the process finishes, `docker-compose up` should work to have your local environment running.

## Common Issues

1. Problems with Database:
    Inside `config`, check the file `database.yml` and ensure that configurations like host and port are accordingly with your Postgres
2. Problems with `./setup_dev`:
    Check if you have the permissions to run the script. You can do that with `chmod +x setup_dev`

## Heroku

1. The application is also hosted in Heroku if you don't want to install it locally.
   You can access it on: https://organizational-chart-api.herokuapp.com/

## Tests

You can run the tests with `bundle exec rspec`. If you are using Docker, you should run `docker-compose run --rm bundle exec rspec`.