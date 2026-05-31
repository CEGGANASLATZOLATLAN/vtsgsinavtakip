using System;
using System.Globalization;
using System.Runtime.InteropServices;
using System.Threading;
using System.Windows.Forms;

namespace SinavTakipApp
{
    static class Program
    {
        [DllImport("kernel32.dll")] private static extern bool SetThreadLocale(uint Locale);
        [DllImport("kernel32.dll")] private static extern ushort SetThreadUILanguage(ushort LangId);

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

            // EnableVisualStyles sonrasi tekrar set et — bazi Windows versiyonlarinda sifirlanir
            SetThreadLocale(1055);       // tr-TR LCID
            SetThreadUILanguage(0x041F); // tr-TR LangId

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
