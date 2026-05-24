-- ============================================================
-- 08_SampleData.sql  -  Ornek/Test verisi
-- ============================================================
USE SinavTakip;
GO

-- Triggerlari gecici olarak devre disi birak (veri ekleme kolayligi icin)
DISABLE TRIGGER dbo.trg_DönemCakismaKontrol ON Sinavlar;
GO

-- ============================================================
-- Bolumler
-- ============================================================
INSERT INTO Bolumler (BolumAdi) VALUES
    (N'Yazilim Muhendisligi'),
    (N'Elektrik Muhendisligi'),
    (N'Makine Muhendisligi'),
    (N'Mekatronik Muhendisligi'),
    (N'Enerji Sistemleri Muhendisligi');
GO

-- ============================================================
-- Oturumlar
-- ============================================================
INSERT INTO Oturumlar (Tanim, BaslangicSaat, BitisSaat) VALUES
    (N'1. Oturum (09:00-10:30)', '09:00', '10:30'),
    (N'2. Oturum (11:00-12:30)', '11:00', '12:30'),
    (N'3. Oturum (13:30-15:00)', '13:30', '15:00'),
    (N'4. Oturum (15:30-17:00)', '15:30', '17:00'),
    (N'5. Oturum (17:30-19:00)', '17:30', '19:00');
GO

-- ============================================================
-- Derslikler
-- ============================================================
INSERT INTO Derslikler (Ad, Kapasite, Tip, Kat) VALUES
    (N'Amfi-1',  100, N'Amfi',  0),
    (N'Amfi-2',   80, N'Amfi',  0),
    (N'Z-01',     60, N'Sinif', 0),
    (N'Z-02',     60, N'Sinif', 0),
    (N'Z-03',     60, N'Sinif', 0),
    (N'Z-04',     70, N'Sinif', 0),
    (N'A-101',    50, N'Sinif', 1),
    (N'A-102',    50, N'Sinif', 1),
    (N'A-103',    40, N'Sinif', 1),
    (N'B-201',    30, N'Sinif', 2),
    (N'Lab-1',    30, N'Lab',   1),
    (N'Lab-2',    30, N'Lab',   2);
GO

-- ============================================================
-- Dersler  (BolumID: 1=YM, 2=BM, 3=EE, 4=MM, 5=EM)
-- ============================================================
INSERT INTO Dersler (DersKodu, DersTuru, Ad, OgrenciSayisi, Yariyil, BolumID) VALUES
    -- Yazilim Muhendisligi
    (N'YZM1101', N'Zorunlu', N'Programlamaya Giris',              90,  1, 1),
    (N'YZM1102', N'Zorunlu', N'Matematik I',                       85,  1, 1),
    (N'YZM1103', N'Zorunlu', N'Fizik I',                           88,  1, 1),
    (N'YZM2101', N'Zorunlu', N'Veri Yapilari ve Algoritmalar',     75,  3, 1),
    (N'YZM2102', N'Zorunlu', N'Nesne Yonelimli Programlama',       72,  3, 1),
    (N'YZM2126', N'Zorunlu', N'Veritabani Sistemlerine Giris',    132,  3, 1),
    (N'YZM3101', N'Zorunlu', N'Yazilim Muhendisligi',              68,  5, 1),
    (N'YZM3201', N'Secmeli', N'Yapay Zeka',                        45,  5, 1),
    -- Bilgisayar Muhendisligi
    (N'BM1101',  N'Zorunlu', N'Bilgisayar Organizasyonu',          80,  1, 2),
    (N'BM2201',  N'Zorunlu', N'Algoritma Analizi',                 65,  3, 2),
    (N'BM3301',  N'Zorunlu', N'Isletim Sistemleri',                60,  5, 2),
    -- Elektrik-Elektronik
    (N'EE1101',  N'Zorunlu', N'Devre Analizi',                     95,  1, 3),
    (N'EE2201',  N'Zorunlu', N'Elektromanyetik Alan Teorisi',       70,  3, 3);
GO

-- ============================================================
-- Personel
-- ============================================================
INSERT INTO Personel (Unvan, Ad, Soyad, BolumID) VALUES
    (N'Prof. Dr.', N'Ahmet',   N'Yilmaz',  1),
    (N'Doc. Dr.',  N'Mehmet',  N'Kaya',    1),
    (N'Dr. Ogr.',  N'Ayse',    N'Demir',   1),
    (N'Ar. Gor.',  N'Fatma',   N'Celik',   1),
    (N'Ar. Gor.',  N'Ali',     N'Sahin',   1),
    (N'Prof. Dr.', N'Hasan',   N'Ozturk',  2),
    (N'Doc. Dr.',  N'Zeynep',  N'Arslan',  2),
    (N'Dr. Ogr.',  N'Mustafa', N'Yildiz',  2),
    (N'Ar. Gor.',  N'Emine',   N'Acar',    2),
    (N'Prof. Dr.', N'Ibrahim', N'Coskun',  3),
    (N'Doc. Dr.',  N'Hatice',  N'Polat',   3),
    (N'Dr. Ogr.',  N'Yusuf',   N'Kilic',   4),
    (N'Ar. Gor.',  N'Meryem',  N'Ozkan',   5);
GO

-- ============================================================
-- Personel_Durum (Ornek mazeretler)
-- ============================================================
INSERT INTO Personel_Durum (PersonelID, Tarih, OturumID, MazeretTuru, Aciklama) VALUES
    (3, '2026-06-10', NULL, N'Izinli',           N'Yillik izin'),
    (4, '2026-06-11', 1,   N'DanismanlikSaati', N'Ogrenci danismanligi'),
    (7, '2026-06-12', NULL, N'Diger',            N'Konferans katilimi');
GO

-- ============================================================
-- Sinavlar (Ornek - trigger yeniden aktif edilince cakisma kontrolu devreye girer)
-- ============================================================
INSERT INTO Sinavlar (DersID, Tarih, OturumID) VALUES
    (1, '2026-06-10', 1),   -- YZM1101 - 1.yariyil - 1.oturum
    (9, '2026-06-10', 2),   -- BM1101  - 1.yariyil - 2.oturum (farkli oturum, cakisma yok)
    (4, '2026-06-11', 1),   -- YZM2101 - 3.yariyil - 1.oturum
    (6, '2026-06-11', 2),   -- YZM2126 - 3.yariyil - 2.oturum
    (7, '2026-06-12', 1),   -- YZM3101 - 5.yariyil - 1.oturum
    (12,'2026-06-12', 1);   -- EE1101  - 1.yariyil - 1.oturum (farkli yariyil, cakisma yok)
GO

-- Akilli salon atamasi (YZM2126 - 132 kisi)
-- Amfi-1 (100) + Z-04 (70) -> toplam 170 >= 132
INSERT INTO Sinav_Salonlari (SinavID, DerslikID) VALUES
    (1, 1),   -- YZM1101 -> Amfi-1
    (2, 2),   -- BM1101  -> Amfi-2
    (3, 7),   -- YZM2101 -> A-101
    (4, 1),   -- YZM2126 -> Amfi-1  (100)
    (4, 4);   -- YZM2126 -> Z-02    (60) -> Toplam 160 >= 132
GO

-- Ornek gozetmen atamalari
INSERT INTO Gozetmen_Atamalari (SinavSalonID, PersonelID) VALUES
    (1, 1),   -- Ahmet Yilmaz -> Sinav 1, Amfi-1
    (1, 4),   -- Fatma Celik  -> Sinav 1, Amfi-1
    (2, 6),   -- Hasan Ozturk -> Sinav 2, Amfi-2
    (4, 2),   -- Mehmet Kaya  -> YZM2126, Amfi-1
    (5, 3);   -- Ayse Demir   -> YZM2126, Z-02
GO

-- Triggeri yeniden aktif et
ENABLE TRIGGER dbo.trg_DönemCakismaKontrol ON Sinavlar;
GO

PRINT 'Ornek veriler basariyla eklendi.';
GO
