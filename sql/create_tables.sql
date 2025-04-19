-- create_shipsmart_db.sql

-- 1. Create the user (replace 'your_strong_password' with a real password)
CREATE USER shipsmart WITH PASSWORD 'password123';

-- 2. Create the database owned by that user
CREATE DATABASE shipsmart OWNER shipsmart;

