using Dapr.Client;
using Starships.ReadModel;

namespace Starships.Query.Api.Controllers;

[Route("starship")]
public class StarshipQueryController : ControllerBase
{
    private readonly ILogger<StarshipQueryController> _logger;
    private readonly DaprClient _daprClient;

    public StarshipQueryController(ILogger<StarshipQueryController> logger, DaprClient daprClient)
    {
        _logger = logger;
        _daprClient = daprClient;
    }

    [HttpGet]
    [Route("list")]
    [SwaggerOperation(OperationId = "GetStarshipList")]
    public async Task<ActionResult<IEnumerable<Starship>>> GetStarshipList()
    {
        _logger.LogInformation(nameof(GetStarshipList));

        var items = await _daprClient.InvokeMethodAsync<IEnumerable<Starship>>(
            HttpMethod.Get,
            "starships-query-service",
            "starship/list",
            HttpContext.RequestAborted);
        return Ok(items);
    }
}