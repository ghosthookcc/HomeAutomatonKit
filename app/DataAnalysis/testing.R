# Load CSV
data <- read.csv("output.csv", stringsAsFactors = FALSE)

# Convert 'date' column to POSIXct
data$date <- as.POSIXct(data$date, format="%Y-%m-%d %H:%M:%S")

# Filter only the first 24 hours
start_time <- min(data$date)
end_time <- start_time + 24*60*60  # 24 hours later
data_24h <- subset(data, date >= start_time & date <= end_time)

# Determine min and max humidity, rounded to nearest 5%
y_min <- floor(min(data_24h$humidity) / 5) * 5
y_max <- ceiling(max(data_24h$humidity) / 5) * 5

# Plot line chart, suppress default axes
plot(data_24h$date, data_24h$humidity,
     type = "l", lwd = 2, col = "blue",
     xlab = "Date-Time", ylab = "Humidity (%)",
     main = "Humidity - First 24 Hours",
     xaxt = "n", yaxt = "n")  # suppress axes

# Custom y-axis: every 5%
axis(2, at = seq(y_min, y_max, by = 10))

# Custom x-axis: use actual recorded timestamps (approx. 8-10 ticks)
num_ticks <- 10
tick_indices <- round(seq(1, nrow(data_24h), length.out = num_ticks))
x_ticks <- data_24h$date[tick_indices]
axis.POSIXct(1, at = x_ticks, format="%d-%m %H:%M")

# Optional: add grid
grid()
