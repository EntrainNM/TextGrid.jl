using TextGrid

"""
fix() - remove the '\n' charachter inserted randomly on the TextGrid file.

Inputs:
TextGridFile - Full path to the TextGrid file to remove the '\n'
                charachter that cause error when calling extract(TextGridFile)

Example:
fix(TextGridFile)

"""
function fix(TextGridFile)

    text = readlines(TextGridFile)
    remove = [] # array to store line# to remove
    for n in 1:length(text)
        if (n>15)
            if (text[n][1] != ' ')
                println(text[n])
                text[n-1] = text[n-1]*text[n]
                append!( remove, n )
            end
        end
    end

    print(remove," lines will be removed")
    deleteat!(text,remove)

    open(TextGridFile, "w") do f
        for lines in text
            write(f, lines*"\n")
        end
    end
end
