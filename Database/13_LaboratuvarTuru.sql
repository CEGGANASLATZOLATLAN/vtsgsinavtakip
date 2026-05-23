-- ============================================================
-- 13_LaboratuvarTuru.sql
-- Adinda LAB veya LABORATUVAR gecen tum dersleri
-- DersTuru = Laboratuvar yapip OgrenciSayisi = 0 atar.
-- ONEMLI: 12_TumBolumlerDersler.sql'den SONRA calistirin.
-- ============================================================
USE SinavTakip;
GO

-- Kisita Laboratuvar yoksa ekle (10_ calistirilmadiysa yedek)
IF NOT EXISTS (
    SELECT 1 FROM sys.check_constraints
    WHERE name = N'CK_Ders_Tur'
      AND definition LIKE N'%Laboratuvar%'
)
BEGIN
    -- Mevcut kisiti kaldir
    IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = N'CK_Ders_Tur')
        ALTER TABLE Dersler DROP CONSTRAINT CK_Ders_Tur;

    ALTER TABLE Dersler
        ADD CONSTRAINT CK_Ders_Tur
        CHECK (DersTuru IN (N'Zorunlu', N'Secmeli', N'Uzaktan', N'Laboratuvar'));

    PRINT 'CK_Ders_Tur kisiti Laboratuvar icin guncellendi.';
END
ELSE
    PRINT 'CK_Ders_Tur zaten Laboratuvar iceriyor, atlanıyor.';
GO

-- Adinda LABORATUVAR veya LAB gecen TUM dersleri guncelle
UPDATE Dersler
SET DersTuru      = N'Laboratuvar',
    OgrenciSayisi = 0
WHERE Ad LIKE N'%LABORATUVAR%'
   OR Ad LIKE N'%LAB I%'
   OR Ad LIKE N'%LAB II%'
   OR Ad LIKE N'%LAB III%'
   OR Ad LIKE N'% LAB'
   OR Ad LIKE N'LAB %';

PRINT CAST(@@ROWCOUNT AS NVARCHAR) + ' ders Laboratuvar turune alindi.';
GO

-- Dogrulama: Laboratuvar turundeki dersler
PRINT '';
PRINT '=== Laboratuvar turundeki dersler ===';
SELECT
    d.DersKodu,
    d.Ad,
    d.DersTuru,
    d.OgrenciSayisi,
    d.Yariyil,
    b.BolumAdi
FROM Dersler d
JOIN Bolumler b ON d.BolumID = b.BolumID
WHERE d.DersTuru = N'Laboratuvar'
ORDER BY b.BolumAdi, d.Yariyil, d.DersKodu;
GO

PRINT '';
PRINT '=== Bolum bazi ders sayilari ===';
SELECT
    b.BolumAdi,
    COUNT(*) AS ToplamDers,
    SUM(CASE WHEN d.DersTuru = N'Zorunlu'    THEN 1 ELSE 0 END) AS Zorunlu,
    SUM(CASE WHEN d.DersTuru = N'Uzaktan'    THEN 1 ELSE 0 END) AS Uzaktan,
    SUM(CASE WHEN d.DersTuru = N'Laboratuvar' THEN 1 ELSE 0 END) AS Laboratuvar,
    SUM(CASE WHEN d.DersTuru = N'Secmeli'    THEN 1 ELSE 0 END) AS Secmeli
FROM Dersler d
JOIN Bolumler b ON d.BolumID = b.BolumID
GROUP BY b.BolumAdi
ORDER BY b.BolumAdi;
GO
