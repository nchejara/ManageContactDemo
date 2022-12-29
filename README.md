# ManageContactsDemo
A simple Web demo application

# Setup Application using Docker

Install Docker and docker-compose

    ```
        apt install docker.io -y
        apt install docker-compose -y

    ```

Update .env file in docker folder, Make sure DH_Host name set correctly


Build Application and launch containers usinf docker-compose
```
    docker-compose up -d
    // -d option used to run container in dettached mode 

```


# Manual Configuration 

## Setup Database
1. Install Postgres 

    ```
        sh ./setup_env/database.sh

    ```

2. Connect to psql

    ```
        sudo -u postgres psql

    ```

3. Create Role ( Run below snippet on psql prompt )

    ```
        CREATE ROLE "Naren" WITH
            LOGIN
            NOSUPERUSER
            CREATEDB
            NOCREATEROLE
            INHERIT
            NOREPLICATION
            CONNECTION LIMIT 10
            PASSWORD 'admin';
        GRANT postgres TO "Naren" WITH ADMIN OPTION;
    ```

4. Create database ( Run below snippet on psql prompt )

    ```
        CREATE DATABASE "manage_contacts" WITH 
        OWNER = "Naren" 
        ENCODING = 'UTF8' 
        CONNECTION LIMIT = 10;

    ```
    **note**: Run /l command on psql prompt to see list of database

# App Installation

1. Install Nodejs and npm

    ```
        sudo apt install nodejs npm

    ```
2. Instlal NPM Dependencies and start application
    ```
        export NODE_ENV=development
        export DB_USERNAME=<username>
        export DB_PASSWORD=<password>
        export DB_DATABASE=manage_contacts
        export DB_HOST=<docker host Machine IP>
        export DB_PORT=5432
        export PORT=3000

        sudo sh ./start.sh

    ```
## Run sample test
```
    export HOST=<application_host_IP>
    export PORT=3000
    sudo node_modules/mocha/bin/mocha -R spec tests/dummy-spec.js
    
    //on windows
    // npm install
    // set HOST=<application_host_IP>
    // set PORT-3000
    //node_module\.bin\mocha -R spec test\home-spec.js
```
