-- ============================================================
-- 18_uzaktanLabOgrenciSayisi.sql
-- Uzaktan ve Laboratuvar derslerinin OgrenciSayisi guncellenir.
--
-- Bölüm bazlı değerler:
--   Yazilim Muhendisligi          → 75
--   Mekatronik Muhendisligi       → 75
--   Makine Muhendisligi           → 75
--   Elektrik Muhendisligi         → 35
--   Enerji Sistemleri Muhendisligi→ 35
--
-- CALISTIRMA: Mevcut veritabaninda calistir, diger veriler korunur.
-- ============================================================
USE SinavTakip;
GO

UPDATE d
SET d.OgrenciSayisi = CASE b.BolumAdi
    WHEN N'Yazilim Muhendisligi'            THEN 75
    WHEN N'Mekatronik Muhendisligi'         THEN 75
    WHEN N'Makine Muhendisligi'             THEN 75
    WHEN N'Elektrik Muhendisligi'           THEN 35
    WHEN N'Enerji Sistemleri Muhendisligi'  THEN 35
    ELSE d.OgrenciSayisi
END
FROM Dersler d
JOIN Bolumler b ON d.BolumID = b.BolumID
WHERE d.DersTuru IN (N'Uzaktan', N'Laboratuvar')
  AND d.OgrenciSayisi = 0;

PRINT CAST(@@ROWCOUNT AS NVARCHAR) + ' ders guncellendi.';
GO

-- Kontrol sorgusu
SELECT
    b.BolumAdi,
    d.DersTuru,
    COUNT(*)         AS DersSayisi,
    d.OgrenciSayisi
FROM Dersler d
JOIN Bolumler b ON d.BolumID = b.BolumID
WHERE d.DersTuru IN (N'Uzaktan', N'Laboratuvar')
GROUP BY b.BolumAdi, d.DersTuru, d.OgrenciSayisi
ORDER BY b.BolumAdi, d.DersTuru;
GO
