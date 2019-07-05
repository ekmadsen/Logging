using System.Data.Common;
using System.Threading.Tasks;
using JetBrains.Annotations;


namespace ErikTheCoder.Logging
{
    public interface IDatabase
    {
        [UsedImplicitly]
        Task<DbConnection> OpenConnectionAsync(string Connection);
    }
}