using System;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Windows.Forms;

namespace SinavTakipApp.Forms
{
    // Yeni sinav olusturma formu - sp_SinavOlustur stored procedure'unu cagirir
    public class SinavForm : Form
    {
        private ComboBox cmbDers, cmbOturum;
        private DateTimePicker dtpTarih;
        private Button btnKaydet, btnIptal;
        private Label lblUyari;

        public SinavForm()
        {
            Text = "Yeni Sinav Olustur";
            Size = new Size(640, 340);
            StartPosition = FormStartPosition.CenterParent;
            FormBorderStyle = FormBorderStyle.FixedDialog;
            MaximizeBox = false; MinimizeBox = false;
            Font = new Font("Segoe UI", 9f);

            int y = 15;
            void AddRow(string label, Control ctrl)
            {
                Controls.Add(new Label { Text = label, Location = new Point(15, y + 3), AutoSize = true });
                ctrl.Location = new Point(150, y); ctrl.Width = 460;
                Controls.Add(ctrl); y += 40;
            }

            cmbDers    = new ComboBox { DropDownStyle = ComboBoxStyle.DropDownList, DropDownWidth = 580 };
            dtpTarih   = new DateTimePicker { Format = DateTimePickerFormat.Custom, CustomFormat = "dd MMMM yyyy", Value = DateTime.Today };
            cmbOturum  = new ComboBox { DropDownStyle = ComboBoxStyle.DropDownList };

            LoadDersler();
            LoadOturumlar();

            AddRow("Ders:", cmbDers);
            AddRow("Sinav Tarihi:", dtpTarih);
            AddRow("Oturum:", cmbOturum);

            lblUyari = new Label
            {
                Location = new Point(15, y),
                Size = new Size(600, 50),
                ForeColor = Color.FromArgb(255, 100, 0),
                Font = new Font("Segoe UI", 8.5f, FontStyle.Bold),
                Text = ""
            };
            Controls.Add(lblUyari); y += 55;

            btnKaydet = new Button { Text = "Kaydet", Location = new Point(440, y), Width = 90,
                BackColor = Color.FromArgb(40, 167, 69), ForeColor = Color.White, FlatStyle = FlatStyle.Flat, Height = 34 };
            btnIptal  = new Button { Text = "Iptal",  Location = new Point(540, y), Width = 75, Height = 34, DialogResult = DialogResult.Cancel };
            Controls.AddRange(new Control[] { btnKaydet, btnIptal });
            btnKaydet.Click += BtnKaydet_Click;
            AcceptButton = btnKaydet; CancelButton = btnIptal;

            // Ders degistiginde UDF ile gunluk limit kontrolu goster
            cmbDers.SelectedIndexChanged += CheckDailyLimit;
            dtpTarih.ValueChanged += CheckDailyLimit;
        }

        private void LoadDersler()
        {
            cmbDers.Items.Clear();
            var dt = DatabaseHelper.Query(
                "SELECT d.DersID, d.DersKodu+' - '+d.Ad+' ['+d.DersTuru+'] ('+CAST(d.OgrenciSayisi AS NVARCHAR)+' kisi, '+CAST(d.Yariyil AS NVARCHAR)+'. Yariyil) | '+b.BolumAdi AS Ad " +
                "FROM Dersler d JOIN Bolumler b ON d.BolumID=b.BolumID " +
                "WHERE NOT EXISTS (SELECT 1 FROM Sinavlar sv WHERE sv.DersID = d.DersID) " +
                "ORDER BY b.BolumAdi, d.Yariyil, d.DersKodu");
            foreach (DataRow row in dt.Rows)
                cmbDers.Items.Add(new ComboItem(Convert.ToInt32(row["DersID"]), row["Ad"].ToString()));
            if (cmbDers.Items.Count > 0) cmbDers.SelectedIndex = 0;
        }

        private void LoadOturumlar()
        {
            cmbOturum.Items.Clear();
            var dt = DatabaseHelper.Query("SELECT OturumID, Tanim FROM Oturumlar ORDER BY BaslangicSaat");
            foreach (DataRow row in dt.Rows)
                cmbOturum.Items.Add(new ComboItem(Convert.ToInt32(row["OturumID"]), row["Tanim"].ToString()));
            if (cmbOturum.Items.Count > 0) cmbOturum.SelectedIndex = 0;
        }

        private void CheckDailyLimit(object sender, EventArgs e)
        {
            if (cmbDers.SelectedIndex < 0) return;
            try
            {
                // UDF: fn_SinifGunlukSinavSayisi ile kontrol
                var dersId  = ((ComboItem)cmbDers.SelectedItem).Id;
                var tarih   = dtpTarih.Value.Date;
                var yariyil = DatabaseHelper.Scalar(
                    "SELECT Yariyil FROM Dersler WHERE DersID=@id",
                    new[] { new SqlParameter("@id", dersId) });

                if (yariyil != null && yariyil != DBNull.Value)
                {
                    var sayi = DatabaseHelper.Scalar(
                        "SELECT dbo.fn_SinifGunlukSinavSayisi(@y, @t)",
                        new[] { new SqlParameter("@y", (int)yariyil),
                                new SqlParameter("@t", tarih) });
                    int s = Convert.ToInt32(sayi);
                    if (s >= 2)
                        lblUyari.Text = $"UYARI: {yariyil}. yariyil icin bu tarihte zaten {s} sinav var! " +
                                        "Eklenmesi engellenmez ama uygun olmayabilir.";
                    else
                        lblUyari.Text = "";
                }
            }
            catch { lblUyari.Text = ""; }
        }

        private void BtnKaydet_Click(object sender, EventArgs e)
        {
            if (cmbDers.SelectedIndex < 0)   { MessageBox.Show("Ders secin."); return; }
            if (cmbOturum.SelectedIndex < 0)  { MessageBox.Show("Oturum secin."); return; }

            int dersId   = ((ComboItem)cmbDers.SelectedItem).Id;
            int oturumId = ((ComboItem)cmbOturum.SelectedItem).Id;
            var tarih    = dtpTarih.Value.Date;

            using (var conn = DatabaseHelper.GetConnection())
            using (var cmd = new SqlCommand("dbo.sp_SinavOlustur", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.AddWithValue("@DersID",   dersId);
                cmd.Parameters.AddWithValue("@Tarih",    tarih);
                cmd.Parameters.AddWithValue("@OturumID", oturumId);

                var pSinavId = new SqlParameter("@SinavID", SqlDbType.Int)
                { Direction = ParameterDirection.Output };
                var pUyari = new SqlParameter("@UyariMesaji", SqlDbType.NVarChar, 500)
                { Direction = ParameterDirection.Output };

                cmd.Parameters.Add(pSinavId);
                cmd.Parameters.Add(pUyari);

                try
                {
                    conn.Open();
                    cmd.ExecuteNonQuery();
                    string uyari = pUyari.Value?.ToString() ?? "";
                    if (!string.IsNullOrEmpty(uyari))
                        MessageBox.Show(uyari, "Uyari", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    DialogResult = DialogResult.OK;
                    Close();
                }
                catch (SqlException ex)
                {
                    MessageBox.Show("Sinav olusturulamadi:\n\n" + ex.Message,
                        "Hata", MessageBoxButtons.OK, MessageBoxIcon.Error);
                }
            }
        }
    }
}
