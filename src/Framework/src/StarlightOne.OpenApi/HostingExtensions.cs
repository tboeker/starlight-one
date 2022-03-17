using Serilog;

namespace StarlightOne;

internal static class HostingExtensions
{
    internal static WebApplication ConfigureServices(this WebApplicationBuilder builder, Action<string> log)
    {
        builder
            .AddMySerilog().
            AddMyIngress(log);
        
        builder.Services.Configure<MySwaggerOptions>(builder.Configuration.GetSection("Swagger"));

        return builder.Build();
    }


    internal static WebApplication ConfigurePipeline(this WebApplication app, Action<string> log)
    {
        app.UseSerilogRequestLogging();

        app.UseMyIngress(log);
        
        app.UseMyInfoPage(c =>
        {
            c.ShowSwaggerLinks = false;
            c.AddLink("SwaggerUi", "/swagger");
            c.AddLink("SwaggerDocs", "/swaggerdocs");
        });

        var options = app.Services.GetRequiredService<IOptions<MySwaggerOptions>>().Value;

        app.UseSwaggerUI(c =>
        {
            foreach (var doc in options.Docs)
            {
                log($"Adding Swagger Endpoint: {doc.Name} - {doc.Url}");
                c.SwaggerEndpoint(doc.Url, doc.Name);
            }
        });

        app.MapGet("/swaggerdocs",
            async context =>
            {
                var response = context.Response;
                response.ContentType = "application/json";
                await response.WriteAsync(System.Text.Json.JsonSerializer.Serialize(options.Docs));
            });

        return app;
    }
}