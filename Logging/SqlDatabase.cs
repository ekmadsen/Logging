using System.Data.Common;
using System.Data.SqlClient;
using System.Threading.Tasks;


namespace ErikTheCoder.Logging
{
    public class SqlDatabase : IDatabase
    {
        public async Task<DbConnection> OpenConnectionAsync(string Connection)
        {
            DbConnection connection = new SqlConnection(Connection);
            await connection.OpenAsync();
            return connection;
        }
    }
}
