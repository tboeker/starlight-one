using Serilog;
using Starships.Query.Service;
using Starships.ReadModel;

var log = SerilogExtensions.CreateBootstrapLogger();
log("Starting up");
//
// foreach (var productCategory in ProductCategory.Items)
// {
//     Console.WriteLine(productCategory.Name);
// }


try
{
    var builder = WebApplication.CreateBuilder(args);

    var application = builder
        .ConfigureServices(log)
        .ConfigurePipeline(log);

    application.Run();
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