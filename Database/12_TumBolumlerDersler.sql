-- ============================================================
-- 12_TumBolumlerDersler.sql
-- Tum bolumler icin ders kayitlari
-- Kaynak: PDF ders programlari (guz + bahar, 2025-2026)
-- Calistirma sirasi: 09_ -> 10_ -> 14_ -> 12_ -> 13_
-- ============================================================

-- Cascade temizlik (bagimlilık sirasi)
DELETE FROM Gozetmen_Atamalari;
DELETE FROM Sinav_Salonlari;
DELETE FROM Sinavlar;
DELETE FROM Dersler;

GO

-- ============================================================
-- YZM - YAZILIM MUHENDISLIGI
-- ============================================================
DECLARE @YZM INT;
SELECT @YZM = BolumID FROM Bolumler WHERE BolumAdi = N'Yazilim Muhendisligi';
IF @YZM IS NULL BEGIN PRINT N'HATA: Yazilim Muhendisligi bulunamadi!'; RETURN; END

-- Yariyil 1 (Guz)
IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'YZM1111' AND BolumID=@YZM)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'YZM1111',N'ALGORITMA VE PROGRAMLAMA I',N'Zorunlu',150,1,@YZM);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MAT1301' AND BolumID=@YZM)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MAT1301',N'MATEMATIK I',N'Zorunlu',150,1,@YZM);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'YZM1107' AND BolumID=@YZM)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'YZM1107',N'TEMEL BILGISAYAR BILIMLERI',N'Uzaktan',0,1,@YZM);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'FIZ1301' AND BolumID=@YZM)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'FIZ1301',N'FIZIK I',N'Zorunlu',150,1,@YZM);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'YZM1113' AND BolumID=@YZM)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'YZM1113',N'YAZILIM MUH. KARIYER PLANLAMA',N'Zorunlu',60,1,@YZM);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'AIT1101' AND BolumID=@YZM)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'AIT1101',N'ATATURK ILKELERI VE INKILAP TARIHI I',N'Uzaktan',0,1,@YZM);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'TDL1111' AND BolumID=@YZM)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'TDL1111',N'TURK DILI I',N'Uzaktan',0,1,@YZM);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'YDI1121' AND BolumID=@YZM)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'YDI1121',N'YABANCI DIL I',N'Uzaktan',0,1,@YZM);

-- Yariyil 2 (Bahar)
IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'YZM1108' AND BolumID=@YZM)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'YZM1108',N'YAZILIM MUHENDISLIGINE GIRIS',N'Zorunlu',150,2,@YZM);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'YZM1110' AND BolumID=@YZM)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'YZM1110',N'ALGORITMA VE PROGRAMLAMA II',N'Zorunlu',150,2,@YZM);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MAT1302' AND BolumID=@YZM)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MAT1302',N'MATEMATIK II',N'Zorunlu',150,2,@YZM);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'FIZ1302' AND BolumID=@YZM)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'FIZ1302',N'FIZIK II',N'Zorunlu',60,2,@YZM);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'AIT1102' AND BolumID=@YZM)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'AIT1102',N'ATATURK ILKELERI VE INKILAP TARIHI II',N'Uzaktan',0,2,@YZM);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'TDL1112' AND BolumID=@YZM)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'TDL1112',N'TURK DILI II',N'Uzaktan',0,2,@YZM);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'YDI1122' AND BolumID=@YZM)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'YDI1122',N'YABANCI DIL II',N'Uzaktan',0,2,@YZM);

-- Yariyil 3 (Guz)
IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'YZM2127' AND BolumID=@YZM)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'YZM2127',N'YAZILIM GEREKSINIM ANALIZI',N'Zorunlu',150,3,@YZM);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'YZM2113' AND BolumID=@YZM)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'YZM2113',N'MUHENDISLIK MATEMATIGI',N'Zorunlu',150,3,@YZM);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'YZM2123' AND BolumID=@YZM)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'YZM2123',N'WEB PROGRAMLAMAYA GIRIS',N'Zorunlu',150,3,@YZM);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'YZM2125' AND BolumID=@YZM)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'YZM2125',N'NESNEYE YONELIMLI PROGRAMLAMA',N'Zorunlu',150,3,@YZM);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'YZM2111' AND BolumID=@YZM)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'YZM2111',N'AYRIK YAPILAR',N'Zorunlu',150,3,@YZM);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'YZM2135' AND BolumID=@YZM)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'YZM2135',N'DIFERANSIYEL DENKLEMLER',N'Zorunlu',80,3,@YZM);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'CBU4403' AND BolumID=@YZM)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'CBU4403',N'IS SAGLIGI VE GUVENLIGI I',N'Zorunlu',60,3,@YZM);

-- Yariyil 4 (Bahar)
IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'YZM2134' AND BolumID=@YZM)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'YZM2134',N'YAPAY ZEKADA MATEMATIKSEL YONTEMLER',N'Zorunlu',150,4,@YZM);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'YZM2118' AND BolumID=@YZM)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'YZM2118',N'YAZILIM MIMARISI VE TASARIMI',N'Zorunlu',150,4,@YZM);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'YZM2122' AND BolumID=@YZM)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'YZM2122',N'YAZILIM YAPIMI',N'Zorunlu',150,4,@YZM);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'YZM2124' AND BolumID=@YZM)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'YZM2124',N'VERI YAPILARI',N'Zorunlu',60,4,@YZM);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'YZM2126' AND BolumID=@YZM)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'YZM2126',N'VERITABANI SISTEMLERINE GIRIS',N'Zorunlu',60,4,@YZM);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'YZM2114' AND BolumID=@YZM)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'YZM2114',N'OLASILIK VE ISTATISTIK',N'Zorunlu',150,4,@YZM);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'CBU4404' AND BolumID=@YZM)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'CBU4404',N'IS SAGLIGI VE GUVENLIGI II',N'Zorunlu',80,4,@YZM);

-- Yariyil 5 (Guz)
IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'YZM3107' AND BolumID=@YZM)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'YZM3107',N'VERITABANI YONETIM SISTEMLERI',N'Zorunlu',80,5,@YZM);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'YZM3109' AND BolumID=@YZM)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'YZM3109',N'BILGISAYAR AGLARI',N'Zorunlu',60,5,@YZM);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'YZM3111' AND BolumID=@YZM)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'YZM3111',N'YAZILIM SINAMASI',N'Zorunlu',150,5,@YZM);

-- Yariyil 6 (Bahar)
IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'YZM3114' AND BolumID=@YZM)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'YZM3114',N'PROFESYONEL YAZILIM GELISTIRME I',N'Zorunlu',60,6,@YZM);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'YZM3112' AND BolumID=@YZM)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'YZM3112',N'ALGORITMA ANALIZI VE TASARIMI',N'Zorunlu',150,6,@YZM);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'YZM3108' AND BolumID=@YZM)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'YZM3108',N'ISLETIM SISTEMLERI',N'Zorunlu',150,6,@YZM);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'YZM3110' AND BolumID=@YZM)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'YZM3110',N'YAZILIM PROJESI YONETIMI',N'Zorunlu',60,6,@YZM);

-- Yariyil 7 (Guz)
IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'YZM4105' AND BolumID=@YZM)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'YZM4105',N'SOSYAL SORUMLULUK',N'Zorunlu',60,7,@YZM);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'YZM4104' AND BolumID=@YZM)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'YZM4104',N'IS YERI UYGULAMA EGITIMI',N'Uzaktan',0,7,@YZM);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'YZM4115' AND BolumID=@YZM)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'YZM4115',N'PROFESYONEL YAZILIM GELISTIRME II',N'Zorunlu',60,7,@YZM);

-- Yariyil 8 (Bahar)
IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'YZM4106' AND BolumID=@YZM)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'YZM4106',N'ISLETMEDE MESLEKI EGITIM',N'Uzaktan',0,8,@YZM);

GO

-- ============================================================
-- ELK - ELEKTRIK MUHENDISLIGI
-- ============================================================
DECLARE @ELK INT;
SELECT @ELK = BolumID FROM Bolumler WHERE BolumAdi = N'Elektrik Muhendisligi';
IF @ELK IS NULL BEGIN PRINT N'HATA: Elektrik Muhendisligi bulunamadi!'; RETURN; END

-- Yariyil 1 (Guz) - FIZ1301 oda 309 -> 80
IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MAT1301' AND BolumID=@ELK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MAT1301',N'MATEMATIK I',N'Zorunlu',60,1,@ELK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'ELK1107' AND BolumID=@ELK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'ELK1107',N'BILGISAYAR DESTEKLI CIZIM',N'Laboratuvar',0,1,@ELK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'ELK1101' AND BolumID=@ELK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'ELK1101',N'LINEER CEBIR',N'Zorunlu',60,1,@ELK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'FIZ1301' AND BolumID=@ELK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'FIZ1301',N'FIZIK I',N'Zorunlu',80,1,@ELK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'ELK1105' AND BolumID=@ELK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'ELK1105',N'ELEKTRIK MUHENDISLIGINE GIRIS',N'Zorunlu',60,1,@ELK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'ELK1103' AND BolumID=@ELK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'ELK1103',N'KARIYER PLANLAMA',N'Zorunlu',60,1,@ELK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'AIT1101' AND BolumID=@ELK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'AIT1101',N'ATATURK ILKELERI VE INKILAP TARIHI I',N'Uzaktan',0,1,@ELK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'TDL1111' AND BolumID=@ELK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'TDL1111',N'TURK DILI I',N'Uzaktan',0,1,@ELK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'YDI1121' AND BolumID=@ELK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'YDI1121',N'YABANCI DIL I',N'Uzaktan',0,1,@ELK);

-- Yariyil 2 (Bahar)
IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'ELK1106' AND BolumID=@ELK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'ELK1106',N'ELEKTRIK OLCME TEKNIKLERI',N'Zorunlu',60,2,@ELK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'ELK1104' AND BolumID=@ELK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'ELK1104',N'BILGISAYAR PROGRAMLAMA',N'Laboratuvar',0,2,@ELK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MAT1302' AND BolumID=@ELK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MAT1302',N'MATEMATIK II',N'Zorunlu',60,2,@ELK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'ELK1102' AND BolumID=@ELK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'ELK1102',N'ELEKTRIK DEVRELERI I',N'Zorunlu',60,2,@ELK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'FIZ1302' AND BolumID=@ELK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'FIZ1302',N'FIZIK II',N'Zorunlu',60,2,@ELK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'AIT1102' AND BolumID=@ELK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'AIT1102',N'ATATURK ILKELERI VE INKILAP TARIHI II',N'Uzaktan',0,2,@ELK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'TDL1112' AND BolumID=@ELK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'TDL1112',N'TURK DILI II',N'Uzaktan',0,2,@ELK);

-- Yariyil 3 (Guz - 2. Sinif)
IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'ELK2107' AND BolumID=@ELK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'ELK2107',N'ELEKTRONIK',N'Zorunlu',60,3,@ELK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'ELK2101' AND BolumID=@ELK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'ELK2101',N'ELEKTRIK DEVRELERI II',N'Zorunlu',60,3,@ELK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'ELK2103' AND BolumID=@ELK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'ELK2103',N'ELEKTROMANYETIK ALAN TEORISI',N'Zorunlu',60,3,@ELK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'ELK2105' AND BolumID=@ELK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'ELK2105',N'DIFERANSIYEL DENKLEMLER',N'Zorunlu',60,3,@ELK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'CBU4403' AND BolumID=@ELK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'CBU4403',N'IS SAGLIGI VE GUVENLIGI I',N'Zorunlu',60,3,@ELK);

-- Yariyil 4 (Bahar - 2. Sinif)
IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'ELK2104' AND BolumID=@ELK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'ELK2104',N'AYDINLATMA TEKNIGI VE TESIS PROJESI',N'Zorunlu',60,4,@ELK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'ELK2102' AND BolumID=@ELK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'ELK2102',N'SAYISAL ELEKTRONIK',N'Zorunlu',60,4,@ELK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'ELK2110' AND BolumID=@ELK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'ELK2110',N'ELEKTRIK VE ELEKTROMEKANIK ENERJI DONUSUMU',N'Zorunlu',60,4,@ELK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'ELK2112' AND BolumID=@ELK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'ELK2112',N'AYRIK MATEMATIK',N'Zorunlu',60,4,@ELK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'CBU4404' AND BolumID=@ELK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'CBU4404',N'IS SAGLIGI VE GUVENLIGI II',N'Zorunlu',60,4,@ELK);

GO

-- ============================================================
-- MAK - MAKINE MUHENDISLIGI
-- ============================================================
DECLARE @MAK INT;
SELECT @MAK = BolumID FROM Bolumler WHERE BolumAdi = N'Makine Muhendisligi';
IF @MAK IS NULL BEGIN PRINT N'HATA: Makine Muhendisligi bulunamadi!'; RETURN; END

-- Yariyil 1 (Guz)
IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MAK1101' AND BolumID=@MAK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MAK1101',N'TEKNIK RESIM',N'Zorunlu',60,1,@MAK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'KIM1301' AND BolumID=@MAK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'KIM1301',N'KIMYA',N'Zorunlu',150,1,@MAK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MAT1301' AND BolumID=@MAK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MAT1301',N'MATEMATIK I',N'Zorunlu',80,1,@MAK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'FIZ1301' AND BolumID=@MAK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'FIZ1301',N'FIZIK I',N'Zorunlu',60,1,@MAK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MAK1103' AND BolumID=@MAK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MAK1103',N'MAKINE MUH. GIRIS',N'Zorunlu',150,1,@MAK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'AIT1101' AND BolumID=@MAK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'AIT1101',N'ATATURK ILKELERI VE INKILAP TARIHI I',N'Uzaktan',0,1,@MAK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'TDL1111' AND BolumID=@MAK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'TDL1111',N'TURK DILI I',N'Uzaktan',0,1,@MAK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'YDI1121' AND BolumID=@MAK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'YDI1121',N'YABANCI DIL I',N'Uzaktan',0,1,@MAK);

-- Yariyil 2 (Bahar)
IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MAK1102' AND BolumID=@MAK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MAK1102',N'BILGISAYAR DESTEKLI TEKNIK RESIM',N'Laboratuvar',0,2,@MAK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MAT1302' AND BolumID=@MAK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MAT1302',N'MATEMATIK II',N'Zorunlu',80,2,@MAK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MAK1104' AND BolumID=@MAK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MAK1104',N'STATIK',N'Zorunlu',150,2,@MAK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'FIZ1302' AND BolumID=@MAK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'FIZ1302',N'FIZIK II',N'Zorunlu',150,2,@MAK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'AIT1102' AND BolumID=@MAK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'AIT1102',N'ATATURK ILKELERI VE INKILAP TARIHI II',N'Uzaktan',0,2,@MAK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'TDL1112' AND BolumID=@MAK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'TDL1112',N'TURK DILI II',N'Uzaktan',0,2,@MAK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'YDI1122' AND BolumID=@MAK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'YDI1122',N'YABANCI DIL II',N'Uzaktan',0,2,@MAK);

-- Yariyil 3 (Guz - 2. Sinif)
IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MAK2101' AND BolumID=@MAK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MAK2101',N'MUHENDISLIK MATEMATIGI I',N'Zorunlu',150,3,@MAK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MAK2105' AND BolumID=@MAK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MAK2105',N'MALZEME BILIMI',N'Zorunlu',150,3,@MAK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MAK2107' AND BolumID=@MAK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MAK2107',N'AKISKANLAR MEKANIGI',N'Zorunlu',150,3,@MAK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MAK2109' AND BolumID=@MAK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MAK2109',N'TERMODINAMIK I',N'Zorunlu',150,3,@MAK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MAK2111' AND BolumID=@MAK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MAK2111',N'ENDUSTRIYEL OLCME',N'Zorunlu',60,3,@MAK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MAK2113' AND BolumID=@MAK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MAK2113',N'DINAMIK',N'Zorunlu',80,3,@MAK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MAK2119' AND BolumID=@MAK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MAK2119',N'MUKAVEMET I',N'Zorunlu',150,3,@MAK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MAK2121' AND BolumID=@MAK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MAK2121',N'MUH. DENEYSEL METODLAR I',N'Zorunlu',60,3,@MAK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MAK2127' AND BolumID=@MAK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MAK2127',N'ISTATISTIK',N'Zorunlu',150,3,@MAK);

-- Yariyil 4 (Bahar - 2. Sinif)
IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MAK2102' AND BolumID=@MAK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MAK2102',N'MUHENDISLIK MATEMATIGI II',N'Zorunlu',80,4,@MAK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MAK2104' AND BolumID=@MAK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MAK2104',N'MUKAVEMET II',N'Zorunlu',150,4,@MAK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MAK2106' AND BolumID=@MAK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MAK2106',N'MUHENDISLIK MALZEMELERI',N'Zorunlu',80,4,@MAK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MAK2108' AND BolumID=@MAK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MAK2108',N'DINAMIK',N'Zorunlu',80,4,@MAK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MAK2110' AND BolumID=@MAK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MAK2110',N'ISI TRANSFERI',N'Zorunlu',150,4,@MAK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MAK2114' AND BolumID=@MAK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MAK2114',N'MUH. DENEYSEL METOTLAR II',N'Zorunlu',60,4,@MAK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MAK2116' AND BolumID=@MAK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MAK2116',N'MUKAVEMET III',N'Zorunlu',150,4,@MAK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MAK2120' AND BolumID=@MAK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MAK2120',N'TERMODINAMIK II',N'Zorunlu',150,4,@MAK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MAK2132' AND BolumID=@MAK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MAK2132',N'SAYISAL ANALIZ',N'Zorunlu',60,4,@MAK);

-- Yariyil 5 (Guz - 3. Sinif)
IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MAK3101' AND BolumID=@MAK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MAK3101',N'MAKINE ELEMANLARI I',N'Zorunlu',80,5,@MAK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MAK3103' AND BolumID=@MAK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MAK3103',N'MUKAVEMET IV',N'Zorunlu',60,5,@MAK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MAK3105' AND BolumID=@MAK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MAK3105',N'MEKANIZMA TEKNIGI',N'Zorunlu',60,5,@MAK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MAK3107' AND BolumID=@MAK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MAK3107',N'SISTEM ANALIZI VE KONTROL',N'Zorunlu',60,5,@MAK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MAK3109' AND BolumID=@MAK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MAK3109',N'BILGISAYAR DESTEKLI MUHENDISLIK',N'Laboratuvar',0,5,@MAK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MAK3113' AND BolumID=@MAK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MAK3113',N'URETIM YONTEMLERI I',N'Zorunlu',60,5,@MAK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'CBU4403' AND BolumID=@MAK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'CBU4403',N'IS SAGLIGI VE GUVENLIGI I',N'Zorunlu',60,5,@MAK);

-- Yariyil 6 (Bahar - 3. Sinif)
IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MAK3102' AND BolumID=@MAK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MAK3102',N'MAKINE ELEMANLARI II',N'Zorunlu',60,6,@MAK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MAK3104' AND BolumID=@MAK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MAK3104',N'ISTATISTIK',N'Zorunlu',60,6,@MAK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MAK3108' AND BolumID=@MAK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MAK3108',N'ELEKTRONIK VE OTOMASYON BILGISI',N'Zorunlu',80,6,@MAK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MAK3110' AND BolumID=@MAK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MAK3110',N'MUHENDISLIK YONETIMI VE EKONOMISI',N'Zorunlu',60,6,@MAK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MAK3112' AND BolumID=@MAK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MAK3112',N'URETIM YONTEMLERI II',N'Zorunlu',60,6,@MAK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MAK3116' AND BolumID=@MAK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MAK3116',N'MAKINE DINAMIGI',N'Zorunlu',60,6,@MAK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MAK3124' AND BolumID=@MAK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MAK3124',N'ISI TRANSFERI',N'Zorunlu',150,6,@MAK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'CBU4404' AND BolumID=@MAK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'CBU4404',N'IS SAGLIGI VE GUVENLIGI II',N'Zorunlu',60,6,@MAK);

-- Yariyil 7 (Guz - 4. Sinif)
IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MAK4105' AND BolumID=@MAK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MAK4105',N'SOSYAL SORUMLULUK',N'Zorunlu',60,7,@MAK);

GO

-- ============================================================
-- MEK - MEKATRONIK MUHENDISLIGI
-- ============================================================
DECLARE @MEK INT;
SELECT @MEK = BolumID FROM Bolumler WHERE BolumAdi = N'Mekatronik Muhendisligi';
IF @MEK IS NULL BEGIN PRINT N'HATA: Mekatronik Muhendisligi bulunamadi!'; RETURN; END

-- Yariyil 1 (Guz)
IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MKR1101' AND BolumID=@MEK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MKR1101',N'MEKATRONIK MUH. GIRIS',N'Zorunlu',60,1,@MEK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MAT1301' AND BolumID=@MEK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MAT1301',N'MATEMATIK I',N'Zorunlu',150,1,@MEK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'FIZ1301' AND BolumID=@MEK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'FIZ1301',N'FIZIK I',N'Zorunlu',150,1,@MEK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'KIM1311' AND BolumID=@MEK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'KIM1311',N'KIMYA',N'Zorunlu',150,1,@MEK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MKR1103' AND BolumID=@MEK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MKR1103',N'BILGISAYAR BILIMI VE PROGRAMLAMAYA GIRIS',N'Laboratuvar',0,1,@MEK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'AIT1101' AND BolumID=@MEK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'AIT1101',N'ATATURK ILKELERI VE INKILAP TARIHI I',N'Uzaktan',0,1,@MEK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'TDL1111' AND BolumID=@MEK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'TDL1111',N'TURK DILI I',N'Uzaktan',0,1,@MEK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'YDI1121' AND BolumID=@MEK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'YDI1121',N'YABANCI DIL I',N'Uzaktan',0,1,@MEK);

-- Yariyil 2 (Bahar)
IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MAT1302' AND BolumID=@MEK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MAT1302',N'MATEMATIK II',N'Zorunlu',60,2,@MEK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MKR1102' AND BolumID=@MEK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MKR1102',N'STATIK',N'Zorunlu',80,2,@MEK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MKR1104' AND BolumID=@MEK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MKR1104',N'BILGISAYAR PROGRAMLAMA',N'Zorunlu',60,2,@MEK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MKR1106' AND BolumID=@MEK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MKR1106',N'ELEKTRIK DEVRELERI',N'Zorunlu',60,2,@MEK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MKR1108' AND BolumID=@MEK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MKR1108',N'BILGISAYAR DESTEKLI TEKNIK RESIM',N'Laboratuvar',0,2,@MEK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'FIZ1302' AND BolumID=@MEK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'FIZ1302',N'FIZIK II',N'Zorunlu',60,2,@MEK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'AIT1102' AND BolumID=@MEK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'AIT1102',N'ATATURK ILKELERI VE INKILAP TARIHI II',N'Uzaktan',0,2,@MEK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'TDL1112' AND BolumID=@MEK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'TDL1112',N'TURK DILI II',N'Uzaktan',0,2,@MEK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'YDI1122' AND BolumID=@MEK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'YDI1122',N'YABANCI DIL II',N'Uzaktan',0,2,@MEK);

-- Yariyil 3 (Guz - 2. Sinif)
IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MKR2109' AND BolumID=@MEK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MKR2109',N'DIFERANSIYEL DENKLEMLER',N'Zorunlu',150,3,@MEK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MKR2111' AND BolumID=@MEK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MKR2111',N'DINAMIK',N'Zorunlu',60,3,@MEK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MKR2113' AND BolumID=@MEK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MKR2113',N'MANTIK DEVRELERI',N'Zorunlu',150,3,@MEK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MKR2117' AND BolumID=@MEK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MKR2117',N'MUKAVEMET',N'Zorunlu',60,3,@MEK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MKT2103' AND BolumID=@MEK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MKT2103',N'ELEKTRIK DEVRELERI II',N'Zorunlu',60,3,@MEK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MKT2105' AND BolumID=@MEK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MKT2105',N'STATIK',N'Zorunlu',60,3,@MEK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MKT2109' AND BolumID=@MEK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MKT2109',N'MALZEME BILIMI',N'Zorunlu',80,3,@MEK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MKT2115' AND BolumID=@MEK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MKT2115',N'MUHENDISLER ICIN KIMYA',N'Zorunlu',150,3,@MEK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'CBU4403' AND BolumID=@MEK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'CBU4403',N'IS SAGLIGI VE GUVENLIGI I',N'Zorunlu',150,3,@MEK);

-- Yariyil 4 (Bahar - 2. Sinif)
IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MKR2110' AND BolumID=@MEK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MKR2110',N'ALGILAYICILAR VE AKTUATORLER',N'Zorunlu',150,4,@MEK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MKR2112' AND BolumID=@MEK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MKR2112',N'ELEKTRIK MAKINELERI',N'Zorunlu',60,4,@MEK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MKR2114' AND BolumID=@MEK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MKR2114',N'ELEKTRONIK DEVRELER VE ANALIZI',N'Zorunlu',150,4,@MEK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MKR2118' AND BolumID=@MEK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MKR2118',N'MALZEME KIMYASI VE BILIMI',N'Zorunlu',80,4,@MEK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MKR2120' AND BolumID=@MEK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MKR2120',N'LINEER CEBIR',N'Zorunlu',150,4,@MEK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MKT2102' AND BolumID=@MEK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MKT2102',N'MUHENDISLIK MATEMATIGI II',N'Zorunlu',150,4,@MEK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MKT2106' AND BolumID=@MEK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MKT2106',N'MUKAVEMET',N'Zorunlu',60,4,@MEK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MKT2108' AND BolumID=@MEK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MKT2108',N'MAKINE TEORISI',N'Zorunlu',60,4,@MEK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MKT2110' AND BolumID=@MEK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MKT2110',N'MAKINE ELEMANLARI',N'Zorunlu',150,4,@MEK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'CBU4404' AND BolumID=@MEK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'CBU4404',N'IS SAGLIGI VE GUVENLIGI II',N'Zorunlu',80,4,@MEK);

-- Yariyil 5 (Guz - 3. Sinif)
IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MKT3101' AND BolumID=@MEK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MKT3101',N'OTOMATIK KONTROL I',N'Zorunlu',60,5,@MEK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MKT3103' AND BolumID=@MEK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MKT3103',N'HIDROLIK VE PNOMATIK SISTEMLERI',N'Zorunlu',150,5,@MEK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MKT3105' AND BolumID=@MEK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MKT3105',N'AKISKANLAR MEKANIGI',N'Zorunlu',60,5,@MEK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MKT3107' AND BolumID=@MEK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MKT3107',N'BILGISAYAR DESTEKLI TASARIM',N'Laboratuvar',0,5,@MEK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MKT3109' AND BolumID=@MEK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MKT3109',N'MIKRODENETLEYICILER',N'Zorunlu',150,5,@MEK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MKT3111' AND BolumID=@MEK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MKT3111',N'GUC ELEKTRONI VE SURUCU SISTEMLERI',N'Zorunlu',60,5,@MEK);

-- Yariyil 6 (Bahar - 3. Sinif)
IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MKT3102' AND BolumID=@MEK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MKT3102',N'OTOMATIK KONTROL II',N'Zorunlu',60,6,@MEK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MKT3104' AND BolumID=@MEK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MKT3104',N'ALGILAYICILAR VE AKTUATORLER',N'Zorunlu',60,6,@MEK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MKT3106' AND BolumID=@MEK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MKT3106',N'TERMODINAMIK VE ISI TRANSFERI',N'Zorunlu',60,6,@MEK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MKT3108' AND BolumID=@MEK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MKT3108',N'BILGISAYAR DESTEKLI URETIM',N'Laboratuvar',0,6,@MEK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MKT3110' AND BolumID=@MEK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MKT3110',N'ENDUSTRIYEL OTOMASYON SISTEMLERI',N'Zorunlu',150,6,@MEK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MKT3112' AND BolumID=@MEK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MKT3112',N'ROBOTIK',N'Zorunlu',150,6,@MEK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MKT3120' AND BolumID=@MEK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MKT3120',N'MEKATRONIK MUH. PROJESI',N'Zorunlu',60,6,@MEK);

-- Yariyil 7 (Guz - 4. Sinif)
IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MKT4105' AND BolumID=@MEK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MKT4105',N'SOSYAL SORUMLULUK',N'Zorunlu',60,7,@MEK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MKT4111' AND BolumID=@MEK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MKT4111',N'MEKATRONIK MUH. TASARIMI',N'Zorunlu',60,7,@MEK);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MKT4112' AND BolumID=@MEK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MKT4112',N'ISLETMEDE MESLEKI EGITIM',N'Zorunlu',60,7,@MEK);

-- Yariyil 8 (Bahar - 4. Sinif)
IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MKT4101' AND BolumID=@MEK)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MKT4101',N'MEKATRONIK MUHENDISLIGI TASARIMI',N'Zorunlu',60,8,@MEK);

GO

-- ============================================================
-- ENS - ENERJI SISTEMLERI MUHENDISLIGI
-- ============================================================
DECLARE @ENS INT;
SELECT @ENS = BolumID FROM Bolumler WHERE BolumAdi = N'Enerji Sistemleri Muhendisligi';
IF @ENS IS NULL BEGIN PRINT N'HATA: Enerji Sistemleri Muhendisligi bulunamadi!'; RETURN; END

-- Yariyil 1 (Guz)
IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'ESM1103' AND BolumID=@ENS)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'ESM1103',N'ENERJI SIS. MUH. GIRIS',N'Zorunlu',60,1,@ENS);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'ESM1107' AND BolumID=@ENS)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'ESM1107',N'TEMEL BILGISAYAR BILIMLERI',N'Laboratuvar',0,1,@ENS);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'ESM1109' AND BolumID=@ENS)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'ESM1109',N'KARIYER PLANLAMA',N'Zorunlu',60,1,@ENS);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MAT1301' AND BolumID=@ENS)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MAT1301',N'MATEMATIK I',N'Zorunlu',60,1,@ENS);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'FIZ1301' AND BolumID=@ENS)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'FIZ1301',N'FIZIK I',N'Zorunlu',60,1,@ENS);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'KIM1311' AND BolumID=@ENS)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'KIM1311',N'KIMYA',N'Zorunlu',60,1,@ENS);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'AIT1101' AND BolumID=@ENS)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'AIT1101',N'ATATURK ILKELERI VE INKILAP TARIHI I',N'Uzaktan',0,1,@ENS);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'TDL1111' AND BolumID=@ENS)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'TDL1111',N'TURK DILI I',N'Uzaktan',0,1,@ENS);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'YDI1121' AND BolumID=@ENS)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'YDI1121',N'YABANCI DIL I',N'Uzaktan',0,1,@ENS);

-- Yariyil 2 (Bahar) - MAT1302 oda 409 -> 150
IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'ESM1102' AND BolumID=@ENS)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'ESM1102',N'ELEKTRIK DEVRELERI I',N'Zorunlu',60,2,@ENS);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'ESM1104' AND BolumID=@ENS)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'ESM1104',N'BILGISAYAR DESTEKLI TEKNIK RESIM',N'Laboratuvar',0,2,@ENS);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'ESM1106' AND BolumID=@ENS)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'ESM1106',N'BILGISAYAR BILIMI VE PROGRAMLAMA',N'Laboratuvar',0,2,@ENS);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'ESM1108' AND BolumID=@ENS)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'ESM1108',N'ALGORITMA VE PROGRAMLAMANIN TEMELLERI',N'Laboratuvar',0,2,@ENS);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'ESM1110' AND BolumID=@ENS)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'ESM1110',N'SOSYAL SORUMLULUK PROJESI',N'Zorunlu',60,2,@ENS);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'MAT1302' AND BolumID=@ENS)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'MAT1302',N'MATEMATIK II',N'Zorunlu',150,2,@ENS);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'FIZ1302' AND BolumID=@ENS)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'FIZ1302',N'FIZIK II',N'Zorunlu',60,2,@ENS);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'AIT1102' AND BolumID=@ENS)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'AIT1102',N'ATATURK ILKELERI VE INKILAP TARIHI II',N'Uzaktan',0,2,@ENS);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'TDL1112' AND BolumID=@ENS)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'TDL1112',N'TURK DILI II',N'Uzaktan',0,2,@ENS);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'YDI1122' AND BolumID=@ENS)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'YDI1122',N'YABANCI DIL II',N'Uzaktan',0,2,@ENS);

-- Yariyil 3 (Guz - 2. Sinif) - ESM2107(310->150), ESM2111/ESM2121(409->150)
IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'ESM2101' AND BolumID=@ENS)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'ESM2101',N'MUHENDISLIK MATEMATIGI',N'Zorunlu',60,3,@ENS);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'ESM2105' AND BolumID=@ENS)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'ESM2105',N'MALZEME BILIMI',N'Zorunlu',60,3,@ENS);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'ESM2107' AND BolumID=@ENS)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'ESM2107',N'STATIK',N'Zorunlu',150,3,@ENS);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'ESM2111' AND BolumID=@ENS)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'ESM2111',N'ELEKTRIK DEVRELERI I',N'Zorunlu',150,3,@ENS);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'ESM2113' AND BolumID=@ENS)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'ESM2113',N'ELEKTROMEKANIK ENERJI DONUSUMU',N'Zorunlu',60,3,@ENS);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'ESM2117' AND BolumID=@ENS)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'ESM2117',N'AKISKANLAR MEKANIGI I',N'Zorunlu',60,3,@ENS);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'ESM2119' AND BolumID=@ENS)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'ESM2119',N'TERMODINAMIK I',N'Zorunlu',60,3,@ENS);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'ESM2121' AND BolumID=@ENS)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'ESM2121',N'ELEKTRIK DEVRELERI II',N'Zorunlu',150,3,@ENS);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'ESM2123' AND BolumID=@ENS)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'ESM2123',N'TEMEL ELEKTRONIK',N'Zorunlu',60,3,@ENS);

-- Yariyil 4 (Bahar - 2. Sinif)
IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'ESM2102' AND BolumID=@ENS)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'ESM2102',N'DINAMIK',N'Zorunlu',60,4,@ENS);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'ESM2104' AND BolumID=@ENS)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'ESM2104',N'MUKAVEMET',N'Zorunlu',60,4,@ENS);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'ESM2106' AND BolumID=@ENS)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'ESM2106',N'OLCME TEKNIGI',N'Zorunlu',60,4,@ENS);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'ESM2108' AND BolumID=@ENS)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'ESM2108',N'AKISKANLAR MEKANIGI II',N'Zorunlu',60,4,@ENS);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'ESM2110' AND BolumID=@ENS)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'ESM2110',N'TERMODINAMIK II',N'Zorunlu',60,4,@ENS);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'ESM2112' AND BolumID=@ENS)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'ESM2112',N'ELEKTRIK MAKINELERI',N'Zorunlu',60,4,@ENS);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'ESM2116' AND BolumID=@ENS)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'ESM2116',N'ENDUSTRIYEL OLCME VE KONTROL',N'Zorunlu',60,4,@ENS);

-- Yariyil 5 (Guz - 3. Sinif) - ESM3105 oda 409 -> 150
IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'ESM3101' AND BolumID=@ENS)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'ESM3101',N'RUZGAR ENERJISI TEKNOLOJILERI',N'Zorunlu',60,5,@ENS);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'ESM3103' AND BolumID=@ENS)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'ESM3103',N'KAZANLAR VE YANMA TEKNOLOJILERI',N'Zorunlu',60,5,@ENS);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'ESM3105' AND BolumID=@ENS)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'ESM3105',N'MAKINE ELEMANLARI',N'Zorunlu',150,5,@ENS);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'ESM3107' AND BolumID=@ENS)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'ESM3107',N'GUC ELEKTRONI',N'Zorunlu',60,5,@ENS);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'ESM3109' AND BolumID=@ENS)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'ESM3109',N'ENERJI MUHENDISLIGI LABORATUVARI I',N'Laboratuvar',0,5,@ENS);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'CBU4403' AND BolumID=@ENS)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'CBU4403',N'IS SAGLIGI VE GUVENLIGI I',N'Zorunlu',60,5,@ENS);

-- Yariyil 6 (Bahar - 3. Sinif)
IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'ESM3102' AND BolumID=@ENS)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'ESM3102',N'YENILENEBILIR ENERJI KAYNAKLARI',N'Zorunlu',60,6,@ENS);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'ESM3104' AND BolumID=@ENS)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'ESM3104',N'ENERJI ILETIMI VE DAGITIMI',N'Zorunlu',60,6,@ENS);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'ESM3106' AND BolumID=@ENS)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'ESM3106',N'ENERJI VERIMLILIGI VE YONETIMI',N'Zorunlu',60,6,@ENS);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'ESM3110' AND BolumID=@ENS)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'ESM3110',N'MUHENDISLIK TASARIMI',N'Zorunlu',60,6,@ENS);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'ESM3112' AND BolumID=@ENS)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'ESM3112',N'ENERJI MUHENDISLIGI LABORATUVARI II',N'Laboratuvar',0,6,@ENS);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'ESM3114' AND BolumID=@ENS)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'ESM3114',N'GUC SISTEMLERI ANALIZI',N'Zorunlu',60,6,@ENS);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'CBU4404' AND BolumID=@ENS)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'CBU4404',N'IS SAGLIGI VE GUVENLIGI II',N'Zorunlu',60,6,@ENS);

-- Yariyil 7 (Guz - 4. Sinif)
IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'ESM4101' AND BolumID=@ENS)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'ESM4101',N'MUHENDISLIKTE BILGISAYAR UYGULAMALARI',N'Laboratuvar',0,7,@ENS);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'ESM4106' AND BolumID=@ENS)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'ESM4106',N'ISLETMEDE MESLEKI EGITIM',N'Zorunlu',60,7,@ENS);

IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'ESM4111' AND BolumID=@ENS)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'ESM4111',N'MUHENDISLIK PROJESI',N'Zorunlu',60,7,@ENS);

-- Yariyil 8 (Bahar - 4. Sinif)
IF NOT EXISTS (SELECT 1 FROM Dersler WHERE DersKodu=N'ESM4102' AND BolumID=@ENS)
    INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID)
    VALUES(N'ESM4102',N'ENERJI KANUNLARI VE DUZENLEMELERI',N'Zorunlu',60,8,@ENS);

GO

PRINT N'12_TumBolumlerDersler.sql basariyla tamamlandi.';
PRINT N'Bolumler: YZM, ELK, MAK, MEK, ENS';
PRINT N'Lab dersleri DersTuru=Laboratuvar OgrenciSayisi=0 olarak eklendi.';
PRINT N'Uzaktan dersler DersTuru=Uzaktan OgrenciSayisi=0 olarak eklendi.';
