using System;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Windows.Forms;

namespace SinavTakipApp.Forms
{
    public class PersonelForm : Form, IEditForm
    {
        private TextBox txtAd, txtSoyad;
        private ComboBox cmbUnvan, cmbBolum;
        private CheckBox chkAktif;
        private Button btnKaydet, btnIptal;
        private int _editId = -1;

        public PersonelForm()
        {
            Text = "Personel";
            Size = new Size(380, 310);
            StartPosition = FormStartPosition.CenterParent;
            FormBorderStyle = FormBorderStyle.FixedDialog;
            MaximizeBox = false; MinimizeBox = false;
            Font = new Font("Segoe UI", 9f);

            int y = 15;
            void AddRow(string label, Control ctrl)
            {
                Controls.Add(new Label { Text = label, Location = new Point(15, y + 3), AutoSize = true });
                ctrl.Location = new Point(120, y); ctrl.Width = 230;
                Controls.Add(ctrl); y += 38;
            }

            cmbUnvan = new ComboBox { DropDownStyle = ComboBoxStyle.DropDownList };
            cmbUnvan.Items.AddRange(new object[] { "Prof. Dr.", "Doc. Dr.", "Dr. Ogr. Uyesi", "Ar. Gor.", "Ogr. Gor." });
            cmbUnvan.SelectedIndex = 0;

            txtAd    = new TextBox();
            txtSoyad = new TextBox();
            cmbBolum = new ComboBox { DropDownStyle = ComboBoxStyle.DropDownList };
            chkAktif = new CheckBox { Text = "Aktif", Checked = true, Width = 80 };

            LoadBolumler();

            AddRow("Unvan:", cmbUnvan);
            AddRow("Ad:", txtAd);
            AddRow("Soyad:", txtSoyad);
            AddRow("Bolum:", cmbBolum);

            Controls.Add(new Label { Text = "Durum:", Location = new Point(15, y + 3), AutoSize = true });
            chkAktif.Location = new Point(120, y);
            Controls.Add(chkAktif); y += 38;

            btnKaydet = new Button { Text = "Kaydet", Location = new Point(195, y + 5), Width = 75,
                BackColor = Color.FromArgb(40, 167, 69), ForeColor = Color.White, FlatStyle = FlatStyle.Flat };
            btnIptal  = new Button { Text = "Iptal",  Location = new Point(280, y + 5), Width = 65, DialogResult = DialogResult.Cancel };
            Controls.AddRange(new Control[] { btnKaydet, btnIptal });
            btnKaydet.Click += BtnKaydet_Click;
            AcceptButton = btnKaydet; CancelButton = btnIptal;
        }

        private void LoadBolumler()
        {
            cmbBolum.Items.Clear();
            var dt = DatabaseHelper.Query("SELECT BolumID, BolumAdi FROM Bolumler WHERE Aktif=1 ORDER BY BolumAdi");
            foreach (DataRow row in dt.Rows)
                cmbBolum.Items.Add(new ComboItem(Convert.ToInt32(row["BolumID"]), row["BolumAdi"].ToString()));
            if (cmbBolum.Items.Count > 0) cmbBolum.SelectedIndex = 0;
        }

        public void LoadForEdit(int id)
        {
            _editId = id; Text = "Personel Duzenle";
            var dt = DatabaseHelper.Query("SELECT * FROM Personel WHERE PersonelID=@id",
                new[] { new SqlParameter("@id", id) });
            if (dt.Rows.Count == 0) return;
            var r = dt.Rows[0];
            cmbUnvan.SelectedItem = r["Unvan"].ToString();
            if (cmbUnvan.SelectedIndex < 0) { cmbUnvan.Items.Add(r["Unvan"].ToString()); cmbUnvan.SelectedIndex = cmbUnvan.Items.Count - 1; }
            txtAd.Text    = r["Ad"].ToString();
            txtSoyad.Text = r["Soyad"].ToString();
            chkAktif.Checked = Convert.ToBoolean(r["Aktif"]);
            int bolumId = Convert.ToInt32(r["BolumID"]);
            foreach (ComboItem item in cmbBolum.Items)
                if (item.Id == bolumId) { cmbBolum.SelectedItem = item; break; }
        }

        private void BtnKaydet_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtAd.Text))    { MessageBox.Show("Ad bos olamaz."); return; }
            if (string.IsNullOrWhiteSpace(txtSoyad.Text)) { MessageBox.Show("Soyad bos olamaz."); return; }
            if (cmbBolum.SelectedIndex < 0) { MessageBox.Show("Bolum secin."); return; }

            int bolumId = ((ComboItem)cmbBolum.SelectedItem).Id;
            var ps = new[]
            {
                new SqlParameter("@u",  cmbUnvan.SelectedItem?.ToString() ?? ""),
                new SqlParameter("@a",  txtAd.Text.Trim()),
                new SqlParameter("@s",  txtSoyad.Text.Trim()),
                new SqlParameter("@b",  bolumId),
                new SqlParameter("@ak", chkAktif.Checked)
            };

            string err; bool ok;
            if (_editId < 0)
                ok = DatabaseHelper.TryExecute(
                    "INSERT INTO Personel(Unvan,Ad,Soyad,BolumID,Aktif) VALUES(@u,@a,@s,@b,@ak)",
                    ps, out err);
            else
            {
                var ps2 = new SqlParameter[ps.Length + 1];
                ps.CopyTo(ps2, 0);
                ps2[ps.Length] = new SqlParameter("@id", _editId);
                ok = DatabaseHelper.TryExecute(
                    "UPDATE Personel SET Unvan=@u,Ad=@a,Soyad=@s,BolumID=@b,Aktif=@ak WHERE PersonelID=@id",
                    ps2, out err);
            }

            if (!ok) { MessageBox.Show("Hata: " + err, "Hata", MessageBoxButtons.OK, MessageBoxIcon.Error); return; }
            DialogResult = DialogResult.OK; Close();
        }
    }
}
