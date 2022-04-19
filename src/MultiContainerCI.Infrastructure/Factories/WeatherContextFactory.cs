using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;
using Microsoft.Extensions.Configuration;

namespace MultiContainerCI.Infrastructure.Factories
{
    internal class WeatherContextFactory : IDesignTimeDbContextFactory<WeatherContext>
    {
        private readonly IConfiguration Configuration;

        public WeatherContextFactory()
        {
            var builder = new ConfigurationBuilder()
              .SetBasePath(AppContext.BaseDirectory)
              .AddJsonFile("appsettings.ef.json", optional: false, reloadOnChange: true);

            Configuration = builder.Build();
        }

        public WeatherContext CreateDbContext(string[] args)
        {
            var options = new DbContextOptionsBuilder<WeatherContext>()
                .UseSqlServer(Configuration["ConnectionString"])
                .Options;

            return new WeatherContext(options);
        }
    }
}
