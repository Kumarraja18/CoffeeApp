#!/bin/bash

# Brew & Co - Complete Startup Script

echo "========================================="
echo "  Brew & Co - Coffee Ordering Platform  "
echo "========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Step 1: Check if database exists
echo -e "${YELLOW}Step 1: Checking database...${NC}"
DB_EXISTS=$(sudo mysql -e "SHOW DATABASES LIKE 'brewco_db';" 2>/dev/null | grep brewco_db)

if [ -z "$DB_EXISTS" ]; then
    echo "Database doesn't exist. Creating brewco_db..."
    sudo mysql -e "CREATE DATABASE IF NOT EXISTS brewco_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    echo -e "${GREEN}✓ Database created successfully!${NC}"
else
    echo -e "${GREEN}✓ Database already exists!${NC}"
fi
echo ""

# Step 2: Start Backend
echo -e "${YELLOW}Step 2: Starting Spring Boot Backend...${NC}"
cd backend
echo "Building and running backend on http://localhost:8080"
mvn spring-boot:run &
BACKEND_PID=$!
cd ..
echo -e "${GREEN}✓ Backend started (PID: $BACKEND_PID)${NC}"
echo ""

# Wait a bit for backend to initialize
echo "Waiting 15 seconds for backend to initialize..."
sleep 15

# Step 3: Start Frontend
echo -e "${YELLOW}Step 3: Starting React Frontend...${NC}"
cd frontend
echo "Starting frontend on http://localhost:5173"
npm run dev &
FRONTEND_PID=$!
cd ..
echo -e "${GREEN}✓ Frontend started (PID: $FRONTEND_PID)${NC}"
echo ""

echo "========================================="
echo -e "${GREEN}✓ Application is running!${NC}"
echo "========================================="
echo ""
echo "Backend API:  http://localhost:8080"
echo "Frontend App: http://localhost:5173"
echo ""
echo "Press Ctrl+C to stop both servers"
echo ""

# Wait for both processes
wait $BACKEND_PID $FRONTEND_PID
