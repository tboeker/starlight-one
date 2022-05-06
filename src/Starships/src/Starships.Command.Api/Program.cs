var builder = new MyAppBuilder(args)
        .AddControllers()
        .AddSwagger()
        .AddDaprClient()
    ;

var app = builder.BuildApplication()
        .UseInfoPage()
        .UseControllers()
        .UseSwagger()
    ;

await app.Run();