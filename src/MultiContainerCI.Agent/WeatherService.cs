using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using MultiContainerCI.Core.Entities;
using MultiContainerCI.Infrastructure;

namespace MultiContainerCI.Agent
{
    public class WeatherService : BackgroundService
    {
        private readonly ILogger<WeatherService> _logger;
        private readonly WeatherContext _context;
        private const int TIMEOUT_SECONDS = 10;
        private static readonly string[] Summaries = new[]
        {
            "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
        };

        public WeatherService(ILogger<WeatherService> logger,
            WeatherContext context)
        {
            _logger = logger;
            _context = context;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            await MigrateDatabaseAsync();

            while (!stoppingToken.IsCancellationRequested)
            {
                await UpdateForecastAsync();
                await Task.Delay(TIMEOUT_SECONDS * 1000);
            }
        }

        private async Task MigrateDatabaseAsync()
        {
            _logger.LogInformation("Migrating database...");
            int maxRetries = 5;
            for(int i = 0; i < maxRetries; i++)
            {
                try
                {
                    await _context.Database.MigrateAsync();
                }
                catch
                {
                    await Task.Delay(TIMEOUT_SECONDS * 1000);
                    _logger.LogWarning("Database not started yet, retrying attempt: {attempts}", i + 1);
                }
            }
            
            _logger.LogInformation("Migration complete!");
        }

        private async Task UpdateForecastAsync()
        {
            _logger.LogInformation("Updating forecasts...");
            var forecasts = await _context.WeatherForecasts.ToListAsync();
            _context.RemoveRange(forecasts);
            var newForecasts = Enumerable.Range(1, 5).Select(index =>
            {
                return WeatherForecast.Create(
                    DateTime.Now.AddDays(index),
                    Random.Shared.Next(-20, 55),
                    Summaries[Random.Shared.Next(Summaries.Length)]
                    );
            });
            await _context.WeatherForecasts.AddRangeAsync(newForecasts);
            await _context.SaveChangesAsync();
            _logger.LogInformation("Completed updating forecasts.");
        }
    }
}
