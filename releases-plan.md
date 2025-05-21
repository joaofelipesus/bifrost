# Features to implement:

## V0.1

Clone and start a project using SQLite3 and a fixed port for each application.

### Clone Github project

Clone a project into a ignored folder using a github token present in the ENV.
  - [x] add Git lib which will clone a repo from github;
  - [x] add to README.md that support only projects which production db is SQLite3;
  - [x] ignore .env file with github token, add to README env var name;
  - [x] clone project:
    - [x] use solid queue to clone the project in background using Github wrapper;
    - [x] display clone repository clone status on view show.

### Setup project

What must be done to start a project?
  - [x] save project server port used;
  - [x] build image
  - [x] start rails server in a specific port; (continue)
  - [x] create database;
  - [x] run pending migrations;
  - [x] copy ssl direectory;
  - [x] add needed configs to the README.md;
  - [x] add script that install app in production;
    - generate .env;
    - generate ssl vertificates.

### Project env vars:
  - [x] save ENV vars top integrate with external services like amazon S3 or rollbar;
      - if rails detect the env var used to connect to database DATABASE_URL it ignore the database.yml config.

### Deploy project:
  - [x] stop project;
  - [x] update repo;
  - [x] pull new changes;
  - [x] run migrations;
  - [x] start app again.

### Review layout:
  - [x] add dark mode support;
  - [x] review CSS base classes;
  - [x] extract helpers.

---

## V0.2

### Hide env vars
  - [ ] hide env variables and display on button click;

### Review views routes
  - [ ] make new env var nested to project.

### Integrate project to aws S3

Save backups from time to time into the cloud.
  - [ ] config S3 env vars;
  - [ ] config active storage;
  - [ ] manage servicve to have up to five backups;
  - [ ] add button to generate new backup.

### Use a custom domain for each app

Use nginx-proxy to use a custom domain for each application.
  - [ ] set domain in project model?
  - [ ] how to config nginx-proxy to run projects that isn't on dockerfile? Maybe generate a dockerfile?
  - [ ] generate ssl ceritficate? rails apps force ssl;
  - [ ] use thruster or nginx.

---

## V0.3

### Integrate backgound jobs

Use solid-queue to manage cron tasks for each app:
  - [ ] add support to create a cron-task for a app;
  - [ ] generate backups based on a date interval.

### Secure admin dashboard

Use rails native authentication to protect admin dashboard view:
  - [ ] add password protection on admin dashboard.

### Run rails console commands
  - [ ] run rails command;
  - [ ] run rails seed;

---

## V1.0

### Deploy app using kamal-2

Configure kamal-2 to deploy new versions on server.

---

## 1.X

  - support elixir apps;
  - add "add on" configuration, use a file with the formula or add it using a crud?
  - support telegram configuration;
  - use postgres as main db;
  - add authentication support;
  - run docker inside docker in development?
  - usar ujm servidor git? Bit book chapter five;
  - generate and import backup;
