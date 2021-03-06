using System.Runtime.CompilerServices;

namespace StarlightOne;

[PublicAPI]
public static class Ensure {
    /// <summary>
    /// Checks if the object is not null, otherwise throws
    /// </summary>
    /// <param name="value">Object to check for null value</param>
    /// <param name="name">Name of the object to be used in the exception message</param>
    /// <typeparam name="T">Object type</typeparam>
    /// <returns>Non-null object value</returns>
    /// <exception cref="ArgumentNullException"></exception>
    public static T NotNull<T>(T? value, [CallerArgumentExpression("value")] string? name = default) where T : class
        => value ?? throw new ArgumentNullException(name);

    /// <summary>
    /// Checks if the string is not null or empty, otherwise throws
    /// </summary>
    /// <param name="value">String value to check</param>
    /// <param name="name">Name of the parameter to be used in the exception message</param>
    /// <returns>Non-null and not empty string</returns>
    /// <exception cref="ArgumentNullException"></exception>
    public static string NotEmptyString(string? value, [CallerArgumentExpression("value")] string? name = default)
        => !string.IsNullOrWhiteSpace(value) ? value : throw new ArgumentNullException(name);

  }