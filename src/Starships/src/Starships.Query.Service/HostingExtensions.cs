using Serilog;

namespace Starships.Query.Service;

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

        builder.Services.AddSingleton<StarshipQuery.Service>();

        return builder.Build();
    }

    internal static WebApplication ConfigurePipeline(this WebApplication app, Action<string> log)
    {
        app.UseSerilogRequestLogging();

        app.UseMyInfoPage()
            .UseMySwagger(log);

        app.MapQuery.Services();

        app.UseRouting();
        app.UseCloudEvents();

     
         app.UseEndpoints(endpoints =>
            {
                endpoints.MapSubscribeHandler();
                endpoints.MapControllers();
            });


        return app;
    }

    private static void MapQuery.Services(this IEndpointRouteBuilder app)
    {
        app.MapGet("starship/list",
            (CancellationToken cancellationToken, StarshipQuery.Service service) =>
                service.GetListAsync(cancellationToken)
        ); 
        
        app.MapGet("starship/list2",
            (CancellationToken cancellationToken, StarshipQuery.Service service) =>
                service.GetList2Async(cancellationToken)
        );
        
    }
}