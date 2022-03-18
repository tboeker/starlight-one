using Serilog;

namespace Starships.Query.Api;

internal static class HostingExtensions
{
    internal static WebApplication ConfigureServices(this WebApplicationBuilder builder, Action<string> log)
    {
        builder.AddMySerilog()
            .AddMyIngress(log)
            .AddMySwagger(log)
            .AddMyDaprClient(log);

        builder
            .AddMyControllers(log)
            ;
        
        return builder.Build();
    }

    internal static WebApplication ConfigurePipeline(this WebApplication app, Action<string> log)
    {
        app.UseSerilogRequestLogging();

        app.UseMyIngress(log)
            .UseMyInfoPage()
            .UseMySwagger(log);

        app.MapControllers()
            ;
        
        return app;
    }
}