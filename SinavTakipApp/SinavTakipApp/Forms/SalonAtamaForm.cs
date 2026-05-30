using System;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Windows.Forms;

namespace SinavTakipApp.Forms
{
    // Akilli salon atama formu - sp_AkilliSalonAta stored procedure'unu cagirir
    public class SalonAtamaForm : Form
    {
        private readonly int _sinavId;
        private DataGridView dgvSonuc;
        private Label lblSinavBilgi, lblDurum;
        private NumericUpDown numTercihliKat;
        private CheckBox chkTercihliKat;
        private Button btnAta, btnKapat;

        public SalonAtamaForm(int sinavId)
        {
            _sinavId = sinavId;
            InitializeForm();
            LoadSinavBilgi();
            LoadMevcutAtamalar();
        }

        private void InitializeForm()
        {
            Text = "Akilli Salon Atama";
            Size = new Size(620, 500);
            StartPosition = FormStartPosition.CenterParent;
            FormBorderStyle = FormBorderStyle.FixedDialog;
            MaximizeBox = false;
            Font = new Font("Segoe UI", 9f);

            lblSinavBilgi = new Label
            {
                Location = new Point(15, 15),
                Size = new Size(570, 50),
                Font = new Font("Segoe UI", 10f, FontStyle.Bold),
                ForeColor = Color.FromArgb(0, 70, 140)
            };
            Controls.Add(lblSinavBilgi);

            var grpAyar = new GroupBox
            {
                Text = "Salon Secim Ayarlari",
                Location = new Point(15, 70),
                Size = new Size(570, 60)
            };

            chkTercihliKat = new CheckBox { Text = "Tercihli Kat:", Location = new Point(10, 25), Width = 110 };
            numTercihliKat = new NumericUpDown { Location = new Point(125, 23), Width = 60, Minimum = 0, Maximum = 20, Enabled = false };
            chkTercihliKat.CheckedChanged += (s, e) => numTercihliKat.Enabled = chkTercihliKat.Checked;

            var lblAcik = new Label
            {
                Text = "(Sistem, oncelikle ayni kattaki en buyuk salonlari secdikten sonra diger katlara gider)",
                Location = new Point(200, 27),
                AutoSize = true,
                ForeColor = Color.Gray,
                Font = new Font("Segoe UI", 7.5f)
            };

            grpAyar.Controls.AddRange(new Control[] { chkTercihliKat, numTercihliKat, lblAcik });
            Controls.Add(grpAyar);

            lblDurum = new Label
            {
                Location = new Point(15, 140),
                Size = new Size(570, 20),
                ForeColor = Color.FromArgb(0, 100, 0),
                Font = new Font("Segoe UI", 9f, FontStyle.Italic)
            };
            Controls.Add(lblDurum);

            dgvSonuc = new DataGridView
            {
                Location = new Point(15, 165),
                Size = new Size(570, 240),
                ReadOnly = true,
                AllowUserToAddRows = false,
                AllowUserToDeleteRows = false,
                AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill,
                BackgroundColor = Color.White,
                RowHeadersVisible = false,
                SelectionMode = DataGridViewSelectionMode.FullRowSelect,
                AlternatingRowsDefaultCellStyle = new DataGridViewCellStyle { BackColor = Color.FromArgb(235, 245, 255) }
            };
            Controls.Add(dgvSonuc);

            btnAta = new Button
            {
                Text = "Akilli Salon Ata (SP)",
                Location = new Point(350, 420),
                Width = 160, Height = 36,
                BackColor = Color.FromArgb(0, 123, 255),
                ForeColor = Color.White,
                FlatStyle = FlatStyle.Flat,
                Font = new Font("Segoe UI", 9.5f, FontStyle.Bold)
            };
            btnKapat = new Button
            {
                Text = "Kapat",
                Location = new Point(520, 420),
                Width = 65, Height = 36,
                DialogResult = DialogResult.OK
            };

            btnAta.Click += BtnAta_Click;
            Controls.AddRange(new Control[] { btnAta, btnKapat });
            AcceptButton = btnKapat;
        }

        private void LoadSinavBilgi()
        {
            try
            {
                var dt = DatabaseHelper.Query(
                    "SELECT sp.DersKodu, sp.DersAdi, sp.OgrenciSayisi, sp.Tarih, sp.Oturum, " +
                    "sp.AtananKapasite, dbo.fn_ToplamKapasite(@sid) AS Kapasite " +
                    "FROM v_SinavProgrami sp WHERE sp.SinavID=@sid",
                    new[] { new SqlParameter("@sid", _sinavId) });

                if (dt.Rows.Count > 0)
                {
                    var r = dt.Rows[0];
                    lblSinavBilgi.Text = $"{r["DersKodu"]} - {r["DersAdi"]}\n" +
                        $"Tarih: {Convert.ToDateTime(r["Tarih"]):dd.MM.yyyy}  |  Oturum: {r["Oturum"]}  |  Ogrenci: {r["OgrenciSayisi"]}";
                }
            }
            catch (Exception ex) { DatabaseHelper.ShowError("Sinav bilgisi alinamadi", ex); }
        }

        private void LoadMevcutAtamalar()
        {
            try
            {
                var dt = DatabaseHelper.Query(
                    "SELECT d.Ad AS DerslikAdi, d.Kapasite, d.Tip, d.Kat " +
                    "FROM Sinav_Salonlari ss " +
                    "JOIN Derslikler d ON ss.DerslikID=d.DerslikID " +
                    "WHERE ss.SinavID=@sid ORDER BY d.Kapasite DESC",
                    new[] { new SqlParameter("@sid", _sinavId) });

                dgvSonuc.DataSource = dt;
                int toplamKap = 0;
                foreach (DataRow row in dt.Rows) toplamKap += Convert.ToInt32(row["Kapasite"]);

                if (dt.Rows.Count > 0)
                    lblDurum.Text = $"Mevcut atama: {dt.Rows.Count} salon, toplam kapasite: {toplamKap}";
                else
                    lblDurum.Text = "Henuz salon atanmamis.";
            }
            catch (Exception ex) { DatabaseHelper.ShowError("Mevcut atamalar alinamadi", ex); }
        }

        private void BtnAta_Click(object sender, EventArgs e)
        {
            if (MessageBox.Show(
                "Mevcut salon atamalari temizlenecek ve yeniden hesaplanacak. Devam?",
                "Onay", MessageBoxButtons.YesNo, MessageBoxIcon.Question) != DialogResult.Yes) return;

            object tercihliKat = chkTercihliKat.Checked
                ? (object)(int)numTercihliKat.Value
                : DBNull.Value;

            DataTable result; string err;
            bool ok = DatabaseHelper.TrySP("dbo.sp_AkilliSalonAta",
                new[]
                {
                    new SqlParameter("@SinavID",     _sinavId),
                    new SqlParameter("@TercihliKat", tercihliKat)
                }, out err, out result);

            if (!ok)
            {
                if (err.Contains("SALON_GEREKMIYOR"))
                {
                    MessageBox.Show(
                        "Bu ders türü (Uzaktan / Laboratuvar) için fiziksel salon ataması gerekmez.\n\n" +
                        "Sınav kaydı oluşturulmuş durumda, salon ataması yapılmayacak.",
                        "Bilgi", MessageBoxButtons.OK, MessageBoxIcon.Information);
                    lblDurum.Text = "Bu ders türü salon ataması gerektirmiyor (Uzaktan/Laboratuvar).";
                    lblDurum.ForeColor = Color.FromArgb(100, 100, 0);
                }
                else
                {
                    MessageBox.Show("Salon atanamadi:\n\n" + err, "Hata", MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
                return;
            }

            dgvSonuc.DataSource = result;
            int toplamKap = 0;
            foreach (DataRow row in result.Rows) toplamKap += Convert.ToInt32(row["Kapasite"]);
            lblDurum.Text = $"Atama tamamlandi: {result.Rows.Count} salon, toplam kapasite: {toplamKap}. " +
                            $"Gerekli gozetmen sayisi: {result.Rows.Count}";
            lblDurum.ForeColor = Color.FromArgb(0, 120, 0);

            MessageBox.Show($"Akilli salon atama tamamlandi!\n{result.Rows.Count} salon atandi.\nToplam kapasite: {toplamKap}",
                "Basarili", MessageBoxButtons.OK, MessageBoxIcon.Information);
        }
    }
}
