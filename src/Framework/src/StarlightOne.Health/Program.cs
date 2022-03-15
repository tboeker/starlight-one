var builder = WebApplication.CreateBuilder(args);
var log = builder.AddMySerilog();
builder.AddMyIngress(log);


var app = builder.Build();
app.UseSerilogRequestLogging();
app.UseMyIngress(log);

app.UseMyInfoPage(c => c.ShowSwaggerLinks = false);

app.Run();