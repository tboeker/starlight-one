namespace Starships.QueryApi;

public static class ReadModels
{
    public record Starship(string StarshipId, DateTime BuiltOnUtc);
}