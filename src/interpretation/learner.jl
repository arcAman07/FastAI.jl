
"""
    showoutputs(task, learner[; n = 4, context = Validation()])

Run a trained model in `learner` on `n` samples and visualize the
outputs.
"""
function showoutputs(task::AbstractBlockTask, learner::Learner; n=4, context=Validation(), backend = default_showbackend())
    cb = FluxTraining.getcallback(learner, ToDevice)
    devicefn = isnothing(cb) ? identity : cb.movedatafn
    backfn = isnothing(cb) ? identity : cpu

    xs, ys = getbatch(learner; n = n, context = Validation())
    ŷs = learner.model(devicefn(xs)) |> backfn
    return showoutputbatch(backend, task, (xs, ys), ŷs)
end
