using System;
using System.Collections.Generic;
using System.Text;

namespace SourceGenerators;

public static class EnumSourceGenerationHelper
{
    public const string AttributeName = "StarlightOne.EnumExtensionsAttribute";

    public const string AttributeSource = @"
namespace StarlightOne
{
    [System.AttributeUsage(System.AttributeTargets.Enum)]
    public class EnumExtensionsAttribute : System.Attribute
    {
    }
}";

    public static string GenerateExtensionClass(List<EnumToGenerate> enumsToGenerate)
    {
        var sb = new StringBuilder();
        sb.Append(@"
namespace StarlightOne
{
    public static partial class EnumExtensions
    {");
        foreach (var enumToGenerate in enumsToGenerate)
        {
            sb.Append(@"
                public static string ToStringFast(this ").Append(enumToGenerate.Name).Append(@" value)
                    => value switch
                    {");
            foreach (var member in enumToGenerate.Values)
            {
                sb.Append(@"
                ").Append(enumToGenerate.Name).Append('.').Append(member)
                    .Append(" => nameof(")
                    .Append(enumToGenerate.Name).Append('.').Append(member).Append("),");
            }

            sb.Append(@"
                    _ => value.ToString(),
                };
");
        }

        sb.Append(@"
    }
}");

        return sb.ToString();
    }

}
