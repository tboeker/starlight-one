using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.DependencyInjection;

namespace StarlightOne;

public class MyAppBuilder
{
    private readonly Action<string> _log;
    public IMvcBuilder? MvcBuilder { get; private set; }

    public MyAppBuilder(string[] args)
    {
        _log = SerilogExtensions.CreateBootstrapLogger();
        _log("Starting up");

        WebApplicationBuilder = WebApplication
                .CreateBuilder(args)
                .AddMySerilog()
                .AddMyIngress(_log)
            ;
    }

    public WebApplicationBuilder WebApplicationBuilder { get; }

    public MyAppBuilder AddControllers()
    {
        MvcBuilder = WebApplicationBuilder
            .AddMyControllers(Log);

        return this;
    }

    public MyAppBuilder AddSwagger()
    {
        WebApplicationBuilder.AddMySwagger(Log);
        return this;
    }

    public MyAppBuilder AddDaprClient()
    {
        WebApplicationBuilder.AddMyDaprClient(Log);
        return this;
    }


    public MyApp BuildApplication()
    {
        var app = WebApplicationBuilder
            .Build();
        return new MyApp(app, Log);
    }

    public MyApp BuildApplication(Action<MyAppBuilder, MyApp> action)
    {
        var app = BuildApplication();
        action(this, app);
        return app;
    }

    public void Log(string text)
    {
        _log(text);
    }

    public MyAppBuilder AddDapr()
    {
        (MvcBuilder ?? throw new InvalidOperationException()).AddMyDapr(Log);
        return this;
    }

    public MyAppBuilder AddApi<T>() where T : IApi
    {
        var services = WebApplicationBuilder.Services;
        services.AddSingleton(typeof(IApi), typeof(T));
        return this;
    }

    public MyAppBuilder AddService<T>() where T : class
    {
        var services = WebApplicationBuilder.Services;
        services.AddSingleton<T>();
        return this;
    }
}