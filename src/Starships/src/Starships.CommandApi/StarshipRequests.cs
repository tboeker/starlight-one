namespace Starships.CommandApi;

public static class StarshipRequests
{
    public record BuildStarshipRequest(string StarshipId, DateTime? TimeStampUtc);
}