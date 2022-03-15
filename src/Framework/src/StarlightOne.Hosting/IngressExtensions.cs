using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Options;

namespace StarlightOne;

public class IngressOptions
{
    public string? PathBase { get; set; }

    public string GetPath(string path)
    {
        if (string.IsNullOrEmpty(PathBase))
            return path;

        path = path.EnsureNotStartsWith('/');
        return $"{PathBase.EnsureEndsWith('/')}{path}";
    }

    public bool HasPathBase() => !string.IsNullOrEmpty(PathBase);
}

public static class IngressExtensions
{
    public static void AddMyIngress(this WebApplicationBuilder builder, Action<string> log)
    {
        log("Ingress: Adding Configuration");
        builder.Services.Configure<IngressOptions>(builder.Configuration.GetSection("Ingress"));
    }


    public static void UseMyIngress(this WebApplication app, Action<string> log)
    {
        var ingress = app.Services.GetRequiredService<IOptions<IngressOptions>>().Value;

        app.UseForwardedHeaders();

        if (ingress.HasPathBase())
        {
            var p = ingress.PathBase.EnsureStartsWith('/').EnsureNotEndsWith('/');
            log($"Ingress: UsePathBase: {p}");
            app.UsePathBase(p);
        }
    }
}