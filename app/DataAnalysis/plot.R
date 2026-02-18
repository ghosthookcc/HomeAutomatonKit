library(ggplot2)

data <- read.csv("data/output.csv", stringsAsFactors = FALSE)

data$date <- as.POSIXct(data$date, format="%Y-%m-%d %H:%M:%S")

days <- 1
daysInHours <- days*60*60

yMin <- floor(min(data$humidity) / 5) * 5
yMax <- ceiling(max(data$humidity) / 5) * 5

timeTicks = 3
xBreaks = seq(min(data$date), max(data$date), length.out = timeTicks)

plot <- ggplot(data, aes(x = date, y = humidity)) +
  geom_line(linewidth = 1, color = "steelblue") +
  scale_y_continuous(breaks = seq(yMin, yMax, by = 10),
                     limits = c(yMin, yMax)) +
  scale_x_datetime(date_labels = "%d-%m %H:%M",
		   breaks = xBreaks,
		   expand = expansion(mult = 0)) +
  labs(
    title = "Humidity Over Time",
    x = "Date-Time",
    y = "Humidity (%)"
  ) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(hjust = 0.5),
    axis.text.x = element_text(angle = 45, hjust = 1)
  )

ggsave("plots/plot.png", plot = plot, width = 12, height = 6, dpi = 300)
