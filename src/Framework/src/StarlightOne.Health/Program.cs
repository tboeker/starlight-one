var builder = new MyAppBuilder(args)
        .AddSwagger()
        .AddControllers()
    ;

var app = builder.BuildApplication()
        
        .UseInfoPage()
        .UseSwagger()
        .UseControllers()
    ;

await app.Run();