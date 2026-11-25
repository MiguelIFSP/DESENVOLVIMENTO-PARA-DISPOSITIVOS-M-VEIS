CREATE DATABASE IF NOT EXISTS atividades_db
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE atividades_db;

CREATE TABLE IF NOT EXISTS activities (
  id INT AUTO_INCREMENT PRIMARY KEY,
  activity_date DATE NOT NULL,
  description TEXT NOT NULL,
  INDEX idx_activities_activity_date (activity_date)
);
