using TextGrid, DelimitedFiles

# inputs
parentFolder = raw"C:\Users\hemad\.julia\dev\TextGrid\src\audio\A005_A006"
speakerOrder = 1
transcription = parentFolder*"\\S$speakerOrder"*"\\transcription.txt"
TextGridFile = parentFolder*parentFolder[findlast('\\', parentFolder):end]*".TextGrid"
itemNum = 10

# save new TextGrid file in TextGridFile's location
output = TextGridFile[begin:findlast(".", TextGridFile)[1]-1]*"S$speakerOrder"*"_copy.TextGrid"
interval = extract(TextGridFile)
speakerOrder==1 ? S_info = interval[1] : S_info = interval[5]
words = readdlm(transcription) # store results from speech-to-text
allWords = [] # create empty vector to insert all words in

# vector of vectors (1 vector for each word): [start, end, "word"]
cnt = 0
for i in 1:length(S_info)
    if S_info[i][3] == "S$speakerOrder" # check if speaker interval contains "S1" or "S2"
                                        # if not, it is empty interval (skip)
        # println("S$speakerOrder: ",S_info[i])
        cnt += 1
        start = round( S_info[i][1], digits=3)
        ends = round( S_info[i][2], digits=3)
        # println("word # = ", words[cnt,:][2]," starts at ", start, " ends at ",ends)
        for n in 1:words[cnt,:][2] # for each word in the current interval
            s = round( start + words[cnt+n,:][2] / 10^7, digits=3)
            e = round( s + words[cnt+n,:][3] / 10^7, digits = 3)
            # println(words[cnt+n,:][1], " ", s, " : ", e)
            append!(allWords,[ [s,e,words[cnt+n,:][1]] ])
        end
        cnt += words[cnt,:][2] # go to next interval
    end
end

# insert empty intervals to allow manually editing TextGrid
insert!(allWords,1, [0, allWords[1][1], ""]) # insert "" to first word interval
temp = copy( allWords )
for i in length(temp):-1:2
    temp[i][1] !== temp[i-1][2] ? insert!(allWords,i, [allWords[i-1][2], allWords[i][1], ""]) : nothing
end
insert!(allWords,length(allWords)+1, [allWords[end][2], interval[speakerOrder][end][2], ""]) # insert "" to last word interval


# set item info
class = "IntervalTier"
name = "Words S"*string(speakerOrder)
size1 = length(allWords)
xmin = allWords[1][1]
xmax = allWords[end][2]

# open transcription to read
f = open(transcription, "r")

open(output, "w") do file
    # add annotaiton information
    write(file, " "^4*"item ["*string(itemNum)*"]:\n")
    write(file, " "^8*"class = \""*class*"\" \n")
    write(file, " "^8*"name = \""*name*"\" \n")
    write(file, " "^8*"xmin = "*string(xmin)*" \n")
    write(file, " "^8*"xmax = "*string(xmax)*" \n")
    write(file, " "^8*"intervals: size = "*string(size1)*" \n")
    for n in 1:length(allWords) # each speaker segment
        write(file, " "^8*"intervals ["*string(n)*"]:\n") #interval[""]
        write(file, " "^12*"xmin = "*string(allWords[n][1])*" \n") #xmin = ""
        write(file, " "^12*"xmax = "*string(allWords[n][2])*" \n") #xmax = ""
        write(file, " "^12*"text = \""*string(allWords[n][3])*"\" \n") #text = ""
    end
end



TextGrid.fillWords(S_info, words, speakerOrder, interval[1][end][2])
