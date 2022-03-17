using Serilog;
using Starships.QueryApi;

var log = SerilogExtensions.CreateBootstrapLogger();
log("Starting up");

try
{
    var builder = WebApplication.CreateBuilder(args);

    var app = builder
        .ConfigureServices(log)
        .ConfigurePipeline(log);

    app.Run();
}
catch (Exception ex)
{
    Log.Fatal(ex, "Unhandled exception");
}
finally
{
    Log.Information("Shut down complete");
    Log.CloseAndFlush();
}