-- Runs once on first DB init, after 01-schema.sql has created the spiritunite database.
GRANT ALL PRIVILEGES ON spiritunite.* TO 'spiritunite'@'%';
FLUSH PRIVILEGES;
