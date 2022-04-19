using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using MultiContainerCI.Agent;
using MultiContainerCI.Infrastructure;

var host = Host.CreateDefaultBuilder()
                .ConfigureServices((hostContext, services) =>
                {
                    services.AddDbContext<WeatherContext>(options =>
                        options.UseSqlServer(hostContext.Configuration["ConnectionString"]));

                    services.AddHostedService<WeatherService>();
                })
                .UseConsoleLifetime()
                .Build();

await host.RunAsync();