using System;
using System.Windows.Forms;

namespace SinavTakipApp
{
    static class Program
    {
        [STAThread]
        static void Main()
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);

            if (!DatabaseHelper.TestConnection())
            {
                MessageBox.Show(
                    "Veritabani baglantisinda hata!\n\n" +
                    "Lutfen App.config dosyasindaki baglanma dizesini kontrol edin.\n" +
                    "SQL Server'in calistigina ve 'SinavTakip' veritabaninin var olduguna emin olun.",
                    "Baglanti Hatasi",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error);
                return;
            }

            Application.Run(new Forms.MainForm());
        }
    }
}
