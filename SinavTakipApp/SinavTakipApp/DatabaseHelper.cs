using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Windows.Forms;

namespace SinavTakipApp
{
    public static class DatabaseHelper
    {
        private static readonly string _cs =
            ConfigurationManager.ConnectionStrings["SinavTakipDB"].ConnectionString;

        public static SqlConnection GetConnection() => new SqlConnection(_cs);

        public static bool TestConnection()
        {
            try
            {
                using (var conn = GetConnection())
                {
                    conn.Open();
                    return true;
                }
            }
            catch { return false; }
        }

        public static DataTable Query(string sql, SqlParameter[] p = null)
        {
            var dt = new DataTable();
            using (var conn = GetConnection())
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.CommandTimeout = 30;
                if (p != null) cmd.Parameters.AddRange(p);
                conn.Open();
                new SqlDataAdapter(cmd).Fill(dt);
            }
            return dt;
        }

        public static int Execute(string sql, SqlParameter[] p = null)
        {
            using (var conn = GetConnection())
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.CommandTimeout = 30;
                if (p != null) cmd.Parameters.AddRange(p);
                conn.Open();
                return cmd.ExecuteNonQuery();
            }
        }

        public static object Scalar(string sql, SqlParameter[] p = null)
        {
            using (var conn = GetConnection())
            using (var cmd = new SqlCommand(sql, conn))
            {
                cmd.CommandTimeout = 30;
                if (p != null) cmd.Parameters.AddRange(p);
                conn.Open();
                return cmd.ExecuteScalar();
            }
        }

        public static DataTable SP(string procName, SqlParameter[] p = null)
        {
            var dt = new DataTable();
            using (var conn = GetConnection())
            using (var cmd = new SqlCommand(procName, conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandTimeout = 60;
                if (p != null) cmd.Parameters.AddRange(p);
                conn.Open();
                new SqlDataAdapter(cmd).Fill(dt);
            }
            return dt;
        }

        public static void SPNoResult(string procName, SqlParameter[] p = null)
        {
            using (var conn = GetConnection())
            using (var cmd = new SqlCommand(procName, conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandTimeout = 60;
                if (p != null) cmd.Parameters.AddRange(p);
                conn.Open();
                cmd.ExecuteNonQuery();
            }
        }

        public static bool TryExecute(string sql, SqlParameter[] p, out string error)
        {
            error = null;
            try { Execute(sql, p); return true; }
            catch (SqlException ex) { error = ex.Message; return false; }
            catch (Exception ex) { error = ex.Message; return false; }
        }

        public static bool TrySP(string proc, SqlParameter[] p, out string error, out DataTable result)
        {
            error = null; result = null;
            try { result = SP(proc, p); return true; }
            catch (SqlException ex) { error = ex.Message; return false; }
            catch (Exception ex) { error = ex.Message; return false; }
        }

        public static void ShowError(string context, Exception ex)
        {
            MessageBox.Show(context + "\n\n" + ex.Message, "Hata",
                MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
    }
}
