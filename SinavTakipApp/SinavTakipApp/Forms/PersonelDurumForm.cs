using System;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Windows.Forms;

namespace SinavTakipApp.Forms
{
    public class PersonelDurumForm : Form, IEditForm
    {
        private ComboBox cmbPersonel, cmbOturum, cmbMazeret;
        private NumericUpDown numGun, numYil; private ComboBox cmbAy;
        private Label lblGunAdi;
        private TextBox txtAciklama;
        private CheckBox chkTumGun;
        private Button btnKaydet, btnIptal;
        private int _editId = -1;

        public PersonelDurumForm()
        {
            Text = "Personel Mazeret / Uygunsuzluk";
            Size = new Size(500, 340);
            StartPosition = FormStartPosition.CenterParent;
            FormBorderStyle = FormBorderStyle.FixedDialog;
            MaximizeBox = false; MinimizeBox = false;
            Font = new Font("Segoe UI", 9f);

            int y = 15;
            void AddRow(string label, Control ctrl)
            {
                Controls.Add(new Label { Text = label, Location = new Point(15, y + 3), AutoSize = true });
                ctrl.Location = new Point(140, y); ctrl.Width = 330;
                Controls.Add(ctrl); y += 38;
            }

            cmbPersonel = new ComboBox { DropDownStyle = ComboBoxStyle.DropDownList };
            LoadPersonel();

            // Turkce gun/ay/yil kontrolleri
            numGun = new NumericUpDown { Minimum = 1, Maximum = 31, Value = DateTime.Today.Day,
                Width = 50, ThousandsSeparator = false };
            numYil = new NumericUpDown { Minimum = 2024, Maximum = 2035, Value = DateTime.Today.Year,
                Width = 65, ThousandsSeparator = false };
            cmbAy  = new ComboBox { DropDownStyle = ComboBoxStyle.DropDownList, Width = 120 };
            cmbAy.Items.AddRange(new object[] {
                "Ocak", "Şubat", "Mart", "Nisan", "Mayıs", "Haziran",
                "Temmuz", "Ağustos", "Eylül", "Ekim", "Kasım", "Aralık" });
            cmbAy.SelectedIndex = DateTime.Today.Month - 1;

            lblGunAdi = new Label
            {
                AutoSize  = true,
                Font      = new Font("Segoe UI", 9f, FontStyle.Bold),
                ForeColor = Color.FromArgb(0, 100, 180)
            };

            chkTumGun = new CheckBox { Text = "Tum Gun", Checked = true, Width = 100 };
            cmbOturum = new ComboBox { DropDownStyle = ComboBoxStyle.DropDownList, Enabled = false };
            LoadOturumlar();

            cmbMazeret = new ComboBox { DropDownStyle = ComboBoxStyle.DropDownList };
            cmbMazeret.Items.AddRange(new object[] { "Izinli", "DanismanlikSaati", "Diger" });
            cmbMazeret.SelectedIndex = 0;

            txtAciklama = new TextBox { Multiline = true, Height = 50 };

            AddRow("Personel:", cmbPersonel);

            // Tarih satiri: gun | ay | yil | gun-adi
            Controls.Add(new Label { Text = "Tarih:", Location = new Point(15, y + 3), AutoSize = true });
            numGun.Location    = new Point(140, y);
            cmbAy.Location     = new Point(140 + 55, y);
            numYil.Location    = new Point(140 + 55 + 125, y);
            lblGunAdi.Location = new Point(140 + 55 + 125 + 70, y + 4);
            Controls.AddRange(new Control[] { numGun, cmbAy, numYil, lblGunAdi }); y += 38;

            Controls.Add(new Label { Text = "Tum Gun:", Location = new Point(15, y + 3), AutoSize = true });
            chkTumGun.Location = new Point(140, y);
            Controls.Add(chkTumGun); y += 30;

            Controls.Add(new Label { Text = "Oturum:", Location = new Point(15, y + 3), AutoSize = true });
            cmbOturum.Location = new Point(140, y); cmbOturum.Width = 330;
            Controls.Add(cmbOturum); y += 38;

            AddRow("Mazeret Turu:", cmbMazeret);

            Controls.Add(new Label { Text = "Aciklama:", Location = new Point(15, y + 3), AutoSize = true });
            txtAciklama.Location = new Point(140, y); txtAciklama.Width = 330;
            Controls.Add(txtAciklama); y += 60;

            chkTumGun.CheckedChanged += (s, e) => cmbOturum.Enabled = !chkTumGun.Checked;

            // Tarih degisince max gun guncelle + gun adi goster
            numGun.ValueChanged        += UpdateDateControls;
            cmbAy.SelectedIndexChanged += UpdateDateControls;
            numYil.ValueChanged        += UpdateDateControls;

            btnKaydet = new Button { Text = "Kaydet", Location = new Point(310, y + 5), Width = 75,
                BackColor = Color.FromArgb(40, 167, 69), ForeColor = Color.White, FlatStyle = FlatStyle.Flat };
            btnIptal  = new Button { Text = "Iptal",  Location = new Point(395, y + 5), Width = 65, DialogResult = DialogResult.Cancel };
            Controls.AddRange(new Control[] { btnKaydet, btnIptal });
            btnKaydet.Click += BtnKaydet_Click;
            AcceptButton = btnKaydet; CancelButton = btnIptal;

            UpdateDateControls(null, EventArgs.Empty);
        }

        // Ayin gun sayisina gore numGun.Maximum gunceller ve secilen gun adini gosterir
        private void UpdateDateControls(object sender, EventArgs e)
        {
            if (cmbAy.SelectedIndex < 0) return;
            try
            {
                int ay  = cmbAy.SelectedIndex + 1;
                int yil = (int)numYil.Value;
                int maxGun = DateTime.DaysInMonth(yil, ay);
                if (numGun.Maximum != maxGun) numGun.Maximum = maxGun;
            }
            catch { }

            try
            {
                var tarih = new DateTime((int)numYil.Value, cmbAy.SelectedIndex + 1, (int)numGun.Value);
                string[] gunler = { "Pazar", "Pazartesi", "Salı", "Çarşamba", "Perşembe", "Cuma", "Cumartesi" };
                lblGunAdi.Text = gunler[(int)tarih.DayOfWeek];
            }
            catch { lblGunAdi.Text = ""; }
        }

        private void LoadPersonel()
        {
            cmbPersonel.Items.Clear();
            var dt = DatabaseHelper.Query("SELECT PersonelID, Unvan+' '+Ad+' '+Soyad AS Ad FROM Personel WHERE Aktif=1 ORDER BY Soyad");
            foreach (DataRow row in dt.Rows)
                cmbPersonel.Items.Add(new ComboItem(Convert.ToInt32(row["PersonelID"]), row["Ad"].ToString()));
            if (cmbPersonel.Items.Count > 0) cmbPersonel.SelectedIndex = 0;
        }

        private void LoadOturumlar()
        {
            cmbOturum.Items.Clear();
            var dt = DatabaseHelper.Query("SELECT OturumID, Tanim FROM Oturumlar ORDER BY BaslangicSaat");
            foreach (DataRow row in dt.Rows)
                cmbOturum.Items.Add(new ComboItem(Convert.ToInt32(row["OturumID"]), row["Tanim"].ToString()));
            if (cmbOturum.Items.Count > 0) cmbOturum.SelectedIndex = 0;
        }

        public void LoadForEdit(int id)
        {
            _editId = id; Text = "Mazeret Duzenle";
            var dt = DatabaseHelper.Query("SELECT * FROM Personel_Durum WHERE DurumID=@id",
                new[] { new SqlParameter("@id", id) });
            if (dt.Rows.Count == 0) return;
            var r = dt.Rows[0];
            int personelId = Convert.ToInt32(r["PersonelID"]);
            foreach (ComboItem item in cmbPersonel.Items)
                if (item.Id == personelId) { cmbPersonel.SelectedItem = item; break; }

            var tarihVal = Convert.ToDateTime(r["Tarih"]);
            numGun.Value        = tarihVal.Day;
            cmbAy.SelectedIndex = tarihVal.Month - 1;
            numYil.Value        = tarihVal.Year;
            UpdateDateControls(null, EventArgs.Empty);

            cmbMazeret.SelectedItem = r["MazeretTuru"].ToString();
            txtAciklama.Text = r["Aciklama"]?.ToString() ?? "";

            if (r["OturumID"] == DBNull.Value)
            {
                chkTumGun.Checked = true;
            }
            else
            {
                chkTumGun.Checked = false;
                cmbOturum.Enabled = true;
                int oturumId = Convert.ToInt32(r["OturumID"]);
                foreach (ComboItem item in cmbOturum.Items)
                    if (item.Id == oturumId) { cmbOturum.SelectedItem = item; break; }
            }
        }

        private void BtnKaydet_Click(object sender, EventArgs e)
        {
            if (cmbPersonel.SelectedIndex < 0) { MessageBox.Show("Personel secin."); return; }
            if (!chkTumGun.Checked && cmbOturum.SelectedIndex < 0) { MessageBox.Show("Oturum secin."); return; }

            int personelId = ((ComboItem)cmbPersonel.SelectedItem).Id;
            object oturumId = chkTumGun.Checked ? (object)DBNull.Value
                : ((ComboItem)cmbOturum.SelectedItem).Id;

            DateTime tarih;
            try { tarih = new DateTime((int)numYil.Value, cmbAy.SelectedIndex + 1, (int)numGun.Value); }
            catch { MessageBox.Show("Gecersiz tarih! Gun/ay/yil degerlerini kontrol edin.", "Hata"); return; }

            var ps = new[]
            {
                new SqlParameter("@pid",  personelId),
                new SqlParameter("@t",    tarih),
                new SqlParameter("@oid",  oturumId),
                new SqlParameter("@mt",   cmbMazeret.SelectedItem.ToString()),
                new SqlParameter("@ac",   string.IsNullOrWhiteSpace(txtAciklama.Text)
                    ? (object)DBNull.Value
                    : txtAciklama.Text.Trim())
            };

            string err; bool ok;
            if (_editId < 0)
                ok = DatabaseHelper.TryExecute(
                    "INSERT INTO Personel_Durum(PersonelID,Tarih,OturumID,MazeretTuru,Aciklama) VALUES(@pid,@t,@oid,@mt,@ac)",
                    ps, out err);
            else
            {
                var ps2 = new SqlParameter[ps.Length + 1];
                ps.CopyTo(ps2, 0);
                ps2[ps.Length] = new SqlParameter("@id", _editId);
                ok = DatabaseHelper.TryExecute(
                    "UPDATE Personel_Durum SET PersonelID=@pid,Tarih=@t,OturumID=@oid,MazeretTuru=@mt,Aciklama=@ac WHERE DurumID=@id",
                    ps2, out err);
            }

            if (!ok) { MessageBox.Show("Hata: " + err, "Hata", MessageBoxButtons.OK, MessageBoxIcon.Error); return; }
            DialogResult = DialogResult.OK; Close();
        }
    }
}
