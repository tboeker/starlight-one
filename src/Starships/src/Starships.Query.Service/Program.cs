using Starships.Query.Service;

var builder = new MyAppBuilder(args)
        .AddControllers()
        .AddSwagger()
        .AddDapr()
        .AddService<StarshipQueryService>()
        .AddApi<StarshipQueryApi>()
    ;

var app = builder.BuildApplication()
        .UseInfoPage()
        .UseControllers()
        .UseSwagger()
        .UseDapr()
        .UseApis()
    ;


await app.Run();