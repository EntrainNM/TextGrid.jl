module TextGrid

include("./extractor.jl")
export extract, speaker, wordSegments

include("./Transcription/insertorTranscription.jl")
export insertTranscription

include("audio/chunks.jl")
export chunks

include("audio/fixTextGrid.jl")
export fix

end
