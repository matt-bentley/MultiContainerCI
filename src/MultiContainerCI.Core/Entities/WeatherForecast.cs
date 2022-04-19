
namespace MultiContainerCI.Core.Entities
{
    public class WeatherForecast
    {
        protected WeatherForecast(Guid id, DateTime date, int temperatureC, string summary)
        {
            Id = id;
            Update(date, temperatureC, summary);
        }

        public static WeatherForecast Create(DateTime date, int temperatureC, string summary)
        {
            return new WeatherForecast(Guid.NewGuid(), date, temperatureC, summary);
        }

        public Guid Id { get; private set; }
        public DateTime Date { get; private set; }
        public int TemperatureC { get; private set; }
        public string Summary { get; private set; }
        public int TemperatureF { get; private set; }

        public void Update(DateTime date, int temperatureC, string summary)
        {
            Date = date;
            TemperatureC = temperatureC;
            TemperatureF = 32 + (int)(TemperatureC / 0.5556);
            Summary = summary;
        }
    }
}
