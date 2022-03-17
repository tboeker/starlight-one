using System.Reflection;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;

namespace StarlightOne;

public static class WebApplicationExtensions
{
    public static WebApplication UseMyInfoPage(this WebApplication app, Action<InfoPageOptions>? setup = null)
    {
        var options = new InfoPageOptions();
        if (setup != null)
            setup(options);

        var ipb = new InfoPageBuilder(Assembly.GetEntryAssembly(), app, options);

        app.MapGet("/",
            async context =>
            {
                var response = context.Response;
                response.ContentType = "text/html";
                await response.WriteAsync(ipb.GetContent());
            });

        return app;
    }


    // private static string GetConfigurationAsString(IConfiguration config)
    // {
    //     var sb = new StringBuilder();
    //
    //     sb.Append(Assembly.GetEntryAssembly()?.FullName);
    //     sb.Append(Environment.NewLine);
    //     sb.Append(Environment.NewLine);
    //
    //     sb.Append("Configuration:");
    //     sb.Append(Environment.NewLine);
    //
    //     foreach (var pair in config.AsEnumerable().OrderBy(x => x.Key))
    //     {
    //         sb.Append($"{pair.Key}: {pair.Value}");
    //         sb.Append(Environment.NewLine);
    //     }
    //
    //     return sb.ToString();
    // }
}