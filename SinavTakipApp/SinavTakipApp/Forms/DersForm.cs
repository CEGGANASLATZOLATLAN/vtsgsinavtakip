using System;
using System.Data;
using System.Data.SqlClient;
using System.Drawing;
using System.Windows.Forms;

namespace SinavTakipApp.Forms
{
    public class DersForm : Form, IEditForm
    {
        private TextBox txtKod, txtAd;
        private NumericUpDown numOgrenci, numYariyil;
        private ComboBox cmbTur, cmbBolum;
        private Button btnKaydet, btnIptal;
        private int _editId = -1;

        public DersForm()
        {
            Text = "Ders";
            Size = new Size(400, 360);
            StartPosition = FormStartPosition.CenterParent;
            FormBorderStyle = FormBorderStyle.FixedDialog;
            MaximizeBox = false; MinimizeBox = false;
            Font = new Font("Segoe UI", 9f);

            int y = 15;
            void AddRow(string label, Control ctrl)
            {
                Controls.Add(new Label { Text = label, Location = new Point(15, y + 3), AutoSize = true });
                ctrl.Location = new Point(140, y); ctrl.Width = 225;
                Controls.Add(ctrl); y += 38;
            }

            txtKod    = new TextBox();
            txtAd     = new TextBox();
            numOgrenci = new NumericUpDown { Minimum = 0, Maximum = 5000, Value = 60 };
            numYariyil = new NumericUpDown { Minimum = 1, Maximum = 8,    Value = 1  };

            cmbTur = new ComboBox { DropDownStyle = ComboBoxStyle.DropDownList };
            cmbTur.Items.AddRange(new object[] { "Zorunlu", "Secmeli", "Uzaktan", "Laboratuvar" });
            cmbTur.SelectedIndex = 0;
            cmbTur.SelectedIndexChanged += (s, e) =>
            {
                string t = cmbTur.SelectedItem?.ToString();
                bool sifirTur = t == "Uzaktan" || t == "Laboratuvar";
                numOgrenci.Enabled = !sifirTur;
                if (sifirTur) numOgrenci.Value = 0;
            };

            cmbBolum = new ComboBox { DropDownStyle = ComboBoxStyle.DropDownList };
            LoadBolumler();

            AddRow("Ders Kodu:", txtKod);
            AddRow("Ders Adi:", txtAd);
            AddRow("Tur:", cmbTur);
            AddRow("Ogrenci Sayisi:", numOgrenci);
            AddRow("Yariyil:", numYariyil);
            AddRow("Bolum:", cmbBolum);

            btnKaydet = new Button { Text = "Kaydet", Location = new Point(215, y + 5), Width = 75,
                BackColor = Color.FromArgb(40, 167, 69), ForeColor = Color.White, FlatStyle = FlatStyle.Flat };
            btnIptal  = new Button { Text = "Iptal",  Location = new Point(300, y + 5), Width = 65, DialogResult = DialogResult.Cancel };
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
            _editId = id; Text = "Ders Duzenle";
            var dt = DatabaseHelper.Query("SELECT * FROM Dersler WHERE DersID=@id",
                new[] { new SqlParameter("@id", id) });
            if (dt.Rows.Count == 0) return;
            var r = dt.Rows[0];
            txtKod.Text          = r["DersKodu"].ToString();
            txtAd.Text           = r["Ad"].ToString();
            cmbTur.SelectedItem  = r["DersTuru"].ToString();
            numOgrenci.Value     = Convert.ToDecimal(r["OgrenciSayisi"]);
            numYariyil.Value     = Convert.ToDecimal(r["Yariyil"]);
            int bolumId          = Convert.ToInt32(r["BolumID"]);
            foreach (ComboItem item in cmbBolum.Items)
                if (item.Id == bolumId) { cmbBolum.SelectedItem = item; break; }
        }

        private void BtnKaydet_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtKod.Text)) { MessageBox.Show("Ders kodu bos olamaz."); return; }
            if (string.IsNullOrWhiteSpace(txtAd.Text))  { MessageBox.Show("Ders adi bos olamaz."); return; }
            if (cmbBolum.SelectedIndex < 0) { MessageBox.Show("Bolum secin."); return; }
            string selectedTur = cmbTur.SelectedItem?.ToString();
            bool sifirTur = selectedTur == "Uzaktan" || selectedTur == "Laboratuvar";
            if (!sifirTur && numOgrenci.Value == 0) { MessageBox.Show("Ogrenci sayisi 0 olamaz."); return; }

            int bolumId = ((ComboItem)cmbBolum.SelectedItem).Id;
            var ps = new[]
            {
                new SqlParameter("@k",  txtKod.Text.Trim()),
                new SqlParameter("@a",  txtAd.Text.Trim()),
                new SqlParameter("@t",  cmbTur.SelectedItem.ToString()),
                new SqlParameter("@o",  (int)numOgrenci.Value),
                new SqlParameter("@y",  (int)numYariyil.Value),
                new SqlParameter("@b",  bolumId)
            };

            string err; bool ok;
            if (_editId < 0)
                ok = DatabaseHelper.TryExecute(
                    "INSERT INTO Dersler(DersKodu,Ad,DersTuru,OgrenciSayisi,Yariyil,BolumID) VALUES(@k,@a,@t,@o,@y,@b)",
                    ps, out err);
            else
            {
                var ps2 = new SqlParameter[ps.Length + 1];
                ps.CopyTo(ps2, 0);
                ps2[ps.Length] = new SqlParameter("@id", _editId);
                ok = DatabaseHelper.TryExecute(
                    "UPDATE Dersler SET DersKodu=@k,Ad=@a,DersTuru=@t,OgrenciSayisi=@o,Yariyil=@y,BolumID=@b WHERE DersID=@id",
                    ps2, out err);
            }

            if (!ok) { MessageBox.Show("Hata: " + err, "Hata", MessageBoxButtons.OK, MessageBoxIcon.Error); return; }
            DialogResult = DialogResult.OK; Close();
        }
    }

    // Shared helper for ComboBox items
    public class ComboItem
    {
        public int    Id   { get; }
        public string Text { get; }
        public ComboItem(int id, string text) { Id = id; Text = text; }
        public override string ToString() => Text;
    }
}
