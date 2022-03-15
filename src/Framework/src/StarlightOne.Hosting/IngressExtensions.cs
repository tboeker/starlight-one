using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Options;

namespace StarlightOne;

public class IngressOptions
{
    public string? PathBase { get; set; }
}

public static class IngressExtensions
{
    public static void AddMyIngress(this WebApplicationBuilder builder, Action<string> log)
    {
        log("Ingress: Adding Configuration");

        builder.Services.Configure<IngressOptions>(builder.Configuration.GetSection("Ingress"));
        
        // builder.Services
        //     .AddOptions<IngressOptions>()
        //     .Configure(options => builder.Configuration.Bind("Ingress", options))
        //     ;
    }


    public static void UseMyIngress(this WebApplication app, Action<string> log)
    {
        var options = app.Services.GetRequiredService<IOptions<IngressOptions>>().Value;

        if (!string.IsNullOrEmpty(options.PathBase))
        {
            log($"Ingress: UsePathBase: {options.PathBase}");
            app.UsePathBase(options.PathBase);
        }
    }
}