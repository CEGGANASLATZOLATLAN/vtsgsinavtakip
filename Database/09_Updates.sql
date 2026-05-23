-- ============================================================
-- 09_Updates.sql
-- Hoca guncellemesi: dogru derslik/oturum/bolum verileri +
-- yeni is kurallari (gap, gunluk max 4 gozetmen, tum dersler)
-- SSMS'de bu dosyayi calistirin.
-- ============================================================
USE SinavTakip;
GO

-- ============================================================
-- ADIM 1: ESKİ VERİLERİ TEMİZLE
-- ============================================================
DISABLE TRIGGER dbo.trg_DönemCakismaKontrol    ON Sinavlar;
DISABLE TRIGGER dbo.trg_SalonCakismaKontrol     ON Sinav_Salonlari;
DISABLE TRIGGER dbo.trg_GozetmenCakismaKontrol  ON Gozetmen_Atamalari;
GO

DELETE FROM Gozetmen_Atamalari;
DELETE FROM Sinav_Salonlari;
DELETE FROM Sinavlar;
DELETE FROM Personel_Durum;
DELETE FROM Personel;
DELETE FROM Dersler;
DELETE FROM Derslikler;
DELETE FROM Oturumlar;
DELETE FROM Bolumler;
GO

DBCC CHECKIDENT ('Gozetmen_Atamalari', RESEED, 0);
DBCC CHECKIDENT ('Sinav_Salonlari',    RESEED, 0);
DBCC CHECKIDENT ('Sinavlar',           RESEED, 0);
DBCC CHECKIDENT ('Personel_Durum',     RESEED, 0);
DBCC CHECKIDENT ('Personel',           RESEED, 0);
DBCC CHECKIDENT ('Dersler',            RESEED, 0);
DBCC CHECKIDENT ('Derslikler',         RESEED, 0);
DBCC CHECKIDENT ('Oturumlar',          RESEED, 0);
DBCC CHECKIDENT ('Bolumler',           RESEED, 0);
GO

-- ============================================================
-- ADIM 2: DOĞRU OTURUMLAR
-- ============================================================
INSERT INTO Oturumlar (Tanim, BaslangicSaat, BitisSaat) VALUES
    (N'Sabah-1',         '09:00', '10:00'),
    (N'Sabah-2',         '10:30', '11:30'),
    (N'Ogle',            '12:00', '13:00'),
    (N'Ogleden Sonra-1', '13:45', '14:45'),
    (N'Ogleden Sonra-2', '15:15', '16:30');
GO

-- ============================================================
-- ADIM 3: DOĞRU DERSLİKLER
-- Kucuk Siniflar (36 kisi): 205-208, 305-308
-- Orta: 309 (40), 311 (50)
-- Buyuk (60 kisi): 209, 210, 310, 409, 410
-- Kat: 2xx=Kat2, 3xx=Kat3, 4xx=Kat4
-- ============================================================
INSERT INTO Derslikler (Ad, Kapasite, Tip, Kat, Aktif) VALUES
    -- 2. Kat - Kücük
    (N'205', 36, N'Sinif', 2, 1),
    (N'206', 36, N'Sinif', 2, 1),
    (N'207', 36, N'Sinif', 2, 1),
    (N'208', 36, N'Sinif', 2, 1),
    -- 2. Kat - Büyük
    (N'209', 60, N'Sinif', 2, 1),
    (N'210', 60, N'Sinif', 2, 1),
    -- 3. Kat - Küçük
    (N'305', 36, N'Sinif', 3, 1),
    (N'306', 36, N'Sinif', 3, 1),
    (N'307', 36, N'Sinif', 3, 1),
    (N'308', 36, N'Sinif', 3, 1),
    -- 3. Kat - Orta
    (N'309', 40, N'Sinif', 3, 1),
    (N'311', 50, N'Sinif', 3, 1),
    -- 3. Kat - Büyük
    (N'310', 60, N'Sinif', 3, 1),
    -- 4. Kat - Büyük
    (N'409', 60, N'Sinif', 4, 1),
    (N'410', 60, N'Sinif', 4, 1);
GO

-- ============================================================
-- ADIM 4: DOĞRU BÖLÜMLER
-- ============================================================
INSERT INTO Bolumler (BolumAdi, Aktif) VALUES
    (N'Yazilim Muhendisligi',           1),
    (N'Elektrik Muhendisligi',          1),
    (N'Makine Muhendisligi',            1),
    (N'Mekatronik Muhendisligi',        1),
    (N'Enerji Sistemleri Muhendisligi', 1);
GO

-- Triggerlari yeniden ac
ENABLE TRIGGER dbo.trg_DönemCakismaKontrol    ON Sinavlar;
ENABLE TRIGGER dbo.trg_SalonCakismaKontrol     ON Sinav_Salonlari;
ENABLE TRIGGER dbo.trg_GozetmenCakismaKontrol  ON Gozetmen_Atamalari;
GO

-- ============================================================
-- ADIM 5: sp_SinavOlustur GÜNCELLE
-- Yeni kurallar:
--   - Tum dersler icin gecerli (sadece Zorunlu degil)
--   - Gunluk max 2 sinav: HARD BLOCK (artik sadece uyari degil)
--   - Oturum boslugu: ayni yariyil ayni gunde oturumlar
--     arasinda en az 1 bosluk olmali (Kural 2)
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

    DECLARE @Yariyil INT;
    SELECT @Yariyil = Yariyil FROM Dersler WHERE DersID = @DersID;

    -- Kural 1: Ayni yariyil + ayni oturum + ayni tarih (tum dersler)
    IF EXISTS (
        SELECT 1
        FROM Sinavlar sv
        JOIN Dersler d ON sv.DersID = d.DersID
        WHERE sv.Tarih    = @Tarih
          AND sv.OturumID = @OturumID
          AND d.Yariyil   = @Yariyil
          AND sv.DersID  != @DersID
    )
    BEGIN
        RAISERROR(N'KURAL 1 - Cakisma: Ayni yariyildaki derslerin sinavlari ayni oturuma konamaz!', 16, 1);
        RETURN;
    END

    -- Kural 2a: Oturum boslugu - ayni yariyil ayni gunde bitisik oturum yasak
    DECLARE @GapIhlal BIT = 0;
    ;WITH SiraOturum AS (
        SELECT OturumID, ROW_NUMBER() OVER (ORDER BY BaslangicSaat) AS SiraNo
        FROM Oturumlar
    )
    SELECT TOP 1 @GapIhlal = 1
    FROM Sinavlar sv
    JOIN Dersler d ON sv.DersID = d.DersID
    JOIN SiraOturum so_var  ON sv.OturumID    = so_var.OturumID
    JOIN SiraOturum so_yeni ON so_yeni.OturumID = @OturumID
    WHERE sv.Tarih   = @Tarih
      AND d.Yariyil  = @Yariyil
      AND sv.DersID != @DersID
      AND ABS(so_var.SiraNo - so_yeni.SiraNo) = 1;

    IF @GapIhlal = 1
    BEGIN
        RAISERROR(N'KURAL 2 - Oturum Boslugu: Ayni yariyildaki sinavlar arasinda en az 1 oturum boslugu olmali!', 16, 1);
        RETURN;
    END

    -- Kural 2b: Gunluk max 2 sinav (hard block)
    DECLARE @GunlukSayi INT = dbo.fn_SinifGunlukSinavSayisi(@Yariyil, @Tarih);
    IF @GunlukSayi >= 2
    BEGIN
        RAISERROR(N'KURAL 2 - Gunluk Limit: Bu yariyil icin bu gune zaten 2 sinav var, 3. eklenemez!', 16, 1);
        RETURN;
    END

    -- Kaydet
    INSERT INTO Sinavlar (DersID, Tarih, OturumID)
    VALUES (@DersID, @Tarih, @OturumID);
    SET @SinavID = SCOPE_IDENTITY();
END
GO

-- ============================================================
-- ADIM 6: sp_GozetmenAta GÜNCELLE
-- Yeni kural: Gunluk max 4 oturum (Kural 6)
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

    -- Kural 7: Mazeret kontrolü
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
-- ADIM 7: trg_DönemCakismaKontrol GÜNCELLE
-- Tum dersler + oturum boslugu kurali eklendi
-- ============================================================
ALTER TRIGGER dbo.trg_DönemCakismaKontrol
ON Sinavlar
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Kural 1: Ayni yariyil + ayni oturum + ayni tarih
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN Dersler d_yeni ON i.DersID = d_yeni.DersID
        JOIN Sinavlar sv_var ON sv_var.Tarih    = i.Tarih
                             AND sv_var.OturumID = i.OturumID
                             AND sv_var.SinavID <> i.SinavID
        JOIN Dersler d_var ON sv_var.DersID = d_var.DersID
        WHERE d_var.Yariyil = d_yeni.Yariyil
    )
    BEGIN
        RAISERROR(N'KURAL 1 - Donem Cakismasi: Ayni yariyildaki sinavlar ayni oturuma konamaz!', 16, 1);
        ROLLBACK TRANSACTION; RETURN;
    END

    -- Kural 2: Oturum boslugu (bitisik oturum yasak)
    DECLARE @GapIhlal BIT = 0;
    ;WITH SiraOturum AS (
        SELECT OturumID, ROW_NUMBER() OVER (ORDER BY BaslangicSaat) AS SiraNo
        FROM Oturumlar
    )
    SELECT TOP 1 @GapIhlal = 1
    FROM inserted i
    JOIN Dersler d_yeni    ON i.DersID         = d_yeni.DersID
    JOIN SiraOturum so_yeni ON i.OturumID      = so_yeni.OturumID
    JOIN Sinavlar sv_var   ON sv_var.Tarih      = i.Tarih
                           AND sv_var.SinavID  <> i.SinavID
    JOIN Dersler d_var     ON sv_var.DersID     = d_var.DersID
    JOIN SiraOturum so_var ON sv_var.OturumID   = so_var.OturumID
    WHERE d_var.Yariyil = d_yeni.Yariyil
      AND ABS(so_var.SiraNo - so_yeni.SiraNo) = 1;

    IF @GapIhlal = 1
    BEGIN
        RAISERROR(N'KURAL 2 - Oturum Boslugu: Ayni yariyildaki sinavlar arasinda en az 1 oturum boslugu olmali!', 16, 1);
        ROLLBACK TRANSACTION; RETURN;
    END
END
GO

PRINT '====================================================';
PRINT 'Tum guncellemeler basariyla tamamlandi!';
PRINT '';
PRINT 'Simdi uygulamadan yapmaniz gerekenler:';
PRINT '  1) Ders bilgilerini bolum web sitelerinden girin';
PRINT '     - Kontenjan hesabi:';
PRINT '       Kucuk sinif (205-208, 305-308) -> 60 ogrenci';
PRINT '       309 -> 80 ogrenci';
PRINT '       311 -> 50 ogrenci';
PRINT '       Buyuk sinif (209,210,310,409,410) -> 150 ogrenci';
PRINT '  2) Personel bilgilerini Akademik Personel menusunden girin';
PRINT '====================================================';
GO
