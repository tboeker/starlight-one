var builder = WebApplication.CreateBuilder(args);

var log = builder.AddMySerilog();
builder.AddMyIngress(log);
builder.AddMySwagger(log);
builder.Services.AddControllers();

var app = builder.Build();

// app.Use(async (context, func) =>
// {
//     log($"MyRequest: Path: {context.Request.Path} | PathBase: {context.Request.PathBase}");
//     await func(context);
// });

app.UseMyIngress(log);
app.UseSerilogRequestLogging();
app.UseMyInfoPage();
app.UseMySwagger(log);



app.MapControllers();
app.Run();