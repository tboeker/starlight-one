namespace StarlightOne;

[DefaultImpl]
public interface IUserId
{
    [DefaultImplProp(1)]
    string UserId { get; init; }
}

[DefaultImpl]
public interface IUserId2
{
    [DefaultImplProp(1)]
    string UserId1 { get; init; }

    [DefaultImplProp(2)]
    string UserId2 { get; init; }
}


public class DefaultUserId : IUserId
{
    public string UserId { get; init; }

    public DefaultUserId(string userId)
    {
        UserId = userId;
    }
}


public class DefaultUserId2 : IUserId2
{
    public string UserId1 { get; init; }
    public string UserId2 { get; init; }

    public DefaultUserId2(string userId1, string userId2)
    {
        UserId1 = userId1;
        UserId2 = userId2;
    }
}