using Serilog;
using Starships.Query.Service;
using Starships.ReadModel;

var log = SerilogExtensions.CreateBootstrapLogger();
log("Starting up");

// foreach (var VARIABLE in ProductCategory.Items)
// {
//     ProductCategory.
// }


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