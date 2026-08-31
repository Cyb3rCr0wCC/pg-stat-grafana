-- Enable pg_stat_statements
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

-- Create a dedicated user for Grafana
CREATE USER grafana_reader
WITH PASSWORD 'change-this-grafana-password';

-- Allow Grafana to connect to the database
GRANT CONNECT ON DATABASE homelab TO grafana_reader;

-- Allow the user to access the public schema
GRANT USAGE ON SCHEMA public TO grafana_reader;


-- Function exposing pg_stat_statements
--
-- SECURITY DEFINER means this function executes with the
-- privileges of its owner rather than the caller.

CREATE OR REPLACE FUNCTION public.my_stat_statements()
RETURNS SETOF pg_stat_statements
LANGUAGE SQL
SECURITY DEFINER
SET search_path = public, pg_catalog
AS $$
    SELECT *
    FROM pg_stat_statements;
$$;


-- Only allow Grafana to execute this function
GRANT EXECUTE
ON FUNCTION public.my_stat_statements()
TO grafana_reader;


-- Make sure nobody can accidentally execute this as PUBLIC
REVOKE EXECUTE
ON FUNCTION public.my_stat_statements()
FROM PUBLIC;