using System;
using JetBrains.Annotations;


namespace ErikTheCoder.Logging
{
    [UsedImplicitly]
    public interface ICorrelationIdAccessor
    {
        [UsedImplicitly] Guid GetCorrelationId();
    }
}
