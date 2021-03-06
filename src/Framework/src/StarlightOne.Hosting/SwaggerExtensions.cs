using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Options;
using Microsoft.OpenApi.Models;
using Swashbuckle.AspNetCore.SwaggerGen;

namespace StarlightOne;

public static class SwaggerExtensions
{
    public const string SwaggerV1SwaggerJson = "/swagger/v1/swagger.json";

    public static WebApplicationBuilder AddMySwagger(this WebApplicationBuilder builder, Action<string> log,
        Action<SwaggerGenOptions>? configure = null)
    {
        log($"Adding SwaggerDoc: {builder.Environment.ApplicationName}");

        var services = builder.Services;

        services.AddEndpointsApiExplorer();

        services.AddSingleton<IConfigureOptions<SwaggerGenOptions>>(p =>
            new ConfigureSwaggerGenOptions(builder, p.GetRequiredService<IOptions<IngressOptions>>(), log, configure)
        );
        
        services.AddSwaggerGen();


        return builder;
    }

    private class ConfigureSwaggerGenOptions : IConfigureOptions<SwaggerGenOptions>
    {
        private readonly WebApplicationBuilder _builder;
        private readonly Action<string> _log;
        private readonly Action<SwaggerGenOptions>? _configure;
        private readonly IngressOptions _ingress;

        public ConfigureSwaggerGenOptions(WebApplicationBuilder builder, IOptions<IngressOptions> ingressOptions,
            Action<string> log, Action<SwaggerGenOptions>? configure)
        {
            _builder = builder;
            _log = log;
            _configure = configure;
            _ingress = ingressOptions.Value;
        }

        public void Configure(SwaggerGenOptions options)
        {
            options.EnableAnnotations();

            if (_ingress.Enabled && _ingress.HasPathBase())
            {
                _log($"ConfigureSwaggerGen: Add IngressPathFilter");
                options.DocumentFilter<IngressPathFilter>(_ingress, _log);
            }

            options.SwaggerDoc("v1",
                new OpenApiInfo
                {
                    Title = _builder.Environment.ApplicationName,
                    Version = "v1"
                });

            _configure?.Invoke(options);
        }
    }

    // ReSharper disable once ClassNeverInstantiated.Local
    private class IngressPathFilter : IDocumentFilter
    {
        private readonly IngressOptions _ingress;
        private readonly Action<string> _log;

        public IngressPathFilter(IngressOptions ingress, Action<string> log)
        {
            _ingress = ingress;
            _log = log;
        }

        public void Apply(OpenApiDocument swaggerDoc, DocumentFilterContext context)
        {
            _log($"IngressPathFilter: Apply Path Updates for Doc {swaggerDoc.Info.Title}");

            var editedPaths = new OpenApiPaths();
            foreach (var (key, value) in swaggerDoc.Paths)
            {
                var newKey = _ingress.GetPath(key).EnsureStartsWith('/');
                editedPaths.Add(newKey, value);
            }

            swaggerDoc.Paths = editedPaths;
        }
    }

    public static WebApplication UseMySwagger(this WebApplication app, Action<string> log)
    {
        log("UseSwagger");
        app.UseSwagger();
        // app.UseSwagger(c =>
        // {
        //     var ingress = app.Services.GetRequiredService<IOptions<IngressOptions>>().Value;
        //     if (ingress.HasPathBase())
        //     {
        //       //  c.RouteTemplate = ingress.PathBase.EnsureEndsWith('/') + c.RouteTemplate;
        //
        //         //     // https://vmsdurano.com/fixing-swagger-ui-when-in-behind-proxy/
        //         //     c.PreSerializeFilters.Add((document, httpReq) =>
        //         //     {
        //         //         if (httpReq.Headers.ContainsKey("X-Forwarded-Host"))
        //         //         {
        //         //             log($"Filter: Is Forwarded Host");
        //         //         }
        //         //         
        //         //         log($"Filter: {httpReq.Path}");
        //         //         // 
        //         //         //     
        //         //         //     var basePath = options.PathBase;
        //         //         //     var serverUrl = $"{request.Scheme}://{request.Path}/{basePath}";
        //         //         //  //   document.Servers = new List<OpenApiServer> { new OpenApiServer { Url = serverUrl } };
        //     }
        // });

        if (app.Environment.IsDevelopment())
        {
            var ingress = app.Services.GetRequiredService<IOptions<IngressOptions>>().Value;
            var url = ingress.GetPath(SwaggerV1SwaggerJson);

            log("UseSwaggerUI");

            app.UseSwaggerUI(
                c =>
                {
                    // if (ingress.HasPathBase())
                    //     c.RoutePrefix = ingress.PathBase.EnsureEndsWith('/') + c.RoutePrefix;

                    log($"SwaggerUI: RoutePrefix: {c.RoutePrefix}");

                    var name = $"{app.Environment.ApplicationName} v1";
                    log($"SwaggerUI: SwaggerEndpoint: {url}: {name}");
                    c.SwaggerEndpoint(url, name);
                });
        }


        return app;
    }
}