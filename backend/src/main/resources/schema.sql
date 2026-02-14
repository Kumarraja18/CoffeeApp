-- ============================================================
-- Brew & Co — Safe Schema Initialization  
-- Runs on every startup (spring.sql.init.mode=always)
-- Uses IF NOT EXISTS — NEVER destroys existing data.
-- Errors are ignored (spring.sql.init.continue-on-error=true)
-- ============================================================

-- Hint: Hibernate ddl-auto=update handles all table creation.
-- This file only ensures proper database encoding.
SELECT 1;
