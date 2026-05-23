-- ============================================================
-- 05_Functions.sql  -  Kullanici Tanimli Fonksiyonlar (UDF)
-- En az 3 adet gereklidir.
-- ============================================================
USE SinavTakip;
GO

-- ============================================================
-- UDF 1: fn_GozetmenMuzaitMi
-- Belirtilen tarih ve oturumda personelin musait olup olmadigini dondurur.
-- 1 = musait, 0 = mazeretli
-- ============================================================
CREATE FUNCTION dbo.fn_GozetmenMuzaitMi
(
    @PersonelID INT,
    @Tarih      DATE,
    @OturumID   INT
)
RETURNS BIT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM Personel_Durum
        WHERE PersonelID = @PersonelID
          AND Tarih      = @Tarih
          AND (OturumID IS NULL OR OturumID = @OturumID)
    )
        RETURN 0;   -- mazeretli

    RETURN 1;       -- musait
END
GO

-- ============================================================
-- UDF 2: fn_ToplamKapasite
-- Bir sinavin atandigi salonlarin toplam kapasitesini dondurur.
-- ============================================================
CREATE FUNCTION dbo.fn_ToplamKapasite
(
    @SinavID INT
)
RETURNS INT
AS
BEGIN
    DECLARE @Toplam INT;
    SELECT @Toplam = ISNULL(SUM(d.Kapasite), 0)
    FROM Sinav_Salonlari ss
    JOIN Derslikler d ON ss.DerslikID = d.DerslikID
    WHERE ss.SinavID = @SinavID;
    RETURN @Toplam;
END
GO

-- ============================================================
-- UDF 3: fn_GozetmenGorevSayisi
-- Belirtilen tarih araliginda bir personelin gozetmen gorev sayisini dondurur.
-- Adil dagitim kontrolu icin kullanilir.
-- ============================================================
CREATE FUNCTION dbo.fn_GozetmenGorevSayisi
(
    @PersonelID INT,
    @BasTarih   DATE,
    @BitTarih   DATE
)
RETURNS INT
AS
BEGIN
    DECLARE @Sayi INT;
    SELECT @Sayi = COUNT(*)
    FROM Gozetmen_Atamalari ga
    JOIN Sinav_Salonlari ss ON ga.SinavSalonID = ss.SinavSalonID
    JOIN Sinavlar sv ON ss.SinavID = sv.SinavID
    WHERE ga.PersonelID = @PersonelID
      AND sv.Tarih BETWEEN @BasTarih AND @BitTarih;
    RETURN ISNULL(@Sayi, 0);
END
GO

-- ============================================================
-- UDF 4: fn_SinifGunlukSinavSayisi
-- Belirtilen yariyil ve tarih icin o gune planlanmis sinav sayisini dondurur.
-- Gunluk limit uyarisi icin kullanilir.
-- ============================================================
CREATE FUNCTION dbo.fn_SinifGunlukSinavSayisi
(
    @Yariyil INT,
    @Tarih   DATE
)
RETURNS INT
AS
BEGIN
    DECLARE @Sayi INT;
    SELECT @Sayi = COUNT(DISTINCT sv.SinavID)
    FROM Sinavlar sv
    JOIN Dersler d ON sv.DersID = d.DersID
    WHERE d.Yariyil = @Yariyil
      AND sv.Tarih  = @Tarih;
    RETURN ISNULL(@Sayi, 0);
END
GO

PRINT 'UDFler basariyla olusturuldu.';
GO
