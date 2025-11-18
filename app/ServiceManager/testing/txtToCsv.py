import csv
from datetime import datetime

input_file = "humidity_log.txt"  # replace with your txt file name
output_file = "output.csv"

with open(input_file, "r") as f, open(output_file, "w", newline="") as csvfile:
    writer = csv.writer(csvfile)
    writer.writerow(["humidity", "date"])  # header

    for line in f:
        parts = line.strip().split()
        if len(parts) < 3:
            continue  # skip malformed lines

        humidity = parts[0].replace("%", "")
        date_iso = parts[2]

        # Convert ISO 8601 to 'YYYY-MM-DD HH:MM:SS' format
        dt = datetime.fromisoformat(date_iso)
        date_str = dt.strftime("%Y-%m-%d %H:%M:%S")

        writer.writerow([humidity, date_str])

print(f"CSV file saved as {output_file}")
