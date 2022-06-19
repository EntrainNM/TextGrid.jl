using TextGrid, WAV

"""
chunks - save segments of speaker (S1 or S2) as wav files to use in speech-to-text softwares
         to imporve accuracy and alignment

Inputs:
audiofile: path to the wav file
TextGridFile - Full path to the TextGrid file to extract segment location from
outLocation: path to save wav files to (where to store the chunks)
speakerOrder - The speaker (1 or 2) corresponding to the transcription.

Output:
no output, WAV chunks will be saved in outLocation directory

# Examples
```@example
# segment speaker 2 (audiofile is S2 in this case) audio to chunks and save them in outLocation
outLocation = raw"Path\\Example.TextGrid"
audiofile = raw"Path\\Example..wav"
TextGridFile = raw"Path\\Example.TextGrid"
speaker=2
chunks(audiofile, TextGridFile, outLocation, speaker)
```
# notes:
# 0.1S length is added to each segment to improve recognition accuracy
"""
function chunks(audiofile, TextGridFile, outLocation, speakerOrder)

    interval = extract(TextGridFile)
    sound, f = wavread(audiofile)

    # speaker 1 ==> interval[1]
    # speaker 2 ==> interval[5]
    speakerOrder == 1 ? speakerInterval = interval[1] : speakerInterval = interval[5]
    speakerString = string(speakerOrder)

    # save speaker information in array S
    S_temp = fill(-1.0, (length(speakerInterval), 2))
    for n in 1:length(speakerInterval)
        if "S"*speakerString in speakerInterval[n]
            S_temp[n,:] = speakerInterval[n][1:2]
        end
    end
    # filter non segmented intervals
    S = [S_temp[i,:] for i in 1:length(S_temp[:,1]) if S_temp[i,:] != [-1,-1.0]]
    # add 0.1s for each segment for Azure to recognize properly
    # temp = [[S[i][1]-0.2,S[i][2]+0.2] for i in 1:length(S)]
    temp = [[S[i][1],S[i][2]+0.1] for i in 1:length(S)]
    S = temp

    # save chunks
    for i in 1:length(S)
        S_audio = sound[seconds(S[i],f)] # split audio to each speaker interval
        # wavwrite(S_audio,location*"S\\S_$i.wav",Fs=f)
        try # save chunk to "S1" or "S2" if exist, if not, creat new folder
            wavwrite(S_audio, outLocation*"\\S$speakerString\\"*string(i)*".wav", Fs=f, nbits=16, compression=WAVE_FORMAT_PCM)
        catch e
            mkdir(outLocation*"\\S$speakerString")
            wavwrite(S_audio, outLocation*"\\S$speakerString\\"*string(i)*".wav", Fs=f, nbits=16, compression=WAVE_FORMAT_PCM)
        end
    end

    return nothing

end

"""
seconds - given one element of S array, return array of all samples within that element in seconds
"""
function seconds(S,f)
    trunc(Int64,S[1]*f):trunc(Int64,S[2]*f)
end

# outLocation = raw"C:\Users\hemad\Desktop\Master\Transcriptions\CASD_CNT_Completed\CASD005_07252018"# where to store the chunks
# audiofile = outLocation*outLocation[findlast('\\', outLocation):end]*".wav"
# TextGridFile = outLocation*outLocation[findlast('\\', outLocation):end]*".TextGrid"
# speaker=2
# chunks(audiofile, TextGridFile, outLocation, speaker)
#
# fix(TextGridFile)
