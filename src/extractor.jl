

"""
interval = extract(file)

Read tiers information of each labelled interval from a TextGrid file

Inputs:

    \t☆ file: full path to a TextGrid file

    \t☆ showinfo: optional

Output:

    \t☆ interval - matrix containing all TextGrid interval tiers

# Examples
```@example
using TextGrid
interval = extract(raw"full\\path\\file.TextGrid")
```

"""
function extract(input; showinfo=false)
    f = open(input, "r")
    #CHECK FILE TYPE
    readline(f)#line#1
    # occursin("ooTextFile", readline(f)) ? print("Successuflly opened ooTextFile\n") : print("File type NOT: \"ooTextFile\n")#line#1
    #CHECK OBJECT CLASS
    if !(readline(f) == "Object class = \"TextGrid\"")#line#2
     throw(UndefVarError(:NotTextGridFile))
    end
    readline(f)#SKIP BLANK LINE (line#3)
    #READ START TIME
    xmin = parse(Float64,readline(f)[8:end])#line#4
    #READ END TIME
    xmax = parse(Float64,readline(f)[8:end])#line#5
    #READ TIERS INFO
    tiers = occursin("tiers? <exists>", readline(f))#line#6
    tierSize = parse(Int64,readline(f)[8:end])#line#7
    #CREATE VECTOR VARIABLES
    class = Array{String}(undef, 1, tierSize)
    name = Array{String}(undef, 1, tierSize)
    xmin = Array{Float64}(undef, 1, tierSize)
    xmax = Array{Float64}(undef, 1, tierSize)
    intervalSize = Array{Int64}(undef, 1, tierSize)
    interval = Vector{Vector}(undef, tierSize)
    readline(f)#SKIP "item[]" (line#8)
    for i in 1:tierSize
        readline(f)#SKIP "item[i]" (line#9....)
        class[i] = readline(f)[18:end-2]

        show = "tier#"*string(i)*"\nname: " * readline(f)[17:end-2]*"\nxmin: " * readline(f)[15:end]*"\nxmax: " * readline(f)[15:end]

        showinfo ? println(show*"\n") : nothing

        if occursin("IntervalTier", class[i])
            intervalSize[i] = parse(Int64,readline(f)[26:end])#println("intervalSize: " * readline(f)[26:end])
        else
            intervalSize[i] = parse(Int64,readline(f)[23:end])
        end
        intervalLines = Vector{Any}(undef,intervalSize[i])

        for j in 1:intervalSize[i]
            readline(f)#SKIP "intervals [j]:" (line#15)
            if occursin("IntervalTier", class[i])
                intervalLines[j] = [parse(Float64,readline(f)[19:end]),
                                    parse(Float64,readline(f)[19:end]),
                                    readline(f)[21:end-2]]
            else
                intervalLines[j] = [parse(Float64,readline(f)[21:end]),
                                    readline(f)[21:end-2]]
            end
            #append!(interval,[readline(f)[19:end],readline(f)[19:end],readline(f)[21:end-2]])
            if(j == intervalSize[i])
                interval[i] = copy(intervalLines)
            end
        end
    end
    interval end


"""
Read speaker 1 or 2 annotaiton information in array

to eleminate human error, 0.2s added at the begining and end of each speaker segment
"""
function speaker(interval,i)
    if i == 1 # speaker #1
        text = interval[1]
    elseif i == 2 # speaker #2
        text = interval[5]
    else
        return error("Chose between speaker 1 or speaker 2")
    end
    temp = fill(-1.0, (length(text), 2))
    for n in 1:1:length(text)
        if "S"*string(i) in text[n]
            temp[n,:] = text[n][1:2]
        end
    end
    # filter non annotated intervals
    S = [temp[i,:] for i in 1:length(temp[:,1]) if temp[i,:] != [-1,-1.0]]
        # add 0.2s for each segment for Azure to recognize properly
        # temp = [[S[i][1]-0.2,S[i][2]+0.2] for i in 1:length(S)]
    temp = [[S[i][1]-0.2,S[i][2]+0.2] for i in 1:length(S)]
    return temp
end



"""
S1_words = segmentWords(interval, 1)

return array of information related to S1 or S2 depending on input.

returned array in the following formate:
[Speaker location, start, end, # of words, [word end timestamps], speaker # (1 or 2)]

"""
function wordSegments(interval, speaker)

    # speaker 1 or 2
    if speaker == 1
        SLocation = [("S$speaker" in interval[1][i]) for i in 1:length(interval[1])]
        speakerInterval = interval[1]
        wordInterval = interval[10]
    elseif speaker == 2
        SLocation = [("S$speaker" in interval[5][i]) for i in 1:length(interval[5])]
        wordInterval = interval[11]
        speakerInterval = interval[5]
    end

    timedWords = Vector{Vector{Any}}(undef,length(speakerInterval))
    # skip segment if shorter than:
    minSegment = 0.1
    for i in 1:length(SLocation)
        test = 0
        endStamp = []
        for n in 1:length(wordInterval)
            averageTime = (wordInterval[n][1] + wordInterval[n][2]) / 2
            #  (if word ends withing S1 ith segment)                                           & (segment is longer than 0.2 second)                  # word segment not empty
            # if ((speakerInterval[i][1]<wordInterval[n][2]) & (wordInterval[n][2]<speakerInterval[i][2])) & ((speakerInterval[i][2]-speakerInterval[i][1]) > minSegment) & !isempty(wordInterval[n][3])
            if ((speakerInterval[i][1]<averageTime) & (averageTime<speakerInterval[i][2])) & ((speakerInterval[i][2]-speakerInterval[i][1]) > minSegment) & !isempty(wordInterval[n][3]) & (wordInterval[n][3] != " ")
                test += 1
                append!( endStamp, wordInterval[n][2] )
            end
        end

        timedWords[i] = [i,speakerInterval[i][1],speakerInterval[i][2],test,endStamp,"S$speaker"]
    end

    return timedWords[SLocation]

end
