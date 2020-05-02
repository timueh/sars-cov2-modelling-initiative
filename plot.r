library(plotly)
library(magrittr)
library(lubridate)

plot_repronum <- function(estimates, country_name, language, unreliable = 0) {
    # do not plot anything before first estimate
    if (is.na(estimates$repronum[1])) {
        first_non_na_estimate <- min(which(!is.na(estimates$repronum)))
        estimates <- estimates[-(1:(first_non_na_estimate -1)),]
    }

    zero_estimates <- abs(estimates$repronum) < 1e-10
    zero_estimates <- zero_estimates[!is.na(zero_estimates)]
    estimates[zero_estimates, c("repronum", "ci.lower", "ci.upper")] <- NA

    strings <- list(
        en = list(
            repno = "reproduction number",
            est_repno = "estimated reproduction number",
            ci = "95% confidence interval",
            new_cases = "newly reported cases",
            title = paste0("Estimated reproduction number / newly reported cases - ", country_name),
            date = "date",
            xaxis = "corresponding date of infection / reporting date of new cases",
            unreliable = "This data may be updated in the future."
        ),
        de = list(
            repno = "Reproduktionszahl",
            est_repno = "geschätzte Reproduktionszahl",
            ci = "95% Konfidenzintervall",
            new_cases = "neu gemeldete Fälle",
            title = paste0("Geschätzte Reproduktionszahl / neu gemeldete Fälle - ", country_name),
            date = "Datum",
            xaxis = "zugehöriges Infektionsdatum / Meldedatum neuer Fälle",
            unreliable = "Dieser Datenpunkt ist noch nicht endgültig."
        )
    )

    n_dates <- nrow(estimates)
    last_estimate <- max(which(!is.na(estimates$repronum)))
    translations <- strings[[language]]

    # make lower limit smaller, otherwise it may look like R = 0 
    min_y <- min(c(0.3, estimates$repronum), na.rm = TRUE) * .8
    max_y <- max(c(10, estimates$repronum), na.rm = TRUE)

    # plotly needs log of axis range for log-axis
    ylim <- log(c(min_y, max_y), base = 10)
        

    if (unreliable > 0) {
        unreliable_estimates <- estimates[
            seq(last_estimate - unreliable - 1, n_dates),
            c("date", "repronum", "ci.lower", "ci.upper")
            ]
        unreliable_cases <- estimates[
            seq(n_dates - unreliable, n_dates),
            c("date", "new.cases")
            ]
        estimates[seq(n_dates - unreliable, n_dates), c("new.cases")] <- NA
        estimates[
            seq(last_estimate - unreliable, n_dates),
            c("repronum", "ci.lower", "ci.upper")
            ] <- NA
    }

    estimates_neighboring_NAs <- estimates[, c("date", "repronum")]
    for (i in 1:nrow(estimates_neighboring_NAs)) {
        previous <- if ( i == 1) 0 else estimates$repronum[i - 1]
        following <- if (i == nrow(estimates)) 0 else estimates$repronum[i + 1]

        if (sum(!is.na(c(previous, following))) == 2) {
            estimates_neighboring_NAs[i, "repronum"] <- NA
        }
    }

    first_monday <- ymd("2020-01-06")
    plot_ly(estimates, x= ~date, y= ~repronum) %>%
        add_lines(
            name = translations$repno,
            hoverinfo = "none"
        ) %>%
        add_ribbons(
            ymin = ~ci.lower,
            ymax = ~ci.upper,
            opacity = .5,
            hoverinfo = "none",
            name = translations$ci
        ) %>%
        add_lines(
            y = ~1,
            name = "R = 1",
            opacity = .3,
            hoverinfo = "none",
            line = list(dash = "dash")
        ) %>%
        add_bars(
            y = ~new.cases,
            yaxis = "y2",
            opacity = .1,
            hovertemplate = paste0(
                "<b>", translations$date, "</b>: %{x|", if(language == "en") "%d/%m/%Y" else "%d.%m.%Y", "}",
                "<br><b>", translations$new_cases, "</b>: %{y:.0f}",
                "<extra></extra>" # remove extra information
            ),
            hoverinfo = "text",
            name = translations$new_cases
        ) %>% {
            if (unreliable > 0) {
                add_lines(.,
                    data = unreliable_estimates,
                    name = translations$repno,
                    x = ~date,
                    y = ~repronum,
                    hoverinfo = "none",
                    showlegend = FALSE,
                    opacity = 0.3,
                    line = list(dash = "dot")
                ) %>%
                add_trace(.,
                    data = unreliable_estimates,
                    mode = "markers",
                    type = "scatter",
                    x = ~date,
                    y = ~repronum,
                    hovertemplate = paste0(
                        "<b>", translations$date, "</b>: %{x|", if(language == "en") "%d/%m/%Y" else "%d.%m.%Y", "}",
                        "<br><b>", translations$est_repno, "</b>: %{y:.2f}",
                        "<br><b>", translations$ci, "</b>: %{text}",
                        "<br><i>", translations$unreliable, "</i>",
                        "<extra></extra>" # remove extra information
                    ),
                    text = ~sprintf("[%.2f, %.2f]", ci.lower, ci.upper),
                    hoverinfo = "text",
                    showlegend = FALSE,
                    opacity = 0.6,
                    marker = list(color = "black", size = 5)
                ) %>%
                add_ribbons(
                    data = unreliable_estimates,
                    x = ~date,
                    ymin = ~ci.lower,
                    ymax = ~ci.upper,
                    opacity = .1,
                    hoverinfo = "none",
                    showlegend = FALSE,
                    fillcolor = "grey",
                    line = list(color = "grey")
                ) %>%
                add_bars(
                    data = unreliable_cases,
                    y = ~new.cases,
                    yaxis = "y2",
                    opacity = .05,
                    hovertemplate = paste0(
                        "<b>", translations$date, "</b>: %{x|", if(language == "en") "%d/%m/%Y" else "%d.%m.%Y", "}",
                        "<br><b>", translations$new_cases, "</b>: %{y:.0f}",
                        "<br><i>", translations$unreliable, "</i>",
                        "<extra></extra>" # remove extra information
                    ),
                    hoverinfo = "text",
                    name = translations$new_cases,
                    showlegend = FALSE,
                    marker = list(color = "blue")
                )
            }
            else {
                .
            }
        } %>%
        add_lines(
            data = estimates,
            x = ~date,
            y = ~repronum,
            connectgaps = TRUE,
            opacity = .2,
            line = list(dash = "dash"),
            showlegend = FALSE,
            hoverinfo = "none"
        ) %>%
        add_trace(
            data = estimates,
            x = ~date,
            y = ~repronum,
            showlegend = FALSE,
            hovertemplate = paste0(
                "<b>", translations$date, "</b>: %{x|", if(language == "en") "%d/%m/%Y" else "%d.%m.%Y", "}",
                "<br><b>", translations$est_repno, "</b>: %{y:.2f}",
                "<br><b>", translations$ci, "</b>: %{text}",
                "<extra></extra>" # remove extra information
            ),
            text = ~sprintf("[%.2f, %.2f]", ci.lower, ci.upper),
            hoverinfo = "text",
            mode = "markers",
            type = "scatter",
            marker = list(size = 5, color = "black")
        ) %>%
        layout(
            title = translations$title,
            yaxis = list(
                type = "log",
                title = translations$repno,
                #tickmode = "array",
                tickvals = c(0.1 * (1:9), 1:10),
                ticktext = c(0.1 * (1:3), " ", 0.5, " ", 0.7, " ", " ", 1:3, " ", 5, " ", 7, " ", " ", 10),
                range = ylim,
                gridcolor = "#00000018"
                ),
            colorway = c("black", "grey", "red", "blue", "black", "grey", "blue"),
            yaxis2 = list(
                overlaying = "y",
                side = "right",
                title = translations$new_cases,
                fixedrange = TRUE,
                gridcolor = "#FFFFFF00"
                ),
            xaxis =  list(
                ticks = "outside",
                tickvals = seq(first_monday, today(), by = "1 week"),
                showline = TRUE,
                showgrid = TRUE,
                type = "date",
                tickformat = if (language == "en") "%d/%m" else "%d.%m.",
                title = translations$xaxis,
                gridcolor = "#00000040"
                ),
            legend = list(
                x = 0.2,
                y = -0.23,
                font = list(size = 10),
                bgcolor = "#FFFFFF00",
                orientation = "h",
                itemclick = FALSE,
                itemdoubleclick = FALSE,
                traceorder = "normal"
                ),
            margin = list(r = 60, t = 100),
            shapes = lapply(seq(min(estimates$date), today(), by = "1 day"), function (day) {
                list(
                    type = "line",
                    y0 = 0,
                    y1 = 1,
                    yref = "paper",
                    x0 = day,
                    x1 = day,
                    line = list(color = "#eee", width = 1),
                    layer = "below"
                )
            }),
            barmode = "stack"
        )
}
