using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.DependencyInjection;
using Serilog;

namespace StarlightOne;

public class MyApp
{
    public WebApplication App { get; }
    public Action<string> Log { get; }

    internal MyApp(WebApplication app, Action<string> log)
    {
        App = app;
        Log = log;
        
        app.UseSerilogRequestLogging();
        app.UseMyIngress(Log);
    }

    public async Task<int> Run()
    {
        try
        {
            await App.RunAsync();
            return 0;
        }
        catch (Exception ex)
        {
            Serilog.Log.Fatal(ex, "Host terminated unexpectedly");
            return -1;
        }
        finally
        {
            Serilog.Log.CloseAndFlush();
        }
    }

    public MyApp UseInfoPage()
    {
        App.UseMyInfoPage();
        return this;
    }

    public MyApp UseSwagger()
    {
        App.UseMySwagger(Log);
        return this;
    }

    public MyApp UseControllers()
    {
        App.MapControllers();
        return this;
    }

    public MyApp UseDapr()
    {
        App.UseRouting();
        App.UseCloudEvents();
        App.MapSubscribeHandler();

        return this;
    }

    public MyApp UseApis()
    {
        App.UseRouting();
        var apis = App.Services.GetServices<IApi>();
        foreach (var api in apis)
        {
            Log($"Registering Api: {api.GetType().Name}");
            api.Register(App);
        }

        return this;
    }
}