var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();
app.AddDefaultRoutes();

app.Run();