-- ============================================================
-- 19_yedekAlFix.sql
-- sp_YedekAl'dan COMPRESSION kaldirildi.
-- SQL Server Express BACKUP WITH COMPRESSION desteklemiyor.
--
-- CALISTIRMA: Mevcut veritabaninda calistir.
-- ============================================================
USE SinavTakip;
GO

ALTER PROCEDURE dbo.sp_YedekAl
    @YedekKlasor NVARCHAR(500) = N'C:\Yedekler'
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @DosyaAdi NVARCHAR(600);
    DECLARE @SQL      NVARCHAR(800);

    SET @DosyaAdi = @YedekKlasor + N'\SinavTakip_' +
                    FORMAT(GETDATE(), 'yyyyMMdd_HHmmss') + N'.bak';

    -- COMPRESSION kaldirildi: SQL Server Express desteklemiyor
    SET @SQL = N'BACKUP DATABASE SinavTakip TO DISK = N''' + @DosyaAdi +
               N''' WITH FORMAT, NAME = N''SinavTakip Otomatik Yedek'';';

    EXEC sp_executesql @SQL;

    SELECT
        @DosyaAdi   AS YedekDosyasi,
        GETDATE()   AS YedekTarihi,
        N'Basarili' AS Durum;
END
GO

PRINT '19_yedekAlFix.sql tamamlandi.';
PRINT 'sp_YedekAl: COMPRESSION kaldirildi, Express Edition ile uyumlu.';
GO
