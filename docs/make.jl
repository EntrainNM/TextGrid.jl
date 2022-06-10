using Documenter
using TextGrid

makedocs(
    sitename = "TextGrid",
    format = Documenter.HTML(),
    modules = [TextGrid]
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
deploydocs(
    repo = "github.com/EntrainNM/TextGrid.jl"
)
