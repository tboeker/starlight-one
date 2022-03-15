using Serilog;

var builder = WebApplication.CreateBuilder(args);
builder.AddMySerilog();

var app = builder.Build();
app.UseSerilogRequestLogging();
app.UseMyInfoPage(new InfoPageOptions()
{
    ShowSwaggerDocLink = false
});


app.Run();