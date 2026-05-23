-- ============================================================
-- 07_Triggers.sql  -  Tetikleyiciler
-- En az 2 adet gereklidir.
-- ============================================================
USE SinavTakip;
GO

-- ============================================================
-- TRIGGER 1: trg_SalonCakismaKontrol
-- Bir dersliğe ayni tarih/oturumda iki farkli sinav atanamaz.
-- (Salon Cakismasi: B1 kurali)
-- ============================================================
CREATE TRIGGER dbo.trg_SalonCakismaKontrol
ON Sinav_Salonlari
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN Sinavlar sv_yeni ON i.SinavID = sv_yeni.SinavID
        JOIN Sinav_Salonlari ss_var ON ss_var.DerslikID = i.DerslikID
                                   AND ss_var.SinavID  <> i.SinavID
        JOIN Sinavlar sv_var ON ss_var.SinavID = sv_var.SinavID
        WHERE sv_var.Tarih    = sv_yeni.Tarih
          AND sv_var.OturumID = sv_yeni.OturumID
    )
    BEGIN
        RAISERROR(N'Salon Cakismasi: Bu derslik ayni tarih/oturumda baska bir sinavda kullaniliyor!', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END
GO

-- ============================================================
-- TRIGGER 2: trg_DönemCakismaKontrol
-- Ayni yariyildaki zorunlu derslerin sinavlari ayni oturuma atanamaz.
-- (Donem Cakismasi: A1 kurali) - SP'deki kontrole ek guvenlik katmani.
-- ============================================================
CREATE TRIGGER dbo.trg_DönemCakismaKontrol
ON Sinavlar
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN Dersler d_yeni ON i.DersID = d_yeni.DersID
        WHERE d_yeni.DersTuru = N'Zorunlu'
          AND EXISTS (
              SELECT 1
              FROM Sinavlar sv_var
              JOIN Dersler d_var ON sv_var.DersID = d_var.DersID
              WHERE sv_var.Tarih    = i.Tarih
                AND sv_var.OturumID = i.OturumID
                AND sv_var.SinavID <> i.SinavID
                AND d_var.Yariyil   = d_yeni.Yariyil
                AND d_var.DersTuru  = N'Zorunlu'
          )
    )
    BEGIN
        RAISERROR(N'Donem Cakismasi: Ayni yariyildaki zorunlu derslerin sinavlari ayni oturuma konamaz!', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END
GO

-- ============================================================
-- TRIGGER 3: trg_GozetmenCakismaKontrol
-- Bir gozetmen ayni anda iki farkli sinavda goreve atanamaz.
-- (Personel Zaman Cakismasi: C1 kurali)
-- ============================================================
CREATE TRIGGER dbo.trg_GozetmenCakismaKontrol
ON Gozetmen_Atamalari
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN Sinav_Salonlari ss_yeni ON i.SinavSalonID = ss_yeni.SinavSalonID
        JOIN Sinavlar sv_yeni ON ss_yeni.SinavID = sv_yeni.SinavID
        -- Ayni personelin diger atamalarini bul
        JOIN Gozetmen_Atamalari ga_var ON ga_var.PersonelID   = i.PersonelID
                                      AND ga_var.SinavSalonID <> i.SinavSalonID
        JOIN Sinav_Salonlari ss_var ON ga_var.SinavSalonID = ss_var.SinavSalonID
        JOIN Sinavlar sv_var ON ss_var.SinavID = sv_var.SinavID
        WHERE sv_var.Tarih    = sv_yeni.Tarih
          AND sv_var.OturumID = sv_yeni.OturumID
    )
    BEGIN
        RAISERROR(N'Gozetmen Cakismasi: Bu personel ayni oturumda baska bir sinavda gorevli!', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END
GO

PRINT 'Triggerler basariyla olusturuldu.';
GO
