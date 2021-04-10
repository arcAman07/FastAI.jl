

"""
    ImageClassification(classes, sz[; augmentations, ...]) <: Method{ImageClassificationTask}

A learning method for single-label image classification:
given an image and a set of `classes`, determine which class the image
falls into. For example, decide if an image contains a dog or a cat.

Images are resized and cropped to `sz` (see [`ProjectiveTransforms`](#))
and preprocessed using [`ImagePreprocessing`](#). `classes` is a vector of the class labels.

## Reference

This learning method implements the following interfaces:

{.tight}
- Core interface
- Plotting interface
- Training interface
- Testing interface

### Types

{.tight}
- **`sample`**: `Tuple`/`NamedTuple` of
    - **`input`**`::AbstractArray{2, T}`: A 2-dimensional array with dimensions (height, width)
        and elements of a color or number type. `Matrix{RGB{Float32}}` is a 2D RGB image,
        while `Array{Float32, 3}` would be a 3D grayscale image. If element type is a number
        it should fall between `0` and `1`. It is recommended to use the `Gray` color type
        to represent grayscale images.
    - **`target`**: A class. Has to be an element in `method.classes`.
- **`x`**`::AbstractArray{Float32, 3}`: a normalized array with dimensions (height, width, color channels). See [`ImagePreprocessing`](#) for additional information.
- **`y`**`::AbstractVector{Float32}`: a one-hot encoded vector of length `length(method.classes)` with true class index  `1.` and all other entries `0`.
- **`y`**`::AbstractVector{Float32}`: vector of predicted class scores.

### Model sizes

Array sizes that compatible models must conform to.

- Full model: `(method.sz..., 3, batch) -> (length(method.classes), batch)`
- Backbone model: `(method.sz..., 3, batch) -> ((method.sz ./ f)..., ch, batch)` where `f`
    is a downscaling factor `f = 2^k`

It is recommended *not* to use [`Flux.softmax`](#) as the final layer for custom models;
instead use [`Flux.logitcrossentropy`](#) as the loss function for increased numerical
stability. This is done automatically if using with `methodmodel` and `methodlossfn`.
"""
mutable struct ImageClassification <: DLPipelines.LearningMethod{ImageClassificationTask}
    sz::Tuple{Int,Int}
    classes::AbstractVector
    projectivetransforms::ProjectiveTransforms
    imagepreprocessing::ImagePreprocessing
end

Base.show(io::IO, method::ImageClassification) = print(
    io, "ImageClassification() with $(length(method.classes)) classes")

function ImageClassification(
        classes::AbstractVector,
        sz=(224, 224);
        augmentations=Identity(),
        means=IMAGENET_MEANS,
        stds=IMAGENET_STDS,
        C=RGB{N0f8},
        T=Float32,
        buffered=false,
    )
    projectivetransforms = ProjectiveTransforms(sz, augmentations=augmentations, buffered=buffered)
    imagepreprocessing = ImagePreprocessing(means, stds; C=C, T=T)
    ImageClassification(sz, classes, projectivetransforms, imagepreprocessing)
end


# Core interface implementation

function DLPipelines.encodeinput(
        method::ImageClassification,
        context,
        image)
    imagecropped = run(method.projectivetransforms, context, image)
    x = run(method.imagepreprocessing, context, imagecropped)
    return x
end


function DLPipelines.encodetarget(
        method::ImageClassification,
        context,
        category)
    idx = findfirst(isequal(category), method.classes)
    isnothing(idx) && error("`category` could not be found in `method.classes`.")
    return DataAugmentation.onehot(idx, length(method.classes))
end


function DLPipelines.encodetarget!(
        y::AbstractVector{T},
        method::ImageClassification,
        context,
        category) where T
    fill!(y, zero(T))
    idx = findfirst(isequal(category), method.classes)
    y[idx] = one(T)
    return y
end

DLPipelines.decodeŷ(method::ImageClassification, context, ŷ) = method.classes[argmax(ŷ)]

# Interpretation interface

DLPipelines.interpretinput(::ImageClassification, image) = image

function DLPipelines.interpretx(method::ImageClassification, x)
    return invert(method.imagepreprocessing, x)
end


function DLPipelines.interprettarget(task::ImageClassification, class)
    return "Class $class"
end

# Plotting interface

function plotsample!(f, method::ImageClassification, sample)
    image, class = sample
    f[1, 1] = ax1 = imageaxis(f, title = class)
    plotimage!(ax1, image)
end

function plotxy!(f, method::ImageClassification, (x, y))
    image = invert(method.imagepreprocessing, x)
    i = argmax(y)
    ax1 = f[1, 1] = imageaxis(f, title = "$(method.classes[i]) ($(y[i]))", titlesize=12.)
    plotimage!(ax1, image)
end

# Training interface

function DLPipelines.methodmodel(method::ImageClassification, backbone)
    h, w, ch, b = Flux.outdims(backbone, (method.sz..., 3, 1))
    return Chain(
        backbone,
        Chain(
            AdaptiveMeanPool((1, 1)),
            flatten,
            Dense(ch, length(method.classes)),
        )
    )
end

DLPipelines.methodlossfn(::ImageClassification) = Flux.Losses.logitcrossentropy

# Testing interface

function DLPipelines.mockinput(method::ImageClassification)
    inputsz = rand.(UnitRange.(method.sz, method.sz .* 2))
    return rand(RGB{N0f8}, inputsz)
end


function DLPipelines.mocktarget(method::ImageClassification)
    rand(1:length(method.classes))
end


function DLPipelines.mockmodel(method::ImageClassification)
    return xs -> rand(Float32, length(method.classes), size(xs)[end])
end