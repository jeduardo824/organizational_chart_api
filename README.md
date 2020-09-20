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
4. Copy the database configuration file with `cp config/database.yml.sample database.yml`.
6. If you don't have `bundler` installed, please do with `gem install bundler`.
7. If you don't have `foreman` installed, please do with `gem install foreman`.
8. Run `bundle install` to install the necessary gems.
9. After this, you can set up your local database with `bundle exec rails db:setup`.
10. You should be ready to run your local server with `foreman start -f Procfile.dev`.

## Docker Usage

1. Clone the project:
    `git clone https://github.com/jeduardo824/organizational_chart_api`
2. Open a Terminal window inside the folder that you downloaded the project.
3. You need to have Docker installed and running to use this method. You can find information about how to install Docker [here](https://docs.docker.com/get-docker/)
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

## API Documentation
- The root of the API is configured to redirect to ___"api/v1/companies#index"___
### Company:
#### POST /api/v1/companies
- Action: ___api/v1/companies#create___
- Required fields:
	- ___name___ (String)
- Optional fields:
	- ___collaborators_attributes___ (Array of collaborators attributes)
- Request body:
	1. Without nested collaborators:
	```json
	{
		"company": {
			"name": "Company Name"
		}
    }
	```
	2. With nested collaborators:
	```json
	{
		"company": {
			"name": "Company Name",
			"collaborators_attributes": [
				{ "name": "Collab 1", "email": "collab1@example.com" },
				{ "name": "Collab 2", "email": "collab2@example.com" },
				{ "name": "Collab 3", "email": "collab3@example.com" }
			]
		}
    }
	```
- Expected response:
	```json
	{
		"id": "26cfa903-28d9-4657-9674-e8cffb9b7dd7",
		"name": "Company Name",
		"collaborators": [...]
	}		
	```
- Success status: ___201 Created___
- Error status: ___422 Unprocessable Entity___

#### GET /api/v1/companies
- Action: ___api/v1/companies#index___
- Expected response:
	```json
	[
		{
			"id": "06df2259-e9de-4e29-9524-f372e1d22e99",
			"name": "Company 1"
		},
		{
			"id": "26cfa903-28d9-4657-9674-e8cffb9b7dd7",
			"name": "Company 2"
		}
	]
	```
- Success status: ___200 OK___

#### GET /api/v1/companies/:company_uuid
- Action: ___api/v1/companies#show___
- Expected response:
	```json
	{
		"id": "06df2259-e9de-4e29-9524-f372e1d22e99",
		"name": "Company 1",
		"collaborators": [
			{
				"id": "ff4ffb2a-9b6f-41a7-b999-ae6c55cfd98b",
				"name": "Collab 1",
				"email": "collab1@example.com",
				"manager_id": null
			},
			{
				"id": "f2970fbd-a2fa-4e0b-a033-1b1be2c1ad7f",
				"name": "Collab 2",
				"email": "collab2@example.com",
				"manager_id": "ff4ffb2a-9b6f-41a7-b999-ae6c55cfd98b"			
			}
		]
	}
	```
- Success status: ___200 OK___
- Error status: ___404 Not Found___

### Collaborator:
#### POST /api/v1/companies/:company_uuid/collaborators
- Action: ___api/v1/collaborators#create___
- Required fields:
	- ___name___ (String)
	- ___email___ (String)
- Request body:
	```json
	{
		"collaborator": {
			"name": "Collab 1",
			"email": "collab1@example.com"
		}
    }
	```
- Expected response:
	```json
	{
		"id": "eedd4f11-8ccb-4ede-adb2-d9d8291efc52",
		"name": "Collab 1",
		"email": "collab1@example.com",
		"manager_id": null,
		"company_id": "26cfa903-28d9-4657-9674-e8cffb9b7dd7"
	}		
	```
- Success status: ___201 Created___
- Error status #1: ___422 Unprocessable Entity___
- Error status #2: ___404 Not Found___ when company is not found

#### GET /api/v1/companies/:company_uuid/collaborators
- Action: ___api/v1/collaborators#index___
- Expected response:
	```json
	[
		{
			"id": "ff4ffb2a-9b6f-41a7-b999-ae6c55cfd98b",
			"name": "Collab 1",
			"email": "collab1@example.com",
			"manager_id": null,
			"company_id": "26cfa903-28d9-4657-9674-e8cffb9b7dd7"
		},
		{
			"id": "f2970fbd-a2fa-4e0b-a033-1b1be2c1ad7f",
			"name": "Collab 2",
			"email": "collab2@example.com",
			"manager_id": null,
			"company_id": "26cfa903-28d9-4657-9674-e8cffb9b7dd7"
		}
	]
	```
- Success status: ___200 OK___ 
- Error status: ___404 Not Found___ when company is not found

#### DELETE /api/v1/collaborators/:collaborator_uuid
- Action: ___api/v1/collaborators#destroy___
- Expected response:
	```json
	{
		"id": "eedd4f11-8ccb-4ede-adb2-d9d8291efc52",
		"name": "Collab 1",
		"email": "collab1@example.com",
		"manager_id": null,
		"company_id": "26cfa903-28d9-4657-9674-e8cffb9b7dd7"
	}		
	```
- Success status: ___200 OK___ 
- Error status: ___404 Not Found___

#### PUT/PATCH /api/v1/collaborators/:collaborator_uuid
- Action: ___api/v1/collaborators#update___
- Required fields:
	- ___manager_id___ (String)
- Request body:
	```json
	{
		"manager_id": "f2970fbd-a2fa-4e0b-a033-1b1be2c1ad7f"
    }
	```
- Expected response:
	```json
	{
		"id": "eedd4f11-8ccb-4ede-adb2-d9d8291efc52",
		"name": "Collab 1",
		"email": "collab1@example.com",
		"manager_id": "f2970fbd-a2fa-4e0b-a033-1b1be2c1ad7f",
		"company_id": "26cfa903-28d9-4657-9674-e8cffb9b7dd7"
	}
	```
- Success status: ___200 OK___ 
- Error status #1: ___404 Not Found___ when collaborator or manager is not found
- Error status #2: ___422 Unprocessable Entity___

#### GET /api/v1/collaborators/:collaborator_uuid
- Action: ___api/v1/collaborators#show___
- Query parameters:
	- ___info_type___ (String -> [peers, managed, second_level_managed])
- Expected response:
	```json
	[
		{
			"id": "ff4ffb2a-9b6f-41a7-b999-ae6c55cfd98b",
			"name": "Collab 1",
			"email": "collab1@example.com",
			"manager_id": "f2970fbd-a2fa-4e0b-a033-1b1be2c1ad7f",
			"company_id": "26cfa903-28d9-4657-9674-e8cffb9b7dd7"
		},
		{
			"id": "f2970fbd-a2fa-4e0b-a033-1b1be2c1ad7f",
			"name": "Collab 2",
			"email": "collab2@example.com",
			"manager_id": "f2970fbd-a2fa-4e0b-a033-1b1be2c1ad7f",
			"company_id": "26cfa903-28d9-4657-9674-e8cffb9b7dd7"
		}
	]
	```
- Success status: ___200 OK___ 
- Error status #1: ___404 Not Found___
- Error status #2: ___400 Bad Request___ when information type does not exist
