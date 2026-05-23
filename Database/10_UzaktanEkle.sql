-- ============================================================
-- 10_UzaktanEkle.sql
-- Dersler tablosuna Uzaktan tur secenegi eklenir.
-- SSMS'de bu dosyayi calistirin.
-- ============================================================
USE SinavTakip;
GO

-- Eski CHECK kısıtını kaldır
ALTER TABLE Dersler DROP CONSTRAINT CK_Ders_Tur;
GO

-- Yeni CHECK kisitini ekle (Uzaktan + Laboratuvar dahil)
ALTER TABLE Dersler
    ADD CONSTRAINT CK_Ders_Tur
    CHECK (DersTuru IN (N'Zorunlu', N'Secmeli', N'Uzaktan', N'Laboratuvar'));
GO

-- Uzaktan dersler icin OgrenciSayisi 0 olabilsin
ALTER TABLE Dersler DROP CONSTRAINT CK_Ders_Ogrenci;
GO

ALTER TABLE Dersler
    ADD CONSTRAINT CK_Ders_Ogrenci
    CHECK (OgrenciSayisi >= 0);
GO

PRINT 'Uzaktan ve Laboratuvar tur secenek basariyla eklendi.';
GO
