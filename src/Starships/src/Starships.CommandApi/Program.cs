var builder = WebApplication.CreateBuilder(args);
builder.AddMySerilog();
builder.AddMySwagger();

var app = builder.Build();
app.UseSerilogRequestLogging();

app.UseMyInfoPage();
app.UseMySwagger();

app.Run();