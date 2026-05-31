-- ============================================================
-- BEYAZ EŞYA TOPTANCI MALZEME SATIŞ TAKİP SİSTEMİ
-- Fiziksel Tasarım - MS SQL Server (T-SQL)
-- Hazırlayan: AKEL Beyaz Eşya Toptancılık A.Ş.
-- Tarih: 2026
-- ============================================================

-- ============================================================
-- VERİTABANI OLUŞTURMA (Her çalıştırmada temiz başlat)
-- ============================================================
USE master;
GO

-- Mevcut bağlantıları kes ve veritabanını sil
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'BeyazEsyaToptanci')
BEGIN
    ALTER DATABASE BeyazEsyaToptanci SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE BeyazEsyaToptanci;
END
GO

CREATE DATABASE BeyazEsyaToptanci COLLATE Turkish_CI_AS;
GO

USE BeyazEsyaToptanci;
GO

SET QUOTED_IDENTIFIER ON;
GO


-- ============================================================
-- BÖLÜM 1: TABLO OLUŞTURMA
-- Tablolar FK bağımlılık sırasına göre (önce bağımlılar silinir)
-- ============================================================

-- Önce bağımlı tablolar silinir (ters sıra)
IF OBJECT_ID('dbo.FATURA',                'U') IS NOT NULL DROP TABLE dbo.FATURA;
IF OBJECT_ID('dbo.SATISSIPARISDETAY',     'U') IS NOT NULL DROP TABLE dbo.SATISSIPARISDETAY;
IF OBJECT_ID('dbo.SATISSIPARISI',         'U') IS NOT NULL DROP TABLE dbo.SATISSIPARISI;
IF OBJECT_ID('dbo.SATINALMASIPARISDETAY', 'U') IS NOT NULL DROP TABLE dbo.SATINALMASIPARISDETAY;
IF OBJECT_ID('dbo.SATINALMASIPARISI',     'U') IS NOT NULL DROP TABLE dbo.SATINALMASIPARISI;
IF OBJECT_ID('dbo.DEPOSTOK',              'U') IS NOT NULL DROP TABLE dbo.DEPOSTOK;
IF OBJECT_ID('dbo.URUN',                  'U') IS NOT NULL DROP TABLE dbo.URUN;
IF OBJECT_ID('dbo.DEPO',                  'U') IS NOT NULL DROP TABLE dbo.DEPO;
IF OBJECT_ID('dbo.CALISKAN',              'U') IS NOT NULL DROP TABLE dbo.CALISKAN;
IF OBJECT_ID('dbo.MUSTERI',               'U') IS NOT NULL DROP TABLE dbo.MUSTERI;
IF OBJECT_ID('dbo.TEDARIKCI',             'U') IS NOT NULL DROP TABLE dbo.TEDARIKCI;
IF OBJECT_ID('dbo.KATEGORI',              'U') IS NOT NULL DROP TABLE dbo.KATEGORI;
IF OBJECT_ID('dbo.MARKA',                 'U') IS NOT NULL DROP TABLE dbo.MARKA;
IF OBJECT_ID('dbo.DEPARTMAN',             'U') IS NOT NULL DROP TABLE dbo.DEPARTMAN;
GO

-- ------------------------------------------------------------
-- 1. KATEGORI
-- ------------------------------------------------------------
CREATE TABLE KATEGORI (
    KategoriID  INT           IDENTITY(1,1) PRIMARY KEY,
    KategoriAdi VARCHAR(100)  NOT NULL,
    Aciklama    VARCHAR(255)  NULL,
    CONSTRAINT UQ_KategoriAdi UNIQUE (KategoriAdi)
);
GO

-- ------------------------------------------------------------
-- 2. MARKA
-- ------------------------------------------------------------
CREATE TABLE MARKA (
    MarkaID   INT          IDENTITY(1,1) PRIMARY KEY,
    MarkaAdi  VARCHAR(100) NOT NULL,
    UlkeKodu  CHAR(2)      NOT NULL,
    CONSTRAINT UQ_MarkaAdi UNIQUE (MarkaAdi)
);
GO

-- ------------------------------------------------------------
-- 3. DEPARTMAN
-- ------------------------------------------------------------
CREATE TABLE DEPARTMAN (
    DepartmanID  INT          IDENTITY(1,1) PRIMARY KEY,
    DepartmanAdi VARCHAR(100) NOT NULL,
    Aciklama     VARCHAR(255) NULL,
    CONSTRAINT UQ_DepartmanAdi UNIQUE (DepartmanAdi)
);
GO

-- ------------------------------------------------------------
-- 4. CALISKAN
-- ------------------------------------------------------------
CREATE TABLE CALISKAN (
    CalisanID       INT           IDENTITY(1,1) PRIMARY KEY,
    Ad              VARCHAR(50)   NOT NULL,
    Soyad           VARCHAR(50)   NOT NULL,
    TCKN            CHAR(11)      NOT NULL,
    DepartmanID     INT           NOT NULL,
    Gorev           VARCHAR(100)  NOT NULL,
    Maas            DECIMAL(10,2) NOT NULL,
    IseGirisTarihi  DATE          NOT NULL,
    Telefon         VARCHAR(20)   NULL,
    Email           VARCHAR(100)  NULL,
    AktifMi         TINYINT       NOT NULL DEFAULT 1,
    CONSTRAINT UQ_TCKN          UNIQUE (TCKN),
    CONSTRAINT CHK_Maas         CHECK  (Maas > 0),
    CONSTRAINT FK_Caliskan_Dept FOREIGN KEY (DepartmanID) REFERENCES DEPARTMAN(DepartmanID)
);
GO

-- ------------------------------------------------------------
-- 5. TEDARIKCI
-- ------------------------------------------------------------
CREATE TABLE TEDARIKCI (
    TedarikciID  INT          IDENTITY(1,1) PRIMARY KEY,
    FirmaAdi     VARCHAR(150) NOT NULL,
    VergiNo      VARCHAR(20)  NOT NULL,
    YetkiliAdi   VARCHAR(100) NULL,
    Telefon      VARCHAR(20)  NOT NULL,
    Email        VARCHAR(100) NULL,
    Adres        VARCHAR(300) NOT NULL,
    OdemeVadesi  INT          NOT NULL DEFAULT 30,
    AktifMi      TINYINT      NOT NULL DEFAULT 1,
    CONSTRAINT UQ_Tedarikci_VergiNo UNIQUE (VergiNo),
    CONSTRAINT CHK_OdemeVadesi      CHECK  (OdemeVadesi >= 0)
);
GO

-- ------------------------------------------------------------
-- 6. MUSTERI
-- ------------------------------------------------------------
CREATE TABLE MUSTERI (
    MusteriID    INT           IDENTITY(1,1) PRIMARY KEY,
    FirmaAdi     VARCHAR(150)  NOT NULL,
    VergiNo      VARCHAR(20)   NOT NULL,
    YetkiliAdi   VARCHAR(100)  NULL,
    Telefon      VARCHAR(20)   NOT NULL,
    Email        VARCHAR(100)  NULL,
    Adres        VARCHAR(300)  NOT NULL,
    KrediLimiti  DECIMAL(12,2) NOT NULL DEFAULT 0,
    IndirimOrani DECIMAL(5,2)  NOT NULL DEFAULT 0,
    MusteriTipi  VARCHAR(50)   NOT NULL DEFAULT 'Bayi',
    KayitTarihi  DATE          NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    AktifMi      TINYINT       NOT NULL DEFAULT 1,
    CONSTRAINT UQ_Musteri_VergiNo UNIQUE (VergiNo),
    CONSTRAINT CHK_MusteriTipi   CHECK  (MusteriTipi IN ('Bayi','Servis','Perakendeci')),
    CONSTRAINT CHK_IndirimOrani  CHECK  (IndirimOrani BETWEEN 0 AND 100),
    CONSTRAINT CHK_KrediLimiti   CHECK  (KrediLimiti >= 0)
);
GO

-- ------------------------------------------------------------
-- 7. DEPO
-- ------------------------------------------------------------
CREATE TABLE DEPO (
    DepoID             INT           IDENTITY(1,1) PRIMARY KEY,
    DepoAdi            VARCHAR(100)  NOT NULL,
    Adres              VARCHAR(300)  NOT NULL,
    SorumluCalisanID   INT           NULL,
    KapasiteM2         DECIMAL(10,2) NULL,
    CONSTRAINT FK_Depo_Calisan FOREIGN KEY (SorumluCalisanID) REFERENCES CALISKAN(CalisanID)
);
GO

-- ------------------------------------------------------------
-- 6. URUN
-- ------------------------------------------------------------
IF OBJECT_ID('dbo.URUN', 'U') IS NOT NULL DROP TABLE dbo.URUN;
GO
CREATE TABLE URUN (
    UrunID        INT           IDENTITY(1,1) PRIMARY KEY,
    UrunKodu      VARCHAR(50)   NOT NULL,
    UrunAdi       VARCHAR(200)  NOT NULL,
    KategoriID    INT           NOT NULL,
    MarkaID       INT           NOT NULL,
    BirimFiyat    DECIMAL(10,2) NOT NULL,
    KDVOrani      DECIMAL(5,2)  NOT NULL DEFAULT 18.00,
    StokMiktari   INT           NOT NULL DEFAULT 0,
    MinStokEsigi  INT           NOT NULL DEFAULT 10,
    Birim         VARCHAR(20)   NOT NULL DEFAULT 'Adet',
    AktifMi       TINYINT       NOT NULL DEFAULT 1,
    CONSTRAINT UQ_UrunKodu       UNIQUE (UrunKodu),
    CONSTRAINT CHK_BirimFiyat    CHECK  (BirimFiyat > 0),
    CONSTRAINT CHK_StokMiktari   CHECK  (StokMiktari >= 0),
    CONSTRAINT FK_Urun_Kategori  FOREIGN KEY (KategoriID) REFERENCES KATEGORI(KategoriID),
    CONSTRAINT FK_Urun_Marka     FOREIGN KEY (MarkaID)    REFERENCES MARKA(MarkaID)
);
GO

-- ------------------------------------------------------------
-- 7. DEPOSTOK
-- ------------------------------------------------------------
IF OBJECT_ID('dbo.DEPOSTOK', 'U') IS NOT NULL DROP TABLE dbo.DEPOSTOK;
GO
CREATE TABLE DEPOSTOK (
    DepoStokID  INT         IDENTITY(1,1) PRIMARY KEY,
    DepoID      INT         NOT NULL,
    UrunID      INT         NOT NULL,
    Miktar      INT         NOT NULL DEFAULT 0,
    RafKonumu   VARCHAR(50) NULL,
    CONSTRAINT CHK_DepoStok_Miktar CHECK (Miktar >= 0),
    CONSTRAINT UQ_DepoUrun         UNIQUE (DepoID, UrunID),
    CONSTRAINT FK_DepoStok_Depo    FOREIGN KEY (DepoID)  REFERENCES DEPO(DepoID),
    CONSTRAINT FK_DepoStok_Urun    FOREIGN KEY (UrunID)  REFERENCES URUN(UrunID)
);
GO

-- ------------------------------------------------------------
-- 8. TEDARIKCI
-- ------------------------------------------------------------
IF OBJECT_ID('dbo.TEDARIKCI', 'U') IS NOT NULL DROP TABLE dbo.TEDARIKCI;
GO
CREATE TABLE TEDARIKCI (
    TedarikciID  INT          IDENTITY(1,1) PRIMARY KEY,
    FirmaAdi     VARCHAR(150) NOT NULL,
    VergiNo      VARCHAR(20)  NOT NULL,
    YetkiliAdi   VARCHAR(100) NULL,
    Telefon      VARCHAR(20)  NOT NULL,
    Email        VARCHAR(100) NULL,
    Adres        VARCHAR(300) NOT NULL,
    OdemeVadesi  INT          NOT NULL DEFAULT 30,
    AktifMi      TINYINT      NOT NULL DEFAULT 1,
    CONSTRAINT UQ_Tedarikci_VergiNo UNIQUE (VergiNo),
    CONSTRAINT CHK_OdemeVadesi      CHECK  (OdemeVadesi >= 0)
);
GO

-- ------------------------------------------------------------
-- 9. MUSTERI
-- ------------------------------------------------------------
IF OBJECT_ID('dbo.MUSTERI', 'U') IS NOT NULL DROP TABLE dbo.MUSTERI;
GO
CREATE TABLE MUSTERI (
    MusteriID    INT           IDENTITY(1,1) PRIMARY KEY,
    FirmaAdi     VARCHAR(150)  NOT NULL,
    VergiNo      VARCHAR(20)   NOT NULL,
    YetkiliAdi   VARCHAR(100)  NULL,
    Telefon      VARCHAR(20)   NOT NULL,
    Email        VARCHAR(100)  NULL,
    Adres        VARCHAR(300)  NOT NULL,
    KrediLimiti  DECIMAL(12,2) NOT NULL DEFAULT 0,
    IndirimOrani DECIMAL(5,2)  NOT NULL DEFAULT 0,
    MusteriTipi  VARCHAR(50)   NOT NULL DEFAULT 'Bayi',
    KayitTarihi  DATE          NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    AktifMi      TINYINT       NOT NULL DEFAULT 1,
    CONSTRAINT UQ_Musteri_VergiNo UNIQUE (VergiNo),
    CONSTRAINT CHK_MusteriTipi   CHECK  (MusteriTipi IN ('Bayi','Servis','Perakendeci')),
    CONSTRAINT CHK_IndirimOrani  CHECK  (IndirimOrani BETWEEN 0 AND 100),
    CONSTRAINT CHK_KrediLimiti   CHECK  (KrediLimiti >= 0)
);
GO

-- ------------------------------------------------------------
-- 10. SATINALMASIPARISI
-- ------------------------------------------------------------
IF OBJECT_ID('dbo.SATINALMASIPARISI', 'U') IS NOT NULL DROP TABLE dbo.SATINALMASIPARISI;
GO
CREATE TABLE SATINALMASIPARISI (
    SatinAlmaSiparisID  INT           IDENTITY(1,1) PRIMARY KEY,
    TedarikciID         INT           NOT NULL,
    CalisanID           INT           NOT NULL,
    SiparisTarihi       DATE          NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    TeslimTarihi        DATE          NULL,
    ToplamTutar         DECIMAL(12,2) NOT NULL DEFAULT 0,
    Durum               VARCHAR(50)   NOT NULL DEFAULT 'Beklemede',
    Notlar              VARCHAR(500)  NULL,
    CONSTRAINT FK_SAS_Tedarikci FOREIGN KEY (TedarikciID) REFERENCES TEDARIKCI(TedarikciID),
    CONSTRAINT FK_SAS_Calisan   FOREIGN KEY (CalisanID)   REFERENCES CALISKAN(CalisanID),
    CONSTRAINT CHK_SAS_Durum    CHECK (Durum IN ('Beklemede','Onaylandi','Teslim Alindi','Iptal'))
);
GO

-- ------------------------------------------------------------
-- 11. SATINALMASIPARISDETAY
-- ------------------------------------------------------------
IF OBJECT_ID('dbo.SATINALMASIPARISDETAY', 'U') IS NOT NULL DROP TABLE dbo.SATINALMASIPARISDETAY;
GO
CREATE TABLE SATINALMASIPARISDETAY (
    DetayID              INT           IDENTITY(1,1) PRIMARY KEY,
    SatinAlmaSiparisID   INT           NOT NULL,
    UrunID               INT           NOT NULL,
    Miktar               INT           NOT NULL,
    BirimAlimFiyati      DECIMAL(10,2) NOT NULL,
    ToplamFiyat          AS (Miktar * BirimAlimFiyati) PERSISTED,
    CONSTRAINT CHK_SASD_Miktar   CHECK (Miktar > 0),
    CONSTRAINT CHK_SASD_Fiyat    CHECK (BirimAlimFiyati > 0),
    CONSTRAINT FK_SASD_Siparis   FOREIGN KEY (SatinAlmaSiparisID) REFERENCES SATINALMASIPARISI(SatinAlmaSiparisID),
    CONSTRAINT FK_SASD_Urun      FOREIGN KEY (UrunID) REFERENCES URUN(UrunID)
);
GO

-- ------------------------------------------------------------
-- 12. SATISSIPARISI
-- ------------------------------------------------------------
IF OBJECT_ID('dbo.SATISSIPARISI', 'U') IS NOT NULL DROP TABLE dbo.SATISSIPARISI;
GO
CREATE TABLE SATISSIPARISI (
    SatisSiparisID        INT           IDENTITY(1,1) PRIMARY KEY,
    MusteriID             INT           NOT NULL,
    CalisanID             INT           NOT NULL,
    SiparisTarihi         DATETIME      NOT NULL DEFAULT GETDATE(),
    TalepEdilenTeslimat   DATE          NULL,
    AraToplam             DECIMAL(12,2) NOT NULL DEFAULT 0,
    IskontoTutari         DECIMAL(12,2) NOT NULL DEFAULT 0,
    KDVTutari             DECIMAL(12,2) NOT NULL DEFAULT 0,
    GenelToplam           DECIMAL(12,2) NOT NULL DEFAULT 0,
    Durum                 VARCHAR(50)   NOT NULL DEFAULT 'Yeni',
    Notlar                VARCHAR(500)  NULL,
    CONSTRAINT FK_SS_Musteri FOREIGN KEY (MusteriID) REFERENCES MUSTERI(MusteriID),
    CONSTRAINT FK_SS_Calisan FOREIGN KEY (CalisanID) REFERENCES CALISKAN(CalisanID),
    CONSTRAINT CHK_SS_Durum  CHECK (Durum IN ('Yeni','Onaylandi','Hazirlaniyor','Kargoda','Teslim Edildi','Iptal'))
);
GO

-- ------------------------------------------------------------
-- 13. SATISSIPARISDETAY
-- ------------------------------------------------------------
IF OBJECT_ID('dbo.SATISSIPARISDETAY', 'U') IS NOT NULL DROP TABLE dbo.SATISSIPARISDETAY;
GO
CREATE TABLE SATISSIPARISDETAY (
    DetayID           INT           IDENTITY(1,1) PRIMARY KEY,
    SatisSiparisID    INT           NOT NULL,
    UrunID            INT           NOT NULL,
    Miktar            INT           NOT NULL,
    BirimSatisFiyati  DECIMAL(10,2) NOT NULL,
    IskontoOrani      DECIMAL(5,2)  NOT NULL DEFAULT 0,
    ToplamFiyat       DECIMAL(12,2) NOT NULL DEFAULT 0,
    CONSTRAINT CHK_SSD_Miktar     CHECK (Miktar > 0),
    CONSTRAINT CHK_SSD_Fiyat      CHECK (BirimSatisFiyati > 0),
    CONSTRAINT CHK_SSD_Iskonto    CHECK (IskontoOrani BETWEEN 0 AND 100),
    CONSTRAINT FK_SSD_Siparis     FOREIGN KEY (SatisSiparisID) REFERENCES SATISSIPARISI(SatisSiparisID),
    CONSTRAINT FK_SSD_Urun        FOREIGN KEY (UrunID)         REFERENCES URUN(UrunID)
);
GO

-- ------------------------------------------------------------
-- 14. FATURA
-- ------------------------------------------------------------
IF OBJECT_ID('dbo.FATURA', 'U') IS NOT NULL DROP TABLE dbo.FATURA;
GO
CREATE TABLE FATURA (
    FaturaID        INT           IDENTITY(1,1) PRIMARY KEY,
    SatisSiparisID  INT           NOT NULL,
    FaturaNo        VARCHAR(30)   NOT NULL,
    FaturaTarihi    DATE          NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    VadeTarihi      DATE          NOT NULL,
    ToplamTutar     DECIMAL(12,2) NOT NULL,
    OdenenTutar     DECIMAL(12,2) NOT NULL DEFAULT 0,
    KalanBorc       DECIMAL(12,2) NOT NULL,
    OdemeDurumu     VARCHAR(50)   NOT NULL DEFAULT 'Odenmedi',
    CONSTRAINT UQ_FaturaNo           UNIQUE (FaturaNo),
    CONSTRAINT UQ_Fatura_Siparis     UNIQUE (SatisSiparisID),
    CONSTRAINT CHK_Fatura_Durum      CHECK  (OdemeDurumu IN ('Odenmedi','Kismen Odendi','Odendi')),
    CONSTRAINT FK_Fatura_Siparis     FOREIGN KEY (SatisSiparisID) REFERENCES SATISSIPARISI(SatisSiparisID)
);
GO

-- ------------------------------------------------------------
-- 15. ODEME
-- ------------------------------------------------------------
IF OBJECT_ID('dbo.ODEME', 'U') IS NOT NULL DROP TABLE dbo.ODEME;
GO
CREATE TABLE ODEME (
    OdemeID        INT           IDENTITY(1,1) PRIMARY KEY,
    FaturaID       INT           NOT NULL,
    OdemeTarihi    DATE          NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    OdemeYontemi   VARCHAR(50)   NOT NULL,
    OdenenTutar    DECIMAL(12,2) NOT NULL,
    Aciklama       VARCHAR(300)  NULL,
    CONSTRAINT CHK_Odeme_Tutar   CHECK (OdenenTutar > 0),
    CONSTRAINT CHK_Odeme_Yontem  CHECK (OdemeYontemi IN ('Nakit','Havale','Cek','Kredi Karti')),
    CONSTRAINT FK_Odeme_Fatura   FOREIGN KEY (FaturaID) REFERENCES FATURA(FaturaID)
);
GO

-- ------------------------------------------------------------
-- 16. TESLIMAT
-- ------------------------------------------------------------
IF OBJECT_ID('dbo.TESLIMAT', 'U') IS NOT NULL DROP TABLE dbo.TESLIMAT;
GO
CREATE TABLE TESLIMAT (
    TeslimatID      INT          IDENTITY(1,1) PRIMARY KEY,
    SatisSiparisID  INT          NOT NULL,
    CalisanID       INT          NOT NULL,
    TeslimatTarihi  DATE         NOT NULL,
    TeslimatAdresi  VARCHAR(300) NOT NULL,
    Durum           VARCHAR(50)  NOT NULL DEFAULT 'Hazirlaniyor',
    KargoFirmasi    VARCHAR(100) NULL,
    TakipNo         VARCHAR(100) NULL,
    CONSTRAINT CHK_Teslimat_Durum    CHECK (Durum IN ('Hazirlaniyor','Kargoya Verildi','Teslim Edildi','Iade')),
    CONSTRAINT FK_Teslimat_Siparis   FOREIGN KEY (SatisSiparisID) REFERENCES SATISSIPARISI(SatisSiparisID),
    CONSTRAINT FK_Teslimat_Calisan   FOREIGN KEY (CalisanID)      REFERENCES CALISKAN(CalisanID)
);
GO


-- ============================================================
-- BÖLÜM 2: STORED PROCEDURE'LER
-- ============================================================

-- ============================================================
-- SP: KATEGORİ
-- ============================================================

-- Ekle
CREATE OR ALTER PROCEDURE sp_KategoriEkle
    @KategoriAdi VARCHAR(100),
    @Aciklama    VARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO KATEGORI (KategoriAdi, Aciklama)
    VALUES (@KategoriAdi, @Aciklama);
    SELECT SCOPE_IDENTITY() AS YeniKategoriID;
END;
GO

-- Güncelle
CREATE OR ALTER PROCEDURE sp_KategoriGuncelle
    @KategoriID  INT,
    @KategoriAdi VARCHAR(100),
    @Aciklama    VARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE KATEGORI
    SET KategoriAdi = @KategoriAdi,
        Aciklama    = @Aciklama
    WHERE KategoriID = @KategoriID;
END;
GO

-- Sil
CREATE OR ALTER PROCEDURE sp_KategoriSil
    @KategoriID INT
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM URUN WHERE KategoriID = @KategoriID)
    BEGIN
        RAISERROR('Bu kategoriye bağlı ürünler bulunduğu için silinemez.', 16, 1);
        RETURN;
    END
    DELETE FROM KATEGORI WHERE KategoriID = @KategoriID;
END;
GO

-- Listele
CREATE OR ALTER PROCEDURE sp_KategoriListele
    @KategoriID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT KategoriID, KategoriAdi, Aciklama
    FROM   KATEGORI
    WHERE  (@KategoriID IS NULL OR KategoriID = @KategoriID)
    ORDER BY KategoriAdi;
END;
GO

-- ============================================================
-- SP: MARKA
-- ============================================================

CREATE OR ALTER PROCEDURE sp_MarkaEkle
    @MarkaAdi VARCHAR(100),
    @UlkeKodu CHAR(2)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO MARKA (MarkaAdi, UlkeKodu)
    VALUES (@MarkaAdi, @UlkeKodu);
    SELECT SCOPE_IDENTITY() AS YeniMarkaID;
END;
GO

CREATE OR ALTER PROCEDURE sp_MarkaGuncelle
    @MarkaID  INT,
    @MarkaAdi VARCHAR(100),
    @UlkeKodu CHAR(2)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE MARKA
    SET MarkaAdi = @MarkaAdi,
        UlkeKodu = @UlkeKodu
    WHERE MarkaID = @MarkaID;
END;
GO

CREATE OR ALTER PROCEDURE sp_MarkaSil
    @MarkaID INT
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM URUN WHERE MarkaID = @MarkaID)
    BEGIN
        RAISERROR('Bu markaya bağlı ürünler bulunduğu için silinemez.', 16, 1);
        RETURN;
    END
    DELETE FROM MARKA WHERE MarkaID = @MarkaID;
END;
GO

CREATE OR ALTER PROCEDURE sp_MarkaListele
    @MarkaID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT MarkaID, MarkaAdi, UlkeKodu
    FROM   MARKA
    WHERE  (@MarkaID IS NULL OR MarkaID = @MarkaID)
    ORDER BY MarkaAdi;
END;
GO

-- ============================================================
-- SP: DEPARTMAN
-- ============================================================

CREATE OR ALTER PROCEDURE sp_DepartmanEkle
    @DepartmanAdi VARCHAR(100),
    @Aciklama     VARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO DEPARTMAN (DepartmanAdi, Aciklama)
    VALUES (@DepartmanAdi, @Aciklama);
    SELECT SCOPE_IDENTITY() AS YeniDepartmanID;
END;
GO

CREATE OR ALTER PROCEDURE sp_DepartmanGuncelle
    @DepartmanID  INT,
    @DepartmanAdi VARCHAR(100),
    @Aciklama     VARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE DEPARTMAN
    SET DepartmanAdi = @DepartmanAdi,
        Aciklama     = @Aciklama
    WHERE DepartmanID = @DepartmanID;
END;
GO

CREATE OR ALTER PROCEDURE sp_DepartmanSil
    @DepartmanID INT
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM CALISKAN WHERE DepartmanID = @DepartmanID)
    BEGIN
        RAISERROR('Bu departmana bağlı çalışanlar olduğu için silinemez.', 16, 1);
        RETURN;
    END
    DELETE FROM DEPARTMAN WHERE DepartmanID = @DepartmanID;
END;
GO

CREATE OR ALTER PROCEDURE sp_DepartmanListele
    @DepartmanID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT DepartmanID, DepartmanAdi, Aciklama
    FROM   DEPARTMAN
    WHERE  (@DepartmanID IS NULL OR DepartmanID = @DepartmanID)
    ORDER BY DepartmanAdi;
END;
GO

-- ============================================================
-- SP: ÇALIŞAN
-- ============================================================

CREATE OR ALTER PROCEDURE sp_CalisanEkle
    @Ad             VARCHAR(50),
    @Soyad          VARCHAR(50),
    @TCKN           CHAR(11),
    @DepartmanID    INT,
    @Gorev          VARCHAR(100),
    @Maas           DECIMAL(10,2),
    @IseGirisTarihi DATE,
    @Telefon        VARCHAR(20)  = NULL,
    @Email          VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO CALISKAN (Ad, Soyad, TCKN, DepartmanID, Gorev, Maas, IseGirisTarihi, Telefon, Email, AktifMi)
    VALUES (@Ad, @Soyad, @TCKN, @DepartmanID, @Gorev, @Maas, @IseGirisTarihi, @Telefon, @Email, 1);
    SELECT SCOPE_IDENTITY() AS YeniCalisanID;
END;
GO

CREATE OR ALTER PROCEDURE sp_CalisanGuncelle
    @CalisanID   INT,
    @Ad          VARCHAR(50),
    @Soyad       VARCHAR(50),
    @DepartmanID INT,
    @Gorev       VARCHAR(100),
    @Maas        DECIMAL(10,2),
    @Telefon     VARCHAR(20)  = NULL,
    @Email       VARCHAR(100) = NULL,
    @AktifMi     TINYINT      = 1
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE CALISKAN
    SET Ad          = @Ad,
        Soyad       = @Soyad,
        DepartmanID = @DepartmanID,
        Gorev       = @Gorev,
        Maas        = @Maas,
        Telefon     = @Telefon,
        Email       = @Email,
        AktifMi     = @AktifMi
    WHERE CalisanID = @CalisanID;
END;
GO

CREATE OR ALTER PROCEDURE sp_CalisanSil
    @CalisanID INT
AS
BEGIN
    SET NOCOUNT ON;
    -- Pasif yap, fiziksel silme yapma
    UPDATE CALISKAN SET AktifMi = 0 WHERE CalisanID = @CalisanID;
END;
GO

CREATE OR ALTER PROCEDURE sp_CalisanListele
    @CalisanID   INT    = NULL,
    @DepartmanID INT    = NULL,
    @AktifMi     TINYINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT C.CalisanID, C.Ad, C.Soyad, C.TCKN,
           D.DepartmanAdi, C.Gorev, C.Maas,
           C.IseGirisTarihi, C.Telefon, C.Email, C.AktifMi
    FROM   CALISKAN C
    JOIN   DEPARTMAN D ON C.DepartmanID = D.DepartmanID
    WHERE  (@CalisanID   IS NULL OR C.CalisanID   = @CalisanID)
      AND  (@DepartmanID IS NULL OR C.DepartmanID = @DepartmanID)
      AND  (@AktifMi     IS NULL OR C.AktifMi     = @AktifMi)
    ORDER BY C.Soyad, C.Ad;
END;
GO

-- ============================================================
-- SP: DEPO
-- ============================================================

CREATE OR ALTER PROCEDURE sp_DepoEkle
    @DepoAdi           VARCHAR(100),
    @Adres             VARCHAR(300),
    @SorumluCalisanID  INT           = NULL,
    @KapasiteM2        DECIMAL(10,2) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO DEPO (DepoAdi, Adres, SorumluCalisanID, KapasiteM2)
    VALUES (@DepoAdi, @Adres, @SorumluCalisanID, @KapasiteM2);
    SELECT SCOPE_IDENTITY() AS YeniDepoID;
END;
GO

CREATE OR ALTER PROCEDURE sp_DepoGuncelle
    @DepoID            INT,
    @DepoAdi           VARCHAR(100),
    @Adres             VARCHAR(300),
    @SorumluCalisanID  INT           = NULL,
    @KapasiteM2        DECIMAL(10,2) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE DEPO
    SET DepoAdi           = @DepoAdi,
        Adres             = @Adres,
        SorumluCalisanID  = @SorumluCalisanID,
        KapasiteM2        = @KapasiteM2
    WHERE DepoID = @DepoID;
END;
GO

CREATE OR ALTER PROCEDURE sp_DepoSil
    @DepoID INT
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM DEPOSTOK WHERE DepoID = @DepoID)
    BEGIN
        RAISERROR('Bu depoya ait stok kayıtları olduğu için silinemez.', 16, 1);
        RETURN;
    END
    DELETE FROM DEPO WHERE DepoID = @DepoID;
END;
GO

CREATE OR ALTER PROCEDURE sp_DepoListele
    @DepoID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT D.DepoID, D.DepoAdi, D.Adres,
           C.Ad + ' ' + C.Soyad AS SorumluCalisan,
           D.KapasiteM2
    FROM   DEPO D
    LEFT JOIN CALISKAN C ON D.SorumluCalisanID = C.CalisanID
    WHERE  (@DepoID IS NULL OR D.DepoID = @DepoID)
    ORDER BY D.DepoAdi;
END;
GO

-- ============================================================
-- SP: ÜRÜN
-- ============================================================

CREATE OR ALTER PROCEDURE sp_UrunEkle
    @UrunKodu      VARCHAR(50),
    @UrunAdi       VARCHAR(200),
    @KategoriID    INT,
    @MarkaID       INT,
    @BirimFiyat    DECIMAL(10,2),
    @KDVOrani      DECIMAL(5,2)  = 18.00,
    @StokMiktari   INT           = 0,
    @MinStokEsigi  INT           = 10,
    @Birim         VARCHAR(20)   = 'Adet'
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO URUN (UrunKodu, UrunAdi, KategoriID, MarkaID, BirimFiyat,
                      KDVOrani, StokMiktari, MinStokEsigi, Birim, AktifMi)
    VALUES (@UrunKodu, @UrunAdi, @KategoriID, @MarkaID, @BirimFiyat,
            @KDVOrani, @StokMiktari, @MinStokEsigi, @Birim, 1);
    SELECT SCOPE_IDENTITY() AS YeniUrunID;
END;
GO

CREATE OR ALTER PROCEDURE sp_UrunGuncelle
    @UrunID        INT,
    @UrunAdi       VARCHAR(200),
    @KategoriID    INT,
    @MarkaID       INT,
    @BirimFiyat    DECIMAL(10,2),
    @KDVOrani      DECIMAL(5,2),
    @MinStokEsigi  INT,
    @Birim         VARCHAR(20),
    @AktifMi       TINYINT = 1
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE URUN
    SET UrunAdi      = @UrunAdi,
        KategoriID   = @KategoriID,
        MarkaID      = @MarkaID,
        BirimFiyat   = @BirimFiyat,
        KDVOrani     = @KDVOrani,
        MinStokEsigi = @MinStokEsigi,
        Birim        = @Birim,
        AktifMi      = @AktifMi
    WHERE UrunID = @UrunID;
END;
GO

CREATE OR ALTER PROCEDURE sp_UrunSil
    @UrunID INT
AS
BEGIN
    SET NOCOUNT ON;
    -- Pasif yap
    UPDATE URUN SET AktifMi = 0 WHERE UrunID = @UrunID;
END;
GO

CREATE OR ALTER PROCEDURE sp_UrunListele
    @UrunID     INT     = NULL,
    @KategoriID INT     = NULL,
    @MarkaID    INT     = NULL,
    @AktifMi    TINYINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT U.UrunID, U.UrunKodu, U.UrunAdi,
           K.KategoriAdi, M.MarkaAdi,
           U.BirimFiyat, U.KDVOrani,
           U.StokMiktari, U.MinStokEsigi, U.Birim, U.AktifMi,
           CASE WHEN U.StokMiktari <= U.MinStokEsigi THEN 'KRİTİK STOK' ELSE 'Normal' END AS StokUyari
    FROM   URUN U
    JOIN   KATEGORI K ON U.KategoriID = K.KategoriID
    JOIN   MARKA    M ON U.MarkaID    = M.MarkaID
    WHERE  (@UrunID     IS NULL OR U.UrunID     = @UrunID)
      AND  (@KategoriID IS NULL OR U.KategoriID = @KategoriID)
      AND  (@MarkaID    IS NULL OR U.MarkaID    = @MarkaID)
      AND  (@AktifMi    IS NULL OR U.AktifMi    = @AktifMi)
    ORDER BY U.UrunAdi;
END;
GO

-- ============================================================
-- SP: DEPO STOK
-- ============================================================

CREATE OR ALTER PROCEDURE sp_DepoStokEkle
    @DepoID     INT,
    @UrunID     INT,
    @Miktar     INT,
    @RafKonumu  VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM DEPOSTOK WHERE DepoID = @DepoID AND UrunID = @UrunID)
    BEGIN
        UPDATE DEPOSTOK
        SET Miktar = Miktar + @Miktar,
            RafKonumu = ISNULL(@RafKonumu, RafKonumu)
        WHERE DepoID = @DepoID AND UrunID = @UrunID;
    END
    ELSE
    BEGIN
        INSERT INTO DEPOSTOK (DepoID, UrunID, Miktar, RafKonumu)
        VALUES (@DepoID, @UrunID, @Miktar, @RafKonumu);
    END
END;
GO

CREATE OR ALTER PROCEDURE sp_DepoStokGuncelle
    @DepoStokID INT,
    @Miktar     INT,
    @RafKonumu  VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE DEPOSTOK
    SET Miktar    = @Miktar,
        RafKonumu = @RafKonumu
    WHERE DepoStokID = @DepoStokID;
END;
GO

CREATE OR ALTER PROCEDURE sp_DepoStokSil
    @DepoStokID INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM DEPOSTOK WHERE DepoStokID = @DepoStokID;
END;
GO

CREATE OR ALTER PROCEDURE sp_DepoStokListele
    @DepoID INT = NULL,
    @UrunID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT DS.DepoStokID, D.DepoAdi, U.UrunKodu, U.UrunAdi,
           DS.Miktar, DS.RafKonumu,
           U.MinStokEsigi,
           CASE WHEN DS.Miktar <= U.MinStokEsigi THEN 'KRİTİK' ELSE 'Normal' END AS StokDurumu
    FROM   DEPOSTOK DS
    JOIN   DEPO D ON DS.DepoID = D.DepoID
    JOIN   URUN U ON DS.UrunID = U.UrunID
    WHERE  (@DepoID IS NULL OR DS.DepoID = @DepoID)
      AND  (@UrunID IS NULL OR DS.UrunID = @UrunID)
    ORDER BY D.DepoAdi, U.UrunAdi;
END;
GO

-- ============================================================
-- SP: TEDARİKÇİ
-- ============================================================

CREATE OR ALTER PROCEDURE sp_TedarikciEkle
    @FirmaAdi    VARCHAR(150),
    @VergiNo     VARCHAR(20),
    @YetkiliAdi  VARCHAR(100) = NULL,
    @Telefon     VARCHAR(20),
    @Email       VARCHAR(100) = NULL,
    @Adres       VARCHAR(300),
    @OdemeVadesi INT = 30
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO TEDARIKCI (FirmaAdi, VergiNo, YetkiliAdi, Telefon, Email, Adres, OdemeVadesi, AktifMi)
    VALUES (@FirmaAdi, @VergiNo, @YetkiliAdi, @Telefon, @Email, @Adres, @OdemeVadesi, 1);
    SELECT SCOPE_IDENTITY() AS YeniTedarikciID;
END;
GO

CREATE OR ALTER PROCEDURE sp_TedarikciGuncelle
    @TedarikciID INT,
    @FirmaAdi    VARCHAR(150),
    @VergiNo     VARCHAR(20),
    @YetkiliAdi  VARCHAR(100) = NULL,
    @Telefon     VARCHAR(20),
    @Email       VARCHAR(100) = NULL,
    @Adres       VARCHAR(300),
    @OdemeVadesi INT,
    @AktifMi     TINYINT = 1
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE TEDARIKCI
    SET FirmaAdi    = @FirmaAdi,
        VergiNo     = @VergiNo,
        YetkiliAdi  = @YetkiliAdi,
        Telefon     = @Telefon,
        Email       = @Email,
        Adres       = @Adres,
        OdemeVadesi = @OdemeVadesi,
        AktifMi     = @AktifMi
    WHERE TedarikciID = @TedarikciID;
END;
GO

CREATE OR ALTER PROCEDURE sp_TedarikciSil
    @TedarikciID INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE TEDARIKCI SET AktifMi = 0 WHERE TedarikciID = @TedarikciID;
END;
GO

CREATE OR ALTER PROCEDURE sp_TedarikciListele
    @TedarikciID INT     = NULL,
    @AktifMi     TINYINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT TedarikciID, FirmaAdi, VergiNo, YetkiliAdi,
           Telefon, Email, Adres, OdemeVadesi, AktifMi
    FROM   TEDARIKCI
    WHERE  (@TedarikciID IS NULL OR TedarikciID = @TedarikciID)
      AND  (@AktifMi     IS NULL OR AktifMi     = @AktifMi)
    ORDER BY FirmaAdi;
END;
GO

-- ============================================================
-- SP: MÜŞTERİ
-- ============================================================

CREATE OR ALTER PROCEDURE sp_MusteriEkle
    @FirmaAdi     VARCHAR(150),
    @VergiNo      VARCHAR(20),
    @YetkiliAdi   VARCHAR(100) = NULL,
    @Telefon      VARCHAR(20),
    @Email        VARCHAR(100) = NULL,
    @Adres        VARCHAR(300),
    @KrediLimiti  DECIMAL(12,2) = 0,
    @IndirimOrani DECIMAL(5,2)  = 0,
    @MusteriTipi  VARCHAR(50)   = 'Bayi'
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO MUSTERI (FirmaAdi, VergiNo, YetkiliAdi, Telefon, Email, Adres,
                         KrediLimiti, IndirimOrani, MusteriTipi, KayitTarihi, AktifMi)
    VALUES (@FirmaAdi, @VergiNo, @YetkiliAdi, @Telefon, @Email, @Adres,
            @KrediLimiti, @IndirimOrani, @MusteriTipi, CAST(GETDATE() AS DATE), 1);
    SELECT SCOPE_IDENTITY() AS YeniMusteriID;
END;
GO

CREATE OR ALTER PROCEDURE sp_MusteriGuncelle
    @MusteriID    INT,
    @FirmaAdi     VARCHAR(150),
    @VergiNo      VARCHAR(20),
    @YetkiliAdi   VARCHAR(100) = NULL,
    @Telefon      VARCHAR(20),
    @Email        VARCHAR(100) = NULL,
    @Adres        VARCHAR(300),
    @KrediLimiti  DECIMAL(12,2),
    @IndirimOrani DECIMAL(5,2),
    @MusteriTipi  VARCHAR(50),
    @AktifMi      TINYINT = 1
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE MUSTERI
    SET FirmaAdi     = @FirmaAdi,
        VergiNo      = @VergiNo,
        YetkiliAdi   = @YetkiliAdi,
        Telefon      = @Telefon,
        Email        = @Email,
        Adres        = @Adres,
        KrediLimiti  = @KrediLimiti,
        IndirimOrani = @IndirimOrani,
        MusteriTipi  = @MusteriTipi,
        AktifMi      = @AktifMi
    WHERE MusteriID = @MusteriID;
END;
GO

CREATE OR ALTER PROCEDURE sp_MusteriSil
    @MusteriID INT
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE MUSTERI SET AktifMi = 0 WHERE MusteriID = @MusteriID;
END;
GO

CREATE OR ALTER PROCEDURE sp_MusteriListele
    @MusteriID   INT     = NULL,
    @MusteriTipi VARCHAR(50) = NULL,
    @AktifMi     TINYINT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT MusteriID, FirmaAdi, VergiNo, YetkiliAdi,
           Telefon, Email, Adres, KrediLimiti,
           IndirimOrani, MusteriTipi, KayitTarihi, AktifMi
    FROM   MUSTERI
    WHERE  (@MusteriID   IS NULL OR MusteriID   = @MusteriID)
      AND  (@MusteriTipi IS NULL OR MusteriTipi = @MusteriTipi)
      AND  (@AktifMi     IS NULL OR AktifMi     = @AktifMi)
    ORDER BY FirmaAdi;
END;
GO

-- ============================================================
-- SP: SATINALMA SİPARİŞİ
-- ============================================================

CREATE OR ALTER PROCEDURE sp_SatinAlmaSiparisEkle
    @TedarikciID  INT,
    @CalisanID    INT,
    @SiparisTarihi DATE = NULL,
    @Notlar        VARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO SATINALMASIPARISI (TedarikciID, CalisanID, SiparisTarihi, Durum, Notlar, ToplamTutar)
    VALUES (@TedarikciID, @CalisanID,
            ISNULL(@SiparisTarihi, CAST(GETDATE() AS DATE)),
            'Beklemede', @Notlar, 0);
    SELECT SCOPE_IDENTITY() AS YeniSiparisID;
END;
GO

CREATE OR ALTER PROCEDURE sp_SatinAlmaSiparisGuncelle
    @SatinAlmaSiparisID INT,
    @Durum              VARCHAR(50),
    @TeslimTarihi       DATE        = NULL,
    @Notlar             VARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE SATINALMASIPARISI
    SET Durum        = @Durum,
        TeslimTarihi = @TeslimTarihi,
        Notlar       = @Notlar
    WHERE SatinAlmaSiparisID = @SatinAlmaSiparisID;
END;
GO

CREATE OR ALTER PROCEDURE sp_SatinAlmaSiparisSil
    @SatinAlmaSiparisID INT
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM SATINALMASIPARISDETAY WHERE SatinAlmaSiparisID = @SatinAlmaSiparisID)
    BEGIN
        DELETE FROM SATINALMASIPARISDETAY WHERE SatinAlmaSiparisID = @SatinAlmaSiparisID;
    END
    DELETE FROM SATINALMASIPARISI WHERE SatinAlmaSiparisID = @SatinAlmaSiparisID;
END;
GO

CREATE OR ALTER PROCEDURE sp_SatinAlmaSiparisListele
    @SatinAlmaSiparisID INT    = NULL,
    @TedarikciID        INT    = NULL,
    @Durum              VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT SA.SatinAlmaSiparisID, T.FirmaAdi AS Tedarikci,
           C.Ad + ' ' + C.Soyad AS SiparisVerenCalisan,
           SA.SiparisTarihi, SA.TeslimTarihi,
           SA.ToplamTutar, SA.Durum, SA.Notlar
    FROM   SATINALMASIPARISI SA
    JOIN   TEDARIKCI T ON SA.TedarikciID = T.TedarikciID
    JOIN   CALISKAN  C ON SA.CalisanID   = C.CalisanID
    WHERE  (@SatinAlmaSiparisID IS NULL OR SA.SatinAlmaSiparisID = @SatinAlmaSiparisID)
      AND  (@TedarikciID        IS NULL OR SA.TedarikciID        = @TedarikciID)
      AND  (@Durum              IS NULL OR SA.Durum              = @Durum)
    ORDER BY SA.SiparisTarihi DESC;
END;
GO

-- ============================================================
-- SP: SATINALMA SİPARİŞ DETAY
-- ============================================================

CREATE OR ALTER PROCEDURE sp_SatinAlmaDetayEkle
    @SatinAlmaSiparisID INT,
    @UrunID             INT,
    @Miktar             INT,
    @BirimAlimFiyati    DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO SATINALMASIPARISDETAY (SatinAlmaSiparisID, UrunID, Miktar, BirimAlimFiyati)
    VALUES (@SatinAlmaSiparisID, @UrunID, @Miktar, @BirimAlimFiyati);

    -- Sipariş toplamını güncelle
    UPDATE SATINALMASIPARISI
    SET ToplamTutar = (
        SELECT SUM(ToplamFiyat) FROM SATINALMASIPARISDETAY
        WHERE SatinAlmaSiparisID = @SatinAlmaSiparisID
    )
    WHERE SatinAlmaSiparisID = @SatinAlmaSiparisID;

    -- Stok artır
    UPDATE URUN SET StokMiktari = StokMiktari + @Miktar WHERE UrunID = @UrunID;
END;
GO

CREATE OR ALTER PROCEDURE sp_SatinAlmaDetayGuncelle
    @DetayID         INT,
    @Miktar          INT,
    @BirimAlimFiyati DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @EskiMiktar INT, @UrunID INT, @SiparisID INT;
    SELECT @EskiMiktar = Miktar, @UrunID = UrunID, @SiparisID = SatinAlmaSiparisID
    FROM SATINALMASIPARISDETAY WHERE DetayID = @DetayID;

    UPDATE SATINALMASIPARISDETAY
    SET Miktar = @Miktar, BirimAlimFiyati = @BirimAlimFiyati
    WHERE DetayID = @DetayID;

    -- Stok farkını güncelle
    UPDATE URUN SET StokMiktari = StokMiktari + (@Miktar - @EskiMiktar) WHERE UrunID = @UrunID;

    -- Sipariş toplamını güncelle
    UPDATE SATINALMASIPARISI
    SET ToplamTutar = (SELECT SUM(ToplamFiyat) FROM SATINALMASIPARISDETAY WHERE SatinAlmaSiparisID = @SiparisID)
    WHERE SatinAlmaSiparisID = @SiparisID;
END;
GO

CREATE OR ALTER PROCEDURE sp_SatinAlmaDetaySil
    @DetayID INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Miktar INT, @UrunID INT, @SiparisID INT;
    SELECT @Miktar = Miktar, @UrunID = UrunID, @SiparisID = SatinAlmaSiparisID
    FROM SATINALMASIPARISDETAY WHERE DetayID = @DetayID;

    DELETE FROM SATINALMASIPARISDETAY WHERE DetayID = @DetayID;
    UPDATE URUN SET StokMiktari = StokMiktari - @Miktar WHERE UrunID = @UrunID;

    UPDATE SATINALMASIPARISI
    SET ToplamTutar = ISNULL((SELECT SUM(ToplamFiyat) FROM SATINALMASIPARISDETAY WHERE SatinAlmaSiparisID = @SiparisID), 0)
    WHERE SatinAlmaSiparisID = @SiparisID;
END;
GO

CREATE OR ALTER PROCEDURE sp_SatinAlmaDetayListele
    @SatinAlmaSiparisID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT SD.DetayID, SA.SatinAlmaSiparisID,
           U.UrunKodu, U.UrunAdi, SD.Miktar,
           SD.BirimAlimFiyati, SD.ToplamFiyat
    FROM   SATINALMASIPARISDETAY SD
    JOIN   SATINALMASIPARISI SA ON SD.SatinAlmaSiparisID = SA.SatinAlmaSiparisID
    JOIN   URUN U ON SD.UrunID = U.UrunID
    WHERE  (@SatinAlmaSiparisID IS NULL OR SD.SatinAlmaSiparisID = @SatinAlmaSiparisID);
END;
GO

-- ============================================================
-- SP: SATIŞ SİPARİŞİ
-- ============================================================

CREATE OR ALTER PROCEDURE sp_SatisSiparisEkle
    @MusteriID           INT,
    @CalisanID           INT,
    @TalepEdilenTeslimat DATE        = NULL,
    @Notlar              VARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO SATISSIPARISI (MusteriID, CalisanID, SiparisTarihi, TalepEdilenTeslimat,
                               AraToplam, IskontoTutari, KDVTutari, GenelToplam, Durum, Notlar)
    VALUES (@MusteriID, @CalisanID, GETDATE(), @TalepEdilenTeslimat,
            0, 0, 0, 0, 'Yeni', @Notlar);
    SELECT SCOPE_IDENTITY() AS YeniSiparisID;
END;
GO

CREATE OR ALTER PROCEDURE sp_SatisSiparisGuncelle
    @SatisSiparisID     INT,
    @Durum              VARCHAR(50),
    @TalepEdilenTeslimat DATE       = NULL,
    @Notlar             VARCHAR(500) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE SATISSIPARISI
    SET Durum               = @Durum,
        TalepEdilenTeslimat = @TalepEdilenTeslimat,
        Notlar              = @Notlar
    WHERE SatisSiparisID = @SatisSiparisID;
END;
GO

CREATE OR ALTER PROCEDURE sp_SatisSiparisSil
    @SatisSiparisID INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Durum VARCHAR(50);
    SELECT @Durum = Durum FROM SATISSIPARISI WHERE SatisSiparisID = @SatisSiparisID;
    IF @Durum <> 'Yeni'
    BEGIN
        RAISERROR('Sadece Yeni durumundaki siparişler silinebilir.', 16, 1);
        RETURN;
    END
    UPDATE SATISSIPARISI SET Durum = 'Iptal' WHERE SatisSiparisID = @SatisSiparisID;
END;
GO

CREATE OR ALTER PROCEDURE sp_SatisSiparisListele
    @SatisSiparisID INT    = NULL,
    @MusteriID      INT    = NULL,
    @Durum          VARCHAR(50) = NULL,
    @BaslangicTarih DATE   = NULL,
    @BitisTarih     DATE   = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT SS.SatisSiparisID, M.FirmaAdi AS Musteri,
           C.Ad + ' ' + C.Soyad AS SatisTemsilcisi,
           SS.SiparisTarihi, SS.TalepEdilenTeslimat,
           SS.AraToplam, SS.IskontoTutari, SS.KDVTutari, SS.GenelToplam,
           SS.Durum, SS.Notlar
    FROM   SATISSIPARISI SS
    JOIN   MUSTERI  M ON SS.MusteriID = M.MusteriID
    JOIN   CALISKAN C ON SS.CalisanID = C.CalisanID
    WHERE  (@SatisSiparisID IS NULL OR SS.SatisSiparisID = @SatisSiparisID)
      AND  (@MusteriID      IS NULL OR SS.MusteriID      = @MusteriID)
      AND  (@Durum          IS NULL OR SS.Durum          = @Durum)
      AND  (@BaslangicTarih IS NULL OR CAST(SS.SiparisTarihi AS DATE) >= @BaslangicTarih)
      AND  (@BitisTarih     IS NULL OR CAST(SS.SiparisTarihi AS DATE) <= @BitisTarih)
    ORDER BY SS.SiparisTarihi DESC;
END;
GO

-- ============================================================
-- SP: SATIŞ SİPARİŞ DETAY
-- ============================================================

-- Yardımcı SP: Sipariş toplamlarını hesapla ve güncelle
-- (sp_SatisDetayEkle bu SP'ye bağımlı olduğu için önce tanımlanıyor)
CREATE OR ALTER PROCEDURE sp_SatisSiparisToplamGuncelle
    @SatisSiparisID INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @AraToplam     DECIMAL(12,2);
    DECLARE @IskontoTutar  DECIMAL(12,2);
    DECLARE @KDVOrani      DECIMAL(5,2) = 18.00;

    SELECT @AraToplam    = SUM(Miktar * BirimSatisFiyati),
           @IskontoTutar = SUM(Miktar * BirimSatisFiyati * IskontoOrani / 100.0)
    FROM SATISSIPARISDETAY WHERE SatisSiparisID = @SatisSiparisID;

    SET @AraToplam    = ISNULL(@AraToplam, 0);
    SET @IskontoTutar = ISNULL(@IskontoTutar, 0);

    DECLARE @NetToplam DECIMAL(12,2) = @AraToplam - @IskontoTutar;
    DECLARE @KDVTutar  DECIMAL(12,2) = @NetToplam * @KDVOrani / 100.0;
    DECLARE @Genel     DECIMAL(12,2) = @NetToplam + @KDVTutar;

    UPDATE SATISSIPARISI
    SET AraToplam     = @AraToplam,
        IskontoTutari = @IskontoTutar,
        KDVTutari     = @KDVTutar,
        GenelToplam   = @Genel
    WHERE SatisSiparisID = @SatisSiparisID;
END;
GO

CREATE OR ALTER PROCEDURE sp_SatisDetayEkle
    @SatisSiparisID   INT,
    @UrunID           INT,
    @Miktar           INT,
    @BirimSatisFiyati DECIMAL(10,2),
    @IskontoOrani     DECIMAL(5,2) = 0
AS
BEGIN
    SET NOCOUNT ON;
    -- Stok kontrol
    DECLARE @MevcutStok INT;
    SELECT @MevcutStok = StokMiktari FROM URUN WHERE UrunID = @UrunID;
    IF @MevcutStok < @Miktar
    BEGIN
        DECLARE @StokMesaj VARCHAR(100);
        SET @StokMesaj = 'Yetersiz stok! Mevcut stok: ' + CAST(@MevcutStok AS VARCHAR(20));
        RAISERROR(@StokMesaj, 16, 1);
        RETURN;
    END

    DECLARE @ToplamFiyat DECIMAL(12,2);
    SET @ToplamFiyat = @Miktar * @BirimSatisFiyati * (1 - @IskontoOrani / 100.0);

    INSERT INTO SATISSIPARISDETAY (SatisSiparisID, UrunID, Miktar, BirimSatisFiyati, IskontoOrani, ToplamFiyat)
    VALUES (@SatisSiparisID, @UrunID, @Miktar, @BirimSatisFiyati, @IskontoOrani, @ToplamFiyat);

    -- Sipariş toplamlarını güncelle
    EXEC sp_SatisSiparisToplamGuncelle @SatisSiparisID;
END;
GO

CREATE OR ALTER PROCEDURE sp_SatisDetayGuncelle
    @DetayID          INT,
    @Miktar           INT,
    @BirimSatisFiyati DECIMAL(10,2),
    @IskontoOrani     DECIMAL(5,2)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ToplamFiyat DECIMAL(12,2);
    SET @ToplamFiyat = @Miktar * @BirimSatisFiyati * (1 - @IskontoOrani / 100.0);

    DECLARE @SiparisID INT;
    SELECT @SiparisID = SatisSiparisID FROM SATISSIPARISDETAY WHERE DetayID = @DetayID;

    UPDATE SATISSIPARISDETAY
    SET Miktar = @Miktar, BirimSatisFiyati = @BirimSatisFiyati,
        IskontoOrani = @IskontoOrani, ToplamFiyat = @ToplamFiyat
    WHERE DetayID = @DetayID;

    EXEC sp_SatisSiparisToplamGuncelle @SiparisID;
END;
GO

CREATE OR ALTER PROCEDURE sp_SatisDetaySil
    @DetayID INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @SiparisID INT, @UrunID INT, @Miktar INT;
    SELECT @SiparisID = SatisSiparisID, @UrunID = UrunID, @Miktar = Miktar
    FROM SATISSIPARISDETAY WHERE DetayID = @DetayID;

    DELETE FROM SATISSIPARISDETAY WHERE DetayID = @DetayID;
    -- Stok iade
    UPDATE URUN SET StokMiktari = StokMiktari + @Miktar WHERE UrunID = @UrunID;
    EXEC sp_SatisSiparisToplamGuncelle @SiparisID;
END;
GO

CREATE OR ALTER PROCEDURE sp_SatisDetayListele
    @SatisSiparisID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT SD.DetayID, SS.SatisSiparisID,
           U.UrunKodu, U.UrunAdi, SD.Miktar,
           SD.BirimSatisFiyati, SD.IskontoOrani, SD.ToplamFiyat
    FROM   SATISSIPARISDETAY SD
    JOIN   SATISSIPARISI SS ON SD.SatisSiparisID = SS.SatisSiparisID
    JOIN   URUN U ON SD.UrunID = U.UrunID
    WHERE  (@SatisSiparisID IS NULL OR SD.SatisSiparisID = @SatisSiparisID);
END;
GO

-- ============================================================
-- SP: FATURA
-- ============================================================

CREATE OR ALTER PROCEDURE sp_FaturaEkle
    @SatisSiparisID INT,
    @FaturaNo       VARCHAR(30),
    @FaturaTarihi   DATE,
    @VadeTarihi     DATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ToplamTutar DECIMAL(12,2);
    SELECT @ToplamTutar = GenelToplam FROM SATISSIPARISI WHERE SatisSiparisID = @SatisSiparisID;

    INSERT INTO FATURA (SatisSiparisID, FaturaNo, FaturaTarihi, VadeTarihi,
                        ToplamTutar, OdenenTutar, KalanBorc, OdemeDurumu)
    VALUES (@SatisSiparisID, @FaturaNo, @FaturaTarihi, @VadeTarihi,
            @ToplamTutar, 0, @ToplamTutar, 'Odenmedi');
    SELECT SCOPE_IDENTITY() AS YeniFaturaID;
END;
GO

CREATE OR ALTER PROCEDURE sp_FaturaGuncelle
    @FaturaID   INT,
    @VadeTarihi DATE,
    @FaturaNo   VARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE FATURA
    SET VadeTarihi = @VadeTarihi,
        FaturaNo   = @FaturaNo
    WHERE FaturaID = @FaturaID;
END;
GO

CREATE OR ALTER PROCEDURE sp_FaturaSil
    @FaturaID INT
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (SELECT 1 FROM ODEME WHERE FaturaID = @FaturaID)
    BEGIN
        RAISERROR('Bu faturaya ait ödeme kayıtları olduğu için silinemez.', 16, 1);
        RETURN;
    END
    DELETE FROM FATURA WHERE FaturaID = @FaturaID;
END;
GO

CREATE OR ALTER PROCEDURE sp_FaturaListele
    @FaturaID    INT    = NULL,
    @MusteriID   INT    = NULL,
    @OdemeDurumu VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT F.FaturaID, F.FaturaNo, M.FirmaAdi AS Musteri,
           F.FaturaTarihi, F.VadeTarihi,
           F.ToplamTutar, F.OdenenTutar, F.KalanBorc, F.OdemeDurumu,
           CASE WHEN F.VadeTarihi < CAST(GETDATE() AS DATE) AND F.OdemeDurumu <> 'Odendi'
                THEN 'VADESİ GEÇMİŞ' ELSE 'Normal' END AS VadeDurumu
    FROM   FATURA F
    JOIN   SATISSIPARISI SS ON F.SatisSiparisID = SS.SatisSiparisID
    JOIN   MUSTERI M ON SS.MusteriID = M.MusteriID
    WHERE  (@FaturaID    IS NULL OR F.FaturaID    = @FaturaID)
      AND  (@MusteriID   IS NULL OR SS.MusteriID  = @MusteriID)
      AND  (@OdemeDurumu IS NULL OR F.OdemeDurumu = @OdemeDurumu)
    ORDER BY F.FaturaTarihi DESC;
END;
GO

-- ============================================================
-- SP: ÖDEME
-- ============================================================

CREATE OR ALTER PROCEDURE sp_OdemeEkle
    @FaturaID      INT,
    @OdemeTarihi   DATE,
    @OdemeYontemi  VARCHAR(50),
    @OdenenTutar   DECIMAL(12,2),
    @Aciklama      VARCHAR(300) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @KalanBorc DECIMAL(12,2);
    SELECT @KalanBorc = KalanBorc FROM FATURA WHERE FaturaID = @FaturaID;

    IF @OdenenTutar > @KalanBorc
    BEGIN
        -- DECIMAL tipi RAISERROR formatında kullanılamaz, VARCHAR'a çevrilir
        DECLARE @HataMesaj VARCHAR(200);
        SET @HataMesaj = 'Odeme tutari kalan borctan buyuk olamaz. Kalan borc: '
                         + CAST(@KalanBorc AS VARCHAR(30)) + ' TL';
        RAISERROR(@HataMesaj, 16, 1);
        RETURN;
    END

    INSERT INTO ODEME (FaturaID, OdemeTarihi, OdemeYontemi, OdenenTutar, Aciklama)
    VALUES (@FaturaID, @OdemeTarihi, @OdemeYontemi, @OdenenTutar, @Aciklama);

    -- Fatura güncelleme trigger tarafından yapılır
    SELECT SCOPE_IDENTITY() AS YeniOdemeID;
END;
GO

CREATE OR ALTER PROCEDURE sp_OdemeGuncelle
    @OdemeID      INT,
    @OdemeTarihi  DATE,
    @OdemeYontemi VARCHAR(50),
    @OdenenTutar  DECIMAL(12,2),
    @Aciklama     VARCHAR(300) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE ODEME
    SET OdemeTarihi  = @OdemeTarihi,
        OdemeYontemi = @OdemeYontemi,
        OdenenTutar  = @OdenenTutar,
        Aciklama     = @Aciklama
    WHERE OdemeID = @OdemeID;
END;
GO

CREATE OR ALTER PROCEDURE sp_OdemeSil
    @OdemeID INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM ODEME WHERE OdemeID = @OdemeID;
END;
GO

CREATE OR ALTER PROCEDURE sp_OdemeListele
    @FaturaID INT = NULL,
    @OdemeID  INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT O.OdemeID, F.FaturaNo, M.FirmaAdi AS Musteri,
           O.OdemeTarihi, O.OdemeYontemi, O.OdenenTutar, O.Aciklama
    FROM   ODEME O
    JOIN   FATURA F ON O.FaturaID = F.FaturaID
    JOIN   SATISSIPARISI SS ON F.SatisSiparisID = SS.SatisSiparisID
    JOIN   MUSTERI M ON SS.MusteriID = M.MusteriID
    WHERE  (@FaturaID IS NULL OR O.FaturaID = @FaturaID)
      AND  (@OdemeID  IS NULL OR O.OdemeID  = @OdemeID)
    ORDER BY O.OdemeTarihi DESC;
END;
GO

-- ============================================================
-- SP: TESLİMAT
-- ============================================================

CREATE OR ALTER PROCEDURE sp_TeslimatEkle
    @SatisSiparisID INT,
    @CalisanID      INT,
    @TeslimatTarihi DATE,
    @TeslimatAdresi VARCHAR(300),
    @KargoFirmasi   VARCHAR(100) = NULL,
    @TakipNo        VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO TESLIMAT (SatisSiparisID, CalisanID, TeslimatTarihi, TeslimatAdresi,
                          Durum, KargoFirmasi, TakipNo)
    VALUES (@SatisSiparisID, @CalisanID, @TeslimatTarihi, @TeslimatAdresi,
            'Hazirlaniyor', @KargoFirmasi, @TakipNo);
    SELECT SCOPE_IDENTITY() AS YeniTeslimatID;
END;
GO

CREATE OR ALTER PROCEDURE sp_TeslimatGuncelle
    @TeslimatID    INT,
    @Durum         VARCHAR(50),
    @KargoFirmasi  VARCHAR(100) = NULL,
    @TakipNo       VARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE TESLIMAT
    SET Durum        = @Durum,
        KargoFirmasi = @KargoFirmasi,
        TakipNo      = @TakipNo
    WHERE TeslimatID = @TeslimatID;

    -- Sipariş durumunu güncelle
    IF @Durum = 'Teslim Edildi'
        UPDATE SATISSIPARISI SET Durum = 'Teslim Edildi'
        WHERE SatisSiparisID = (SELECT SatisSiparisID FROM TESLIMAT WHERE TeslimatID = @TeslimatID);
END;
GO

CREATE OR ALTER PROCEDURE sp_TeslimatSil
    @TeslimatID INT
AS
BEGIN
    SET NOCOUNT ON;
    DELETE FROM TESLIMAT WHERE TeslimatID = @TeslimatID;
END;
GO

CREATE OR ALTER PROCEDURE sp_TeslimatListele
    @TeslimatID     INT    = NULL,
    @SatisSiparisID INT    = NULL,
    @Durum          VARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT T.TeslimatID, SS.SatisSiparisID, M.FirmaAdi AS Musteri,
           C.Ad + ' ' + C.Soyad AS TeslimatYapanCalisan,
           T.TeslimatTarihi, T.TeslimatAdresi,
           T.Durum, T.KargoFirmasi, T.TakipNo
    FROM   TESLIMAT T
    JOIN   SATISSIPARISI SS ON T.SatisSiparisID = SS.SatisSiparisID
    JOIN   MUSTERI  M ON SS.MusteriID = M.MusteriID
    JOIN   CALISKAN C ON T.CalisanID  = C.CalisanID
    WHERE  (@TeslimatID     IS NULL OR T.TeslimatID     = @TeslimatID)
      AND  (@SatisSiparisID IS NULL OR T.SatisSiparisID = @SatisSiparisID)
      AND  (@Durum          IS NULL OR T.Durum          = @Durum)
    ORDER BY T.TeslimatTarihi DESC;
END;
GO


-- ============================================================
-- BÖLÜM 3: KULLANICI TANIMLI FONKSİYONLAR (UDF)
-- ============================================================

-- ------------------------------------------------------------
-- FONKSİYON 1: fn_MusteriToplamBorc
-- Açıklama: Belirtilen müşterinin toplam ödenmemiş borcunu döndürür.
-- Kullanım: SELECT dbo.fn_MusteriToplamBorc(1)
-- ------------------------------------------------------------
CREATE OR ALTER FUNCTION fn_MusteriToplamBorc
(
    @MusteriID INT
)
RETURNS DECIMAL(12,2)
AS
BEGIN
    DECLARE @ToplamBorc DECIMAL(12,2);

    SELECT @ToplamBorc = SUM(F.KalanBorc)
    FROM   FATURA F
    JOIN   SATISSIPARISI SS ON F.SatisSiparisID = SS.SatisSiparisID
    WHERE  SS.MusteriID  = @MusteriID
      AND  F.OdemeDurumu <> 'Odendi';

    RETURN ISNULL(@ToplamBorc, 0);
END;
GO

-- ------------------------------------------------------------
-- FONKSİYON 2: fn_UrunStokDurumu
-- Açıklama: Ürünün stok miktarına göre durum metni döndürür.
-- Kullanım: SELECT dbo.fn_UrunStokDurumu(5)
-- ------------------------------------------------------------
CREATE OR ALTER FUNCTION fn_UrunStokDurumu
(
    @UrunID INT
)
RETURNS VARCHAR(20)
AS
BEGIN
    DECLARE @Stok        INT;
    DECLARE @MinEsik     INT;
    DECLARE @Durum       VARCHAR(20);

    SELECT @Stok    = StokMiktari,
           @MinEsik = MinStokEsigi
    FROM   URUN WHERE UrunID = @UrunID;

    IF @Stok IS NULL
        SET @Durum = 'Bulunamadi'
    ELSE IF @Stok = 0
        SET @Durum = 'Tukendi'
    ELSE IF @Stok <= @MinEsik
        SET @Durum = 'Kritik'
    ELSE IF @Stok <= @MinEsik * 2
        SET @Durum = 'Dusuk'
    ELSE IF @Stok <= @MinEsik * 5
        SET @Durum = 'Normal'
    ELSE
        SET @Durum = 'Yuksek';

    RETURN @Durum;
END;
GO

-- ------------------------------------------------------------
-- FONKSİYON 3: fn_SatisToplamHesapla
-- Açıklama: Verilen sipariş için KDV dahil genel toplamı hesaplar.
-- Kullanım: SELECT dbo.fn_SatisToplamHesapla(1)
-- ------------------------------------------------------------
CREATE OR ALTER FUNCTION fn_SatisToplamHesapla
(
    @SatisSiparisID INT
)
RETURNS DECIMAL(12,2)
AS
BEGIN
    DECLARE @GenelToplam DECIMAL(12,2);

    SELECT @GenelToplam = SUM(
        SD.Miktar * SD.BirimSatisFiyati * (1 - SD.IskontoOrani / 100.0) *
        (1 + ISNULL(U.KDVOrani, 18) / 100.0)
    )
    FROM SATISSIPARISDETAY SD
    JOIN URUN U ON SD.UrunID = U.UrunID
    WHERE SD.SatisSiparisID = @SatisSiparisID;

    RETURN ISNULL(@GenelToplam, 0);
END;
GO


-- ============================================================
-- BÖLÜM 4: TRIGGER'LAR (TESTİKLEYİCİLER)
-- ============================================================

-- ------------------------------------------------------------
-- TRIGGER 1: trg_StokDus_SatisSiparisDetay
-- Tablo    : SATISSIPARISDETAY
-- Olay     : AFTER INSERT
-- Açıklama : Satış siparişine ürün eklendiğinde URUN tablosundaki
--            stok miktarını otomatik olarak düşürür. Eğer stok
--            MinStokEsigi altına düşmüşse bilgi mesajı üretir.
-- İş Kuralı: Sipariş onaylandığında stok otomatik azalmalıdır.
-- ------------------------------------------------------------
CREATE OR ALTER TRIGGER trg_StokDus_SatisSiparisDetay
ON SATISSIPARISDETAY
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Stok düş
    UPDATE U
    SET U.StokMiktari = U.StokMiktari - I.Miktar
    FROM URUN U
    JOIN INSERTED I ON U.UrunID = I.UrunID;

    -- Kritik stok kontrolü
    IF EXISTS (
        SELECT 1
        FROM URUN U
        JOIN INSERTED I ON U.UrunID = I.UrunID
        WHERE U.StokMiktari <= U.MinStokEsigi
    )
    BEGIN
        PRINT 'UYARI: Bir veya daha fazla ürün kritik stok seviyesinin altına düştü!';
    END
END;
GO

-- ------------------------------------------------------------
-- TRIGGER 2: trg_OdemeGuncelle_FaturaYenile
-- Tablo    : ODEME
-- Olay     : AFTER INSERT
-- Açıklama : Yeni ödeme eklendiğinde FATURA tablosundaki
--            OdenenTutar, KalanBorc ve OdemeDurumu alanlarını
--            otomatik olarak günceller.
-- İş Kuralı: Ödeme yapıldığında fatura bakiyesi anında güncellenmelidir.
-- ------------------------------------------------------------
CREATE OR ALTER TRIGGER trg_OdemeGuncelle_FaturaYenile
ON ODEME
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE F
    SET F.OdenenTutar = (
            SELECT ISNULL(SUM(O.OdenenTutar), 0)
            FROM ODEME O WHERE O.FaturaID = F.FaturaID
        ),
        F.KalanBorc = F.ToplamTutar - (
            SELECT ISNULL(SUM(O.OdenenTutar), 0)
            FROM ODEME O WHERE O.FaturaID = F.FaturaID
        ),
        F.OdemeDurumu = CASE
            WHEN F.ToplamTutar <= (
                SELECT ISNULL(SUM(O.OdenenTutar), 0)
                FROM ODEME O WHERE O.FaturaID = F.FaturaID
            ) THEN 'Odendi'
            WHEN (
                SELECT ISNULL(SUM(O.OdenenTutar), 0)
                FROM ODEME O WHERE O.FaturaID = F.FaturaID
            ) > 0 THEN 'Kismen Odendi'
            ELSE 'Odenmedi'
        END
    FROM FATURA F
    JOIN INSERTED I ON F.FaturaID = I.FaturaID;
END;
GO

-- ------------------------------------------------------------
-- TRIGGER 3: trg_StokArtir_SatinAlmaDetay
-- Tablo    : SATINALMASIPARISDETAY
-- Olay     : AFTER INSERT
-- Açıklama : Tedarikçiden alım yapıldığında (satın alma sipariş
--            detayı eklendiğinde) URUN tablosundaki stok miktarını
--            otomatik olarak artırır ve DEPOSTOK tablosunu günceller.
-- İş Kuralı: Tedarikçiden gelen mal stoka otomatik eklenmeli.
-- ------------------------------------------------------------
CREATE OR ALTER TRIGGER trg_StokArtir_SatinAlmaDetay
ON SATINALMASIPARISDETAY
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Ana stok güncelle
    UPDATE U
    SET U.StokMiktari = U.StokMiktari + I.Miktar
    FROM URUN U
    JOIN INSERTED I ON U.UrunID = I.UrunID;

    -- Satın alma siparişi toplamını güncelle
    UPDATE SA
    SET SA.ToplamTutar = (
        SELECT ISNULL(SUM(ToplamFiyat), 0)
        FROM SATINALMASIPARISDETAY
        WHERE SatinAlmaSiparisID = SA.SatinAlmaSiparisID
    )
    FROM SATINALMASIPARISI SA
    JOIN INSERTED I ON SA.SatinAlmaSiparisID = I.SatinAlmaSiparisID;
END;
GO

-- ------------------------------------------------------------
-- TRIGGER 4: trg_VadesiGecmisKontrol
-- Tablo    : FATURA
-- Olay     : AFTER UPDATE
-- Açıklama : Fatura güncellendiğinde vade tarihi kontrolü yapar.
--            Eğer vade tarihi geçmişse ve ödeme yapılmamışsa
--            kayıt tutar (iş kuralı: geç ödeme takibi).
-- İş Kuralı: Vadesi geçmiş ödenmemiş faturaların takibi.
-- ------------------------------------------------------------
CREATE OR ALTER TRIGGER trg_VadesiGecmisKontrol
ON FATURA
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (
        SELECT 1 FROM INSERTED
        WHERE VadeTarihi < CAST(GETDATE() AS DATE)
          AND OdemeDurumu <> 'Odendi'
    )
    BEGIN
        PRINT 'UYARI: Vadesi geçmiş ödenmemiş fatura tespit edildi!';
    END
END;
GO


-- ============================================================
-- ÖRNEK VERİ (TEST)
-- ============================================================

-- Kategoriler
EXEC sp_KategoriEkle 'Buzdolabı', 'Buzdolabı yedek parçaları';
EXEC sp_KategoriEkle 'Çamaşır Makinesi', 'Çamaşır makinesi yedek parçaları';
EXEC sp_KategoriEkle 'Bulaşık Makinesi', 'Bulaşık makinesi yedek parçaları';
EXEC sp_KategoriEkle 'Fırın/Ocak', 'Fırın ve ocak yedek parçaları';
EXEC sp_KategoriEkle 'Klima', 'Klima yedek parçaları';
GO

-- Markalar
EXEC sp_MarkaEkle 'Arçelik', 'TR';
EXEC sp_MarkaEkle 'Bosch', 'DE';
EXEC sp_MarkaEkle 'Vestel', 'TR';
EXEC sp_MarkaEkle 'Samsung', 'KR';
EXEC sp_MarkaEkle 'LG', 'KR';
GO

-- Departmanlar
EXEC sp_DepartmanEkle 'Satış', 'Satış ve pazarlama departmanı';
EXEC sp_DepartmanEkle 'Depo', 'Depo ve lojistik departmanı';
EXEC sp_DepartmanEkle 'Muhasebe', 'Finans ve muhasebe departmanı';
EXEC sp_DepartmanEkle 'Satın Alma', 'Tedarik ve satın alma departmanı';
GO

-- Çalışanlar
EXEC sp_CalisanEkle 'Ahmet', 'Yılmaz', '12345678901', 1, 'Satış Temsilcisi', 18000, '2020-03-15', '0532 111 1111', 'ahmet@akel.com.tr';
EXEC sp_CalisanEkle 'Fatma', 'Kaya', '23456789012', 2, 'Depo Sorumlusu', 16000, '2019-07-01', '0533 222 2222', 'fatma@akel.com.tr';
EXEC sp_CalisanEkle 'Mehmet', 'Demir', '34567890123', 3, 'Muhasebeci', 20000, '2021-01-10', '0534 333 3333', 'mehmet@akel.com.tr';
EXEC sp_CalisanEkle 'Ayşe', 'Çelik', '45678901234', 4, 'Satın Alma Uzmanı', 17000, '2022-05-20', '0535 444 4444', 'ayse@akel.com.tr';
GO

-- Depo
EXEC sp_DepoEkle 'Ana Depo', 'Bağcılar, İstanbul', 2, 2500.00;
EXEC sp_DepoEkle 'Yedek Depo', 'Esenler, İstanbul', 2, 800.00;
GO

-- Ürünler
EXEC sp_UrunEkle 'PRD-001', 'Buzdolabı Kompresörü 1/4 HP', 1, 1, 850.00, 20.00, 50, 5, 'Adet';
EXEC sp_UrunEkle 'PRD-002', 'Çamaşır Makinesi Motor Kapasitörü', 2, 2, 120.00, 20.00, 150, 20, 'Adet';
EXEC sp_UrunEkle 'PRD-003', 'Buzdolabı Kapı Contası Universal', 1, 3, 45.00, 20.00, 200, 30, 'Adet';
EXEC sp_UrunEkle 'PRD-004', 'Bulaşık Makinesi Su Pompası', 3, 2, 320.00, 20.00, 80, 10, 'Adet';
EXEC sp_UrunEkle 'PRD-005', 'Fırın Isıtma Elemanı 2200W', 4, 1, 180.00, 20.00, 100, 15, 'Adet';
GO

-- Tedarikçiler
EXEC sp_TedarikciEkle 'Teknik Parça San. A.Ş.', '1234567890', 'Ali Vural', '0212 555 1111', 'ali@teknikparca.com', 'İkitelli OSB, İstanbul', 45;
EXEC sp_TedarikciEkle 'Euro Beyaz Eşya Ltd.', '9876543210', 'Hans Mueller', '0216 444 2222', 'h.mueller@eurobeyaz.com', 'Ümraniye, İstanbul', 60;
GO

-- Müşteriler
EXEC sp_MusteriEkle 'Konya Teknik Servis Ltd.', '1111111111', 'Hasan Öz', '0332 111 2222', 'hasan@konyateknik.com', 'Selçuklu, Konya', 50000.00, 5.00, 'Servis';
EXEC sp_MusteriEkle 'İzmir Bayii A.Ş.', '2222222222', 'Can Arslan', '0232 333 4444', 'can@izmirbayi.com', 'Bornova, İzmir', 100000.00, 8.00, 'Bayi';
GO

-- ============================================================
-- TEST SORGULARI
-- ============================================================

-- Ürün listesi stok durumu ile
EXEC sp_UrunListele;

-- Müşteri borç kontrolü
SELECT dbo.fn_MusteriToplamBorc(1) AS MusteriBorc;

-- Ürün stok durumu
SELECT dbo.fn_UrunStokDurumu(1) AS StokDurumu;

-- Kritik stokta olan ürünler
SELECT UrunID, UrunAdi, StokMiktari, MinStokEsigi,
       dbo.fn_UrunStokDurumu(UrunID) AS StokDurumu
FROM URUN
WHERE StokMiktari <= MinStokEsigi;
GO
