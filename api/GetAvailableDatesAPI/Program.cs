var builder = WebApplication.CreateBuilder(args);

var app = builder.Build();

app.MapGet("/getavailabledates", () =>
{
    return new[] 
    { 
        "2024-02-01", 
        "2024-02-02", 
        "2024-02-03" 
    };
});

app.Run();
