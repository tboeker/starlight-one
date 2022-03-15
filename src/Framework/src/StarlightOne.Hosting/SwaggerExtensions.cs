using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.OpenApi.Models;

namespace StarlightOne;

public static class SwaggerExtensions
{
    
    public const string SwaggerV1SwaggerJson = "/swagger/v1/swagger.json";
    
    public static void AddMySwagger(this WebApplicationBuilder builder)
    {
        builder.Services.AddEndpointsApiExplorer();
        builder.Services.AddSwaggerGen(c =>
        {
            c.SwaggerDoc("v1",
                new OpenApiInfo
                    { Title = builder.Environment.ApplicationName, Version = "v1" });
        });
    }

    public static void UseMySwagger(this WebApplication app)
    {
        if (app.Environment.IsDevelopment())
        {
            app.UseSwagger();
            app.UseSwaggerUI(
                c =>
                {
                    
                    c.SwaggerEndpoint(SwaggerV1SwaggerJson, $"{app.Environment.ApplicationName} v1");
                });
        }
    }
}