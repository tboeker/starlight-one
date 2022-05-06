var builder = new MyAppBuilder(args)
    .AddControllers()
    .AddSwagger()
    .AddDapr();

var app = builder.BuildApplication()
    .UseInfoPage()
    .UseSwagger()
    .UseControllers()
    .UseDapr()
    ;

app.App.UseEndpoints(endpoints =>
{
    endpoints.MapSubscribeHandler();
    endpoints.MapControllers();
});


await app.Run();