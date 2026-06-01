-- ============================================================
-- 04_StoredProcedures.sql  -  Stored Procedure'ler
-- En az 3 adet + BONUS yedek alma gereklidir.
-- ONEMLI: 05_Functions.sql'den SONRA calistiriniz.
-- ============================================================
USE SinavTakip;
GO

-- ============================================================
-- SP 1: sp_SinavOlustur
-- Yeni sinav olusturur; donem cakisma ve gunluk limit kontrolu yapar.
-- ============================================================
CREATE PROCEDURE dbo.sp_SinavOlustur
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

    -- Dersin yariyil ve turunu bul
    DECLARE @Yariyil INT, @DersTuru NVARCHAR(15);
    SELECT @Yariyil = Yariyil, @DersTuru = DersTuru
    FROM Dersler WHERE DersID = @DersID;

    -- 1. Zorunlu ders donem cakisma kontrolu
    IF @DersTuru = N'Zorunlu'
    BEGIN
        IF EXISTS (
            SELECT 1
            FROM Sinavlar sv
            JOIN Dersler d ON sv.DersID = d.DersID
            WHERE sv.Tarih    = @Tarih
              AND sv.OturumID = @OturumID
              AND d.Yariyil   = @Yariyil
              AND d.DersTuru  = N'Zorunlu'
              AND sv.DersID  != @DersID
        )
        BEGIN
            RAISERROR(N'Donem Cakismasi: Ayni yariyildaki zorunlu derslerin sinavlari ayni oturuma konamaz!', 16, 1);
            RETURN;
        END
    END

    -- 2. Gunluk sınav limiti uyarisi (2'den fazla ayni donem)
    DECLARE @GunlukSayi INT = dbo.fn_SinifGunlukSinavSayisi(@Yariyil, @Tarih);
    IF @GunlukSayi >= 2
        SET @UyariMesaji = N'UYARI: ' + CAST(@Yariyil AS NVARCHAR) +
                           N'. yariyil icin bu gune zaten ' +
                           CAST(@GunlukSayi AS NVARCHAR) + N' sinav planlanmis!';

    -- 3. Kaydet
    INSERT INTO Sinavlar (DersID, Tarih, OturumID)
    VALUES (@DersID, @Tarih, @OturumID);
    SET @SinavID = SCOPE_IDENTITY();
END
GO

-- ============================================================
-- SP 2: sp_AkilliSalonAta
-- Greedy algoritma ile en uygun salon kombinasyonunu bulur ve atar.
-- Oncelik: Amfi > Sinif > Lab; tercihen ayni katta.
-- ============================================================
CREATE PROCEDURE dbo.sp_AkilliSalonAta
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

            -- O tarih/oturumda dolu olan derslikler
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

            -- Tercihli katta bulunamadiysa tum katlardan sec
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

-- ============================================================
-- SP 3: sp_GozetmenAta
-- Bir sinav salonuna gozetmen atar; tum is kurallarini kontrol eder.
-- ============================================================
CREATE PROCEDURE dbo.sp_GozetmenAta
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
    BEGIN
        RAISERROR(N'Sinav salonu bulunamadi.', 16, 1); RETURN;
    END

    -- 1. Mazeret kontrolu
    IF dbo.fn_GozetmenMuzaitMi(@PersonelID, @Tarih, @OturumID) = 0
    BEGIN
        RAISERROR(N'Mazeret: Bu personel belirtilen tarih/oturumda mazeretli!', 16, 1); RETURN;
    END

    -- 2. Ayni anda baska sinavda gozetmen mi?
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
        RAISERROR(N'Cakisma: Bu personel ayni oturumda baska bir sinavda gozetmen!', 16, 1); RETURN;
    END

    -- 3. Ardisik oturum kontrolu (max 3 art arda)
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
        WHERE ga.PersonelID = @PersonelID
          AND sv3.Tarih     = @Tarih
        UNION
        SELECT SiraNo FROM SiraOturum WHERE OturumID = @OturumID
    )
    SELECT TOP 1 @SinavSalonID = @SinavSalonID  -- dummy assignment to check
    FROM MevcutAtamalar m1
    WHERE EXISTS (SELECT 1 FROM MevcutAtamalar m2 WHERE m2.SiraNo = m1.SiraNo + 1)
      AND EXISTS (SELECT 1 FROM MevcutAtamalar m3 WHERE m3.SiraNo = m1.SiraNo + 2)
      AND EXISTS (SELECT 1 FROM MevcutAtamalar m4 WHERE m4.SiraNo = m1.SiraNo + 3);

    IF @@ROWCOUNT > 0
    BEGIN
        RAISERROR(N'Ardisik Oturum Siniri: Bu personel zaten 3 art arda oturumda gorevli!', 16, 1); RETURN;
    END

    -- 4. Kaydet
    INSERT INTO Gozetmen_Atamalari (SinavSalonID, PersonelID)
    VALUES (@SinavSalonID, @PersonelID);

    SELECT N'Gozetmen basariyla atandi.' AS Sonuc;
END
GO

-- ============================================================
-- SP 4: sp_AdilGozetmenListele
-- Bir sinav icin bolumden + havuzdan musait, gorev yukune gore
-- sirali gozetmen listesi getirir.
-- ============================================================
CREATE PROCEDURE dbo.sp_AdilGozetmenListele
    @SinavID INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Tarih DATE, @OturumID INT, @BolumID INT;
    SELECT @Tarih    = sv.Tarih,
           @OturumID = sv.OturumID,
           @BolumID  = d.BolumID
    FROM Sinavlar sv
    JOIN Dersler d ON sv.DersID = d.DersID
    WHERE sv.SinavID = @SinavID;

    SELECT
        p.PersonelID,
        p.Unvan + N' ' + p.Ad + N' ' + p.Soyad  AS PersonelAdi,
        b.BolumAdi,
        dbo.fn_GozetmenGorevSayisi(p.PersonelID, DATEADD(MONTH,-6,@Tarih), @Tarih) AS GorevSayisi,
        CASE WHEN p.BolumID = @BolumID THEN N'Bolum' ELSE N'Havuz' END AS Kaynak,
        dbo.fn_GozetmenMuzaitMi(p.PersonelID, @Tarih, @OturumID) AS Musait
    FROM Personel p
    JOIN Bolumler b ON p.BolumID = b.BolumID
    WHERE p.Aktif = 1
      AND p.PersonelID NOT IN (
          SELECT ga.PersonelID
          FROM Gozetmen_Atamalari ga
          JOIN Sinav_Salonlari ss ON ga.SinavSalonID = ss.SinavSalonID
          JOIN Sinavlar sv2 ON ss.SinavID = sv2.SinavID
          WHERE sv2.Tarih    = @Tarih
            AND sv2.OturumID = @OturumID
      )
    ORDER BY
        CASE WHEN p.BolumID = @BolumID THEN 0 ELSE 1 END,
        dbo.fn_GozetmenGorevSayisi(p.PersonelID, DATEADD(MONTH,-6,@Tarih), @Tarih),
        p.Soyad, p.Ad;
END
GO

-- ============================================================
-- SP 5 (BONUS): sp_YedekAl
-- Veritabaninin yedeğini alir (C:\Yedekler klasorune .bak dosyasi).
-- ============================================================
CREATE PROCEDURE dbo.sp_YedekAl
    @YedekKlasor NVARCHAR(500) = N'C:\Yedekler'
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @DosyaAdi NVARCHAR(600);
    DECLARE @SQL      NVARCHAR(800);

    SET @DosyaAdi = @YedekKlasor + N'\SinavTakip_' +
                    FORMAT(GETDATE(), 'yyyyMMdd_HHmmss') + N'.bak';

    SET @SQL = N'BACKUP DATABASE SinavTakip TO DISK = N''' + @DosyaAdi +
               N''' WITH FORMAT, NAME = N''SinavTakip Otomatik Yedek'';';

    EXEC sp_executesql @SQL;

    SELECT
        @DosyaAdi       AS YedekDosyasi,
        GETDATE()       AS YedekTarihi,
        N'Basarili'     AS Durum;
END
GO

PRINT 'Stored Procedureler basariyla olusturuldu.';
GO
