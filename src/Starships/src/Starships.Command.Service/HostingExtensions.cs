using Serilog;

namespace Starships.Command.Service;

internal static class HostingExtensions
{
    internal static WebApplication ConfigureServices(this WebApplicationBuilder builder, Action<string> log)
    {
        builder.AddMySerilog();
        builder.AddMySwagger(log);

        builder
            .AddMyControllers(log)
            .AddMyDapr(log);

        return builder.Build();
    }

    internal static WebApplication ConfigurePipeline(this WebApplication app, Action<string> log)
    {
        app.UseSerilogRequestLogging();

        app
            .UseMyInfoPage()
            .UseMySwagger(log)
            ;

        app.MapControllers();
        return app;
    }
}