-- ============================================================
-- YZM 2126 - Sinav Takvim Yonetim Sistemi
-- 01_CreateDatabase.sql
-- ============================================================
USE master;
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = N'SinavTakip')
BEGIN
    ALTER DATABASE SinavTakip SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE SinavTakip;
END
GO

CREATE DATABASE SinavTakip
    COLLATE Turkish_CI_AS;
GO

USE SinavTakip;
GO
