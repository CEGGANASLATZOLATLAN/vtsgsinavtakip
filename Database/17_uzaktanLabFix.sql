-- ============================================================
-- 17_uzaktanLabFix.sql
-- Uzaktan ve Laboratuvar dersleri icin salon atama duzeltmesi.
-- Bu ders turleri artik gercek ogrenci sayisiyla salon alabilir.
-- sp_AkilliSalonAta'dan SALON_GEREKMIYOR blogu kaldirildi.
--
-- CALISTIRMA: Mevcut veritabaninda calistir, veri silinmez.
-- Not: Mevcut uzaktan/lab derslerinin OgrenciSayisi'ni
--      uygulamadan Ders Duzenle ekraniyla guncelleyin.
-- ============================================================
USE SinavTakip;
GO

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
                -- Kalani karsilayan odalar once (kucukten buyuge), karsilamayanlar sonra (buyukten kucuge)
                CASE WHEN d.Kapasite >= @KalanKapasite THEN 0 ELSE 1 END,
                CASE WHEN d.Kapasite >= @KalanKapasite THEN d.Kapasite ELSE -d.Kapasite END;

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
                    CASE WHEN d.Kapasite >= @KalanKapasite THEN 0 ELSE 1 END,
                    CASE WHEN d.Kapasite >= @KalanKapasite THEN d.Kapasite ELSE -d.Kapasite END;
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

-- ============================================================
-- sp_GozetmenAta: Bir salona maksimum 1 gozetmen kurali eklendi
-- ============================================================
ALTER PROCEDURE dbo.sp_GozetmenAta
    @SinavSalonID INT,
    @PersonelID   INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Tarih DATE, @OturumID INT, @SinavID INT;
    SELECT @Tarih    = sv.Tarih,
           @OturumID = sv.OturumID,
           @SinavID  = ss.SinavID
    FROM Sinav_Salonlari ss
    JOIN Sinavlar sv ON ss.SinavID = sv.SinavID
    WHERE ss.SinavSalonID = @SinavSalonID;

    IF @Tarih IS NULL
    BEGIN RAISERROR(N'Sinav salonu bulunamadi.', 16, 1); RETURN; END

    -- Kural 3: Bir salona maksimum 1 gozetmen atanabilir
    IF EXISTS (SELECT 1 FROM Gozetmen_Atamalari WHERE SinavSalonID = @SinavSalonID)
    BEGIN
        RAISERROR(N'KURAL 3 - Salon Limiti: Bu salona zaten bir gozetmen atanmis! Her salona maksimum 1 gozetmen atanabilir.', 16, 1); RETURN;
    END

    -- Kural 7: Mazeret kontrolu
    IF dbo.fn_GozetmenMuzaitMi(@PersonelID, @Tarih, @OturumID) = 0
    BEGIN
        RAISERROR(N'KURAL 7 - Mazeret: Bu personel belirtilen tarih/oturumda mazeretli!', 16, 1); RETURN;
    END

    -- Kural 5: Ayni anda baska sinavda gozetmen mi?
    IF EXISTS (
        SELECT 1
        FROM Gozetmen_Atamalari ga
        JOIN Sinav_Salonlari ss2 ON ga.SinavSalonID = ss2.SinavSalonID
        JOIN Sinavlar sv2 ON ss2.SinavID = sv2.SinavID
        WHERE ga.PersonelID   = @PersonelID
          AND sv2.Tarih       = @Tarih
          AND sv2.OturumID    = @OturumID
          AND ga.SinavSalonID <> @SinavSalonID
    )
    BEGIN
        RAISERROR(N'KURAL 5 - Cakisma: Bu personel ayni oturumda baska sinavda gozetmen!', 16, 1); RETURN;
    END

    -- Kural 6: Gunluk max 4 oturum
    DECLARE @GunlukOturum INT;
    SELECT @GunlukOturum = COUNT(DISTINCT sv3.OturumID)
    FROM Gozetmen_Atamalari ga3
    JOIN Sinav_Salonlari ss3 ON ga3.SinavSalonID = ss3.SinavSalonID
    JOIN Sinavlar sv3 ON ss3.SinavID = sv3.SinavID
    WHERE ga3.PersonelID = @PersonelID
      AND sv3.Tarih      = @Tarih;

    IF @GunlukOturum >= 4
    BEGIN
        RAISERROR(N'KURAL 6 - Gunluk Limit: Bu personel bugun zaten 4 oturumda gorevli!', 16, 1); RETURN;
    END

    -- Kural 9: Ardisik max 3 oturum
    ;WITH SiraOturum AS (
        SELECT OturumID, ROW_NUMBER() OVER (ORDER BY BaslangicSaat) AS SiraNo
        FROM Oturumlar
    ),
    MevcutAtamalar AS (
        SELECT so.SiraNo
        FROM Gozetmen_Atamalari ga
        JOIN Sinav_Salonlari ss3 ON ga.SinavSalonID = ss3.SinavSalonID
        JOIN Sinavlar sv3 ON ss3.SinavID = sv3.SinavID
        JOIN SiraOturum so ON sv3.OturumID = so.OturumID
        WHERE ga.PersonelID = @PersonelID AND sv3.Tarih = @Tarih
        UNION
        SELECT SiraNo FROM SiraOturum WHERE OturumID = @OturumID
    )
    SELECT TOP 1 @SinavSalonID = @SinavSalonID
    FROM MevcutAtamalar m1
    WHERE EXISTS (SELECT 1 FROM MevcutAtamalar m2 WHERE m2.SiraNo = m1.SiraNo + 1)
      AND EXISTS (SELECT 1 FROM MevcutAtamalar m3 WHERE m3.SiraNo = m1.SiraNo + 2)
      AND EXISTS (SELECT 1 FROM MevcutAtamalar m4 WHERE m4.SiraNo = m1.SiraNo + 3);

    IF @@ROWCOUNT > 0
    BEGIN
        RAISERROR(N'KURAL 9 - Ardisik Sinir: Bu personel 3 art arda oturumda gorevli, 4. arda atanamaz!', 16, 1); RETURN;
    END

    -- Kaydet
    INSERT INTO Gozetmen_Atamalari (SinavSalonID, PersonelID)
    VALUES (@SinavSalonID, @PersonelID);

    SELECT N'Gozetmen basariyla atandi.' AS Sonuc;
END
GO

-- ============================================================
-- sp_SinavOlustur: Her ders icin yalnizca 1 sinav kurali eklendi
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

    -- Kural 0: Her ders icin yalnizca 1 sinav olusturulabilir
    IF EXISTS (SELECT 1 FROM Sinavlar WHERE DersID = @DersID)
    BEGIN
        RAISERROR(N'KURAL 0 - Tekrar: Bu ders icin zaten bir sinav mevcut! Her ders icin yalnizca 1 sinav olusturulabilir.', 16, 1);
        RETURN;
    END

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

    INSERT INTO Sinavlar (DersID, Tarih, OturumID)
    VALUES (@DersID, @Tarih, @OturumID);
    SET @SinavID = SCOPE_IDENTITY();
END
GO

PRINT '17_uzaktanLabFix.sql tamamlandi.';
PRINT 'sp_AkilliSalonAta: optimize edilmis salon secim algoritmasi.';
PRINT 'sp_GozetmenAta   : maksimum 1 gozetmen per salon kurali eklendi.';
PRINT 'sp_SinavOlustur  : her ders icin yalnizca 1 sinav kurali eklendi.';
GO
