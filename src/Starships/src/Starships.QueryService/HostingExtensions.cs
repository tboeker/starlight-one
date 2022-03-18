using Serilog;

namespace Starships.QueryService;

internal static class HostingExtensions
{
    internal static WebApplication ConfigureServices(this WebApplicationBuilder builder, Action<string> log)
    {
        builder.AddMySerilog();
        builder.AddMySwagger(log);

        builder
            .AddMyControllers(log)
            .AddMyDapr(log)
            ;

        builder.Services.AddSingleton<StarshipQueryService>();

        return builder.Build();
    }

    internal static WebApplication ConfigurePipeline(this WebApplication app, Action<string> log)
    {
        app.UseSerilogRequestLogging();

        app.UseMyInfoPage()
            .UseMySwagger(log);

        app.MapQueryServices();

        app.UseRouting();
        app.UseCloudEvents();

     
         app.UseEndpoints(endpoints =>
            {
                endpoints.MapSubscribeHandler();
                endpoints.MapControllers();
            });


        return app;
    }

    private static void MapQueryServices(this IEndpointRouteBuilder app)
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