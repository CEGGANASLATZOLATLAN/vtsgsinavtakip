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
        private DateTimePicker dtpTarih;
        private TextBox txtAciklama;
        private CheckBox chkTumGun;
        private Button btnKaydet, btnIptal;
        private int _editId = -1;

        public PersonelDurumForm()
        {
            Text = "Personel Mazeret / Uygunsuzluk";
            Size = new Size(420, 340);
            StartPosition = FormStartPosition.CenterParent;
            FormBorderStyle = FormBorderStyle.FixedDialog;
            MaximizeBox = false; MinimizeBox = false;
            Font = new Font("Segoe UI", 9f);

            int y = 15;
            void AddRow(string label, Control ctrl)
            {
                Controls.Add(new Label { Text = label, Location = new Point(15, y + 3), AutoSize = true });
                ctrl.Location = new Point(140, y); ctrl.Width = 250;
                Controls.Add(ctrl); y += 38;
            }

            cmbPersonel = new ComboBox { DropDownStyle = ComboBoxStyle.DropDownList };
            LoadPersonel();

            dtpTarih = new DateTimePicker { Format = DateTimePickerFormat.Short };

            chkTumGun = new CheckBox { Text = "Tum Gun", Checked = true, Width = 100 };
            cmbOturum = new ComboBox { DropDownStyle = ComboBoxStyle.DropDownList, Enabled = false };
            LoadOturumlar();

            cmbMazeret = new ComboBox { DropDownStyle = ComboBoxStyle.DropDownList };
            cmbMazeret.Items.AddRange(new object[] { "Izinli", "DanismanlikSaati", "Diger" });
            cmbMazeret.SelectedIndex = 0;

            txtAciklama = new TextBox { Multiline = true, Height = 50 };

            AddRow("Personel:", cmbPersonel);
            AddRow("Tarih:", dtpTarih);

            Controls.Add(new Label { Text = "Tum Gun:", Location = new Point(15, y + 3), AutoSize = true });
            chkTumGun.Location = new Point(140, y);
            Controls.Add(chkTumGun); y += 30;

            Controls.Add(new Label { Text = "Oturum:", Location = new Point(15, y + 3), AutoSize = true });
            cmbOturum.Location = new Point(140, y); cmbOturum.Width = 250;
            Controls.Add(cmbOturum); y += 38;

            AddRow("Mazeret Turu:", cmbMazeret);

            Controls.Add(new Label { Text = "Aciklama:", Location = new Point(15, y + 3), AutoSize = true });
            txtAciklama.Location = new Point(140, y); txtAciklama.Width = 250;
            Controls.Add(txtAciklama); y += 60;

            chkTumGun.CheckedChanged += (s, e) => cmbOturum.Enabled = !chkTumGun.Checked;

            btnKaydet = new Button { Text = "Kaydet", Location = new Point(225, y + 5), Width = 75,
                BackColor = Color.FromArgb(40, 167, 69), ForeColor = Color.White, FlatStyle = FlatStyle.Flat };
            btnIptal  = new Button { Text = "Iptal",  Location = new Point(310, y + 5), Width = 65, DialogResult = DialogResult.Cancel };
            Controls.AddRange(new Control[] { btnKaydet, btnIptal });
            btnKaydet.Click += BtnKaydet_Click;
            AcceptButton = btnKaydet; CancelButton = btnIptal;
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
            dtpTarih.Value = Convert.ToDateTime(r["Tarih"]);
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

            var ps = new[]
            {
                new SqlParameter("@pid",  personelId),
                new SqlParameter("@t",    dtpTarih.Value.Date),
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
