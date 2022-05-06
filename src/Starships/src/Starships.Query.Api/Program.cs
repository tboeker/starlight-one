var builder = new MyAppBuilder(args)
        .AddSwagger()
        .AddControllers()
        .AddDaprClient()
    ;

var app = builder.BuildApplication()
        .UseInfoPage()
        .UseSwagger()
        .UseControllers()
    ;

await app.Run();