﻿using System.Reflection;
using System.Text;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Hosting;

namespace StartlightOne;

public record InfoPageOptions(bool ShowConfiguration = true, bool ShowSwaggerDocLink = true);

public class InfoPageBuilder
{
    private readonly string _content;

    public InfoPageBuilder(Assembly? assembly, IHostEnvironment webHostEnvironment, InfoPageOptions? options,
        IConfiguration? configuration)
    {
        if (assembly == null)
        {
            throw new ArgumentNullException(nameof(assembly));
        }

        if (options == null)
        {
            options = new InfoPageOptions();
        }

        var sb = new StringBuilder();

        var head = new StringBuilder();
        {
            AddTag(head, "title", assembly.GetName().Name);
        }
        AddTag(sb, "head", head.ToString());

        var body = new StringBuilder();
        {
            body.AppendLine(GetInfo(assembly, webHostEnvironment));

            var links = new StringBuilder();
            if (options.ShowSwaggerDocLink)
            {
                AddLink(links, "SwaggerDoc", SwaggerExtensions.SwaggerV1SwaggerJson);
            }

            if (links.Length > 0)
            {
                AddTag(body, "h1", "LINKS");
                body.AppendLine(links.ToString());
            }


            if (options.ShowConfiguration && configuration != null)
            {
                body.AppendLine(GetConfiguration(configuration));
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

    private void AddLink(StringBuilder sb, string text, string url)
    {
        sb.AppendLine($"<a href={url}>{text}</a>");
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