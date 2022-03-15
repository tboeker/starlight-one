var builder = WebApplication.CreateBuilder(args);

var log = builder.AddMySerilog();
builder.AddMySwagger(log);

var app = builder.Build();
app.UseSerilogRequestLogging();

app.UseMyInfoPage();
app.UseMySwagger(log);

app.Run();