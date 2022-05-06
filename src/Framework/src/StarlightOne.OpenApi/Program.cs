var builder = new MyAppBuilder(args);
builder.WebApplicationBuilder.ConfigureServices(builder.Log);

var app = builder.BuildApplication();
app.App.ConfigurePipeline(app.Log);

await app.Run();