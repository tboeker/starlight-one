namespace Starships.Query.Service;

public class StarshipQueryApi: IApi{
    public void Register(IEndpointRouteBuilder app)
    {
        app.MapGet("starship/list",
            (CancellationToken cancellationToken, StarshipQueryService service) =>
                service.GetListAsync(cancellationToken)
        ); 
        
        app.MapGet("starship/list2",
            (CancellationToken cancellationToken, StarshipQueryService service) =>
                service.GetList2Async(cancellationToken)
        );
    }
}