using System;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Windows.Forms;

namespace SinavTakipApp.Forms
{
    // Gozetmen atama formu - sp_GozetmenAta ve sp_AdilGozetmenListele kullanir
    public class GozetmenAtamaForm : Form
    {
        private readonly int _sinavId;
        private DataGridView dgvSalonlar, dgvGozetmenler, dgvMevcutAtamalar;
        private Label lblSinavBilgi, lblHavuz;
        private Button btnAta, btnKaldir, btnKapat;

        public GozetmenAtamaForm(int sinavId)
        {
            _sinavId = sinavId;
            InitializeForm();
            LoadSinavBilgi();
            LoadSalonlar();
        }

        private void InitializeForm()
        {
            Text = "Gozetmen Atama";
            Size = new Size(1200, 820);
            StartPosition = FormStartPosition.CenterParent;
            Font = new Font("Segoe UI", 9f);

            lblSinavBilgi = new Label
            {
                Location = new Point(10, 10),
                Size = new Size(1160, 45),
                Font = new Font("Segoe UI", 10f, FontStyle.Bold),
                ForeColor = Color.FromArgb(0, 70, 140)
            };
            Controls.Add(lblSinavBilgi);

            // Sol: Sinav Salonlari
            var grpSalon = new GroupBox { Text = "Sinav Salonlari", Location = new Point(10, 60), Size = new Size(270, 660) };
            dgvSalonlar = BuildDgv(new Size(250, 620), new Point(5, 20));
            grpSalon.Controls.Add(dgvSalonlar);
            Controls.Add(grpSalon);
            dgvSalonlar.SelectionChanged += (s, e) => LoadGozetmenler();

            // Orta: Musait Gozetmenler (sp_AdilGozetmenListele - SP cagrisi)
            var grpMusait = new GroupBox { Text = "Musait Gozetmenler (once bolum, yetmezse havuz)", Location = new Point(290, 60), Size = new Size(560, 660) };
            lblHavuz = new Label
            {
                Text = "Mavi = bolum gozetmeni  |  Gri = fakülte havuzu  |  Kirmizi = mazeretli\n" +
                       "Not: Bolumde musait gozetmen varken havuzdan atama yapilamaz.",
                Location = new Point(5, 16), AutoSize = true,
                ForeColor = Color.FromArgb(80, 80, 80),
                Font = new Font("Segoe UI", 7.5f)
            };
            dgvGozetmenler = BuildDgv(new Size(540, 598), new Point(5, 48));
            grpMusait.Controls.AddRange(new Control[] { lblHavuz, dgvGozetmenler });
            Controls.Add(grpMusait);

            // Sag: Mevcut Atamalar
            var grpMevcut = new GroupBox { Text = "Bu Sinava Atanmis Gozetmenler", Location = new Point(860, 60), Size = new Size(320, 660) };
            dgvMevcutAtamalar = BuildDgv(new Size(300, 620), new Point(5, 20));
            grpMevcut.Controls.Add(dgvMevcutAtamalar);
            Controls.Add(grpMevcut);

            btnAta = new Button { Text = "Gozetmen Ata ->", Location = new Point(290, 730), Width = 160, Height = 34,
                BackColor = Color.FromArgb(0,123,255), ForeColor = Color.White, FlatStyle = FlatStyle.Flat };
            btnKaldir = new Button { Text = "<- Atama Kaldir", Location = new Point(460, 730), Width = 160, Height = 34,
                BackColor = Color.FromArgb(220,53,69), ForeColor = Color.White, FlatStyle = FlatStyle.Flat };
            btnKapat  = new Button { Text = "Kapat", Location = new Point(1070, 730), Width = 100, Height = 34, DialogResult = DialogResult.OK };

            btnAta.Click    += BtnAta_Click;
            btnKaldir.Click += BtnKaldir_Click;
            Controls.AddRange(new Control[] { btnAta, btnKaldir, btnKapat });
        }

        private DataGridView BuildDgv(Size size, Point loc) => new DataGridView
        {
            Size = size, Location = loc,
            ReadOnly = true, AllowUserToAddRows = false, AllowUserToDeleteRows = false,
            SelectionMode = DataGridViewSelectionMode.FullRowSelect, MultiSelect = false,
            AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill,
            BackgroundColor = Color.White, RowHeadersVisible = false,
            Font = new Font("Segoe UI", 10f),
            RowTemplate = { Height = 28 },
            AlternatingRowsDefaultCellStyle = new DataGridViewCellStyle { BackColor = Color.FromArgb(245, 247, 255) }
        };

        private void LoadSinavBilgi()
        {
            try
            {
                var dt = DatabaseHelper.Query(
                    "SELECT DersKodu, DersAdi, OgrenciSayisi, Tarih, Oturum, Salonlar " +
                    "FROM v_SinavProgrami WHERE SinavID=@sid",
                    new[] { new SqlParameter("@sid", _sinavId) });
                if (dt.Rows.Count > 0)
                {
                    var r = dt.Rows[0];
                    lblSinavBilgi.Text = $"{r["DersKodu"]} - {r["DersAdi"]}  |  " +
                        $"Tarih: {Convert.ToDateTime(r["Tarih"]):dd.MM.yyyy}  |  " +
                        $"Oturum: {r["Oturum"]}  |  Salonlar: {r["Salonlar"]}";
                }
            }
            catch { }
        }

        private void LoadSalonlar()
        {
            try
            {
                var dt = DatabaseHelper.Query(
                    "SELECT ss.SinavSalonID, d.Ad AS DerslikAdi, d.Kapasite, d.Tip, " +
                    "(SELECT COUNT(*) FROM Gozetmen_Atamalari ga WHERE ga.SinavSalonID=ss.SinavSalonID) AS GozetmenSayisi " +
                    "FROM Sinav_Salonlari ss JOIN Derslikler d ON ss.DerslikID=d.DerslikID " +
                    "WHERE ss.SinavID=@sid ORDER BY d.Ad",
                    new[] { new SqlParameter("@sid", _sinavId) });
                dgvSalonlar.DataSource = dt;
                if (dgvSalonlar.Columns["SinavSalonID"] != null)
                    dgvSalonlar.Columns["SinavSalonID"].Visible = false;
                if (dt.Rows.Count > 0) dgvSalonlar.Rows[0].Selected = true;
            }
            catch (Exception ex) { DatabaseHelper.ShowError("Salonlar yuklenemedi", ex); }
        }

        private void LoadGozetmenler()
        {
            dgvGozetmenler.DataSource = null;
            if (dgvSalonlar.CurrentRow == null) return;
            try
            {
                // sp_AdilGozetmenListele stored procedure cagrisi
                var dt = DatabaseHelper.SP("dbo.sp_AdilGozetmenListele",
                    new[] { new SqlParameter("@SinavID", _sinavId) });
                dgvGozetmenler.DataSource = dt;

                // Gizlenmesi gereken sutunlar
                if (dgvGozetmenler.Columns["PersonelID"] != null)
                    dgvGozetmenler.Columns["PersonelID"].Visible = false;
                if (dgvGozetmenler.Columns["Musait"] != null)
                    dgvGozetmenler.Columns["Musait"].Visible = false;

                // Musait olmayanlar kirmizi, havuzdan gelenler gri, bolumden gelenler mavi
                foreach (DataGridViewRow row in dgvGozetmenler.Rows)
                {
                    if (row.IsNewRow) continue;
                    bool musait = Convert.ToBoolean(row.Cells["Musait"].Value);
                    string kaynak = row.Cells["Kaynak"].Value?.ToString() ?? "";
                    if (!musait)
                        row.DefaultCellStyle.BackColor = Color.FromArgb(255, 200, 200);
                    else if (kaynak == "Havuz")
                        row.DefaultCellStyle.BackColor = Color.FromArgb(230, 230, 230);
                    else
                        row.DefaultCellStyle.BackColor = Color.FromArgb(220, 235, 255);
                }

                LoadMevcutAtamalar();
            }
            catch (Exception ex) { DatabaseHelper.ShowError("Gozetmenler yuklenemedi", ex); }
        }

        private void LoadMevcutAtamalar()
        {
            try
            {
                var dt = DatabaseHelper.Query(
                    "SELECT ga.GozetmenAtamaID, p.Unvan+' '+p.Ad+' '+p.Soyad AS PersonelAdi, " +
                    "b.BolumAdi, d.Ad AS DerslikAdi " +
                    "FROM Gozetmen_Atamalari ga " +
                    "JOIN Personel p ON ga.PersonelID=p.PersonelID " +
                    "JOIN Bolumler b ON p.BolumID=b.BolumID " +
                    "JOIN Sinav_Salonlari ss ON ga.SinavSalonID=ss.SinavSalonID " +
                    "JOIN Derslikler d ON ss.DerslikID=d.DerslikID " +
                    "WHERE ss.SinavID=@sid ORDER BY d.Ad, p.Soyad",
                    new[] { new SqlParameter("@sid", _sinavId) });
                dgvMevcutAtamalar.DataSource = dt;
                if (dgvMevcutAtamalar.Columns["GozetmenAtamaID"] != null)
                    dgvMevcutAtamalar.Columns["GozetmenAtamaID"].Visible = false;
            }
            catch { }
        }

        private void BtnAta_Click(object sender, EventArgs e)
        {
            var salonRow     = dgvSalonlar.CurrentRow;
            var gozetmenRow  = dgvGozetmenler.CurrentRow;
            if (salonRow == null)    { MessageBox.Show("Sol listeden bir salon secin."); return; }
            if (gozetmenRow == null) { MessageBox.Show("Ortadaki listeden bir gozetmen secin."); return; }

            // Salona zaten gozetmen atanmis mi?
            int gozetmenSayisi = Convert.ToInt32(salonRow.Cells["GozetmenSayisi"].Value);
            if (gozetmenSayisi >= 1)
            {
                MessageBox.Show("Bu salona zaten bir gozetmen atanmis!\nOnce mevcut atamay kaldirip yeniden atayabilirsiniz.",
                    "Uyari", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            var musait = gozetmenRow.Cells["Musait"].Value;
            if (musait != null && !Convert.ToBoolean(musait))
            {
                if (MessageBox.Show("Bu personel mazeretli! Yine de atamak istiyor musunuz?",
                    "Uyari", MessageBoxButtons.YesNo, MessageBoxIcon.Warning) != DialogResult.Yes) return;
            }

            // Havuz kisitlamasi: bolumde musait gozetmen varken havuzdan atama yapilamaz
            string kaynak = gozetmenRow.Cells["Kaynak"].Value?.ToString() ?? "";
            if (kaynak == "Havuz")
            {
                bool bolumMusaitVar = false;
                foreach (DataGridViewRow r in dgvGozetmenler.Rows)
                {
                    if (r.IsNewRow) continue;
                    string k = r.Cells["Kaynak"].Value?.ToString() ?? "";
                    bool m   = r.Cells["Musait"].Value != null && Convert.ToBoolean(r.Cells["Musait"].Value);
                    if (k == "Bolum" && m) { bolumMusaitVar = true; break; }
                }
                if (bolumMusaitVar)
                {
                    MessageBox.Show(
                        "Bolumde hala musait gozetmen var!\n\n" +
                        "Once bolum gozetmenlerini atayiniz.\n" +
                        "Bolumde musait gozetmen kalmadiktan sonra\nhavuzdan atama yapilabilir.",
                        "Uyari", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    return;
                }
            }

            int sinavSalonId = Convert.ToInt32(salonRow.Cells["SinavSalonID"].Value);
            int personelId   = Convert.ToInt32(gozetmenRow.Cells["PersonelID"].Value);

            try
            {
                // sp_GozetmenAta stored procedure cagrisi
                DatabaseHelper.SPNoResult("dbo.sp_GozetmenAta",
                    new[]
                    {
                        new SqlParameter("@SinavSalonID", sinavSalonId),
                        new SqlParameter("@PersonelID",   personelId)
                    });
                LoadGozetmenler();
                LoadSalonlar();
            }
            catch (SqlException ex)
            {
                MessageBox.Show("Atama basarisiz:\n\n" + ex.Message, "Hata", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private void BtnKaldir_Click(object sender, EventArgs e)
        {
            var row = dgvMevcutAtamalar.CurrentRow;
            if (row == null) { MessageBox.Show("Kaldirmak istediginiz atamay secin."); return; }
            if (MessageBox.Show("Secili gozetmen atamasi kaldirilsin mi?", "Onay",
                MessageBoxButtons.YesNo, MessageBoxIcon.Question) != DialogResult.Yes) return;

            int atamaId = Convert.ToInt32(row.Cells["GozetmenAtamaID"].Value);
            string err;
            if (!DatabaseHelper.TryExecute(
                "DELETE FROM Gozetmen_Atamalari WHERE GozetmenAtamaID=@id",
                new[] { new SqlParameter("@id", atamaId) }, out err))
                MessageBox.Show("Kaldirilmadi: " + err, "Hata", MessageBoxButtons.OK, MessageBoxIcon.Error);
            else { LoadGozetmenler(); LoadSalonlar(); }
        }
    }
}
