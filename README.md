# ManageContactsDemo
A simple Web demo application

# Installation & start server


    $ npm install
    $ npm start


## Run sample test
    $ mocha -R spec test/home-spec.js
    //on windows
    //node_module\.bin\mocha -R spec test\home-spec.js


## Setup Database Manually
1. Create a Role
```
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

```
2. Create a database
```
CREATE DATABASE "manage_contacts" WITH 
    OWNER = "Naren" 
    ENCODING = 'UTF8' 
    CONNECTION LIMIT = 10;

```

## Create Tables using Sequelize
Run the following commands (Note: Do not forget to create a "Naren" Role or change the available role in the config file)
```
    npm install -g sequelize-cli
    sequelize db:create
    sequelize db:migrate

```

# Reference
