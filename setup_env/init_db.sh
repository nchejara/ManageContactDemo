#!/bin/bash

sudo -u postgres psql -c "CREATE ROLE ""Naren"" WITH LOGIN NOSUPERUSER CREATEDB NOCREATEROLE INHERIT NOREPLICATION CONNECTION LIMIT 1 PASSWORD 'admin';"
sudo -u postgres psql -c "GRANT postgres TO ""Naren"" WITH ADMIN OPTION;"
sudo -u postgres psql -c "CREATE DATABASE ""manage_contacts"" WITH OWNER = ""Naren"" ENCODING = 'UTF8' CONNECTION LIMIT = 10;"