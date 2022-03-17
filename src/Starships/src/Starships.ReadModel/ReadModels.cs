namespace Starships.ReadModel;

public record Starship([property: JsonPropertyName("starship_id")] string StarshipId
    , [property: JsonPropertyName("built_on_utc")] DateTime BuiltOnUtc);