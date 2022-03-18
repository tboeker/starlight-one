namespace Starships.Command.Api;

public static class StarshipRequests
{
    public record BuildStarshipRequest(string StarshipId, DateTime? TimeStampUtc);
}