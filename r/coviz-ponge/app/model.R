### LIBRARIES ###
library(dplyr)

### MODEL INITIALIZATION ###


# initialize projection base data frame
init_projection <- function(){
  res = district_data %>%
    mutate(ctly_susceptible = population) %>%
    mutate(ctly_infected = 0) %>%
    mutate(ctly_recovered = 0)
  
  res
}



# initialize projection base data frame based on empirical data and 
# date provided as POSIXct object.
# All cases from the cases-dataframe until input_date will be considered
#to build the initial scenario
init_projection_at_date <- function(cases, input_date){
  
  # create initial scenario
  start_cases <- cases %>%
    filter(date <= input_date) %>%
    group_by(ags) %>%
    summarize(cum_infections = sum(new_infections), cum_recoveries = sum(new_recoveries))
  
  # configure dataframe with initial infections to run projection from
  initial_scenario <- init_projection() %>%
    left_join(start_cases) %>%
    mutate(ctly_infected = cum_infections - cum_recoveries) %>%
    mutate(ctly_infected = replace(ctly_infected, is.na(ctly_infected), 0)) %>% # replace N/A values with 0
    mutate(ctly_recovered = cum_recoveries) %>%
    mutate(ctly_recovered = replace(ctly_recovered, is.na(ctly_recovered), 0)) %>% # replace N/A values with 0
    mutate(ctly_susceptible = population - ctly_infected - ctly_recovered) %>%
    select(-cum_infections, -cum_recoveries)
  
  initial_scenario
}


### PROJECTION ###

# one infection step with infection probability beta and timestep delta_t
infection <- function(input_scenario, beta, delta_t){
  p = beta * delta_t
  res = input_scenario %>%
    rowwise() %>% 
    mutate(new_infections = rbinom(n = 1, size = ctly_susceptible, prob = p * ctly_infected / population)) %>%
    mutate(ctly_infected = ctly_infected + new_infections) %>%
    mutate(ctly_susceptible = ctly_susceptible - new_infections)
  
  res
}


# one recovery step with transmission rate mu and timestep delta_t
recovery <- function(input_scenario, mu, delta_t){
  p = mu * delta_t
  res = input_scenario %>%
    rowwise() %>% 
    mutate(new_recoveries = rbinom(n = 1, size = ctly_infected, prob = p)) %>%
    mutate(ctly_infected = ctly_infected - new_recoveries) %>%
    mutate(ctly_recovered = ctly_recovered + new_recoveries)
  
  res
}


# moves people between districts
# "input_scenario" has to be current distribution of susceptibles, infected abd recovered people per district
# "travelers" has to be a origin-destination matrix of travels
# "direction" indictates if people are moving from origin to destination (VALUE 1)
# or reverse (VALUE 2) according to travelers matrix
moving_people <- function(input_scenario, travelers, direction){

  # handle input parameters  
  if(direction == 1){
    FROM_AGS = "ags_origin"
    TO_AGS = "ags_destination"
  } else if(direction == 2){
    FROM_AGS = "ags_destination"
    TO_AGS = "ags_origin"
  } else {
    stop('direction must be value 1 or 2')
  }

  compute_outbound_travel <- function(travel, S, I, R){
    # handle districts, that do not have outbound traffic
    if(travel <= 0){
      res <- c(0,0,0)
    } else {
      res <- rmultinom(n = 1, size = travel, prob = c(S, I, R))
    }
    data.frame(moving_susceptibles = res[1], moving_infected = res[2], moving_recovered = res[3])
  }
  
  compute_district_travel <- function(size, prob){
    if(sum(prob) > 0)
      return(rmultinom(1, size, prob))
    else
      return(rep(0, length(prob)))
  }

   # compute how many people will leave each compartment in origin district
   outbound_travel = input_scenario %>%
     inner_join(travelers, c("ags" = FROM_AGS)) %>%
     group_by(ags, ctly_susceptible, ctly_infected, ctly_recovered) %>%
     summarize(total_outbound = sum(travelers)) %>%
     # not all districts have outbound traffic (e.g. per air travel). N/A values need to be replaced by 0
     mutate(total_outbound = replace(total_outbound, is.na(total_outbound), 0)) %>%
     do(compute_outbound_travel(.$total_outbound, .$ctly_susceptible, .$ctly_infected, .$ctly_recovered)) %>%
     rowwise() %>%
     select(ags, moving_susceptibles, moving_infected, moving_recovered) %>%
     # prevent moving more people than available in compartment
     left_join(input_scenario, by = "ags") %>%
     mutate(moving_susceptibles = min(ctly_susceptible, moving_susceptibles)) %>%
     mutate(moving_infected = min(ctly_infected, moving_infected)) %>%
     mutate(moving_recovered = min(ctly_recovered, moving_recovered)) %>%
     select(ags, moving_susceptibles, moving_infected, moving_recovered)

   # compute how many of the moving susceptibles, infected, recovered will move to each destination district
   inter_district_travel = outbound_travel %>%
     inner_join(travelers, c("ags" = FROM_AGS)) %>%
     group_by(ags, moving_susceptibles, moving_infected, moving_recovered) %>%
     mutate(incoming_susceptibles = compute_district_travel(moving_susceptibles, travelers)) %>%
     mutate(incoming_infected = compute_district_travel(moving_infected, travelers)) %>%
     mutate(incoming_recovered = compute_district_travel(moving_recovered, travelers))

   # compute the total incoming susceptible, infected and recovered people from each origin district
   incoming_travel = inter_district_travel %>%
     group_by_(TO_AGS) %>%
     summarize(total_incoming_susceptibles = sum(incoming_susceptibles),
               total_incoming_infected = sum(incoming_infected),
               total_incoming_recovered = sum(incoming_recovered))

   # update the current number of susceptible, infected, recovered people per compartment
   res = input_scenario %>%
     left_join(outbound_travel, by = "ags") %>%
     left_join(incoming_travel, c("ags" = TO_AGS)) %>%
     # replace N/A values if there was no movement
     mutate(moving_susceptibles = replace(moving_susceptibles, is.na(moving_susceptibles), 0)) %>%
     mutate(moving_infected = replace(moving_infected, is.na(moving_infected), 0)) %>%
     mutate(moving_recovered = replace(moving_recovered, is.na(moving_recovered), 0)) %>%
     mutate(total_incoming_susceptibles = replace(total_incoming_susceptibles, is.na(total_incoming_susceptibles), 0)) %>%
     mutate(total_incoming_infected = replace(total_incoming_infected, is.na(total_incoming_infected), 0)) %>%
     mutate(total_incoming_recovered = replace(total_incoming_recovered, is.na(total_incoming_recovered), 0)) %>%
     # compute new susceptible, infected, recovered counts
     mutate(ctly_susceptible = ctly_susceptible - moving_susceptibles + total_incoming_susceptibles) %>%
     mutate(ctly_infected = ctly_infected - moving_infected + total_incoming_infected) %>%
     mutate(ctly_recovered = ctly_recovered - moving_recovered + total_incoming_recovered) %>%
     select(ags, ags_name, population, ctly_susceptible, ctly_infected, ctly_recovered)

   # final sanity check to see if no people were "lost" during movement
   if(sum(res$population) != sum(res$ctly_susceptible) + sum(res$ctly_infected) + sum(res$ctly_recovered)){
     
     test <<- res
     print(res)
     
     stop("Error in moving_people(): sum of susceptible, infected and recovered do not match population size")
   }
     
   
   res
}

# moving people to work
go_to_work <- function(input_scenario, travelers){
  moving_people(input_scenario, travelers, 1)
}

# moving people to home
return_from_work <- function(input_scenario, travelers){
  moving_people(input_scenario, travelers, 2)
}

# run simulation
run_projection <- function(input_scenario, commutes_frac, air_frac, beta, mu, delta_t, days){
  
  # parameter checks
  if(commutes_frac < 0 || commutes_frac > 1) stop("commute_fraction must be between 0 and 1")
  if(air_frac < 0 || air_frac > 1) stop("air_fraction must be between 0 and 1")
  if(delta_t < 0 || delta_t > 1) stop("Delta_t must be between 0 and 1")
  if(!is.numeric(days) || days < 1) stop("days must be larger or equal to 1")

  # compute commute travelers
  com <- commutes_data %>%
    mutate(travelers = round(commutes_frac * travelers))
  
  # compute air travelers
  air <- air_data %>%
    mutate(travelers = round(air_frac * travelers))
  
  # compute daily outbound traffic
  outbound_traffic = rbind(com, air) %>%
    group_by(ags_origin, ags_destination) %>%
    summarize(travelers = sum(travelers))
  
  # copy input data for iterative simulation
  df <- input_scenario
  
  # prepare result data frame
  res = data.frame(day = c(), ags = c(), new_infections = c(), new_recoveries = c())
  
  # run simulation
  for(i in 1:days){
    
    # recover people at home
    df <- recovery(df, mu, 1)
    # infect people at home
    df <- infection(df, beta, delta_t)
    # store new recoveries/infections
    res <- rbind(res, df %>%
                  filter(new_infections > 0 || new_recoveries > 0) %>%
                  mutate(day = i) %>%
                  select(day, ags, new_infections, new_recoveries))
    # move people to work
    df <- moving_people(df, outbound_traffic, 1)
    # recover people at work
    #df <- recovery(df, mu, 1-delta_t)
    # infect people at work
    df <- infection(df, beta, 1-delta_t)
    df <- df %>% mutate(new_recoveries = 0)
    # store new recoveries/infections
    res <- rbind(res, df %>%
                  filter(new_infections > 0 || new_recoveries > 0) %>%
                  mutate(day = i) %>%
                  select(day, ags, new_infections, new_recoveries))
    # move people back home
    df <- moving_people(df, com, 2)
    
    # move air travelers
    #df <- moving_people(df, air, 1)
    
  }
  
  # consolidate work/home infections and add district name to result df
  res = res %>%
    group_by(day, ags) %>%
    summarize(new_infections = sum(new_infections),
              new_recoveries = sum(new_recoveries)) %>%
    left_join(input_scenario) %>%
    arrange(day) %>%
    select(day, ags, ags_name, new_infections, new_recoveries)
  
  res
}