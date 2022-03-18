using System.Text.Json;
using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.DependencyInjection;

namespace StarlightOne;

public static class MvcExtensions
{
    public static IMvcBuilder AddMyControllers(this WebApplicationBuilder builder, Action<string> log)
    {
        var services = builder.Services;

        log("AddMyControllers");

        return services.AddControllers()
            .AddJsonOptions(options =>
            {
                options.JsonSerializerOptions.PropertyNamingPolicy = JsonNamingPolicy.CamelCase;
                options.JsonSerializerOptions.PropertyNameCaseInsensitive = true;
            });
    }
}