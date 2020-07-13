source("sanity_checks.R")

require(rstanarm)
require(bayestestR)
require(stringr)
require(dplyr)
require(shinystan)
options(width=10000)

# file_path, which contains system and topic scores
# system_subset contains the set of system names that you 
# want to see credible intervals + mean on
compute_bayesian_model <- function(file_path) {
    # Original settings
    #chains <- 12
    #cores <- 2
    #iter <- 12000
    #adapt_delta <- 0.9999

    chains <- 2
    cores <- 2
    iter <- 2000
    adapt_delta <- 0.9
    model <- .run_mcmc(file_path, chains, cores, iter, adapt_delta)
    .sanity_checks(model)
    return(model)
}

compute_system_cis <- function(modelfit, system_subset) {
    # compute 95% intervals
    table <- round(as.data.frame(summary(modelfit, digits=3, 
                                         prob=c(.025, .5, .975))), 3)
    table$names <- rownames(table)

    # remove metadata around system values
    allsystems <- table %>% filter(str_detect(names, " system"))
    allsystems <- 
        allsystems %>% mutate(names = 
                              str_replace(names, 
                                          "b\\[\\(Intercept\\) system:", ""))
    allsystems <- allsystems %>% mutate(names = str_replace(names, "_", " "))
    allsystems <- allsystems %>% mutate(names = str_replace(names, "]", ""))

    # subset only the systems we care about
    subsetsystems <- 
        allsystems[allsystems$names %in% system_subset,] %>% select("names", 
                                                                    "2.5%", 
                                                                    "mean", 
                                                                    "97.5%")
    return(subsetsystems)
}

.run_mcmc <- function(file_path, chains, cores, iter, adapt_delta) {
    d <- read.csv(file_path, header=T)

    rgen <- stan_glmer(score ~ (1 | topic) + (1 | system), data=d,
        chains=chains, cores=cores, seed=12345, iter=iter, family=gaussian,
        adapt_delta=adapt_delta, refresh=0)

    return(rgen)
}

.sanity_checks <- function(model) {
    check_dt <- as.data.frame(diagnostic_posterior(model, effects="all"))
    .system_ess_and_rhat_check(check_dt)
    .topic_ess_and_rhat_check(check_dt)
}
