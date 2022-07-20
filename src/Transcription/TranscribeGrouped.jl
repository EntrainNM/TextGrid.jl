# Steps to transcribe audio files, assumed paired auido and TextGrid files are placed
# on one folder each
using TextGrid, DelimitedFiles


# 1- segment speakers into chunks
cd(raw"C:\Users\hemad\Desktop\Master\Original_Data\children_transcribed")
files = readdir(join=true)
# for i in 1:length(files)
#     parentFolder = files[i]# where to store the chunks
#
#     for n in [1,2]
#         audiofile = parentFolder*parentFolder[findlast('\\', parentFolder):end]*".wav" # path Wav file
#         TextGridFile = parentFolder*parentFolder[findlast('\\', parentFolder):end]*".TextGrid" # path to TextGrid file
#         speakerOrder=n
#         try
#             chunks(audiofile, TextGridFile, parentFolder, speakerOrder)
#         catch # in case TextGrid file needs to be fixed (remove '\n' charachter)
#             fix(TextGridFile)
#             chunks(audiofile, TextGridFile, parentFolder, speakerOrder)
#         end
#     end
# end

# step 2, 3, 4, and 5
for i in 1:length(files)
    parentFolder = files[i]
    try
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
    catch
        print("skipped $i")
    end
end



# copy .wav and new .TextGrid to new directory
cd(raw"C:\Users\hemad\Desktop\Flash_Temp\audios\CASD_CNT_Completed")

files = readdir(join=true)

for i in 1:length(files)
    parentFolder = files[i]
    fileName = parentFolder[findlast('\\', parentFolder):end]

    TextGridFile = parentFolder
    wavFile = parentFolder*fileName*".wav"

    println("moving file #", i, ": ",TextGridFile)

    println(fileName)
    # mkdir(destination*fileName)
    # cp(TextGridFile, destination*fileName*fileName*".TextGrid")
    # cp(wavFile, destination*fileName*fileName*".wav")
end


#
# copy .wav and new .TextGrid to new directory, collected versin
destination = raw"C:\Users\hemad\Desktop\Master\Original_Data\CHLD_Finished"

for i in 1:length(files)
    parentFolder = files[i]
    fileName = parentFolder[findlast('\\', parentFolder):end]

    TextGridFile = parentFolder*fileName*"_Transcribed.TextGrid"
    wavFile = parentFolder*fileName*".wav"

    mkdir(destination*fileName)
    cp(TextGridFile, destination*fileName*fileName*".TextGrid")
    cp(wavFile, destination*fileName*fileName*".wav")
end
