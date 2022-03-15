namespace StarlightOne;

public class StringExtensionsTests
{
    [Fact]
    public void EnsureStartsWithTests()
    {
        "test".EnsureStartsWith('/').Should().Be("/test");
        "".EnsureStartsWith('/').Should().Be("/");
    } 
    
    [Fact]
    public void EnsureNotStartsWithTests()
    {
        "/test".EnsureNotStartsWith('/').Should().Be("test");
        "".EnsureNotStartsWith('/').Should().Be("");
    }  
    
    [Fact]
    public void EnsureEndsWithTests()
    {
        "test".EnsureEndsWith('/').Should().Be("test/");
        "".EnsureEndsWith('/').Should().Be("/");
    }
    
    [Fact]
    public void EnsureNotEndsWithTests()
    {
        "test/".EnsureNotEndsWith('/').Should().Be("test");
        "".EnsureNotEndsWith('/').Should().Be("");
    }
}