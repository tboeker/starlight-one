using Microsoft.AspNetCore.Mvc;

namespace Starships.QueryApi.Controllers;

[Route("starship")]
public class StarshipQueryController : ControllerBase
{
    [HttpGet]
    [Route("list")]
    [SwaggerOperation(OperationId = "GetStarshipList")]
    public ActionResult<IEnumerable<ReadModels.Starship>> GetStarshipList()
    {
        var items = Enumerable.Range(1, 99)
            .Select(i => new ReadModels.Starship($"S{i}", DateTime.UtcNow.AddHours(i * -10)));

        var result = Ok(items);
        return result;
    }
}