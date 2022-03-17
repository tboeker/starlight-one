using Starships.ReadModel;

namespace Starships.QueryService;

public class StarshipQueryService
{
    private readonly ILogger _logger;

    public StarshipQueryService(ILoggerFactory loggerFactory)
    {
        _logger = loggerFactory.CreateLogger(GetType());
    }

    public async Task<IEnumerable<Starship>> GetListAsync(CancellationToken cancellationToken)
    {
        _logger.LogInformation(nameof(GetListAsync));

        var items = Enumerable.Range(1, 99)
            .Select(i => new Starship($"S{i}", DateTime.UtcNow.AddHours(i * -10)));

        cancellationToken.ThrowIfCancellationRequested();

        await Task.Delay(10, cancellationToken);

        return items;
    }
}