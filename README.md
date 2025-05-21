# Bifrost

Bifrost is a web app that make simple to deploy rails apps into a local network environment, it uses `Docker` to msnsge the applications.

#### Motivation

The motivation to build it was because I have some simple apps that I've builded over the yeaers and don't wan't to spend money to host them in a PaaS.

#### Why Bifrost?

Bifrost is a deity who protects the Bifrost bridge that connects Asgard to Midgard, and this app aims to act between you and the deployment of your app.

## Setup

In order to the project be able to clone and pull code from github it is required to exist a env var with the name **GITHUB_TOKEN** with the github access token, it is important that you limit the access to this token and don't share it. Also it is required to have `docker` and `docker compose` installed in the host system.

Once you clone the repository and install the used `Ruby` version run the script `./script/setup-env` to generate a `.env` file withe the secrets used by the app and to generate the SSL cvertificates to run apps using HTTPS. In the future versions is planned to use a Docker image also to run bifrost application, but for now it is recommended to use [mise](https://mise.jdx.dev/) to install ruby.

The current environment vars used for bifrost are:
- GITHUB_TOKEN: token used to clone and pull apps from Github;
- POSTGRES_USER: the user for the postgress used by bifrost to config managed apps Database connection;
- POSTGRES_PASSWORD: the password for the postgress used by bifrost to config managed apps Database connection;

### SSL certificates

In order to run a rails app in production SSL must be configured, to run a project you must add the following configs to the file `config/puma.rb`.

Add ssl bind to port `3001`, so `bifrost` manage the binding from port `3001` from app web container to a external port making only HTTPS requests aviable and avoiding the need for a reverse proxy service for now.

Paste the following config in the end of `config/puma.rb`.

```Ruby
# Bind SSL port to deploy app on self hosted environment.
ssl_bind '0.0.0.0', '3001', {
  key: 'config/ssl/server.key',
  cert: 'config/ssl/server.crt',
  verify_mode: 'none'
}
```

### Services

Bifrost uses a **PostgreSQL** container declared in the `docker-compose.yml` file to save data of hosted apps, so the port `5432` must be available. Also, a `metabase` container is declared that is available on port `3100`, so you can browse your data easily once you set up the connection to your apps using the same user and password of PostgreSQL.

---

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version 3.3.6

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
