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
    public static WebApplicationBuilder AddMyIngress(this WebApplicationBuilder builder, Action<string> log)
    {
        log("Ingress: Adding Configuration");
        builder.Services.Configure<IngressOptions>(builder.Configuration.GetSection("Ingress"));

        return builder;
    }

    public static WebApplication UseMyIngress(this WebApplication app, Action<string> log)
    {
        var ingressOptions = app.Services.GetService<IOptions<IngressOptions>>();

        if (ingressOptions == null)
            return app;

        var ingress = ingressOptions.Value;

        app.UseForwardedHeaders();

        if (ingress.HasPathBase())
        {
            var p = ingress.PathBase.EnsureStartsWith('/').EnsureNotEndsWith('/');
            log($"Ingress: UsePathBase: {p}");
            app.UsePathBase(p);
        }

        return app;
    }
}