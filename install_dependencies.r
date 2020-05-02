
libraries <- c(
    "lubridate",
    "rmarkdown",
    "plotly",
    "magrittr",
    "dplyr"
)


for (lib in libraries) {
    if (!require(lib)) install.packages(lib)
}



