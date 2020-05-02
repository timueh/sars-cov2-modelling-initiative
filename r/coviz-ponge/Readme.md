# Getting Started

This shiny-App contains a metapopulation model for the German spread of Covid-19.
All necessary R-packages are listed in ``installs.R``.
The required data is not contained in this repository and must be downloaded individually.
Upon sourcing the ``data_starter.R`` script, it should download and transform all required data.
So, **please run the data_starter.R first!**.
After that, you should be able to launch the shiny-App.

There's also a Dockerfile to deploy the App.
However, it will require the data starter to be run on the host system once at the beginning.
We're working on fixing this.

Please refer to johannes.ponge@ercis.uni-muenster.de or till.sahlmueller@ercis.uni-muenster.de for support.

# Column Naming Convention

## Counties
- **ags**: Allgemeiner Gemeindeschlüssel (County Identifier)
- **ags_name**: County Name
- **population**: number of people per AGS

## Reported & Projected Cases
- **date**: yyyy-mm-dd
- **day**: day since outbreak
- **new_infections**: number of newly infected
- **new_deaths**: number of newly died
- **new_recoveries**: number of newly recovered
- **cum_infections**: cumulated infections
- **cum_deaths**: cumulated deaths
- **cum_recoveries**: cumulated recoveries

## Movement
- **ags_origin**: origin county
- **ags_destination**: destination county
- **travelers**: people moving from origin to desitination county

## Compartment Model
- **ctly_infected**: currently infected inviduals
- **ctly_susceptible**: currently susceptible indivduals
- **ctly_recovered**: currently recovered individuals