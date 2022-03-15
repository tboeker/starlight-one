namespace StarlightOne;

public class IngressOptionsTests
{
    [Fact]
    public void GetPathEmpty()
    {
        var options = new IngressOptions();
        options.GetPath("swagger").Should().Be("swagger");
    }

    [Fact]
    public void GetPathWithStartingSlash()
    {
        var options = new IngressOptions()
        {
            PathBase = "/mypathbase"
        };
        options.GetPath("swagger").Should().Be("/mypathbase/swagger");
    }

    [Fact]
    public void GetPathWithEndingSlash()
    {
        var options = new IngressOptions()
        {
            PathBase = "/mypathbase/"
        };
        options.GetPath("/swagger").Should().Be("/mypathbase/swagger");
    }
}