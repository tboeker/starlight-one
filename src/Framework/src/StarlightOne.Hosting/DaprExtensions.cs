using System.Text.Json;
using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.DependencyInjection;

namespace StarlightOne;

public static class DaprExtensions
{
    public static WebApplicationBuilder AddMyDaprClient(this WebApplicationBuilder builder, Action<string> log)
    {
        var services = builder.Services;

        log("AddMyDaprClient");
        services.AddDaprClient();

        // services.AddDaprClient(clientBuilder =>
        //     {
        //         //      clientBuilder.UseGrpcEndpoint()
        //
        //         // clientBuilder.UseJsonSerializationOptions(new JsonSerializerOptions()
        //         // {
        //         //     PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
        //         //     PropertyNameCaseInsensitive = true,
        //         // })
        //     }
        // );

        return builder;
    }

    public static IMvcBuilder AddMyDapr(this IMvcBuilder builder, Action<string> log)
    {
        log("AddMyDapr");

        builder.AddDapr();
        //
        // builder.AddDapr(clientBuilder => clientBuilder
        //         
        //     .UseJsonSerializationOptions(new JsonSerializerOptions()
        //     {
        //         PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
        //         PropertyNameCaseInsensitive = true,
        //     }));

        return builder;
    }
}