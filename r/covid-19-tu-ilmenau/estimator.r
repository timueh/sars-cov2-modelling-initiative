# infectivity profile:
infectivity <- c((0:3)/3, 1, (5:0)/5)
names(infectivity) <- seq_along(infectivity)
infectivity <- infectivity / sum(infectivity)

width <- 1
report.delay <- 7
alpha <- 0.05

repronum <- function(
    new.cases, # I
    profile, # w
    window = 1, # H
    delay = 0, # Delta
    conf.level = 0.95, # 1-alpha
    pad.zeros = FALSE,
    min.denominator = 5,
    min.numerator = 5
) {
    # pad zeros if desired
    if(pad.zeros) new.cases <- c(rep(0, length(profile) - 1), new.cases)

    # compute convolutions over h, tau and both, respectively
    sum.h.I <- as.numeric(stats::filter(new.cases, rep(1, window),
        method = "convolution", sides = 1))
    sum.tau.wI <- as.numeric(stats::filter(new.cases, c(0, profile),
        method = "convolution", sides = 1))
    sum.htau.wI <- as.numeric(stats::filter(sum.tau.wI, rep(1, window),
        method = "convolution", sides = 1))

    # estimators
    repronum <- ifelse(sum.h.I < min.numerator, NA, sum.h.I) / ifelse(sum.htau.wI < min.denominator, NA, sum.htau.wI)

    # standard errors
    repronum.se <- sqrt(repronum / sum.htau.wI)

    # shift by delay
    repronum <- c(repronum, rep(NA, delay))[(1:length(repronum)) + delay]
    repronum.se <- c(repronum.se,
        rep(NA, delay))[(1:length(repronum.se)) + delay]

    # standard normal qunatile
    q <- qnorm(1 - (1-conf.level) / 2)

    # return data.frame with as many rows as new.cases
    ret <- data.frame(
        repronum = repronum,
        repronum.se = repronum.se,
        ci.lower = repronum - q * repronum.se,
        ci.upper = repronum + q * repronum.se
    )
    if(pad.zeros) ret[-(1:(length(profile)-1)),] else ret
}
