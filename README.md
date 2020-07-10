This is repository for the 2020 SIGIR paper "Bayesian Inferential
Risk Evaluation On Multiple IR Systems".

Reproducible parts of the paper will be released in stages, as they are 
refactored out of system-specific bash/awk/R/python hacks from past papers
and workarounds for lacking root access on shared compute resources.

### Citation

If you use this code in a research setting, please consider citing the paper:

> Rodger Benham, Ben Carterette, J. Shane Culpepper, and Alistair Moffat. 2020.
Bayesian Inferential Risk Evaluation On Multiple IR Systems. In Proceedings of
the 43rd International ACM SIGIR Conference on Research and Development in
Information Retrieval (SIGIR ’20), July 25--30, 2020, Virtual Event, China. ACM,
New York, NY, USA, 10 pages. https://doi.org/10.1145/3397271.3401033

## Current Progress

The part of our paper that is interesting to most researchers is the capacity
to draw inferences between a champion, set of challengers, and artefact systems.
We aim to release this part first as an MVP, and leave risk-adjusted score 
explorations to later stages.
More specifically, we look at reproducing Figure 4 in the SIGIR paper.

## Project Structure

The project structure closely follows the SIGIR 2019 [codebase](https://github.com/julian-urbano/sigir2019-statistical) 
for the paper "Statistical Significance Testing in Information Retrieval: 
An Empirical Analysis of Type I, Type II and Type III Errors" from @julian-urbano et. al.

* `./doit.sh` executes the simulation, edit this file based on your needs.
* `data/` contains input data files, like the system AP scores for all artefact, challenger and champion systems.
* `output/` contains generated output files.
* `R/` contains the source code in R.
* `scratch/` contains temporary files generated in the process.

## System-Specific Workarounds

This part of the readme is useful for those who do not have su access to 
install system libraries (for example, you are using the RMIT compute resources).

One issue was related to the absence of libssl headers being installed 
and not having root access to install it using the package manager. 
Since `brms` and `rstanarm` list `shinystan` as a dependency, and `shinystan`
uses `shiny` to build an interactive web-app for posterior predictive checks,
it wants these headers.
Although `shinystan` is an incredibly useful tool for ensuring the Markov chains
are converging, it was not useful on the shared compute resources as ports were 
not exposed on the server and I couldn't get the project to build without the
libssl headers (YMMV, however, I gave up). 
Instead, I tore out every call `rstanarm` and `brms` made in source to `shinystan`
to get the library to build on the servers.
To validate the model using `shinystan`, I serialised the R object to disk after
simulation, `scp`'d it to a local machine with the capacity to build and 
run `shinystan` and inspected there.
I will not be maintaining a fork of that code as these were very specific issues
related to having insufficient permissions to build the project.

Additionally, I had an issue on the RMIT servers which run Red Hat Linux, 
where Markov Chain Monte Carlo simulation was painfully slow and would take months to
complete simulations that would only take my MacBook hours.

You need to disable fast-math in your compiler flags in `~/.R/Makevars` and recompile
`brms` and/or `rstanarm` from source and install using `install.packages(folder_path, repos = NULL, type="source")`: 

```
CXX14 = g++ -std=c++1y -O3 -mtune=native -march=native -Wno-unused-variable -Wno-macro-redefined -fPIC -fno-fast-math -lcurl
CXXFLAGS = -O3 -mtune=native -march=native -Wno-unused-variable -Wno-macro-redefined -fno-fast-math
```
