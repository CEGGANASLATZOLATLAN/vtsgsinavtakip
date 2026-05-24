-- ============================================================
-- 02_CreateTables.sql  -  3NF uyumlu tablo yapilari
-- ============================================================
USE SinavTakip;
GO

-- ------------------------------------------------------------
-- 1. Bolumler
-- ------------------------------------------------------------
CREATE TABLE Bolumler (
    BolumID   INT            IDENTITY(1,1) PRIMARY KEY,
    BolumAdi  NVARCHAR(100)  NOT NULL,
    Aktif     BIT            NOT NULL DEFAULT 1,
    CONSTRAINT UQ_BolumAdi UNIQUE (BolumAdi)
);
GO

-- ------------------------------------------------------------
-- 2. Oturumlar  (Slotlar)
-- ------------------------------------------------------------
CREATE TABLE Oturumlar (
    OturumID      INT           IDENTITY(1,1) PRIMARY KEY,
    Tanim         NVARCHAR(50)  NOT NULL,
    BaslangicSaat TIME          NOT NULL,
    BitisSaat     TIME          NOT NULL,
    CONSTRAINT CK_Oturum_Saat CHECK (BitisSaat > BaslangicSaat),
    CONSTRAINT UQ_OturumTanim UNIQUE (Tanim)
);
GO

-- ------------------------------------------------------------
-- 3. Derslikler
-- ------------------------------------------------------------
CREATE TABLE Derslikler (
    DerslikID INT           IDENTITY(1,1) PRIMARY KEY,
    Ad        NVARCHAR(50)  NOT NULL,
    Kapasite  INT           NOT NULL,
    Tip       NVARCHAR(10)  NOT NULL,
    Kat       INT           NOT NULL DEFAULT 0,
    Aktif     BIT           NOT NULL DEFAULT 1,
    CONSTRAINT CK_Derslik_Kapasite CHECK (Kapasite > 0),
    CONSTRAINT CK_Derslik_Tip      CHECK (Tip IN (N'Amfi', N'Sinif', N'Lab')),
    CONSTRAINT UQ_DerslikAd        UNIQUE (Ad)
);
GO

-- ------------------------------------------------------------
-- 4. Dersler
-- ------------------------------------------------------------
CREATE TABLE Dersler (
    DersID        INT           IDENTITY(1,1) PRIMARY KEY,
    DersKodu      NVARCHAR(20)  NOT NULL,
    DersTuru      NVARCHAR(15)  NOT NULL,
    Ad            NVARCHAR(200) NOT NULL,
    OgrenciSayisi INT           NOT NULL,
    Yariyil       INT           NOT NULL,
    BolumID       INT           NOT NULL,
    CONSTRAINT UQ_DersBolum       UNIQUE (DersKodu, BolumID),
    CONSTRAINT CK_Ders_Tur        CHECK (DersTuru IN (N'Zorunlu', N'Secmeli', N'Uzaktan', N'Laboratuvar')),
    CONSTRAINT CK_Ders_Ogrenci    CHECK (OgrenciSayisi >= 0),
    CONSTRAINT CK_Ders_Yariyil    CHECK (Yariyil BETWEEN 1 AND 8),
    CONSTRAINT FK_Dersler_Bolumler FOREIGN KEY (BolumID) REFERENCES Bolumler(BolumID)
);
GO

-- ------------------------------------------------------------
-- 5. Personel
-- ------------------------------------------------------------
CREATE TABLE Personel (
    PersonelID INT           IDENTITY(1,1) PRIMARY KEY,
    Unvan      NVARCHAR(30)  NOT NULL,
    Ad         NVARCHAR(50)  NOT NULL,
    Soyad      NVARCHAR(50)  NOT NULL,
    BolumID    INT           NOT NULL,
    Aktif      BIT           NOT NULL DEFAULT 1,
    CONSTRAINT FK_Personel_Bolumler FOREIGN KEY (BolumID) REFERENCES Bolumler(BolumID)
);
GO

-- ------------------------------------------------------------
-- 6. Personel_Durum  (Mazeretler / Uygunsuz zamanlar)
-- ------------------------------------------------------------
CREATE TABLE Personel_Durum (
    DurumID     INT           IDENTITY(1,1) PRIMARY KEY,
    PersonelID  INT           NOT NULL,
    Tarih       DATE          NOT NULL,
    OturumID    INT           NULL,          -- NULL => tum gun
    MazeretTuru NVARCHAR(30)  NOT NULL,
    Aciklama    NVARCHAR(200) NULL,
    CONSTRAINT CK_Mazeret_Tur     CHECK (MazeretTuru IN (N'Izinli', N'DanismanlikSaati', N'Diger')),
    CONSTRAINT FK_PD_Personel     FOREIGN KEY (PersonelID) REFERENCES Personel(PersonelID),
    CONSTRAINT FK_PD_Oturum       FOREIGN KEY (OturumID)   REFERENCES Oturumlar(OturumID)
);
GO

-- ------------------------------------------------------------
-- 7. Sinavlar
-- ------------------------------------------------------------
CREATE TABLE Sinavlar (
    SinavID   INT  IDENTITY(1,1) PRIMARY KEY,
    DersID    INT  NOT NULL,
    Tarih     DATE NOT NULL,
    OturumID  INT  NOT NULL,
    CONSTRAINT FK_Sinav_Ders    FOREIGN KEY (DersID)   REFERENCES Dersler(DersID),
    CONSTRAINT FK_Sinav_Oturum  FOREIGN KEY (OturumID) REFERENCES Oturumlar(OturumID),
    CONSTRAINT UQ_Sinav_Ders_Slot UNIQUE (DersID, Tarih, OturumID)
);
GO

-- ------------------------------------------------------------
-- 8. Sinav_Salonlari  (Ara tablo: hangi sinav, hangi derslikte)
-- ------------------------------------------------------------
CREATE TABLE Sinav_Salonlari (
    SinavSalonID INT IDENTITY(1,1) PRIMARY KEY,
    SinavID      INT NOT NULL,
    DerslikID    INT NOT NULL,
    CONSTRAINT FK_SS_Sinav   FOREIGN KEY (SinavID)   REFERENCES Sinavlar(SinavID)   ON DELETE CASCADE,
    CONSTRAINT FK_SS_Derslik FOREIGN KEY (DerslikID) REFERENCES Derslikler(DerslikID),
    CONSTRAINT UQ_SS         UNIQUE (SinavID, DerslikID)
);
GO

-- ------------------------------------------------------------
-- 9. Gozetmen_Atamalari
-- ------------------------------------------------------------
CREATE TABLE Gozetmen_Atamalari (
    GozetmenAtamaID INT IDENTITY(1,1) PRIMARY KEY,
    SinavSalonID    INT NOT NULL,
    PersonelID      INT NOT NULL,
    CONSTRAINT FK_GA_SinavSalon FOREIGN KEY (SinavSalonID) REFERENCES Sinav_Salonlari(SinavSalonID) ON DELETE CASCADE,
    CONSTRAINT FK_GA_Personel   FOREIGN KEY (PersonelID)   REFERENCES Personel(PersonelID),
    CONSTRAINT UQ_GA            UNIQUE (SinavSalonID, PersonelID)
);
GO

PRINT 'Tablolar basariyla olusturuldu.';
GO
