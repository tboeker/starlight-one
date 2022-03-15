namespace StarlightOne;

internal static class StringExtensions
{
    internal static string EnsureStartsWith(this string? item, char startsWithChar)
    {
        if (string.IsNullOrEmpty(item))
            return startsWithChar.ToString();

        if (item.StartsWith(startsWithChar))
            return item;

        return $"{startsWithChar}{item}";
    }

    internal static string EnsureNotStartsWith(this string?  item, char c)
    {
        if (string.IsNullOrEmpty(item))
            return string.Empty;

        if (item.StartsWith(c))
        {
            return item.Substring(1);
        }

        return item;
    }

    internal static string EnsureEndsWith(this string?  item, char c)
    {
        if (string.IsNullOrEmpty(item))
            return c.ToString();

        if (item.EndsWith(c))
            return item;

        return $"{item}{c}";
    }

    internal static string EnsureNotEndsWith(this string?  item, char c)
    {
        if (string.IsNullOrEmpty(item))
            return string.Empty;

        if (item.EndsWith(c))
            return item.Substring(0, item.Length - 1);

        return item;
    }
}