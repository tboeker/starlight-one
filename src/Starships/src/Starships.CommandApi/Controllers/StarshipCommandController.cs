using Dapr.Client;

namespace Starships.CommandApi.Controllers;

[ApiController]
[Route("starship")]
public class StarshipCommandController : ControllerBase
{
    private readonly ILogger<StarshipCommandController> _logger;
    private readonly DaprClient _daprClient;

    public StarshipCommandController(ILogger<StarshipCommandController> logger, DaprClient daprClient)
    {
        _logger = logger;
        _daprClient = daprClient;
    }

    [SwaggerOperation(OperationId = "PostBuildStarship")]
    [Route("build")]
    [HttpPost]
    public async Task<ActionResult> BuildStarship([FromBody] StarshipRequests.BuildStarshipRequest request)
    {
        var dt = request.TimeStampUtc ?? DateTime.UtcNow;
        _logger.LogInformation("Build Starship on {TimeStamp}", dt);

        await Task.CompletedTask;
        //_daprClient.InvokeMethodAsync<>()

        return Ok(request);
    }
}