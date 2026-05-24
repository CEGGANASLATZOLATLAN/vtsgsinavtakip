-- ============================================================
-- 15_BugFixes.sql
-- Mevcut veritabani uzerinde veri SILMEDEN bug duzeltmeleri uygular.
--
-- Duzeltilen buglar:
--   1. sp_SinavOlustur  : Bolum filtresi eklendi (cross-dept cakisma kaldirildi)
--   2. trg_DönemCakisma : Bolum filtresi eklendi
--   3. sp_AkilliSalonAta: Transaction sarmalayicisi eklendi (atomik atama)
--
-- C# duzeltmeleri (Visual Studio'da derleme ile aktif olur):
--   4. SinavForm.cs        : lblUyari cift Controls.Add kaldirildi
--   5. PersonelDurumForm.cs: Aciklama NULL bug'i duzeltildi
--
-- CALISTIRMA: Bu dosyayi tek basina calistirabilirsiniz.
--             Mevcut sinav, salon ve gozetmen verileri korunur.
-- ============================================================
USE SinavTakip;
GO

-- ============================================================
-- ADIM 1: sp_SinavOlustur - BolumID filtresi ekle
-- ============================================================
ALTER PROCEDURE dbo.sp_SinavOlustur
    @DersID      INT,
    @Tarih       DATE,
    @OturumID    INT,
    @SinavID     INT  OUTPUT,
    @UyariMesaji NVARCHAR(500) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET @SinavID     = NULL;
    SET @UyariMesaji = N'';

    DECLARE @Yariyil INT, @BolumID INT;
    SELECT @Yariyil = Yariyil, @BolumID = BolumID
    FROM Dersler WHERE DersID = @DersID;

    -- Kural 1: Ayni BOLUMDE ayni yariyil + ayni oturum + ayni tarih
    IF EXISTS (
        SELECT 1
        FROM Sinavlar sv
        JOIN Dersler d ON sv.DersID = d.DersID
        WHERE sv.Tarih    = @Tarih
          AND sv.OturumID = @OturumID
          AND d.Yariyil   = @Yariyil
          AND d.BolumID   = @BolumID
          AND sv.DersID  != @DersID
    )
    BEGIN
        RAISERROR(N'KURAL 1 - Cakisma: Ayni bolumde ayni yariyildaki derslerin sinavlari ayni oturuma konamaz!', 16, 1);
        RETURN;
    END

    -- Kural 2a: Oturum boslugu - ayni BOLUMDE bitisik oturum yasak
    DECLARE @GapIhlal BIT = 0;
    ;WITH SiraOturum AS (
        SELECT OturumID, ROW_NUMBER() OVER (ORDER BY BaslangicSaat) AS SiraNo
        FROM Oturumlar
    )
    SELECT TOP 1 @GapIhlal = 1
    FROM Sinavlar sv
    JOIN Dersler d ON sv.DersID = d.DersID
    JOIN SiraOturum so_var  ON sv.OturumID      = so_var.OturumID
    JOIN SiraOturum so_yeni ON so_yeni.OturumID = @OturumID
    WHERE sv.Tarih   = @Tarih
      AND d.Yariyil  = @Yariyil
      AND d.BolumID  = @BolumID
      AND sv.DersID != @DersID
      AND ABS(so_var.SiraNo - so_yeni.SiraNo) = 1;

    IF @GapIhlal = 1
    BEGIN
        RAISERROR(N'KURAL 2 - Oturum Boslugu: Ayni bolumde ayni yariyildaki sinavlar arasinda en az 1 oturum boslugu olmali!', 16, 1);
        RETURN;
    END

    -- Kural 2b: Gunluk max 2 sinav (ayni bolumde, hard block)
    DECLARE @GunlukSayi INT;
    SELECT @GunlukSayi = COUNT(DISTINCT sv.SinavID)
    FROM Sinavlar sv
    JOIN Dersler d ON sv.DersID = d.DersID
    WHERE d.Yariyil = @Yariyil
      AND d.BolumID = @BolumID
      AND sv.Tarih  = @Tarih;

    IF @GunlukSayi >= 2
    BEGIN
        RAISERROR(N'KURAL 2 - Gunluk Limit: Bu bolumde bu yariyil icin bu gune zaten 2 sinav var, 3. eklenemez!', 16, 1);
        RETURN;
    END

    -- Kaydet
    INSERT INTO Sinavlar (DersID, Tarih, OturumID)
    VALUES (@DersID, @Tarih, @OturumID);
    SET @SinavID = SCOPE_IDENTITY();
END
GO
PRINT 'sp_SinavOlustur guncellendi (BolumID filtresi eklendi).';
GO

-- ============================================================
-- ADIM 2: trg_DönemCakismaKontrol - BolumID filtresi ekle
-- ============================================================
ALTER TRIGGER dbo.trg_DönemCakismaKontrol
ON Sinavlar
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Kural 1: Ayni BOLUMDE ayni yariyil + ayni oturum + ayni tarih
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN Dersler d_yeni ON i.DersID = d_yeni.DersID
        JOIN Sinavlar sv_var ON sv_var.Tarih    = i.Tarih
                             AND sv_var.OturumID = i.OturumID
                             AND sv_var.SinavID <> i.SinavID
        JOIN Dersler d_var ON sv_var.DersID = d_var.DersID
        WHERE d_var.Yariyil = d_yeni.Yariyil
          AND d_var.BolumID = d_yeni.BolumID
    )
    BEGIN
        RAISERROR(N'KURAL 1 - Donem Cakismasi: Ayni bolumde ayni yariyildaki sinavlar ayni oturuma konamaz!', 16, 1);
        ROLLBACK TRANSACTION; RETURN;
    END

    -- Kural 2: Oturum boslugu (bitisik oturum yasak, ayni BOLUMDE)
    DECLARE @GapIhlal BIT = 0;
    ;WITH SiraOturum AS (
        SELECT OturumID, ROW_NUMBER() OVER (ORDER BY BaslangicSaat) AS SiraNo
        FROM Oturumlar
    )
    SELECT TOP 1 @GapIhlal = 1
    FROM inserted i
    JOIN Dersler d_yeni     ON i.DersID          = d_yeni.DersID
    JOIN SiraOturum so_yeni ON i.OturumID        = so_yeni.OturumID
    JOIN Sinavlar sv_var    ON sv_var.Tarih       = i.Tarih
                            AND sv_var.SinavID   <> i.SinavID
    JOIN Dersler d_var      ON sv_var.DersID      = d_var.DersID
    JOIN SiraOturum so_var  ON sv_var.OturumID    = so_var.OturumID
    WHERE d_var.Yariyil = d_yeni.Yariyil
      AND d_var.BolumID = d_yeni.BolumID
      AND ABS(so_var.SiraNo - so_yeni.SiraNo) = 1;

    IF @GapIhlal = 1
    BEGIN
        RAISERROR(N'KURAL 2 - Oturum Boslugu: Ayni bolumde ayni yariyildaki sinavlar arasinda en az 1 oturum boslugu olmali!', 16, 1);
        ROLLBACK TRANSACTION; RETURN;
    END
END
GO
PRINT 'trg_DönemCakismaKontrol guncellendi (BolumID filtresi eklendi).';
GO

-- ============================================================
-- ADIM 3: sp_AkilliSalonAta - Transaction sarmalayicisi ekle
-- ============================================================
ALTER PROCEDURE dbo.sp_AkilliSalonAta
    @SinavID      INT,
    @TercihliKat  INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @OgrenciSayisi INT, @OturumID INT, @Tarih DATE;
    SELECT @OgrenciSayisi = d.OgrenciSayisi,
           @OturumID      = s.OturumID,
           @Tarih         = s.Tarih
    FROM Sinavlar s
    JOIN Dersler d ON s.DersID = d.DersID
    WHERE s.SinavID = @SinavID;

    IF @OgrenciSayisi IS NULL
    BEGIN
        RAISERROR(N'Sinav bulunamadi.', 16, 1); RETURN;
    END

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Mevcut atamalar temizlenir
        DELETE ga
        FROM Gozetmen_Atamalari ga
        JOIN Sinav_Salonlari ss ON ga.SinavSalonID = ss.SinavSalonID
        WHERE ss.SinavID = @SinavID;

        DELETE FROM Sinav_Salonlari WHERE SinavID = @SinavID;

        DECLARE @KalanKapasite INT = @OgrenciSayisi;
        DECLARE @SecilenDerslikID INT, @SecilenKapasite INT;

        WHILE @KalanKapasite > 0
        BEGIN
            SET @SecilenDerslikID = NULL;
            SET @SecilenKapasite  = NULL;

            ;WITH DoluSalonlar AS (
                SELECT ss2.DerslikID
                FROM Sinav_Salonlari ss2
                JOIN Sinavlar sv2 ON ss2.SinavID = sv2.SinavID
                WHERE sv2.Tarih    = @Tarih
                  AND sv2.OturumID = @OturumID
                  AND sv2.SinavID <> @SinavID
            ),
            ZatenAtananlar AS (
                SELECT DerslikID FROM Sinav_Salonlari WHERE SinavID = @SinavID
            )
            SELECT TOP 1
                @SecilenDerslikID = d.DerslikID,
                @SecilenKapasite  = d.Kapasite
            FROM Derslikler d
            WHERE d.Aktif = 1
              AND d.DerslikID NOT IN (SELECT DerslikID FROM DoluSalonlar)
              AND d.DerslikID NOT IN (SELECT DerslikID FROM ZatenAtananlar)
              AND (@TercihliKat IS NULL OR d.Kat = @TercihliKat)
            ORDER BY
                CASE d.Tip WHEN N'Amfi' THEN 1 WHEN N'Sinif' THEN 2 ELSE 3 END,
                d.Kapasite DESC;

            IF @SecilenDerslikID IS NULL AND @TercihliKat IS NOT NULL
            BEGIN
                ;WITH DoluSalonlar AS (
                    SELECT ss2.DerslikID
                    FROM Sinav_Salonlari ss2
                    JOIN Sinavlar sv2 ON ss2.SinavID = sv2.SinavID
                    WHERE sv2.Tarih    = @Tarih
                      AND sv2.OturumID = @OturumID
                      AND sv2.SinavID <> @SinavID
                ),
                ZatenAtananlar AS (
                    SELECT DerslikID FROM Sinav_Salonlari WHERE SinavID = @SinavID
                )
                SELECT TOP 1
                    @SecilenDerslikID = d.DerslikID,
                    @SecilenKapasite  = d.Kapasite
                FROM Derslikler d
                WHERE d.Aktif = 1
                  AND d.DerslikID NOT IN (SELECT DerslikID FROM DoluSalonlar)
                  AND d.DerslikID NOT IN (SELECT DerslikID FROM ZatenAtananlar)
                ORDER BY
                    CASE d.Tip WHEN N'Amfi' THEN 1 WHEN N'Sinif' THEN 2 ELSE 3 END,
                    d.Kapasite DESC;
            END

            IF @SecilenDerslikID IS NULL
            BEGIN
                RAISERROR(N'Yeterli bos salon bulunamadi! Toplam kapasite yetersiz.', 16, 1);
            END

            INSERT INTO Sinav_Salonlari (SinavID, DerslikID)
            VALUES (@SinavID, @SecilenDerslikID);

            SET @KalanKapasite = @KalanKapasite - @SecilenKapasite;
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH

    -- Sonucu dondur
    SELECT
        d.Ad        AS DerslikAdi,
        d.Kapasite,
        d.Tip,
        d.Kat,
        ss.SinavSalonID
    FROM Sinav_Salonlari ss
    JOIN Derslikler d ON ss.DerslikID = d.DerslikID
    WHERE ss.SinavID = @SinavID
    ORDER BY d.Kapasite DESC;
END
GO
PRINT 'sp_AkilliSalonAta guncellendi (transaction sarmalayici eklendi).';
GO

PRINT '';
PRINT '============================================================';
PRINT '15_BugFixes.sql tamamlandi. Mevcut veriler korundu.';
PRINT 'Duzeltilen:';
PRINT '  1. sp_SinavOlustur  - BolumID filtresi (cross-dept bug)';
PRINT '  2. trg_DönemCakisma - BolumID filtresi (cross-dept bug)';
PRINT '  3. sp_AkilliSalonAta - atomik transaction';
PRINT '============================================================';
GO
