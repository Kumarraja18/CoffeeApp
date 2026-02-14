#!/bin/bash

# Setup script for Brew & Co database

echo "Setting up brewco_db database..."

# Create the database
sudo mysql -e "CREATE DATABASE IF NOT EXISTS brewco_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

# Verify database was created
sudo mysql -e "SHOW DATABASES LIKE 'brewco_db';"

echo "Database setup complete!"
echo "The Spring Boot application will automatically create the tables when it starts."
