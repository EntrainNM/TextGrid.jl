# Steps to transcribe audio files
using TextGrid, DelimitedFiles

# for individaul files

# 1- segment speakers into chunks
parentFolder = raw"C:\Users\hemad\.julia\dev\TextGrid\src\audio\A005_A006"
audiofile = parentFolder*parentFolder[findlast('\\', parentFolder):end]*".wav" # path Wav file
TextGridFile = parentFolder*parentFolder[findlast('\\', parentFolder):end]*".TextGrid" # path to TextGrid file
chunks(audiofile, TextGridFile, parentFolder, 1)
chunks(audiofile, TextGridFile, parentFolder, 2)

# 2- use python to transcribe audio and save it in the correct format

# 3- insert transcription (S1 and S2) into original TextGrid file
# parentFolder = raw"C:\Users\hemad\Desktop\Master\Azure\Transcriptions\AdultAnnotated\A028_Sarah"
for (speakerOrder,itemNum) in zip((1,2),(10,11))
    transcription = parentFolder*"\\S$speakerOrder"*"\\transcription.txt"
    TextGridFile = parentFolder*parentFolder[findlast('\\', parentFolder):end]*".TextGrid"
    insertTranscription(TextGridFile, transcription, speakerOrder, itemNum)
end

# 4- combied the 2 TextGrid items (item 10 and 11) with the original TextGrid
originalTG = parentFolder*parentFolder[findlast('\\', parentFolder):end]*".TextGrid"
dest = parentFolder*parentFolder[findlast('\\', parentFolder):end]*"_TEMP.TextGrid" # create new TextGrid file

# find TextGrid files
S1Transciption = parentFolder*parentFolder[findlast('\\', parentFolder):end]*"S1_copy.TextGrid"
S2Transciption = parentFolder*parentFolder[findlast('\\', parentFolder):end]*"S2_copy.TextGrid"

# write everthing to the new TextGrid file
first = read(originalTG, String)
second = read(S1Transciption, String)
third = read(S2Transciption, String)
write(dest, first*second*third)


# 5 - replace "size = 9" with "size = 11"
output = parentFolder*parentFolder[findlast('\\', parentFolder):end]*"_Transcribed.TextGrid"
temp = readlines(dest)
temp[7] = "size = 11"
open(output, "w") do file
    for l in temp
        write(file, l*"\n")
    end
end
