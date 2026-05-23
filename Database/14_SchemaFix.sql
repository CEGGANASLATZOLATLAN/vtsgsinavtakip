-- ============================================================
-- 14_SchemaFix.sql
-- Iki kritik schema hatası düzeltilir:
--
--  1. DersTuru NVARCHAR(10) -> NVARCHAR(15)
--     "Laboratuvar" 11 karakter oldugu icin INSERT hatası veriyordu.
--
--  2. UQ_DersKodu (sadece DersKodu) -> UQ_DersBolum (DersKodu + BolumID)
--     Ayni ders kodu (MAT1301 gibi) farkli bolumlerde de olabilmeli.
--     Eski kisit yuzunden ortak dersler (MAT, FIZ, AIT, TDL, YDI, CBU)
--     sadece ilk bolume eklenebiliyordu, digerlerinde UNIQUE hatasıyla atlanıyordu.
--
-- CALISTIRMA SIRASI:
--   09_Updates.sql -> 10_UzaktanEkle.sql -> **14_SchemaFix.sql**
--   -> 12_TumBolumlerDersler.sql -> 13_LaboratuvarTuru.sql
-- ============================================================
USE SinavTakip;
GO

-- ============================================================
-- ADIM 1: DersTuru kolonunu genislet (10 -> 15)
-- ============================================================
ALTER TABLE Dersler
    ALTER COLUMN DersTuru NVARCHAR(15) NOT NULL;
GO
PRINT 'ADIM 1: DersTuru NVARCHAR(15) yapildi.';
GO

-- ============================================================
-- ADIM 2: CHECK kisitini yenile (Laboratuvar icin gerekli)
-- ============================================================
IF EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = N'CK_Ders_Tur')
    ALTER TABLE Dersler DROP CONSTRAINT CK_Ders_Tur;
GO

ALTER TABLE Dersler
    ADD CONSTRAINT CK_Ders_Tur
    CHECK (DersTuru IN (N'Zorunlu', N'Secmeli', N'Uzaktan', N'Laboratuvar'));
GO
PRINT 'ADIM 2: CK_Ders_Tur kisiti guncellendi.';
GO

-- ============================================================
-- ADIM 3: UNIQUE kisitini duzelt (DersKodu + BolumID kombinasyonu)
-- ============================================================
IF EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'UQ_DersKodu')
    ALTER TABLE Dersler DROP CONSTRAINT UQ_DersKodu;
GO

IF NOT EXISTS (SELECT 1 FROM sys.key_constraints WHERE name = N'UQ_DersBolum')
BEGIN
    ALTER TABLE Dersler
        ADD CONSTRAINT UQ_DersBolum UNIQUE (DersKodu, BolumID);
    PRINT 'ADIM 3: UQ_DersBolum kisiti eklendi (DersKodu + BolumID).';
END
ELSE
    PRINT 'ADIM 3: UQ_DersBolum zaten mevcut, atlandi.';
GO

-- ============================================================
-- DOGRULAMA
-- ============================================================
PRINT '';
PRINT '=== Dersler tablosu son durumu ===';
SELECT
    c.name          AS KolonAdi,
    t.name          AS Tip,
    c.max_length / 2 AS MaxKarakter,
    c.is_nullable   AS NullMu
FROM sys.columns c
JOIN sys.types t ON c.user_type_id = t.user_type_id
WHERE c.object_id = OBJECT_ID(N'Dersler')
ORDER BY c.column_id;
GO

PRINT '';
PRINT '=== Aktif kisitlar ===';
SELECT name, type_desc, definition
FROM sys.check_constraints
WHERE parent_object_id = OBJECT_ID(N'Dersler');

SELECT name, type_desc
FROM sys.key_constraints
WHERE parent_object_id = OBJECT_ID(N'Dersler');
GO

PRINT '';
PRINT '============================================================';
PRINT 'Schema duzeltmeleri tamamlandi!';
PRINT '';
PRINT 'Simdi su sirayla calistirin:';
PRINT '  1. 12_TumBolumlerDersler.sql  (eksik dersler eklenecek)';
PRINT '  2. 13_LaboratuvarTuru.sql     (lab dersleri guncellecek)';
PRINT '============================================================';
GO
