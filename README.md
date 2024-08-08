A few simple helper functions to the readABF package, to plot ABF files.

Requires readABF and ggplot2.

Simple usage:

```
library(readABF)

source("ABF_plotter.R")

recording <- readABF("recording.abf")

# Print file information
print_ABF_file_info(recording)

# Plot data from 0 to 20 seconds
plot_ABF_data(recording, sweep=1, channel=1, time_from=0, time_to=20)

# Plot data from 0 to 10 seconds, gives a warning for start time less than 0
plot_ABF_data(recording, sweep=1, channel=1, time_from=-20, time_to=10)

# Plot data from 500 to 510 seconds
plot_ABF_data(recording, sweep=1, channel=1, time_from=500, time_to=510)
# As above, but highlight the x range from 501 to 503 seconds
plot_ABF_data(recording, sweep=1, channel=1, time_from=500, time_to=510,
  highlight_x_range = c(501, 503))
# Change the highlight color to red
plot_ABF_data(recording, sweep=1, channel=1, time_from=800, time_to=1200,
  highlight_y_range = c(-60, -40), highlight_color = "red")
```
