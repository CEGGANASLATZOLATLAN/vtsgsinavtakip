using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Windows.Forms;

namespace SinavTakipApp.Forms
{
    public class MainForm : Form
    {
        private TabControl tabMain;
        private TabPage tabTanimlamalar, tabSinavlar, tabGozetmen, tabRaporlar;

        // Tanimlamalar alt tablari
        private TabControl tabTanim;
        private TabPage tabBolum, tabOturum, tabDerslik, tabDers, tabPersonel, tabMazeret;

        // Sinavlar sekmesi
        private DataGridView dgvSinavlar;
        private Button btnYeniSinav, btnSalonAta, btnGozetmenAta, btnSinavSil, btnSinavYenile;

        // Raporlar
        private Button btnRaporProgram, btnRaporGozetmen, btnRaporIstatistik, btnYedekAl;
        private DataGridView dgvRapor;

        public MainForm()
        {
            InitializeForm();
        }

        private void InitializeForm()
        {
            Text = "Sinav Takvim Yonetim Sistemi - YZM 2126";
            Size = new Size(1200, 750);
            MinimumSize = new Size(900, 600);
            StartPosition = FormStartPosition.CenterScreen;
            Font = new Font("Segoe UI", 9f);

            var statusStrip = new StatusStrip();
            var lblStatus = new ToolStripStatusLabel("Hazir");
            statusStrip.Items.Add(lblStatus);

            tabMain = new TabControl { Dock = DockStyle.Fill, Font = new Font("Segoe UI", 9.5f) };

            tabTanimlamalar = new TabPage("Tanimlamalar");
            tabSinavlar     = new TabPage("Sinav Planlama");
            tabGozetmen     = new TabPage("Gozetmen Atama");
            tabRaporlar     = new TabPage("Raporlar");

            tabMain.TabPages.AddRange(new[] { tabTanimlamalar, tabSinavlar, tabGozetmen, tabRaporlar });

            BuildTanimlamalarTab();
            BuildSinavlarTab();
            BuildGozetmenTab();
            BuildRaporlarTab();

            Controls.Add(tabMain);
            Controls.Add(statusStrip);
        }

        // ============================================================
        // TAB: Tanimlamalar
        // ============================================================
        private void BuildTanimlamalarTab()
        {
            tabTanim = new TabControl { Dock = DockStyle.Fill };
            tabBolum    = new TabPage("Bolumler");
            tabOturum   = new TabPage("Oturumlar");
            tabDerslik  = new TabPage("Derslikler");
            tabDers     = new TabPage("Dersler");
            tabPersonel = new TabPage("Personel");
            tabMazeret  = new TabPage("Mazeretler");

            tabTanim.TabPages.AddRange(new[] { tabBolum, tabOturum, tabDerslik, tabDers, tabPersonel, tabMazeret });
            tabTanimlamalar.Controls.Add(tabTanim);

            BuildCrudPanel(tabBolum,
                "SELECT BolumID, BolumAdi, CASE Aktif WHEN 1 THEN 'Evet' ELSE 'Hayir' END AS Aktif FROM Bolumler ORDER BY BolumAdi",
                () => new BolumForm(), "BolumID",
                new[] { "BolumID", "BolumAdi" },
                "DELETE FROM Bolumler WHERE BolumID=@id");

            BuildCrudPanel(tabOturum,
                "SELECT OturumID, Tanim, CONVERT(NVARCHAR(5),BaslangicSaat,108) AS BaslangicSaat, CONVERT(NVARCHAR(5),BitisSaat,108) AS BitisSaat FROM Oturumlar ORDER BY BaslangicSaat",
                () => new OturumForm(), "OturumID",
                new[] { "OturumID", "Tanim", "BaslangicSaat", "BitisSaat" },
                "DELETE FROM Oturumlar WHERE OturumID=@id");

            BuildCrudPanel(tabDerslik,
                "SELECT DerslikID, Ad, Kapasite, Tip, Kat, CASE Aktif WHEN 1 THEN 'Evet' ELSE 'Hayir' END AS Aktif FROM Derslikler ORDER BY Tip, Kat, Ad",
                () => new DerslikForm(), "DerslikID",
                new[] { "DerslikID", "Ad", "Kapasite", "Tip", "Kat" },
                "DELETE FROM Derslikler WHERE DerslikID=@id");

            BuildCrudPanel(tabDers,
                "SELECT d.DersID, d.DersKodu, d.Ad, d.DersTuru, d.OgrenciSayisi, d.Yariyil, b.BolumAdi FROM Dersler d JOIN Bolumler b ON d.BolumID=b.BolumID ORDER BY d.Yariyil, d.DersKodu",
                () => new DersForm(), "DersID",
                new[] { "DersID", "DersKodu", "Ad", "DersTuru", "OgrenciSayisi", "Yariyil", "BolumAdi" },
                "DELETE FROM Dersler WHERE DersID=@id");

            BuildCrudPanel(tabPersonel,
                "SELECT p.PersonelID, p.Unvan, p.Ad, p.Soyad, b.BolumAdi, CASE p.Aktif WHEN 1 THEN 'Evet' ELSE 'Hayir' END AS Aktif FROM Personel p JOIN Bolumler b ON p.BolumID=b.BolumID ORDER BY b.BolumAdi, p.Soyad",
                () => new PersonelForm(), "PersonelID",
                new[] { "PersonelID", "Unvan", "Ad", "Soyad", "BolumAdi" },
                "DELETE FROM Personel WHERE PersonelID=@id");

            BuildCrudPanel(tabMazeret,
                "SELECT pd.DurumID, p.Ad+' '+p.Soyad AS PersonelAdi, pd.Tarih, ISNULL(o.Tanim,'Tum Gun') AS Oturum, pd.MazeretTuru, ISNULL(pd.Aciklama,'') AS Aciklama FROM Personel_Durum pd JOIN Personel p ON pd.PersonelID=p.PersonelID LEFT JOIN Oturumlar o ON pd.OturumID=o.OturumID ORDER BY pd.Tarih DESC",
                () => new PersonelDurumForm(), "DurumID",
                new[] { "DurumID", "PersonelAdi", "Tarih", "Oturum", "MazeretTuru", "Aciklama" },
                "DELETE FROM Personel_Durum WHERE DurumID=@id");
        }

        private void BuildCrudPanel(TabPage tab, string query, Func<Form> formFactory,
            string idCol, string[] cols, string deleteSql)
        {
            var panel = new Panel { Dock = DockStyle.Fill };
            var dgv = new DataGridView
            {
                Dock = DockStyle.Fill,
                ReadOnly = true,
                AllowUserToAddRows = false,
                AllowUserToDeleteRows = false,
                SelectionMode = DataGridViewSelectionMode.FullRowSelect,
                MultiSelect = false,
                AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill,
                BackgroundColor = Color.White,
                BorderStyle = BorderStyle.None,
                RowHeadersVisible = false,
                AlternatingRowsDefaultCellStyle = new DataGridViewCellStyle
                { BackColor = Color.FromArgb(245, 247, 250) }
            };

            var btnPanel = new FlowLayoutPanel
            {
                Dock = DockStyle.Bottom,
                Height = 45,
                FlowDirection = FlowDirection.LeftToRight,
                Padding = new Padding(5, 5, 5, 5)
            };

            Button MakeBtn(string text, Color back) => new Button
            {
                Text = text, Width = 100, Height = 32,
                BackColor = back, ForeColor = Color.White,
                FlatStyle = FlatStyle.Flat, Margin = new Padding(3)
            };

            var btnYeni    = MakeBtn("+ Yeni Ekle", Color.FromArgb(40, 167, 69));
            var btnDuzenle = MakeBtn("Duzenle",     Color.FromArgb(0, 123, 255));
            var btnSil     = MakeBtn("Sil",         Color.FromArgb(220, 53, 69));
            var btnYenile  = MakeBtn("Yenile",      Color.FromArgb(108, 117, 125));

            btnPanel.Controls.AddRange(new Control[] { btnYeni, btnDuzenle, btnSil, btnYenile });

            Action refresh = () =>
            {
                try
                {
                    var dt = DatabaseHelper.Query(query);
                    dgv.DataSource = dt;
                    if (dgv.Columns.Count > 0 && cols.Length > 0)
                    {
                        dgv.Columns[idCol].Visible = false;
                    }
                }
                catch (Exception ex) { DatabaseHelper.ShowError("Veri yuklenemedi", ex); }
            };

            btnYenile.Click += (s, e) => refresh();
            btnYeni.Click += (s, e) =>
            {
                var f = formFactory();
                if (f.ShowDialog() == DialogResult.OK) refresh();
            };
            btnDuzenle.Click += (s, e) =>
            {
                var row = dgv.CurrentRow;
                if (row == null) { MessageBox.Show("Lutfen bir kayit secin."); return; }
                var id = row.Cells[idCol].Value;
                var f = formFactory();
                if (f is IEditForm ef) ef.LoadForEdit(Convert.ToInt32(id));
                if (f.ShowDialog() == DialogResult.OK) refresh();
            };
            btnSil.Click += (s, e) =>
            {
                var row = dgv.CurrentRow;
                if (row == null) { MessageBox.Show("Lutfen bir kayit secin."); return; }
                if (MessageBox.Show("Secili kayit silinsin mi?", "Onay",
                    MessageBoxButtons.YesNo, MessageBoxIcon.Question) != DialogResult.Yes) return;
                var id = row.Cells[idCol].Value;
                string err;
                if (!DatabaseHelper.TryExecute(deleteSql,
                    new[] { new SqlParameter("@id", id) }, out err))
                    MessageBox.Show("Silinemedi: " + err, "Hata", MessageBoxButtons.OK, MessageBoxIcon.Error);
                else refresh();
            };

            panel.Controls.Add(dgv);
            panel.Controls.Add(btnPanel);
            tab.Controls.Add(panel);

            tab.Enter += (s, e) => refresh();
        }

        // ============================================================
        // TAB: Sinav Planlama
        // ============================================================
        private void BuildSinavlarTab()
        {
            var panel = new Panel { Dock = DockStyle.Fill };

            dgvSinavlar = new DataGridView
            {
                Dock = DockStyle.Fill,
                ReadOnly = true,
                AllowUserToAddRows = false,
                AllowUserToDeleteRows = false,
                SelectionMode = DataGridViewSelectionMode.FullRowSelect,
                MultiSelect = false,
                AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill,
                BackgroundColor = Color.White,
                RowHeadersVisible = false,
                AlternatingRowsDefaultCellStyle = new DataGridViewCellStyle
                { BackColor = Color.FromArgb(245, 247, 250) }
            };

            var btnPanel = new FlowLayoutPanel
            {
                Dock = DockStyle.Bottom, Height = 50,
                FlowDirection = FlowDirection.LeftToRight,
                Padding = new Padding(5, 8, 5, 5)
            };

            Button MakeBtn(string text, Color c, int w = 130) => new Button
            {
                Text = text, Width = w, Height = 34,
                BackColor = c, ForeColor = Color.White,
                FlatStyle = FlatStyle.Flat, Margin = new Padding(3)
            };

            btnYeniSinav   = MakeBtn("+ Yeni Sinav",   Color.FromArgb(40, 167, 69));
            btnSalonAta    = MakeBtn("Akilli Salon Ata", Color.FromArgb(0, 123, 255), 150);
            btnGozetmenAta = MakeBtn("Gozetmen Ata",    Color.FromArgb(255, 128, 0));
            btnSinavSil    = MakeBtn("Sinav Sil",       Color.FromArgb(220, 53, 69));
            btnSinavYenile = MakeBtn("Yenile",          Color.FromArgb(108, 117, 125), 90);

            btnPanel.Controls.AddRange(new Control[] { btnYeniSinav, btnSalonAta, btnGozetmenAta, btnSinavSil, btnSinavYenile });

            panel.Controls.Add(dgvSinavlar);
            panel.Controls.Add(btnPanel);
            tabSinavlar.Controls.Add(panel);

            tabSinavlar.Enter += (s, e) => LoadSinavlar();
            btnSinavYenile.Click += (s, e) => LoadSinavlar();
            btnYeniSinav.Click += (s, e) =>
            {
                var f = new SinavForm();
                if (f.ShowDialog() == DialogResult.OK) LoadSinavlar();
            };
            btnSalonAta.Click += (s, e) =>
            {
                var row = dgvSinavlar.CurrentRow;
                if (row == null) { MessageBox.Show("Lutfen bir sinav secin."); return; }
                int sinavId = Convert.ToInt32(row.Cells["SinavID"].Value);
                new SalonAtamaForm(sinavId).ShowDialog();
                LoadSinavlar();
            };
            btnGozetmenAta.Click += (s, e) =>
            {
                var row = dgvSinavlar.CurrentRow;
                if (row == null) { MessageBox.Show("Lutfen bir sinav secin."); return; }
                int sinavId = Convert.ToInt32(row.Cells["SinavID"].Value);
                new GozetmenAtamaForm(sinavId).ShowDialog();
            };
            btnSinavSil.Click += (s, e) =>
            {
                var row = dgvSinavlar.CurrentRow;
                if (row == null) { MessageBox.Show("Lutfen bir sinav secin."); return; }
                if (MessageBox.Show("Bu sinav ve tum salon/gozetmen atamalari silinecek. Devam?", "Onay",
                    MessageBoxButtons.YesNo, MessageBoxIcon.Warning) != DialogResult.Yes) return;
                int id = Convert.ToInt32(row.Cells["SinavID"].Value);
                string err;
                if (!DatabaseHelper.TryExecute("DELETE FROM Sinavlar WHERE SinavID=@id",
                    new[] { new SqlParameter("@id", id) }, out err))
                    MessageBox.Show("Silinemedi: " + err, "Hata", MessageBoxButtons.OK, MessageBoxIcon.Error);
                else LoadSinavlar();
            };
        }

        private void LoadSinavlar()
        {
            try
            {
                var dt = DatabaseHelper.Query(
                    "SELECT * FROM v_SinavProgrami ORDER BY Tarih, BaslangicSaat");
                dgvSinavlar.DataSource = dt;
                if (dgvSinavlar.Columns["AtananKapasite"] != null)
                {
                    foreach (DataGridViewRow row in dgvSinavlar.Rows)
                    {
                        if (row.IsNewRow) continue;
                        int ogr = Convert.ToInt32(row.Cells["OgrenciSayisi"].Value);
                        int kap = Convert.ToInt32(row.Cells["AtananKapasite"].Value);
                        if (kap < ogr)
                        {
                            row.DefaultCellStyle.BackColor = Color.FromArgb(255, 220, 220);
                        }
                    }
                }
            }
            catch (Exception ex) { DatabaseHelper.ShowError("Sinavlar yuklenemedi", ex); }
        }

        // ============================================================
        // TAB: Gozetmen Atama (detay goruntuleme)
        // ============================================================
        private void BuildGozetmenTab()
        {
            var panel = new Panel { Dock = DockStyle.Fill };

            var dgvGozetmen = new DataGridView
            {
                Dock = DockStyle.Fill,
                ReadOnly = true,
                AllowUserToAddRows = false,
                AllowUserToDeleteRows = false,
                SelectionMode = DataGridViewSelectionMode.FullRowSelect,
                AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill,
                BackgroundColor = Color.White,
                RowHeadersVisible = false,
                AlternatingRowsDefaultCellStyle = new DataGridViewCellStyle
                { BackColor = Color.FromArgb(245, 247, 250) }
            };

            var btnPanel = new FlowLayoutPanel
            {
                Dock = DockStyle.Bottom, Height = 50,
                FlowDirection = FlowDirection.LeftToRight,
                Padding = new Padding(5, 8, 5, 5)
            };

            var btnYenile = new Button
            {
                Text = "Yenile", Width = 100, Height = 34,
                BackColor = Color.FromArgb(108, 117, 125), ForeColor = Color.White,
                FlatStyle = FlatStyle.Flat, Margin = new Padding(3)
            };
            btnPanel.Controls.Add(btnYenile);

            panel.Controls.Add(dgvGozetmen);
            panel.Controls.Add(btnPanel);
            tabGozetmen.Controls.Add(panel);

            Action refresh = () =>
            {
                try
                {
                    var dt = DatabaseHelper.Query(
                        "SELECT * FROM v_GozetmenGorevleri ORDER BY Tarih, BaslangicSaat, PersonelAdi");
                    dgvGozetmen.DataSource = dt;
                }
                catch (Exception ex) { DatabaseHelper.ShowError("Gozetmen gorevleri yuklenemedi", ex); }
            };

            btnYenile.Click += (s, e) => refresh();
            tabGozetmen.Enter += (s, e) => refresh();
        }

        // ============================================================
        // TAB: Raporlar
        // ============================================================
        private void BuildRaporlarTab()
        {
            var panel = new Panel { Dock = DockStyle.Fill };

            var btnPanel = new FlowLayoutPanel
            {
                Dock = DockStyle.Top, Height = 55,
                FlowDirection = FlowDirection.LeftToRight,
                Padding = new Padding(8, 10, 5, 5),
                BackColor = Color.FromArgb(248, 249, 250)
            };

            Button MakeBtn(string text, Color c) => new Button
            {
                Text = text, Height = 34, Width = 190,
                BackColor = c, ForeColor = Color.White,
                FlatStyle = FlatStyle.Flat, Margin = new Padding(3)
            };

            btnRaporProgram    = MakeBtn("Sinav Programi",       Color.FromArgb(0, 123, 255));
            btnRaporGozetmen   = MakeBtn("Gozetmen Gorevi",      Color.FromArgb(23, 162, 184));
            btnRaporIstatistik = MakeBtn("Gozetmen Istatistigi", Color.FromArgb(102, 16, 242));
            btnYedekAl         = MakeBtn("Yedek Al (BONUS)",     Color.FromArgb(40, 167, 69));

            btnPanel.Controls.AddRange(new Control[] { btnRaporProgram, btnRaporGozetmen, btnRaporIstatistik, btnYedekAl });

            dgvRapor = new DataGridView
            {
                Dock = DockStyle.Fill,
                ReadOnly = true,
                AllowUserToAddRows = false,
                AllowUserToDeleteRows = false,
                AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill,
                BackgroundColor = Color.White,
                RowHeadersVisible = false,
                AlternatingRowsDefaultCellStyle = new DataGridViewCellStyle
                { BackColor = Color.FromArgb(240, 248, 255) }
            };

            panel.Controls.Add(dgvRapor);
            panel.Controls.Add(btnPanel);
            tabRaporlar.Controls.Add(panel);

            btnRaporProgram.Click += (s, e) =>
            {
                try
                {
                    dgvRapor.DataSource = DatabaseHelper.Query(
                        "SELECT Tarih, Gun, Oturum, BaslangicSaat, BitisSaat, DersKodu, DersAdi, " +
                        "DersTuru, Yariyil, OgrenciSayisi, AtananKapasite, Salonlar, BolumAdi " +
                        "FROM v_SinavProgrami ORDER BY Tarih, BaslangicSaat");
                }
                catch (Exception ex) { DatabaseHelper.ShowError("Rapor hatasi", ex); }
            };

            btnRaporGozetmen.Click += (s, e) =>
            {
                try
                {
                    dgvRapor.DataSource = DatabaseHelper.Query(
                        "SELECT PersonelAdi, PersonelBolumu, Tarih, Gun, Oturum, BaslangicSaat, " +
                        "DersAdi, Yariyil, DersBolumu, DerslikAdi " +
                        "FROM v_GozetmenGorevleri ORDER BY Tarih, BaslangicSaat, PersonelAdi");
                }
                catch (Exception ex) { DatabaseHelper.ShowError("Rapor hatasi", ex); }
            };

            btnRaporIstatistik.Click += (s, e) =>
            {
                try
                {
                    dgvRapor.DataSource = DatabaseHelper.Query(
                        "SELECT PersonelAdi, BolumAdi, ToplamGorev, SonBirAydaGorev " +
                        "FROM v_GozetmenIstatistik ORDER BY ToplamGorev DESC, PersonelAdi");
                }
                catch (Exception ex) { DatabaseHelper.ShowError("Rapor hatasi", ex); }
            };

            btnYedekAl.Click += (s, e) =>
            {
                string klasor = ConfigurationManager.AppSettings["YedekKlasor"] ?? "C:\\Yedekler";
                if (MessageBox.Show($"Yedek '{klasor}' klasorune alinacak. Devam?", "Yedek Al",
                    MessageBoxButtons.YesNo, MessageBoxIcon.Question) != DialogResult.Yes) return;
                try
                {
                    var result = DatabaseHelper.SP("dbo.sp_YedekAl",
                        new[] { new SqlParameter("@YedekKlasor", klasor) });
                    if (result.Rows.Count > 0)
                        MessageBox.Show("Yedek basariyla alindi!\n" + result.Rows[0]["YedekDosyasi"],
                            "Basarili", MessageBoxButtons.OK, MessageBoxIcon.Information);
                }
                catch (Exception ex)
                {
                    MessageBox.Show("Yedek alinamadi:\n" + ex.Message +
                        "\n\nNot: SQL Server servis hesabinin klasore yazma yetkisi olmalidir.",
                        "Hata", MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
            };
        }
    }
}
