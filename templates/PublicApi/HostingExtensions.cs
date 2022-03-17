using Serilog;

namespace PublicApi;

internal static class HostingExtensions
{
    internal static WebApplication ConfigureServices(this WebApplicationBuilder builder, Action<string> log)
    {
        builder.AddMySerilog();
        builder.AddMyIngress(log);
        builder.AddMySwagger(log);
        
        builder.Services.AddControllers();
        
        return builder.Build();
    }

    internal static WebApplication ConfigurePipeline(this WebApplication app, Action<string> log)
    {
        app.UseSerilogRequestLogging();
     
        app.UseMyIngress(log);
        app.UseMyInfoPage();
        app.UseMySwagger(log);

        app.MapControllers();
        return app;
    }
}