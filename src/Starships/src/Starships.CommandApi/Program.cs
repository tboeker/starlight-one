var builder = WebApplication.CreateBuilder(args);

var log = builder.AddMySerilog();
builder.AddMyIngress(log);
builder.AddMySwagger(log);

var app = builder.Build();
app.UseSerilogRequestLogging();

app.UseMyInfoPage();
app.UseMySwagger(log);
app.UseMyIngress(log);

app.Run();