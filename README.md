# Full Bayesian Inference for Hidden Markov Models

[![Travis build status](https://travis-ci.org/luisdamiano/BayesHMM.svg?branch=master)](https://travis-ci.org/luisdamiano/BayesHMM)

We create an R Package to run full Bayesian inference on Hidden Markov Models (HMM) using the probabilistic programming language Stan. By providing an intuitive, expressive yet flexible input interface, we enable non-technical users to carry out research using the Bayesian workflow. We provide the user with an expressive interface to mix and match a wide array of options for the observation and latent models, including ample choices of densities, priors, and link functions whenever covariates are present. The software enables users to fit HMM with time-homogeneous transitions as well as time-varying transition probabilities. Priors can be set for every model parameter. Implemented inference algorithms include forward (filtering), forward-backwards (smoothing), Viterbi (most likely hidden path), prior predictive sampling, and posterior predictive sampling. Graphs, tables and other convenience methods for convergence diagnosis, goodness of fit, and data analysis are provided.

[Google Summer of Code 2018](https://summerofcode.withgoogle.com/projects/#4681157036212224)

### Install

```
devtools::install_github("luisdamiano/BayesHMM")
```

### Prerequisites
  * R (>= 3.4.0)
  
### Examples

See the [vignette](https://luisdamiano.github.io/BayesHMM/articles/introduction.html), which may not reflect the latest changes in the current version. Note that you may also find examples in [inst/examples](inst/examples), but these may not work with the last version in the repository.
  
## Contributing

Reach out to us at [#r-finance](http://webchat.freenode.net/?channels=r-finance) (freenode.net).

## Authors

* **Luis Damiano** - *Creator, author, maintainer* - [luisdamiano](https://github.com/luisdamiano)
* **Brian Peterson** - *Author* - [braverock](https://github.com/braverock)
* **Michael Weylandt** - *Author* - [michaelweylandt](https://github.com/michaelweylandt)

## License
GPL (>=3)

## Acknowledgments

* The Google Summer Of Code (GSOC) program for funding.
* The members of the Stan Development Team.
