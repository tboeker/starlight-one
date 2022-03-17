using Dapr.Client;
using Starships.ReadModel;

namespace Starships.QueryService;

public class StarshipQueryService
{
    private readonly DaprClient _daprClient;
    private readonly ILogger _logger;

    public StarshipQueryService(ILoggerFactory loggerFactory , DaprClient daprClient)
    {
        _daprClient = daprClient;
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
   
    public async Task<IEnumerable<Starship>> GetList2Async(CancellationToken cancellationToken)
    {
        _logger.LogInformation(nameof(GetListAsync));

        var items1 = Enumerable.Range(1, 99)
            .Select(i => new Starship($"S{i}", DateTime.UtcNow.AddHours(i * -10))).ToList();
        
        var items = await _daprClient.InvokeMethodAsync<IEnumerable<Starship>>(
            HttpMethod.Get,
            "starships-query-service",
            "starship/list",
            cancellationToken);
        
        cancellationToken.ThrowIfCancellationRequested();

        items1.AddRange(items);
        
        await Task.Delay(10, cancellationToken);

        return items1;
    }
    
}