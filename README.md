
## Teknolojiler

| Katman | Teknoloji |
|---|---|
| Uygulama | C# .NET Framework 4.8, WinForms |
| Veritabanı | Microsoft SQL Server (MSSQL) |
| Dil (DB) | T-SQL |
| IDE | Visual Studio 2022 |

---

## Özellikler

### Modül 1 — Yönetici Ayarları
- **Bölüm / Ders yönetimi** — 5 mühendislik bölümü, yarıyıl ve kontenjan bilgisiyle
- **Oturum (slot) tanımlama** — Sınavlar önceden belirlenmiş zaman dilimlerine atanır
- **Derslik yönetimi** — Kapasite, tip (Amfi/Sınıf/Lab) ve kat bilgisiyle
- **Personel ve mazeret yönetimi** — İzinli/Danışmanlık saatlerini önceden sisteme işleme

### Modül 2 — Akıllı Salon Atama
- `sp_AkilliSalonAta` stored procedure'ü greedy algoritma ile en verimli salon kombinasyonunu bulur
- Öncelik sırası: **Amfi → Sınıf → Lab**, tercihen aynı katta
- Salon kapasitesi öğrenci sayısını karşılayana kadar salon eklenir

### Modül 3 — Havuz Sistemi ve Gözetmen Atama
- Bölüm gözetmenleri yetmediğinde **fakülte ortak havuzundan** otomatik teklif
- Görev yüküne göre sıralı liste (`fn_GozetmenGorevSayisi`)
- Mavi = bölüm gözetmeni, Gri = havuzdan, Kırmızı = mazeretli

---

## İş Kuralları ve Kısıtlar

| Kural | Uygulama |
|---|---|
| Dönem çakışması: Aynı yarıyıl zorunlu dersler aynı oturuma konulamaz | `sp_SinavOlustur` + `trg_DönemCakismaKontrol` |
| Günlük sınav limiti: Bir yarıyıl için aynı güne 2'den fazla sınav konulursa uyarı | `fn_SinifGunlukSinavSayisi` |
| Salon çakışması: Aynı derslik aynı oturumda iki sınava verilemez | `trg_SalonCakismaKontrol` |
| Kapasite kontrolü: Toplam salon kapasitesi öğrenci sayısının altına düşemez | `sp_AkilliSalonAta` |
| Gözetmen zaman çakışması: Aynı anda iki sınava atanamaz | `sp_GozetmenAta` + `trg_GozetmenCakismaKontrol` |
| Mazeret kontrolü: İzinli/danışmanlık saatinde atama yapılamaz | `fn_GozetmenMuzaitMi` |
| Ardışık oturum sınırı: En fazla 3 arka arkaya oturumda görev | `sp_GozetmenAta` |
| Adil dağıtım: Görev yükü az olan gözetmene öncelik | `sp_AdilGozetmenListele` |

---

## Veritabanı Yapısı

```
Bolumler ──< Dersler ──< Sinavlar ──< Sinav_Salonlari ──< Gozetmen_Atamalari
Bolumler ──< Personel ──────────────────────────────────────/
Oturumlar ──< Sinavlar
Oturumlar ──< Personel_Durum
Derslikler ──< Sinav_Salonlari
```

### SQL Scriptleri (Çalıştırma Sırası)

```
01_CreateDatabase.sql       → Veritabanını oluştur
02_CreateTables.sql         → Tabloları oluştur (9 tablo, 3NF)
03_Indexes.sql              → 9 performans indeksi
04_StoredProcedures.sql     → 4 SP + BONUS yedek SP
05_Functions.sql            → 4 UDF
06_Views.sql                → 4 View
07_Triggers.sql             → 3 Trigger
08_SampleData.sql           → Örnek veriler (oturum, derslik, personel)
09_Updates.sql              → Bölüm güncellemeleri
10_UzaktanEkle.sql          → Uzaktan ders türü ekleme
14_SchemaFix.sql            → Schema düzeltmeleri
12_TumBolumlerDersler.sql   → Tüm 5 bölümün ders verileri (PDF'lerden)
13_LaboratuvarTuru.sql      → Laboratuvar türü güncellemesi
```
!!!  Buradaki sıralara dikkat edin dosya sırasına göre değil burda bahsedilene göre execute etmeniz gerekmektedir.  !!!

### Programlanabilirlik Özeti

| Tür | Adet | İsimler |
|---|---|---|
| Stored Procedure | 4 + BONUS | `sp_SinavOlustur`, `sp_AkilliSalonAta`, `sp_GozetmenAta`, `sp_AdilGozetmenListele`, `sp_YedekAl` |
| UDF | 4 | `fn_GozetmenMuzaitMi`, `fn_ToplamKapasite`, `fn_GozetmenGorevSayisi`, `fn_SinifGunlukSinavSayisi` |
| View | 4 | `v_SinavProgrami`, `v_GozetmenGorevleri`, `v_GozetmenIstatistik`, `v_SalonDoluluk` |
| Trigger | 3 | `trg_SalonCakismaKontrol`, `trg_DönemCakismaKontrol`, `trg_GozetmenCakismaKontrol` |
| Index | 9 | Tarih/oturum, derslik, personel, bölüm/yarıyıl vb. |

---

## Kurulum

### Gereksinimler
- Windows (WinForms uygulaması)
- Visual Studio 2019 / 2022
- SQL Server 2019+ (Express sürümü yeterli)
- .NET Framework 4.8

### Adımlar

**1. Veritabanını kur**

SQL Server Management Studio'da scriptleri sırasıyla çalıştır:
```
01 → 02 → 03 → 04 → 05 → 06 → 07 → 08 → 09 → 10 → 14 → 12 → 13
```

**2. Bağlantı dizesini ayarla**

`SinavTakipApp/SinavTakipApp/App.config` dosyasını aç, `connectionString` değerini kendi SQL Server instance'ına göre güncelle:

connectionString dosyasını değiştirirken localhost kullanıyorsanız localhost, SQLEXPRESS kullanıyorsanız .\SQLEXPRESS ya da MASAUSTU_ADI\SQLEXPRESS.

```xml
<connectionStrings>
  <add name="SinavTakipDB"
       connectionString="Data Source=.\SQLEXPRESS;Initial Catalog=SinavTakip;Integrated Security=True;"
       providerName="System.Data.SqlClient" />
</connectionStrings>
```

**3. Uygulamayı çalıştır**

Visual Studio'da `SinavTakipApp.sln` dosyasını aç → Build --> Build Solution ardından BAŞLAT DÜĞMESİ ile başlat.

---

## Ders Verileri

`dersprogramları/` klasöründeki PDF ders programlarından üretilmiştir:

| Bölüm | Yarıyıl |
|---|---|
| Yazılım Mühendisliği (YZM) | 1–8 |
| Elektrik Mühendisliği (ELK) | 1–4 |
| Makine Mühendisliği (MAK) | 1–7 |
| Mekatronik Mühendisliği (MEK) | 1–8 |
| Enerji Sistemleri Mühendisliği (ENS) | 1–8 |

Uzaktan dersler `DersTuru = 'Uzaktan'`, lab dersleri `DersTuru = 'Laboratuvar'` ve `OgrenciSayisi = 0` olarak işaretlenmiştir.
Normalde isterlerde bu mevcut değildir fakat isterlerin bilgi eksikliğinden dolayı eklenmiştir.

---

## BONUS — Veritabanı Yedekleme

Raporlar sekmesindeki **"Yedek Al"** butonuna basıldığında `sp_YedekAl` stored procedure'ü çalışır ve `C:\Yedekler\SinavTakip_YYYYMMDD_HHmmss.bak` formatında yedek dosyası oluşturur.

> Not: SQL Server servis hesabının hedef klasöre yazma yetkisi olması gerekir.
