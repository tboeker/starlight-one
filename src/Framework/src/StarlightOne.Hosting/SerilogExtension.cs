using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Logging;
using Serilog;
using Serilog.Events;

namespace StarlightOne;

public static class SerilogExtensions
{
    public static Action<string> CreateBootstrapLogger()
    {
        Log.Logger = new LoggerConfiguration()
            .WriteTo.Console()
            .CreateBootstrapLogger();

        return Log.Logger.Information;
    }

    public static WebApplicationBuilder AddMySerilog(this WebApplicationBuilder builder)
    {
        //builder.Logging.ClearProviders();
        builder.Host.UseSerilog((context, configuration) =>
        {
            configuration
                .MinimumLevel.Debug()
                .MinimumLevel.Override("Microsoft", LogEventLevel.Information)
                .MinimumLevel.Override("Microsoft.AspNetCore", LogEventLevel.Warning)
                .MinimumLevel.Override("Grpc", LogEventLevel.Information)
                .MinimumLevel.Override("Grpc.Net.Client.Internal.GrpcCall", LogEventLevel.Error)
                // .MinimumLevel.Override("Microsoft.AspNetCore.Mvc.Infrastructure", LogEventLevel.Warning)
                .Enrich.FromLogContext()
                .Enrich.WithProperty("Application", builder.Environment.ApplicationName)
                .WriteTo.Console()
                .ReadFrom.Configuration(context.Configuration)
                .WriteTo.Seq("http://localhost:5341")
                ;
        });

        return builder;
    }


    public static Action<string> CreateLog(this WebApplication app)
    {
        var logger = app.Services.GetRequiredService<ILoggerFactory>().CreateLogger("Startup");

        // ReSharper disable once TemplateIsNotCompileTimeConstantProblem
#pragma warning disable CA2254
        void Log(string s) => logger.LogInformation(s);
#pragma warning restore CA2254

        return Log;
    }
}