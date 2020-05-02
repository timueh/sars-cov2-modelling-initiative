# CoViz Germany Docs

## Projection Model & Parameters

The CoViz Projection Model is based on a graph where each node represents one district
(Landkreis). Each node has edges to all other nodes. The edge weight resembles the daily
traffic from one node to another.

Each district is equipped with an individual \\(SIR\\)-Compartment-Model. The disease
propagation is dependent on two main factors: intra-district propagation (based on
infection rate \\(\\beta\\) and recovery rate \\(\\mu\\) respectively) and inter-district movements.
Based on commute statistics and air-travel data, the model estimates the probability of 
an infected individual to travel to another district. In fact, it estimates the probability
of all individuals to switch districts.

The model uses both, commute statistics and air-travel, to model movement as we think that
both modes of travel are almost mutually exclusive. We assume there are little to no individuals
commuting by flight.


### District Graph Model

| Parameter                                                        | Definition                                                         |
| ---------------------------------------------------------------- | -------------------------------------------------------------------|
|\\(V=\\{v_i\\}\\)                                                 | Districts                                                          |
|\\(E=\\{e_{ij} :ex.v_i, v_j \in V\\}\\)                           | Paths Between Districts                                            |
|\\(W=\\{w_{ij} :ex.v_i, v_j \in V\\}\\)                            | Number of Travelers Between Districts  |

<br />

### Compartments in District \\(i\\)

| Parameter       | Definition                                                          |
| --------------- | ------------------------------------------------------------------- |
|\\(N_i(t)\\)     | Population in District \\(i\\) at Time \\(t\\)                      |
|\\(S_i(t)\\)     | Number of Currently Susceptible in District \\(i\\) at Time \\(t\\) |
|\\(I_i(t)\\)     | Number of Currently Infected in District \\(i\\) at Time \\(t\\)    |
|\\(R_i(t)\\)     | Number of Currently Recovered in District \\(i\\) at Time \\(t\\)   |

<br />

### Intra-District Infection Dynamics

| Parameter                        | Definition                                |
| -------------------------------- | ----------------------------------------- |
|\\(\\beta\\geq 0\\)               | Infection Rate                            |
|\\(\\mu \\geq 0\\)                | Recovery Rate                             |
|\\(0 \\leq \\Delta_t \\leq 1 \\)  | Fraction of Time Spent in Home District   |

<br />

Number of new infected individuals between \\(t\\) and \\(t+\\Delta_t\\) (in district \\(i\\))

$$I_{i,new}(t) \\sim Binomial(S_i(t),\\frac{\\beta\\cdot\\Delta_t\\cdot I_i(t)}{N_i(t)})$$

<br />

Number of new recovered individuals between \\(t\\) and \\(t+\\Delta_t\\) (in district \\(i\\))

$$R_{i,new}(t + \\Delta_t) \\sim Binomial(I_i(t),\\mu\\cdot\\Delta_t)$$

<br />

Number of susceptible individuals at time \\(t + \\Delta_t\\) (in district \\(i\\))

$$S_i(t+\\Delta_t)=S_i(t) - I_{i, new}(t)$$

<br />

Number of infected individuals at time \\(t + \\Delta_t\\) (in district \\(i\\))

$$I_i(t+\\Delta_t)=I_i(t) + I_{i,new}(t+\\Delta_t) - R_{i,new}(t+\\Delta_t)$$

<br />

Number of recovered individuals at time \\(t + \\Delta_t\\) (in district \\(i\\))

$$R_i(t+\\Delta_t)=R_i(t) + R_{i,new}(t)$$

<br />

### Inter-District Movement Model

Probability of individual in \\(v_i\\) to travel to \\(v_j\\):

$$\\frac{w_{ij}}{N_i(t)}$$

Numbers of individuals traveling from \\(v_i\\) to \\(v_j\\) at time \\(t\\):

$$X_{ij}(t)\\sim Multinomial(w_{ij},\\frac{(S_i(t)}{N_i(t)},\\frac{(I_i(t)}{N_i(t)},\\frac{(R_i(t)}{N_i(t)})$$

<br />


## Projection Procedure

This pseudo code illustrates the general procedure of compartment-transmissions (susceptible->infected & 
infected->recovered) as well as the movement of individuals between compartments. We consider a one-day
timestep. \\(\\Delta_t\\) defines the fraction of each day an individual spends at home. In contrast to
commutes, air-travel only happens once a day as travellers do not move back to their origin district.

<br />

```
run_projection_step(){
	// calculate infections and recoveries in home-district
	infection(beta, delta_t)
	// move commuting people to work district
	moving_people(commutes_weights, commutes_fraction)
	// calculate infections and recoveries in work-district
	infection(beta, 1 - delta_t)
	// move commuting people back home
	moving_people(- commutes_weights, commutes_fraction)
	// move air-traveling people
	moving_people(air_weights, air_fraction)
	recovery(mu)
}
```



## Data

### Reported Cases

The reported cases are retrieved from the Robert Koch-Institut:
https://npgeo-corona-npgeo-de.hub.arcgis.com/datasets/dd4580c810204019a7b8eb3e0b329dd6_0/data

### Population Data
The population data is trieved from Destatis, Kreisfreie Städte und Landkreise
https://www.destatis.de/DE/Themen/Laender-Regionen/Regionales/Gemeindeverzeichnis/Administrativ/Archiv/Standardtabellen/04_KreiseVorjahr.html

### Commuting Data

The commuting statistics are retrieved from Pendleratlas, Deutsche Agentur für Arbeit:
https://statistik.arbeitsagentur.de/Navigation/Statistik/Statistische-Analysen/Interaktive-Visualisierung/Pendleratlas/Pendleratlas-Nav.html

### Air-Travel Data

The air-travel data is retrieved from Destatis, Luftverkehr auf Hauptverkehrsflughäfen
https://www.destatis.de/DE/Themen/Branchen-Unternehmen/Transport-Verkehr/Personenverkehr/Publikationen/Downloads-Luftverkehr/luftverkehr-ausgewaehlte-flugplaetze-2080610197005.xlsx?__blob=publicationFile

So far, the model only connects one origin- and one destination districts for air-travel based
on the airport location. In a future update, we want to link all districts to their "closest" airport
to enable air-traffic for all districts


<br />

## Run Projection

As of now, the projection can be started from any date during the German Covid-19 epidemic.
The initial scenario is then based on the cases reported by the Robert Koch-Institut (RKI).
For the initial scenario all reported cases are assumed to be active for 15 days which is
resembles the average duration of infectiveness.

<br />

## Authors
- **Johannes Ponge** johannes.ponge@ercis.uni-muenster.de
- **Till Sahlmüller** till.sahlmueller@ercis.uni-muenster.de

### Contributers
- **Jennifer Hölling** jhoellin@uni-muenster.de
- **Matthias Gansen** matthias.gansen@uni-muenster.de