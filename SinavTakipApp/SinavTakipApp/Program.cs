using System;
using System.Globalization;
using System.Threading;
using System.Windows.Forms;

namespace SinavTakipApp
{
    static class Program
    {
        [STAThread]
        static void Main()
        {
            // .NET kulturunu Turkce yap
            var trTR = new CultureInfo("tr-TR");
            Thread.CurrentThread.CurrentCulture   = trTR;
            Thread.CurrentThread.CurrentUICulture = trTR;
            CultureInfo.DefaultThreadCurrentCulture   = trTR;
            CultureInfo.DefaultThreadCurrentUICulture = trTR;

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
