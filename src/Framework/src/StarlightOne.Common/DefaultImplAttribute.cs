namespace StarlightOne;

[AttributeUsage(AttributeTargets.Interface)]
public class DefaultImplAttribute : Attribute
{
}


[AttributeUsage(AttributeTargets.Property)]
public class DefaultImplPropAttribute: Attribute
{
    public DefaultImplPropAttribute(int order)
    {
        Order = order;
    }

    public int Order { get; }
}