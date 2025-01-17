module FastAI


using Base: NamedTuple
using Reexport
@reexport using FluxTraining
@reexport using DataLoaders
@reexport using Flux

using Animations
import DataAugmentation
import DataAugmentation: getbounds, Bounds

import LearnBase
using FilePathsBase
using Flux
using Flux.Optimise
import Flux.Optimise: apply!, Optimiser, WeightDecay
using FluxTraining: Learner, handle
using FluxTraining.Events
using JLD2: jldsave, jldopen
using Markdown
using MLDataPattern
using PrettyTables
using Requires
using StaticArrays
using Setfield
using ShowCases
using Tables
import Test
import UnicodePlots
using Statistics
using InlineTest


# ## Learning task API (previously DLPipelines.jl)
include("tasks/task.jl")
include("tasks/taskdata.jl")
include("tasks/predict.jl")
include("tasks/check.jl")

# ## Data block API
include("datablock/block.jl")
include("datablock/encoding.jl")
include("datablock/task.jl")
include("datablock/describe.jl")
include("datablock/wrappers.jl")


# ## Blocks
# ### Wrapper blocks
include("blocks/many.jl")

# ### Other
include("blocks/continuous.jl")
include("blocks/label.jl")

# ## Encodings
# ### Wrapper encodings
include("encodings/only.jl")

# ### Other
include("encodings/onehot.jl")


# Training interface
include("datablock/models.jl")
include("datablock/loss.jl")


# Interpretation
include("interpretation/backend.jl")
include("interpretation/text.jl")
include("interpretation/task.jl")
include("interpretation/showinterpretable.jl")
include("interpretation/learner.jl")
include("interpretation/detect.jl")


# Training
include("learner.jl")
include("training/paramgroups.jl")
include("training/discriminativelrs.jl")
include("training/utils.jl")
include("training/onecycle.jl")
include("training/finetune.jl")
include("training/lrfind.jl")
include("training/metrics.jl")

include("serialization.jl")



# submodules
include("datasets/Datasets.jl")
@reexport using .Datasets


include("fasterai/taskregistry.jl")
include("fasterai/defaults.jl")



# Domain-specific
include("Vision/Vision.jl")
@reexport using .Vision
export Image
export Vision

include("Tabular/Tabular.jl")
@reexport using .Tabular

include("Text/Text.jl")
@reexport using .Text

include("deprecations.jl")
export
    methodmodel,
    methoddataset,
    methoddataloaders,
    methodlossfn,
    BlockMethod,
    describemethod,
    findlearningmethods,
    methodlearner,
    savemethodmodel,
    loadmethodmodel


include("interpretation/makie/stub.jl")
function __init__()
    @require Makie="ee78f7c6-11fb-53f2-987a-cfe4a2b5a57a" begin
        using .Makie
        include("interpretation/makie/showmakie.jl")
        include("interpretation/makie/lrfind.jl")
    end
end

module Models
    using ..FastAI.Tabular: TabularModel
    using ..FastAI.Vision.Models: xresnet18, xresnet50, UNetDynamic
end


export
    # submodules
    Datasets,
    Models,
    datasetpath,
    mapobs,
    groupobs,
    filterobs,
    shuffleobs,
    datasubset,

    # task API
    taskmodel,
    taskdataset,
    taskdataloaders,
    tasklossfn,
    getobs,
    nobs,
    encodesample,
    predict,
    predictbatch,
    Training,
    Validation,
    Inference,

    # blocks
    Label,
    LabelMulti,
    Many,
    TableRow,
    TextRow,
    Continuous,
    Image,

    # encodings
    encode,
    decode,
    setup,
    OneHot,
    Only,
    Named,
    augs_projection, augs_lighting,
    TabularPreprocessing,

    SupervisedTask,
    BlockTask,
    describetask,
    checkblock,
    makebatch,
    getbatch,

    # interpretation
    ShowText,
    ShowMakie,
    showblock,
    showblocks,
    showsample,
    showsamples,
    showoutput,
    showoutputs,
    showoutputbatch,
    showencodedsample,
    showencodedsamples,
    showbatch,
    showprediction,
    showpredictions,

    # learning tasks
    findlearningtasks,
    TabularClassificationSingle,
    TabularRegression,


    # training
    tasklearner,
    Learner,
    fit!,
    fitonecycle!,
    finetune!,
    lrfind,
    savetaskmodel,
    loadtaskmodel,
    accuracy_thresh,

    gpu,
    plot






end  # module
