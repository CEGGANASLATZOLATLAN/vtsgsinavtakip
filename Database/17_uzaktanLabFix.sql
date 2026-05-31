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

PRINT '17_uzaktanLabFix.sql tamamlandi.';
PRINT 'sp_AkilliSalonAta: OgrenciSayisi=0 durumu artik SALON_GEREKMIYOR mesajiyla ele aliniyor.';
GO
