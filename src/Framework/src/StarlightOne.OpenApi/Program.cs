var builder = WebApplication.CreateBuilder(args);
var log = builder.AddMySerilog();
builder.AddMyIngress(log);

builder.Services.Configure<MySwaggerOptions>(builder.Configuration.GetSection("Swagger"));

var app = builder.Build();
app.UseSerilogRequestLogging();
app.UseMyIngress(log);

app.UseMyInfoPage(c =>
{
    c.ShowSwaggerLinks = false;
    c.AddLink("SwaggerUi", "/swagger", false);
    c.AddLink("SwaggerDocs", "/swaggerdocs", false);
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

app.Run();