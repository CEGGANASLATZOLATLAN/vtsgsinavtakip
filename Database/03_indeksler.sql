-- ============================================================
-- 03_Indexes.sql  -  Performans icin indeksler
-- ============================================================
USE SinavTakip;
GO

-- Sinav arama (tarihe ve oturuma gore)
CREATE NONCLUSTERED INDEX IX_Sinavlar_Tarih_Oturum
    ON Sinavlar (Tarih, OturumID)
    INCLUDE (DersID);
GO

-- Sinavlar'da ders arama
CREATE NONCLUSTERED INDEX IX_Sinavlar_DersID
    ON Sinavlar (DersID);
GO

-- Salon atamalarinda sinav arama
CREATE NONCLUSTERED INDEX IX_SinavSalon_SinavID
    ON Sinav_Salonlari (SinavID);
GO

-- Salon atamalarinda derslik arama
CREATE NONCLUSTERED INDEX IX_SinavSalon_DerslikID
    ON Sinav_Salonlari (DerslikID);
GO

-- Gozetmen atamalarinda personel arama
CREATE NONCLUSTERED INDEX IX_GozetmenAtama_PersonelID
    ON Gozetmen_Atamalari (PersonelID);
GO

-- Gozetmen atamalarinda sinav salonu arama
CREATE NONCLUSTERED INDEX IX_GozetmenAtama_SinavSalonID
    ON Gozetmen_Atamalari (SinavSalonID);
GO

-- Personel durum arama (tarih + oturum)
CREATE NONCLUSTERED INDEX IX_PersonelDurum_PersonelTarih
    ON Personel_Durum (PersonelID, Tarih)
    INCLUDE (OturumID, MazeretTuru);
GO

-- Dersler'de bolum ve yariyil arama (cakisma kontrolu icin kritik)
CREATE NONCLUSTERED INDEX IX_Dersler_Bolum_Yariyil
    ON Dersler (BolumID, Yariyil)
    INCLUDE (DersTuru, OgrenciSayisi);
GO

-- Derslikler aktif ve kapasiteye gore siralama (akilli salon icin)
CREATE NONCLUSTERED INDEX IX_Derslikler_Aktif_Kapasite
    ON Derslikler (Aktif, Kapasite DESC)
    INCLUDE (Tip, Kat);
GO

PRINT 'Indeksler basariyla olusturuldu.';
GO
