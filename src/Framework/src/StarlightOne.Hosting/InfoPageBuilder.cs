using System.Reflection;
using System.Text;
using Microsoft.AspNetCore.Builder;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Options;

namespace StarlightOne;

public class InfoPageOptions
{
    public bool ShowConfiguration { get; set; } = true;
    public bool ShowSwaggerLinks { get; set; } = true;

    public List<Link> Links { get; } = new();

    public void AddLink(string name, string url, bool useIngressPath = true)
    {
        Links.Add(new Link
        {
            Name = name,
            Url = url,
            UseIngressPath = useIngressPath
        });
    }

    public class Link
    {
        public string? Name { get; init; }
        public string? Url { get; init; }
        public bool UseIngressPath { get; init; }
    }
}

public class InfoPageBuilder
{
    private readonly string _content;

    public InfoPageBuilder(Assembly? assembly, WebApplication app, InfoPageOptions? options)
    {
        if (assembly == null)
        {
            throw new ArgumentNullException(nameof(assembly));
        }

        if (options == null)
        {
            options = new InfoPageOptions();
        }

        var env = app.Environment;
        var config = app.Configuration;
        var ingress = app.Services.GetRequiredService<IOptions<IngressOptions>>().Value;

        var sb = new StringBuilder();

        var head = new StringBuilder();
        {
            AddTag(head, "title", assembly.GetName().Name);
        }
        AddTag(sb, "head", head.ToString());

        var body = new StringBuilder();
        {
            body.AppendLine(GetInfo(assembly, env));

            var links = new StringBuilder();
            if (options.ShowSwaggerLinks)
            {
                options.AddLink("SwaggerDoc", SwaggerExtensions.SwaggerV1SwaggerJson);

                if (app.Environment.IsDevelopment())
                {
                    options.AddLink("SwaggerUi", "/swagger");
                }
            }

            foreach (var link in options.Links)
            {
                if (link.UseIngressPath && ingress.Enabled)
                    AddLink(links, link.Name, link.Url, ingress.PathBase);
                else
                    AddLink(links, link.Name, link.Url, string.Empty);
            }

            if (links.Length > 0)
            {
                AddTag(body, "h1", "LINKS");
                body.AppendLine(links.ToString());
            }


            if (options.ShowConfiguration)
            {
                body.AppendLine(GetConfiguration(config));
            }
        }

        AddTag(sb, "body", body.ToString());
        sb.AppendLine("<html>");

        _content = sb.ToString();
    }

    internal string GetContent()
    {
        return _content;
    }

    private void AddLink(StringBuilder sb, string? text, string? url, string? ingressPathBase)
    {
        
        if (string.IsNullOrEmpty(ingressPathBase))
            sb.AppendLine($"<a href={url} target=\"_blank\">{text}</a>");
        else
            sb.AppendLine($"<a href={ingressPathBase}{url} target=\"_blank\">{text}</a>");

        sb.AppendLine("</br>");
    }

    private void AddTag(StringBuilder sb, string tag, string? value)
    {
        sb.AppendLine($"<{tag}>");
        sb.AppendLine(value);
        sb.AppendLine($"</{tag}>");
    }

    private string GetConfiguration(IConfiguration configuration)
    {
        var sb = new StringBuilder();

        AddTag(sb, "h1", "CONFIGURATION");

        sb.AppendLine("<table>");

        // _body.AppendLine("<tr>");
        // AddTag(_body, "th", "key");
        // AddTag(_body, "th", "Value");
        // _body.AppendLine("</tr>");

        foreach (var pair in configuration.AsEnumerable().OrderBy(x => x.Key))
        {
            sb.AppendLine("<tr>");
            AddTag(sb, "td", pair.Key);
            AddTag(sb, "td", pair.Value);
            sb.AppendLine("</tr>");
        }

        sb.AppendLine("</table>");

#if DEBUG
        return sb.ToString();
#else
        return string.Empty;
#endif
    }

    private string GetInfo(Assembly assembly, IHostEnvironment webHostEnvironment)
    {
        var sb = new StringBuilder();

        AddTag(sb, "h1", "INFO");

        AddTag(sb, "p", $"AssemblyName: {assembly.GetName().Name}");
        AddTag(sb, "p", $"AssemblyVersion: {assembly.GetName().Version}");

        AddTag(sb, "p", $"ApplicationName: {webHostEnvironment.ApplicationName}");
        AddTag(sb, "p", $"EnvironmentName: {webHostEnvironment.EnvironmentName}");

        var att = assembly.GetCustomAttribute<AssemblyFileVersionAttribute>();
        if (att != null)
        {
            AddTag(sb, "p", $"FileVersion: {att.Version}");
        }

        AddTag(sb, "p", assembly.GetName().FullName);

        return sb.ToString();
    }
}