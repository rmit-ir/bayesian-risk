# This file contains sanity checks that are used after computing the
# model using the method compute_bayesian_model.
# If there are issues with the model, an error is thrown so that you
# do not accidentally use it.

.system_ess_and_rhat_check <- function(check_dt) {
    # Find only system values
    allsystems <- check_dt %>% filter(str_detect(Parameter, " system"))
    
    ess_check <- all(allsystems$ESS > 10000)
    if (!ess_check) {
        stop("The effective sample size (ESS) of a system in the model produced
             is not large enough (10000 needed) to support 95% credible 
             intervals (95% being the canonical accepted tolerance in IR, and 
             what is generated using this tool). Please increase the iterations 
             per chain, number of chains, or both. SIGIR study had 
             12 chains * 12000 iterations = 144,000 independent samples.")
    }

    # Rhat check inspired by bayestestR vignette
    # https://easystats.github.io/bayestestR/reference/diagnostic_posterior.html
    rhat_check <- all(allsystems$Rhat < 1.01)
    if (!rhat_check) {
        stop("Rhat system diagnostic failed. Perhaps you need a larger warmup,
             or the model you are using is too complicated wrt. the prior
             selected or the random effects specified.")
    }
}

.topic_ess_and_rhat_check <- function(check_dt) {
    # Find only topic values
    alltopics <- check_dt %>% filter(str_detect(Parameter, " topic"))

    ess_check_1 <- all(alltopics$ESS > 1000)
    if (!ess_check_1) {
        stop("The effective sample size (ESS) of a topic in the model produced
             is not large enough to be stable. Please increase the iterations 
             per chain, number of chains, or both. SIGIR study had 
             12 chains * 12000 iterations = 144,000 independent samples.")
    }

    
    ess_check_2 <- all(alltopics$ESS > 10000)
    if (!ess_check_2) {
        warning("The effective sample size (ESS) of a topic in the model produced
             is not large enough (10000 needed) to support 95% credible 
             intervals (95% being the canonical accepted tolerance in IR, and 
             what is generated using this tool). This is not as bad as systems
             however, as less often you need statistical confidence that a 
             topic is easier or harder. If that is your goal however, please 
             increase the iterations per chain, number of chains, or both. 
             SIGIR study had 12 chains * 12000 iterations = 144,000 
             independent samples.")
    }

    # Rhat check inspired by bayestestR vignette
    # https://easystats.github.io/bayestestR/reference/diagnostic_posterior.html
    rhat_check <- all(alltopics$Rhat < 1.01)
    if (!rhat_check) {
        stop("Rhat topic diagnostic failed. Perhaps you need a larger warmup,
             or the model you are using is too complicated wrt. the prior
             selected or the random effects specified.")
    }
}
