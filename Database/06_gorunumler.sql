-- ============================================================
-- 06_Views.sql  -  Gorünumler (Views)
-- En az 3 adet gereklidir.
-- ONEMLI: 05_Functions.sql'den SONRA calistiriniz.
-- ============================================================
USE SinavTakip;
GO

-- ============================================================
-- VIEW 1: v_SinavProgrami
-- Tum sinav programi; ders, oturum, salon ve kapasite bilgileriyle.
-- ============================================================
CREATE VIEW dbo.v_SinavProgrami AS
SELECT
    sv.SinavID,
    sv.Tarih,
    DATENAME(WEEKDAY, sv.Tarih)                     AS Gun,
    o.OturumID,
    o.Tanim                                          AS Oturum,
    CONVERT(NVARCHAR(5), o.BaslangicSaat, 108)       AS BaslangicSaat,
    CONVERT(NVARCHAR(5), o.BitisSaat,     108)        AS BitisSaat,
    d.DersID,
    d.DersKodu,
    d.Ad                                             AS DersAdi,
    d.DersTuru,
    d.Yariyil,
    d.OgrenciSayisi,
    b.BolumAdi,
    dbo.fn_ToplamKapasite(sv.SinavID)               AS AtananKapasite,
    (
        SELECT STUFF((
            SELECT N', ' + dk.Ad
            FROM Sinav_Salonlari ss
            JOIN Derslikler dk ON ss.DerslikID = dk.DerslikID
            WHERE ss.SinavID = sv.SinavID
            ORDER BY dk.Ad
            FOR XML PATH(N''), TYPE
        ).value(N'.', N'NVARCHAR(MAX)'), 1, 2, N'')
    )                                                AS Salonlar,
    (
        SELECT COUNT(*)
        FROM Sinav_Salonlari ss
        WHERE ss.SinavID = sv.SinavID
    )                                                AS SalonSayisi
FROM Sinavlar sv
JOIN Dersler   d ON sv.DersID   = d.DersID
JOIN Bolumler  b ON d.BolumID   = b.BolumID
JOIN Oturumlar o ON sv.OturumID = o.OturumID;
GO

-- ============================================================
-- VIEW 2: v_GozetmenGorevleri
-- Her gozetmenin hangi sinav, salon ve tarihte gorev yaptigi.
-- ============================================================
CREATE VIEW dbo.v_GozetmenGorevleri AS
SELECT
    ga.GozetmenAtamaID,
    p.PersonelID,
    p.Unvan + N' ' + p.Ad + N' ' + p.Soyad  AS PersonelAdi,
    bp.BolumAdi                               AS PersonelBolumu,
    sv.Tarih,
    DATENAME(WEEKDAY, sv.Tarih)               AS Gun,
    o.Tanim                                   AS Oturum,
    CONVERT(NVARCHAR(5), o.BaslangicSaat, 108) AS BaslangicSaat,
    d.DersKodu,
    d.Ad                                      AS DersAdi,
    d.Yariyil,
    bd.BolumAdi                               AS DersBolumu,
    dk.Ad                                     AS DerslikAdi,
    dk.Tip                                    AS DerslikTip,
    dk.Kat
FROM Gozetmen_Atamalari ga
JOIN Personel       p   ON ga.PersonelID    = p.PersonelID
JOIN Bolumler       bp  ON p.BolumID        = bp.BolumID
JOIN Sinav_Salonlari ss ON ga.SinavSalonID  = ss.SinavSalonID
JOIN Derslikler     dk  ON ss.DerslikID     = dk.DerslikID
JOIN Sinavlar       sv  ON ss.SinavID       = sv.SinavID
JOIN Dersler        d   ON sv.DersID        = d.DersID
JOIN Bolumler       bd  ON d.BolumID        = bd.BolumID
JOIN Oturumlar      o   ON sv.OturumID      = o.OturumID;
GO

-- ============================================================
-- VIEW 3: v_GozetmenIstatistik
-- Her personelin toplam gozetmenlik yukunu gosterir (adil dagitim icin).
-- ============================================================
CREATE VIEW dbo.v_GozetmenIstatistik AS
SELECT
    p.PersonelID,
    p.Unvan + N' ' + p.Ad + N' ' + p.Soyad  AS PersonelAdi,
    b.BolumAdi,
    COUNT(ga.GozetmenAtamaID)                AS ToplamGorev,
    ISNULL((
        SELECT COUNT(*)
        FROM Gozetmen_Atamalari ga2
        JOIN Sinav_Salonlari ss ON ga2.SinavSalonID = ss.SinavSalonID
        JOIN Sinavlar sv ON ss.SinavID = sv.SinavID
        WHERE ga2.PersonelID = p.PersonelID
          AND sv.Tarih >= DATEADD(MONTH, -1, GETDATE())
    ), 0)                                    AS SonBirAydaGorev
FROM Personel p
JOIN Bolumler b ON p.BolumID = b.BolumID
LEFT JOIN Gozetmen_Atamalari ga ON p.PersonelID = ga.PersonelID
WHERE p.Aktif = 1
GROUP BY p.PersonelID, p.Unvan, p.Ad, p.Soyad, b.BolumAdi;
GO

-- ============================================================
-- VIEW 4: v_SalonDoluluk
-- Her tarih/oturum kombinasyonu icin derslik doluluk durumu.
-- ============================================================
CREATE VIEW dbo.v_SalonDoluluk AS
SELECT
    dk.DerslikID,
    dk.Ad         AS DerslikAdi,
    dk.Kapasite,
    dk.Tip,
    dk.Kat,
    sv.Tarih,
    o.Tanim       AS Oturum,
    sv.SinavID,
    d.DersKodu,
    d.Ad          AS DersAdi
FROM Sinav_Salonlari ss
JOIN Derslikler dk  ON ss.DerslikID = dk.DerslikID
JOIN Sinavlar   sv  ON ss.SinavID   = sv.SinavID
JOIN Dersler    d   ON sv.DersID    = d.DersID
JOIN Oturumlar  o   ON sv.OturumID  = o.OturumID;
GO

PRINT 'Viewler basariyla olusturuldu.';
GO
