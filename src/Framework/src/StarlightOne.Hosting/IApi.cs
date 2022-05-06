using Microsoft.AspNetCore.Routing;

namespace StarlightOne;

public interface IApi
{
    void Register(IEndpointRouteBuilder app);
}