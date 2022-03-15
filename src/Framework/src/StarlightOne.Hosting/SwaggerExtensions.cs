using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.OpenApi.Models;

namespace StarlightOne;

public static class SwaggerExtensions
{
    
    public const string SwaggerV1SwaggerJson = "/swagger/v1/swagger.json";
    
    public static void AddMySwagger(this WebApplicationBuilder builder, Action<string> log)
    {
        log($"Adding SwaggerDoc: {builder.Environment.ApplicationName}");
        
        builder.Services.AddEndpointsApiExplorer();
        builder.Services.AddSwaggerGen(c =>
        {
            c.SwaggerDoc("v1",
                new OpenApiInfo
                    { Title = builder.Environment.ApplicationName, Version = "v1" });
        });
    }

    public static void UseMySwagger(this WebApplication app, Action<string> log)
    {
        if (app.Environment.IsDevelopment())
        {
            log("Use Swagger and SwaggerUI");
            
            app.UseSwagger();
            app.UseSwaggerUI(
                c =>
                {
                    
                    c.SwaggerEndpoint(SwaggerV1SwaggerJson, $"{app.Environment.ApplicationName} v1");
                });
        }
    }
}