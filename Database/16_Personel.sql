-- ============================================================
-- 16_Personel.sql
-- Tum bolum akademik kadro personeli eklenir.
-- Kaynak: Bolum web sayfalarindan alinan akademik kadro listesi
-- Karakter donusumu: TR -> ASCII (I,S,G,U,O,C)
-- Idempotent: IF NOT EXISTS ile tekrar calistirilabilir.
-- ============================================================
USE SinavTakip;
GO

-- ============================================================
-- ELK - ELEKTRIK MUHENDISLIGI
-- ============================================================
DECLARE @ELK INT;
SELECT @ELK = BolumID FROM Bolumler WHERE BolumAdi = N'Elektrik Muhendisligi';
IF @ELK IS NULL BEGIN PRINT N'HATA: Elektrik Muhendisligi bulunamadi!'; RETURN; END

IF NOT EXISTS (SELECT 1 FROM Personel WHERE Ad=N'KIVANC'        AND Soyad=N'BASARAN'       AND BolumID=@ELK)
    INSERT INTO Personel(Unvan,Ad,Soyad,BolumID) VALUES(N'Prof. Dr.',      N'KIVANC',        N'BASARAN',      @ELK);

IF NOT EXISTS (SELECT 1 FROM Personel WHERE Ad=N'ISMAIL'        AND Soyad=N'YABANOVA'       AND BolumID=@ELK)
    INSERT INTO Personel(Unvan,Ad,Soyad,BolumID) VALUES(N'Doc. Dr.',       N'ISMAIL',        N'YABANOVA',     @ELK);

IF NOT EXISTS (SELECT 1 FROM Personel WHERE Ad=N'GOKSU'         AND Soyad=N'GOREL'          AND BolumID=@ELK)
    INSERT INTO Personel(Unvan,Ad,Soyad,BolumID) VALUES(N'Doc. Dr.',       N'GOKSU',         N'GOREL',        @ELK);

IF NOT EXISTS (SELECT 1 FROM Personel WHERE Ad=N'BAYRAM MELIH'  AND Soyad=N'YILMAZ'         AND BolumID=@ELK)
    INSERT INTO Personel(Unvan,Ad,Soyad,BolumID) VALUES(N'Dr. Ogr. Uyesi', N'BAYRAM MELIH',  N'YILMAZ',       @ELK);

IF NOT EXISTS (SELECT 1 FROM Personel WHERE Ad=N'YILMAZ SERYAR' AND Soyad=N'ARIKUSU'        AND BolumID=@ELK)
    INSERT INTO Personel(Unvan,Ad,Soyad,BolumID) VALUES(N'Dr. Ogr. Uyesi', N'YILMAZ SERYAR', N'ARIKUSU',      @ELK);

GO

-- ============================================================
-- ENS - ENERJI SISTEMLERI MUHENDISLIGI
-- ============================================================
DECLARE @ENS INT;
SELECT @ENS = BolumID FROM Bolumler WHERE BolumAdi = N'Enerji Sistemleri Muhendisligi';
IF @ENS IS NULL BEGIN PRINT N'HATA: Enerji Sistemleri Muhendisligi bulunamadi!'; RETURN; END

IF NOT EXISTS (SELECT 1 FROM Personel WHERE Ad=N'ESREF'        AND Soyad=N'BAYSAL'    AND BolumID=@ENS)
    INSERT INTO Personel(Unvan,Ad,Soyad,BolumID) VALUES(N'Prof. Dr.',      N'ESREF',       N'BAYSAL',   @ENS);

IF NOT EXISTS (SELECT 1 FROM Personel WHERE Ad=N'MUSTAFA'      AND Soyad=N'AKKAYA'    AND BolumID=@ENS)
    INSERT INTO Personel(Unvan,Ad,Soyad,BolumID) VALUES(N'Doc. Dr.',       N'MUSTAFA',     N'AKKAYA',   @ENS);

IF NOT EXISTS (SELECT 1 FROM Personel WHERE Ad=N'AYSE BILGEN'  AND Soyad=N'AKSOY'     AND BolumID=@ENS)
    INSERT INTO Personel(Unvan,Ad,Soyad,BolumID) VALUES(N'Dr. Ogr. Uyesi', N'AYSE BILGEN', N'AKSOY',    @ENS);

IF NOT EXISTS (SELECT 1 FROM Personel WHERE Ad=N'OZGUR'        AND Soyad=N'SOLMAZ'    AND BolumID=@ENS)
    INSERT INTO Personel(Unvan,Ad,Soyad,BolumID) VALUES(N'Dr. Ogr. Uyesi', N'OZGUR',       N'SOLMAZ',   @ENS);

IF NOT EXISTS (SELECT 1 FROM Personel WHERE Ad=N'NEZIR YAGIZ'  AND Soyad=N'CAM'       AND BolumID=@ENS)
    INSERT INTO Personel(Unvan,Ad,Soyad,BolumID) VALUES(N'Dr. Ogr. Uyesi', N'NEZIR YAGIZ', N'CAM',      @ENS);

IF NOT EXISTS (SELECT 1 FROM Personel WHERE Ad=N'ELIF MERVE'   AND Soyad=N'BAHAR'     AND BolumID=@ENS)
    INSERT INTO Personel(Unvan,Ad,Soyad,BolumID) VALUES(N'Ars. Gor. Dr.',  N'ELIF MERVE',  N'BAHAR',    @ENS);

IF NOT EXISTS (SELECT 1 FROM Personel WHERE Ad=N'MENAL'        AND Soyad=N'ILHAN'     AND BolumID=@ENS)
    INSERT INTO Personel(Unvan,Ad,Soyad,BolumID) VALUES(N'Ars. Gor.',      N'MENAL',       N'ILHAN',    @ENS);

IF NOT EXISTS (SELECT 1 FROM Personel WHERE Ad=N'MERT'         AND Soyad=N'OKTEN'     AND BolumID=@ENS)
    INSERT INTO Personel(Unvan,Ad,Soyad,BolumID) VALUES(N'Ars. Gor. Dr.',  N'MERT',        N'OKTEN',    @ENS);

GO

-- ============================================================
-- MEK - MEKATRONIK MUHENDISLIGI
-- ============================================================
DECLARE @MEK INT;
SELECT @MEK = BolumID FROM Bolumler WHERE BolumAdi = N'Mekatronik Muhendisligi';
IF @MEK IS NULL BEGIN PRINT N'HATA: Mekatronik Muhendisligi bulunamadi!'; RETURN; END

IF NOT EXISTS (SELECT 1 FROM Personel WHERE Ad=N'IBRAHIM FADIL'   AND Soyad=N'SOYKOK'       AND BolumID=@MEK)
    INSERT INTO Personel(Unvan,Ad,Soyad,BolumID) VALUES(N'Prof. Dr.',      N'IBRAHIM FADIL',   N'SOYKOK',       @MEK);

IF NOT EXISTS (SELECT 1 FROM Personel WHERE Ad=N'MEHMET'           AND Soyad=N'AYVACIKLI'    AND BolumID=@MEK)
    INSERT INTO Personel(Unvan,Ad,Soyad,BolumID) VALUES(N'Prof. Dr.',      N'MEHMET',           N'AYVACIKLI',    @MEK);

IF NOT EXISTS (SELECT 1 FROM Personel WHERE Ad=N'ALI'              AND Soyad=N'UYSAL'         AND BolumID=@MEK)
    INSERT INTO Personel(Unvan,Ad,Soyad,BolumID) VALUES(N'Doc. Dr.',       N'ALI',              N'UYSAL',        @MEK);

IF NOT EXISTS (SELECT 1 FROM Personel WHERE Ad=N'NILAY KUCUKDOGAN' AND Soyad=N'OZTURK'       AND BolumID=@MEK)
    INSERT INTO Personel(Unvan,Ad,Soyad,BolumID) VALUES(N'Dr. Ogr. Uyesi', N'NILAY KUCUKDOGAN', N'OZTURK',      @MEK);

IF NOT EXISTS (SELECT 1 FROM Personel WHERE Ad=N'ETHEM'            AND Soyad=N'KELEKCI'       AND BolumID=@MEK)
    INSERT INTO Personel(Unvan,Ad,Soyad,BolumID) VALUES(N'Dr. Ogr. Uyesi', N'ETHEM',            N'KELEKCI',      @MEK);

IF NOT EXISTS (SELECT 1 FROM Personel WHERE Ad=N'ALKIN YILMAZ'     AND Soyad=N'AKTER'         AND BolumID=@MEK)
    INSERT INTO Personel(Unvan,Ad,Soyad,BolumID) VALUES(N'Dr. Ogr. Uyesi', N'ALKIN YILMAZ',     N'AKTER',        @MEK);

IF NOT EXISTS (SELECT 1 FROM Personel WHERE Ad=N'SEDA'             AND Soyad=N'VATAN CAN'     AND BolumID=@MEK)
    INSERT INTO Personel(Unvan,Ad,Soyad,BolumID) VALUES(N'Ars. Gor. Dr.',  N'SEDA',             N'VATAN CAN',    @MEK);

IF NOT EXISTS (SELECT 1 FROM Personel WHERE Ad=N'KUBRA'            AND Soyad=N'TURAL'         AND BolumID=@MEK)
    INSERT INTO Personel(Unvan,Ad,Soyad,BolumID) VALUES(N'Ars. Gor.',      N'KUBRA',            N'TURAL',        @MEK);

GO

-- ============================================================
-- MAK - MAKINE MUHENDISLIGI
-- ============================================================
DECLARE @MAK INT;
SELECT @MAK = BolumID FROM Bolumler WHERE BolumAdi = N'Makine Muhendisligi';
IF @MAK IS NULL BEGIN PRINT N'HATA: Makine Muhendisligi bulunamadi!'; RETURN; END

IF NOT EXISTS (SELECT 1 FROM Personel WHERE Ad=N'AHMET MURAT'  AND Soyad=N'PINAR'         AND BolumID=@MAK)
    INSERT INTO Personel(Unvan,Ad,Soyad,BolumID) VALUES(N'Prof. Dr.',      N'AHMET MURAT',  N'PINAR',        @MAK);

IF NOT EXISTS (SELECT 1 FROM Personel WHERE Ad=N'MUSTAFA'       AND Soyad=N'AYDIN'         AND BolumID=@MAK)
    INSERT INTO Personel(Unvan,Ad,Soyad,BolumID) VALUES(N'Prof. Dr.',      N'MUSTAFA',      N'AYDIN',        @MAK);

IF NOT EXISTS (SELECT 1 FROM Personel WHERE Ad=N'FIKRET'        AND Soyad=N'SONMEZ'        AND BolumID=@MAK)
    INSERT INTO Personel(Unvan,Ad,Soyad,BolumID) VALUES(N'Doc. Dr.',       N'FIKRET',       N'SONMEZ',       @MAK);

IF NOT EXISTS (SELECT 1 FROM Personel WHERE Ad=N'SERKAN'        AND Soyad=N'CASKA'         AND BolumID=@MAK)
    INSERT INTO Personel(Unvan,Ad,Soyad,BolumID) VALUES(N'Doc. Dr.',       N'SERKAN',       N'CASKA',        @MAK);

IF NOT EXISTS (SELECT 1 FROM Personel WHERE Ad=N'HAMZA'         AND Soyad=N'TAS'           AND BolumID=@MAK)
    INSERT INTO Personel(Unvan,Ad,Soyad,BolumID) VALUES(N'Doc. Dr.',       N'HAMZA',        N'TAS',          @MAK);

IF NOT EXISTS (SELECT 1 FROM Personel WHERE Ad=N'SELDA'         AND Soyad=N'KAYRAL'        AND BolumID=@MAK)
    INSERT INTO Personel(Unvan,Ad,Soyad,BolumID) VALUES(N'Dr. Ogr. Uyesi', N'SELDA',        N'KAYRAL',       @MAK);

IF NOT EXISTS (SELECT 1 FROM Personel WHERE Ad=N'AYSEGUL'       AND Soyad=N'GUNGOR CELIK'  AND BolumID=@MAK)
    INSERT INTO Personel(Unvan,Ad,Soyad,BolumID) VALUES(N'Dr. Ogr. Uyesi', N'AYSEGUL',      N'GUNGOR CELIK', @MAK);

IF NOT EXISTS (SELECT 1 FROM Personel WHERE Ad=N'DENIZ'         AND Soyad=N'COBAN OZKAN'   AND BolumID=@MAK)
    INSERT INTO Personel(Unvan,Ad,Soyad,BolumID) VALUES(N'Dr. Ogr. Uyesi', N'DENIZ',        N'COBAN OZKAN',  @MAK);

IF NOT EXISTS (SELECT 1 FROM Personel WHERE Ad=N'MEHMET MERT'   AND Soyad=N'ILMAN'         AND BolumID=@MAK)
    INSERT INTO Personel(Unvan,Ad,Soyad,BolumID) VALUES(N'Dr. Ogr. Uyesi', N'MEHMET MERT',  N'ILMAN',        @MAK);

IF NOT EXISTS (SELECT 1 FROM Personel WHERE Ad=N'OMER'          AND Soyad=N'ILHAN'         AND BolumID=@MAK)
    INSERT INTO Personel(Unvan,Ad,Soyad,BolumID) VALUES(N'Ars. Gor.',      N'OMER',         N'ILHAN',        @MAK);

IF NOT EXISTS (SELECT 1 FROM Personel WHERE Ad=N'BUSRANUR'      AND Soyad=N'KESER'         AND BolumID=@MAK)
    INSERT INTO Personel(Unvan,Ad,Soyad,BolumID) VALUES(N'Ars. Gor.',      N'BUSRANUR',     N'KESER',        @MAK);

GO

-- ============================================================
-- YZM - YAZILIM MUHENDISLIGI
-- ============================================================
DECLARE @YZM INT;
SELECT @YZM = BolumID FROM Bolumler WHERE BolumAdi = N'Yazilim Muhendisligi';
IF @YZM IS NULL BEGIN PRINT N'HATA: Yazilim Muhendisligi bulunamadi!'; RETURN; END

IF NOT EXISTS (SELECT 1 FROM Personel WHERE Ad=N'FATIH'    AND Soyad=N'YUCALAR'     AND BolumID=@YZM)
    INSERT INTO Personel(Unvan,Ad,Soyad,BolumID) VALUES(N'Doc. Dr.',       N'FATIH',    N'YUCALAR',     @YZM);

IF NOT EXISTS (SELECT 1 FROM Personel WHERE Ad=N'YUSUF'    AND Soyad=N'OZCEVIK'     AND BolumID=@YZM)
    INSERT INTO Personel(Unvan,Ad,Soyad,BolumID) VALUES(N'Doc. Dr.',       N'YUSUF',    N'OZCEVIK',     @YZM);

IF NOT EXISTS (SELECT 1 FROM Personel WHERE Ad=N'AKIN'     AND Soyad=N'OZCIFT'      AND BolumID=@YZM)
    INSERT INTO Personel(Unvan,Ad,Soyad,BolumID) VALUES(N'Prof. Dr.',      N'AKIN',     N'OZCIFT',      @YZM);

IF NOT EXISTS (SELECT 1 FROM Personel WHERE Ad=N'ERSIN'    AND Soyad=N'ASLAN'       AND BolumID=@YZM)
    INSERT INTO Personel(Unvan,Ad,Soyad,BolumID) VALUES(N'Prof. Dr.',      N'ERSIN',    N'ASLAN',       @YZM);

IF NOT EXISTS (SELECT 1 FROM Personel WHERE Ad=N'OSMAN'    AND Soyad=N'ALTAY'       AND BolumID=@YZM)
    INSERT INTO Personel(Unvan,Ad,Soyad,BolumID) VALUES(N'Doc. Dr.',       N'OSMAN',    N'ALTAY',       @YZM);

IF NOT EXISTS (SELECT 1 FROM Personel WHERE Ad=N'ELIF'     AND Soyad=N'VAROL ALTAY' AND BolumID=@YZM)
    INSERT INTO Personel(Unvan,Ad,Soyad,BolumID) VALUES(N'Doc. Dr.',       N'ELIF',     N'VAROL ALTAY', @YZM);

IF NOT EXISTS (SELECT 1 FROM Personel WHERE Ad=N'MUGE'     AND Soyad=N'OZCEVIK'     AND BolumID=@YZM)
    INSERT INTO Personel(Unvan,Ad,Soyad,BolumID) VALUES(N'Doc. Dr.',       N'MUGE',     N'OZCEVIK',     @YZM);

IF NOT EXISTS (SELECT 1 FROM Personel WHERE Ad=N'EMIN'     AND Soyad=N'BORANDAG'    AND BolumID=@YZM)
    INSERT INTO Personel(Unvan,Ad,Soyad,BolumID) VALUES(N'Doc. Dr.',       N'EMIN',     N'BORANDAG',    @YZM);

IF NOT EXISTS (SELECT 1 FROM Personel WHERE Ad=N'IRFAN'    AND Soyad=N'AYGUN'       AND BolumID=@YZM)
    INSERT INTO Personel(Unvan,Ad,Soyad,BolumID) VALUES(N'Dr. Ogr. Uyesi', N'IRFAN',    N'AYGUN',       @YZM);

IF NOT EXISTS (SELECT 1 FROM Personel WHERE Ad=N'SULEYMAN' AND Soyad=N'CETINER'     AND BolumID=@YZM)
    INSERT INTO Personel(Unvan,Ad,Soyad,BolumID) VALUES(N'Ars. Gor.',      N'SULEYMAN', N'CETINER',     @YZM);

IF NOT EXISTS (SELECT 1 FROM Personel WHERE Ad=N'ELIF NUR' AND Soyad=N'AYGUN'       AND BolumID=@YZM)
    INSERT INTO Personel(Unvan,Ad,Soyad,BolumID) VALUES(N'Ars. Gor.',      N'ELIF NUR', N'AYGUN',       @YZM);

IF NOT EXISTS (SELECT 1 FROM Personel WHERE Ad=N'TUGBA'    AND Soyad=N'CELIKTEN'    AND BolumID=@YZM)
    INSERT INTO Personel(Unvan,Ad,Soyad,BolumID) VALUES(N'Ars. Gor.',      N'TUGBA',    N'CELIKTEN',    @YZM);

IF NOT EXISTS (SELECT 1 FROM Personel WHERE Ad=N'GUNEY'    AND Soyad=N'KAYA'        AND BolumID=@YZM)
    INSERT INTO Personel(Unvan,Ad,Soyad,BolumID) VALUES(N'Ars. Gor.',      N'GUNEY',    N'KAYA',        @YZM);

GO

-- Dogrulama
PRINT '';
PRINT '=== Bolum bazi personel sayisi ===';
SELECT b.BolumAdi,
       COUNT(*) AS ToplamPersonel,
       SUM(CASE WHEN p.Unvan LIKE N'Prof%'         THEN 1 ELSE 0 END) AS Profesor,
       SUM(CASE WHEN p.Unvan LIKE N'Doc%'          THEN 1 ELSE 0 END) AS Docent,
       SUM(CASE WHEN p.Unvan LIKE N'Dr. Ogr%'      THEN 1 ELSE 0 END) AS DrOgr,
       SUM(CASE WHEN p.Unvan LIKE N'Ars%'          THEN 1 ELSE 0 END) AS ArsGor
FROM Personel p
JOIN Bolumler b ON p.BolumID = b.BolumID
WHERE p.Aktif = 1
GROUP BY b.BolumAdi
ORDER BY b.BolumAdi;
GO

PRINT '';
PRINT '16_Personel.sql tamamlandi. Toplam 45 akademik personel eklendi.';
GO
