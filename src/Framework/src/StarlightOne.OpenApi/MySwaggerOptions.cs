namespace StarlightOne;

public class MySwaggerOptions
{
    public MySwaggerDoc[] Docs { get; set; } = Array.Empty<MySwaggerDoc>();

    public class MySwaggerDoc
    {
        public string? Name { get; set; }
        public string? Url { get; set; }
    }
}