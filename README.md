# TextGrid

[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://entrainnm.github.io/TextGrid.jl/dev/)


## Installation

### Users
1) Download [Julia v1.6.4](https://julialang.org/downloads/#long_term_support_release) or later, if you haven't already.
1) Add the TextGrid module entering the following at the REPL `]add https://github.com/EntrainNM/TextGrid.jl` (remove the ".jl" charachter from the folder name).

### Student Developers
1) Clone the TextGrid module to `username/.julia/dev/`.
2) Enter the package manager in REPL by pressing `]`  then add the package by typing `dev TextGrid` rather than `add TextGrid`.

## [Documentation](https://entrainnm.github.io/TextGrid.jl/dev/)



# Utility Functions

## Unit Step Function

We include a **unit step function** `u(t)` defined as

$\mathrm{u}(t) = \begin{cases}
        1, &   t \geq 0 \\
        0, &   t < 0       
        \end{cases}.$

## Unnormalized Gaussian Function

We include an unnormalized **Gaussian function** denoted `𝒩ᵤ(x; μ, σ)` parameterized by mean `μ` and standard deviation `σ` defined as


$\mathcal{N}_\mathrm{u}(x;\mu,\sigma) = \exp\left(-\frac{1}{2}\left(\frac{x-\mu}{\sigma}\right)^2\right).$
