# ManageContactsDemo
A simple Web demo application

# Setup Application using Docker

Install Docker and docker-compose

Export Database and application environments Variables
```
    export NODE_ENV=development
    export DB_USERNAME=<username>
    export DB_PASSWORD=<password>
    export DB_DATABASE=manage_contacts
    export DB_HOST=<docker host Machine IP>
    export DB_PORT=5432
    export PORT=3000

```

Build Application and launch containers usinf docker-compose
```
    docker-compose up -d
    // -d option will help to run container in dettached mode 

```


# Manual Configuration 

Prepare database
```
    // Create Role
    CREATE ROLE "Naren" WITH
        LOGIN
        NOSUPERUSER
        CREATEDB
        NOCREATEROLE
        INHERIT
        NOREPLICATION
        CONNECTION LIMIT 10
        PASSWORD 'xxxxxx';
    GRANT postgres TO "Naren" WITH ADMIN OPTION;

    // Create Data base
    CREATE DATABASE "manage_contacts" WITH 
    OWNER = "Naren" 
    ENCODING = 'UTF8' 
    CONNECTION LIMIT = 10;

```

Inarall NPM Dependencies
```
    npm install -g sequelize-cli
    npm install
    npm start

```
## Run sample test
```
    $ mocha -R spec test/home-spec.js
    //on windows
    //node_module\.bin\mocha -R spec test\home-spec.js
```
