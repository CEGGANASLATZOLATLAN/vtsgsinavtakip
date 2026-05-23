using System;
using System.Data.SqlClient;
using System.Drawing;
using System.Windows.Forms;

namespace SinavTakipApp.Forms
{
    public interface IEditForm { void LoadForEdit(int id); }

    public class BolumForm : Form, IEditForm
    {
        private TextBox txtAdi;
        private CheckBox chkAktif;
        private Button btnKaydet, btnIptal;
        private int _editId = -1;

        public BolumForm()
        {
            Text = "Bolum";
            Size = new Size(350, 200);
            StartPosition = FormStartPosition.CenterParent;
            FormBorderStyle = FormBorderStyle.FixedDialog;
            MaximizeBox = false; MinimizeBox = false;
            Font = new Font("Segoe UI", 9f);

            var lbl = new Label { Text = "Bolum Adi:", Location = new Point(15, 20), AutoSize = true };
            txtAdi  = new TextBox { Location = new Point(15, 40), Width = 295 };
            chkAktif = new CheckBox { Text = "Aktif", Location = new Point(15, 70), Checked = true };

            btnKaydet = new Button { Text = "Kaydet", DialogResult = DialogResult.None,
                Location = new Point(150, 110), Width = 80, BackColor = Color.FromArgb(40,167,69),
                ForeColor = Color.White, FlatStyle = FlatStyle.Flat };
            btnIptal  = new Button { Text = "Iptal",  DialogResult = DialogResult.Cancel,
                Location = new Point(240, 110), Width = 70 };

            btnKaydet.Click += BtnKaydet_Click;
            Controls.AddRange(new Control[] { lbl, txtAdi, chkAktif, btnKaydet, btnIptal });
            AcceptButton = btnKaydet; CancelButton = btnIptal;
        }

        public void LoadForEdit(int id)
        {
            _editId = id;
            Text = "Bolum Duzenle";
            var dt = DatabaseHelper.Query("SELECT * FROM Bolumler WHERE BolumID=@id",
                new[] { new SqlParameter("@id", id) });
            if (dt.Rows.Count == 0) return;
            txtAdi.Text   = dt.Rows[0]["BolumAdi"].ToString();
            chkAktif.Checked = Convert.ToBoolean(dt.Rows[0]["Aktif"]);
        }

        private void BtnKaydet_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtAdi.Text))
            { MessageBox.Show("Bolum adi bos olamaz."); return; }

            string err;
            bool ok;
            if (_editId < 0)
                ok = DatabaseHelper.TryExecute(
                    "INSERT INTO Bolumler(BolumAdi,Aktif) VALUES(@a,@b)",
                    new[] { new SqlParameter("@a", txtAdi.Text.Trim()),
                            new SqlParameter("@b", chkAktif.Checked) }, out err);
            else
                ok = DatabaseHelper.TryExecute(
                    "UPDATE Bolumler SET BolumAdi=@a, Aktif=@b WHERE BolumID=@id",
                    new[] { new SqlParameter("@a", txtAdi.Text.Trim()),
                            new SqlParameter("@b", chkAktif.Checked),
                            new SqlParameter("@id", _editId) }, out err);

            if (!ok) { MessageBox.Show("Hata: " + err, "Hata", MessageBoxButtons.OK, MessageBoxIcon.Error); return; }
            DialogResult = DialogResult.OK;
            Close();
        }
    }

    // ============================================================
    public class OturumForm : Form, IEditForm
    {
        private TextBox txtTanim;
        private DateTimePicker dtpBaslangic, dtpBitis;
        private Button btnKaydet, btnIptal;
        private int _editId = -1;

        public OturumForm()
        {
            Text = "Oturum (Slot)";
            Size = new Size(380, 240);
            StartPosition = FormStartPosition.CenterParent;
            FormBorderStyle = FormBorderStyle.FixedDialog;
            MaximizeBox = false; MinimizeBox = false;
            Font = new Font("Segoe UI", 9f);

            var y = 15;
            void AddRow(string label, Control ctrl)
            {
                Controls.Add(new Label { Text = label, Location = new Point(15, y + 3), AutoSize = true });
                ctrl.Location = new Point(130, y); ctrl.Width = 210;
                Controls.Add(ctrl); y += 35;
            }

            txtTanim    = new TextBox();
            dtpBaslangic = new DateTimePicker { Format = DateTimePickerFormat.Time, ShowUpDown = true, Value = DateTime.Today.AddHours(9) };
            dtpBitis     = new DateTimePicker { Format = DateTimePickerFormat.Time, ShowUpDown = true, Value = DateTime.Today.AddHours(10).AddMinutes(30) };

            AddRow("Tanim:", txtTanim);
            AddRow("Baslangic:", dtpBaslangic);
            AddRow("Bitis:", dtpBitis);

            btnKaydet = new Button { Text = "Kaydet", Location = new Point(200, y + 10), Width = 70,
                BackColor = Color.FromArgb(40,167,69), ForeColor = Color.White, FlatStyle = FlatStyle.Flat };
            btnIptal  = new Button { Text = "Iptal",  Location = new Point(280, y + 10), Width = 60, DialogResult = DialogResult.Cancel };
            Controls.AddRange(new Control[] { btnKaydet, btnIptal });
            btnKaydet.Click += BtnKaydet_Click;
            AcceptButton = btnKaydet; CancelButton = btnIptal;
        }

        public void LoadForEdit(int id)
        {
            _editId = id; Text = "Oturum Duzenle";
            var dt = DatabaseHelper.Query("SELECT * FROM Oturumlar WHERE OturumID=@id",
                new[] { new SqlParameter("@id", id) });
            if (dt.Rows.Count == 0) return;
            txtTanim.Text = dt.Rows[0]["Tanim"].ToString();
            dtpBaslangic.Value = DateTime.Today.Add((TimeSpan)dt.Rows[0]["BaslangicSaat"]);
            dtpBitis.Value     = DateTime.Today.Add((TimeSpan)dt.Rows[0]["BitisSaat"]);
        }

        private void BtnKaydet_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtTanim.Text)) { MessageBox.Show("Tanim bos olamaz."); return; }
            if (dtpBitis.Value <= dtpBaslangic.Value) { MessageBox.Show("Bitis saati baslangictan sonra olmali."); return; }

            var bas = dtpBaslangic.Value.TimeOfDay;
            var bit = dtpBitis.Value.TimeOfDay;
            string err; bool ok;
            if (_editId < 0)
                ok = DatabaseHelper.TryExecute(
                    "INSERT INTO Oturumlar(Tanim,BaslangicSaat,BitisSaat) VALUES(@t,@b,@e)",
                    new[] { new SqlParameter("@t", txtTanim.Text.Trim()),
                            new SqlParameter("@b", bas), new SqlParameter("@e", bit) }, out err);
            else
                ok = DatabaseHelper.TryExecute(
                    "UPDATE Oturumlar SET Tanim=@t, BaslangicSaat=@b, BitisSaat=@e WHERE OturumID=@id",
                    new[] { new SqlParameter("@t", txtTanim.Text.Trim()),
                            new SqlParameter("@b", bas), new SqlParameter("@e", bit),
                            new SqlParameter("@id", _editId) }, out err);

            if (!ok) { MessageBox.Show("Hata: " + err, "Hata", MessageBoxButtons.OK, MessageBoxIcon.Error); return; }
            DialogResult = DialogResult.OK; Close();
        }
    }
}
