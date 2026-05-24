# sınav takip sistemi

veri tabanı sistemleri ve yönetimi dersi için geliştirdiğimiz 4 kişilik grup projesi. üniversite sınav süreçlerini — salon atama, gözetmen atama, çakışma kontrolü — otomatikleştiriyor.

---

## kullandığımız teknolojiler

| katman | teknoloji |
|---|---|
| uygulama | c# .net framework 4.8, winforms |
| veritabanı | microsoft sql server (mssql) |
| dil (db) | t-sql |
| ide | visual studio 2022 |

---

## ne yapıyor bu sistem?

### modül 1 — yönetici ayarları
- **bölüm / ders yönetimi** — 5 mühendislik bölümü, yarıyıl ve kontenjan bilgisiyle
- **oturum (slot) tanımlama** — sınavlar önceden belirlenmiş zaman dilimlerine atanır
- **derslik yönetimi** — kapasite, tip (amfi/sınıf/lab) ve kat bilgisiyle
- **personel ve mazeret yönetimi** — izinli/danışmanlık saatlerini önceden sisteme işleme

### modül 2 — akıllı salon atama
- `sp_akilliSalonAta` stored procedure'ü greedy algoritma ile en verimli salon kombinasyonunu buluyor
- öncelik sırası: **amfi → sınıf → lab**, tercihen aynı katta
- salon kapasitesi öğrenci sayısını karşılayana kadar salon ekleniyor

### modül 3 — havuz sistemi ve gözetmen atama
- bölüm gözetmenleri yetmediğinde **fakülte ortak havuzundan** otomatik teklif yapıyor
- görev yüküne göre sıralı liste (`fn_gozetmenGorevSayisi`)
- mavi = bölüm gözetmeni, gri = havuzdan, kırmızı = mazeretli

---

## iş kuralları

| kural | nasıl uygulanıyor |
|---|---|
| dönem çakışması: aynı bölümde aynı yarıyıl zorunlu dersler aynı oturuma konulamaz | `sp_sinavOlustur` + `trg_dönemCakismaKontrol` |
| günlük sınav limiti: bir yarıyıl için aynı güne 2'den fazla sınav konulursa uyarı | `fn_sinifGunlukSinavSayisi` |
| salon çakışması: aynı derslik aynı oturumda iki sınava verilemez | `trg_salonCakismaKontrol` |
| kapasite kontrolü: toplam salon kapasitesi öğrenci sayısının altına düşemez | `sp_akilliSalonAta` |
| gözetmen zaman çakışması: aynı anda iki sınava atanamaz | `sp_gozetmenAta` + `trg_gozetmenCakismaKontrol` |
| mazeret kontrolü: izinli/danışmanlık saatinde atama yapılamaz | `fn_gozetmenMuzaitMi` |
| ardışık oturum sınırı: en fazla 3 arka arkaya oturumda görev | `sp_gozetmenAta` |
| adil dağıtım: görev yükü az olan gözetmene öncelik | `sp_adilGozetmenListele` |

---

## veritabanı yapısı

```
bolumler ──< dersler ──< sinavlar ──< sinav_salonlari ──< gozetmen_atamalari
bolumler ──< personel ──────────────────────────────────────/
oturumlar ──< sinavlar
oturumlar ──< personel_durum
derslikler ──< sinav_salonlari
```

### sql scriptleri

| dosya | ne yapıyor |
|---|---|
| `01_createDatabase.sql` | veritabanını oluşturur |
| `02_createTables.sql` | 9 tabloyu oluşturur (3nf) |
| `03_indexes.sql` | 9 performans indeksi |
| `04_storedProcedures.sql` | 4+1 stored procedure |
| `05_functions.sql` | 4 udf |
| `06_views.sql` | 4 view |
| `07_triggers.sql` | 3 trigger |
| `08_sampleData.sql` | örnek test verisi (opsiyonel) |
| `09_updates.sql` | bölüm güncellemeleri |
| `10_uzaktanEkle.sql` | uzaktan ders türü ekleme |
| `12_tumBolumlerDersler.sql` | 5 bölümün tüm ders verileri |
| `13_laboratuvarTuru.sql` | laboratuvar türü güncellemesi |
| `14_schemaFix.sql` | schema düzeltmeleri |
| `15_bugFixes.sql` | canlı db'ye bug fix (veri silmez) |
| `16_personel.sql` | 45 akademik personel |

> ⚠️ dosya numaralarına göre değil, aşağıdaki sıraya göre çalıştır!

### çalıştırma sırası (fresh install)

```
01 → 02 → 03 → 05 → 04 → 06 → 07 → 09 → 10 → 14 → 12 → 13 → 16
```

> not: 05 (fonksiyonlar), 04'ten (stored procedure'ler) önce gelmeli çünkü sp'ler udf'lere bağımlı.  
> 08 (örnek veri) ve 15 (bug fix) opsiyonel — canlı db'de sadece gerekirse çalıştır.

---

## programlanabilirlik özeti

| tür | adet | isimler |
|---|---|---|
| stored procedure | 4 + bonus | `sp_sinavOlustur`, `sp_akilliSalonAta`, `sp_gozetmenAta`, `sp_adilGozetmenListele`, `sp_yedekAl` |
| udf | 4 | `fn_gozetmenMuzaitMi`, `fn_toplamKapasite`, `fn_gozetmenGorevSayisi`, `fn_sinifGunlukSinavSayisi` |
| view | 4 | `v_sinavProgrami`, `v_gozetmenGorevleri`, `v_gozetmenIstatistik`, `v_salonDoluluk` |
| trigger | 3 | `trg_salonCakismaKontrol`, `trg_dönemCakismaKontrol`, `trg_gozetmenCakismaKontrol` |
| index | 9 | tarih/oturum, derslik, personel, bölüm/yarıyıl vb. |

---

## kurulum

### gereksinimler
- windows (winforms uygulaması)
- visual studio 2019 / 2022
- sql server 2019+ (express sürümü yeterli)
- .net framework 4.8

### adımlar

**1. veritabanını kur**

sql server management studio'da scriptleri yukarıdaki sıraya göre çalıştır.

**2. bağlantı dizesini ayarla**

`SinavTakipApp/SinavTakipApp/App.config` dosyasını aç, `connectionString` değerini kendi sql server instance'ına göre güncelle:

- localhost kullanıyorsan → `localhost`
- sqlexpress kullanıyorsan → `.\SQLEXPRESS` ya da `MASAUSTU_ADI\SQLEXPRESS`

```xml
<connectionStrings>
  <add name="SinavTakipDB"
       connectionString="Data Source=.\SQLEXPRESS;Initial Catalog=SinavTakip;Integrated Security=True;"
       providerName="System.Data.SqlClient" />
</connectionStrings>
```

**3. uygulamayı çalıştır**

visual studio'da `SinavTakipApp.sln` dosyasını aç → build → build solution → başlat.

---

## ders verileri

`dersprogramları/` klasöründeki pdf ders programlarından üretilmiştir:

| bölüm | yarıyıl |
|---|---|
| yazılım mühendisliği (yzm) | 1–8 |
| elektrik mühendisliği (elk) | 1–4 |
| makine mühendisliği (mak) | 1–7 |
| mekatronik mühendisliği (mek) | 1–8 |
| enerji sistemleri mühendisliği (ens) | 1–8 |

uzaktan dersler `dersTuru = 'uzaktan'`, lab dersleri `dersTuru = 'laboratuvar'` ve `ogrenciSayisi = 0` olarak işaretlenmiştir.

---

## bonus — veritabanı yedekleme

raporlar sekmesindeki **"yedek al"** butonuna basıldığında `sp_yedekAl` stored procedure'ü çalışıyor ve `C:\Yedekler\SinavTakip_YYYYMMDD_HHmmss.bak` formatında yedek dosyası oluşturuyor.

> not: sql server servis hesabının hedef klasöre yazma yetkisi olması gerekiyor.
