source("../compute_cis.R", chdir=TRUE)
library(testthat)

# Nondeterministic tests are generally a very bad idea.
# Since nothing is certain in statistics, the only "certainty" 
# we're really hoping to expect is that Chal.4 outperforms the Champion,
# and that model weights are irrelevant.

# NB: These tests are going to take a long time
# Possibly in the order of 3--4 hours.
# If any one of these tests is taking a very long time (more than say, 2hrs)
# You may need to recompile rstanarm with fast-math disabled.

do_sim <- function(data_file) {
    model <- compute_bayesian_model(data_file, TRUE)

    system_subset <- c("Champion", "Chal. 1", "Chal. 2", "Chal. 3", "Chal. 4")
    system_cis <- compute_system_cis(model, system_subset) 

    chal4_left_fence <- ((system_cis %>% filter(names == "Chal. 4"))$"2.5%") 
    champ_right_fence <- ((system_cis %>% filter(names == "Champion"))$"97.5%")

    return(c(chal4_left_fence, champ_right_fence))
}

test_that("robust04 systems", {
    result <- do_sim("../../data/rb04_data.csv") 
    expect_gt(result[1], result[2])
})

test_that("trec17 systems", {
    result <- do_sim("../../data/trec17_data.csv") 
    expect_gt(result[1], result[2])
})

test_that("trec18 systems", {
    result <- do_sim("../../data/trec18_data.csv") 
    expect_gt(result[1], result[2])
})
