using System;
using System.Data.SqlClient;
using System.Drawing;
using System.Windows.Forms;

namespace SinavTakipApp.Forms
{
    public class DerslikForm : Form, IEditForm
    {
        private TextBox txtAd;
        private NumericUpDown numKapasite, numKat;
        private ComboBox cmbTip;
        private CheckBox chkAktif;
        private Button btnKaydet, btnIptal;
        private int _editId = -1;

        public DerslikForm()
        {
            Text = "Derslik / Salon";
            Size = new Size(380, 310);
            StartPosition = FormStartPosition.CenterParent;
            FormBorderStyle = FormBorderStyle.FixedDialog;
            MaximizeBox = false; MinimizeBox = false;
            Font = new Font("Segoe UI", 9f);

            int y = 15;
            void AddRow(string label, Control ctrl)
            {
                Controls.Add(new Label { Text = label, Location = new Point(15, y + 3), AutoSize = true });
                ctrl.Location = new Point(130, y); ctrl.Width = 210;
                Controls.Add(ctrl); y += 38;
            }

            txtAd = new TextBox();
            numKapasite = new NumericUpDown { Minimum = 1, Maximum = 2000, Value = 60 };
            numKat = new NumericUpDown { Minimum = 0, Maximum = 20, Value = 0 };
            cmbTip = new ComboBox { DropDownStyle = ComboBoxStyle.DropDownList };
            cmbTip.Items.AddRange(new object[] { "Amfi", "Sinif", "Lab" });
            cmbTip.SelectedIndex = 1;
            chkAktif = new CheckBox { Text = "Aktif", Checked = true, Width = 80 };

            AddRow("Ad:", txtAd);
            AddRow("Kapasite:", numKapasite);
            AddRow("Tip:", cmbTip);
            AddRow("Kat:", numKat);

            Controls.Add(new Label { Text = "Durum:", Location = new Point(15, y + 3), AutoSize = true });
            chkAktif.Location = new Point(130, y);
            Controls.Add(chkAktif); y += 38;

            btnKaydet = new Button { Text = "Kaydet", Location = new Point(200, y + 5), Width = 70,
                BackColor = Color.FromArgb(40, 167, 69), ForeColor = Color.White, FlatStyle = FlatStyle.Flat };
            btnIptal  = new Button { Text = "Iptal",  Location = new Point(280, y + 5), Width = 60, DialogResult = DialogResult.Cancel };
            Controls.AddRange(new Control[] { btnKaydet, btnIptal });
            btnKaydet.Click += BtnKaydet_Click;
            AcceptButton = btnKaydet; CancelButton = btnIptal;
        }

        public void LoadForEdit(int id)
        {
            _editId = id; Text = "Derslik Duzenle";
            var dt = DatabaseHelper.Query("SELECT * FROM Derslikler WHERE DerslikID=@id",
                new[] { new SqlParameter("@id", id) });
            if (dt.Rows.Count == 0) return;
            var r = dt.Rows[0];
            txtAd.Text           = r["Ad"].ToString();
            numKapasite.Value    = Convert.ToDecimal(r["Kapasite"]);
            numKat.Value         = Convert.ToDecimal(r["Kat"]);
            cmbTip.SelectedItem  = r["Tip"].ToString();
            chkAktif.Checked     = Convert.ToBoolean(r["Aktif"]);
        }

        private void BtnKaydet_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtAd.Text)) { MessageBox.Show("Ad bos olamaz."); return; }
            if (cmbTip.SelectedIndex < 0) { MessageBox.Show("Tip secin."); return; }

            var ps = new[]
            {
                new SqlParameter("@a",   txtAd.Text.Trim()),
                new SqlParameter("@k",   (int)numKapasite.Value),
                new SqlParameter("@t",   cmbTip.SelectedItem.ToString()),
                new SqlParameter("@kat", (int)numKat.Value),
                new SqlParameter("@ak",  chkAktif.Checked)
            };

            string err; bool ok;
            if (_editId < 0)
                ok = DatabaseHelper.TryExecute(
                    "INSERT INTO Derslikler(Ad,Kapasite,Tip,Kat,Aktif) VALUES(@a,@k,@t,@kat,@ak)",
                    ps, out err);
            else
            {
                var ps2 = new SqlParameter[ps.Length + 1];
                ps.CopyTo(ps2, 0);
                ps2[ps.Length] = new SqlParameter("@id", _editId);
                ok = DatabaseHelper.TryExecute(
                    "UPDATE Derslikler SET Ad=@a,Kapasite=@k,Tip=@t,Kat=@kat,Aktif=@ak WHERE DerslikID=@id",
                    ps2, out err);
            }

            if (!ok) { MessageBox.Show("Hata: " + err, "Hata", MessageBoxButtons.OK, MessageBoxIcon.Error); return; }
            DialogResult = DialogResult.OK; Close();
        }
    }
}
