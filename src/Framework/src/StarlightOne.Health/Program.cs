using Serilog;

var builder = WebApplication.CreateBuilder(args);
builder.AddMySerilog();

var app = builder.Build();
app.UseSerilogRequestLogging();
app.UseMyInfoPage();

app.Run();