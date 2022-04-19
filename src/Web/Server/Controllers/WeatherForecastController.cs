using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MultiContainerCI.Infrastructure;
using MultiContainerCI.Web.Shared;

namespace MultiContainerCI.Web.Server.Controllers
{
    [ApiController]
    [Route("[controller]")]
    public class WeatherForecastController : ControllerBase
    {
        private readonly WeatherContext _context;
        private readonly ILogger<WeatherForecastController> _logger;

        public WeatherForecastController(ILogger<WeatherForecastController> logger,
            WeatherContext context)
        {
            _logger = logger;
            _context = context;
        }

        [HttpGet]
        public async Task<IActionResult> Get()
        {
            _logger.LogInformation("Retrieving forecasts");
            var forecasts = await _context.WeatherForecasts
                                          .Select(e => new WeatherForecastDto() 
                                          {
                                              Date = e.Date,
                                              Summary = e.Summary,
                                              TemperatureC = e.TemperatureC,
                                              TemperatureF = e.TemperatureF,
                                          })
                                          .ToListAsync();
            return Ok(forecasts);
        }
    }
}