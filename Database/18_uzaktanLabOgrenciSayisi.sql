-- ============================================================
-- 18_uzaktanLabOgrenciSayisi.sql
-- Uzaktan ve Laboratuvar derslerinin OgrenciSayisi guncellenir.
--
-- Bölüm bazlı değerler:
--   Yazilim Muhendisligi          → 70
--   Mekatronik Muhendisligi       → 60
--   Makine Muhendisligi           → 60
--   Elektrik Muhendisligi         → 30
--   Enerji Sistemleri Muhendisligi→ 45
--
-- CALISTIRMA: Mevcut veritabaninda calistir, diger veriler korunur.
-- ============================================================
USE SinavTakip;
GO

UPDATE d
SET d.OgrenciSayisi = CASE b.BolumAdi
    WHEN N'Yazilim Muhendisligi'            THEN 70
    WHEN N'Mekatronik Muhendisligi'         THEN 60
    WHEN N'Makine Muhendisligi'             THEN 60
    WHEN N'Elektrik Muhendisligi'           THEN 30
    WHEN N'Enerji Sistemleri Muhendisligi'  THEN 45
    ELSE d.OgrenciSayisi
END
FROM Dersler d
JOIN Bolumler b ON d.BolumID = b.BolumID
WHERE d.DersTuru IN (N'Uzaktan', N'Laboratuvar');

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
