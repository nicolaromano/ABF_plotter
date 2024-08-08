library(ggplot2)

print_ABF_file_info <- function(recorting) {
    #' Prints the file information from an ABF file
    #' @param recording the ABF file

    info <- paste("File name: ", basename(recording$path), "\n")
    info <- paste(info, "Number of sweeps: ", length(recording$data), "\n")

    for (i in 1:length(recording$data)) {
        channelNames <- paste(recording$channelNames, recording$channelUnits, sep = "-")
        info <- paste(info, "Sweep: ", i, " - Channels: ", paste(channelNames, collapse = ", "), "\n")

        n_points <- nrow(recording$data[[i]])
        n_sec <- n_points * recording$samplingIntervalInSec
        info <- paste(info, "Number of points", n_points, " - Duration: ", n_sec, "s\n")
    }

    cat(info)
    cat("\n")
}

plot_ABF_data <- function(
    recording, sweep = 1, channel = 1, time_from = 0, time_to = 100,
    highlight_x_range = NULL, highlight_y_range = NULL, highlight_color = "lightgrey") {
    #' Plots the data from an ABF file
    #' @param recording the ABF file
    #' @param sweep the sweep to plot
    #' @param channel the channel to plot
    #' @param time_from the start time of the plot, in seconds
    #' @param time_to the end time of the plot, in seconds
    #' @param highlight_x_range a vector of two values to highlight a range of x values
    #' @param highlight_y_range a vector of two values to highlight a range of y values
    #' @return a ggplot object

    # Check that the sweep and channel are valid
    if (sweep > length(recording$data)) {
        stop("Invalid sweep number")
    }
    if (channel > ncol(recording$data[[sweep]])) {
        stop("Invalid channel number")
    }

    # Convert the time range to points
    time_from_pts <- round(time_from / recording$samplingIntervalInSec)
    time_to_pts <- round(time_to / recording$samplingIntervalInSec)

    # Check that the time range is valid
    if (time_to_pts < time_from_pts) {
        stop("End time is less than start time")
    }

    if (time_from_pts < 0) {
        warning("Start time is less than 0, setting to 0")
        time_from_pts <- 0
        time_from <- 0
    }

    n_points <- nrow(recording$data[[sweep]])

    if (time_to_pts > n_points) {
        warning("End time is greater than the duration of the sweep, setting to the end of the sweep")
        time_to_pts <- n_points
        time_to <- n_points * recording$samplingIntervalInSec
    }

    data <- data.frame(recording$data[[sweep]][time_from_pts:time_to_pts, ])
    channelNames <- paste(recording$channelNames, recording$channelUnits, sep = "-")
    colnames(data) <- channelNames

    # Note we're using seconds here, rather than points!
    data$Time <- seq(time_from, time_to, length.out = nrow(data))

    # See vignette("ggplot2-in-packages") for more information on the .data pronoun
    # This is the recommended way to access string column names in ggplot2,
    # as of version 3.0.0, rather than aes_string
    g <- ggplot(data, aes(x = Time, y = .data[[channelNames[channel]]])) +
        geom_line() +
        labs(
            x = "Time (s)",
            y = channelNames[channel]
        ) +
        theme_minimal() +
        theme(
            axis.title = element_text(size = 16),
            axis.text = element_text(size = 14)
        )

    if (!is.null(highlight_x_range)) {
        g <- g + annotate("rect",
            xmin = highlight_x_range[1], xmax = highlight_x_range[2],
            ymin = -Inf, ymax = Inf, fill = highlight_color, alpha = 0.2
        )
    }

    if (!is.null(highlight_y_range)) {
        g <- g + annotate("rect",
            xmin = -Inf, xmax = Inf,
            ymin = highlight_y_range[1], ymax = highlight_y_range[2], fill = highlight_color, alpha = 0.2
        )
    }

    g
}