require('dotenv').config(); // this is important!
module.exports = {
    "development": {
        "username": process.env.DB_USERNAME || "Naren",
        "password": process.env.DB_PASSWORD || "admin",
        "database": process.env.DB_DATABASE || "manage_contacts",
        "host": process.env.DB_HOST || "127.0.0.1",
        "dialect": "postgres"
    },
    "test": {
        "username": process.env.DB_USERNAME || "Naren",
        "password": process.env.DB_PASSWORD || "admin",
        "database": process.env.DB_DATABASE || "manage_contacts",
        "host": process.env.DB_HOST || "127.0.0.1",
        "dialect": "postgres"
    },
    "production": {
        "username": process.env.DB_USERNAME || "Naren",
        "password": process.env.DB_PASSWORD || "admin",
        "database": process.env.DB_DATABASE || "manage_contacts",
        "host": process.env.DB_HOST || "127.0.0.1",
        "dialect": "postgres"
    }
};
