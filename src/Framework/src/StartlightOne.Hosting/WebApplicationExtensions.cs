using System.Reflection;
using System.Text;
using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.Configuration;

namespace StartlightOne;

public static class WebApplicationExtensions
{
    public static void AddDefaultRoutes(this WebApplication app)
    {
        //app.Configuration.
        // app.MapGet("/", () => Assembly.GetEntryAssembly()?.FullName);
        app.MapGet("/", () => GetConfigurationAsString(app.Configuration));

//         app.MapGet("/test", () => Results.Extensions.Html(@$"<!doctype html>
// <html>
//     <head><title>miniHTML</title></head>
//     <body>
//         <h1>Hello World</h1>
//         <p>The time on the server is {DateTime.Now:O}</p>
//     </body>
// </html>"));
    }

    private static string GetConfigurationAsString(IConfiguration config)
    {
        var sb = new StringBuilder();

        sb.Append(Assembly.GetEntryAssembly()?.FullName);
        sb.Append(Environment.NewLine);
        sb.Append(Environment.NewLine);

        sb.Append("Configuration:");
        sb.Append(Environment.NewLine);

        foreach (var pair in config.AsEnumerable().OrderBy(x => x.Key))
        {
            sb.Append($"{pair.Key}: {pair.Value}");
            sb.Append(Environment.NewLine);
        }

        return sb.ToString();
    }
}