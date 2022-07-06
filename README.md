# A Short Tutorial on Tensor Decompositions and Multi-Trial Neural Data

[Alex H. Williams](http://alexhwilliams.info)

This is a short and self-contained example that illustrates how to fit [canonical polyadic (CP) tensor decompositions](https://en.wikipedia.org/wiki/Tensor_rank_decomposition) to multi-trial neural data.

### Background

A very common and generic experimental design in neuroscience is to record the activity of many neurons across repeated behavioral trials. Let's say we record the activity of `N` neurons at `T` time points in each trial, and that there are `K` total trials. A natural way to represent this data is a three-dimensional data array with size `N x T x K`. Higher-order (more than two dimensions) arrays like this are called *tensors*.

We would like to find a compact and interpretable description of this multi-trial dataset. This is called *dimensionality reduction*, and involves reducing the size of the data (which can easily involve hundreds of neurons, and hundreds of trials given current experimental technologies) to a handful of latent *factors* (the term *latent* means we don't get to observe the factors directly, instead we must infer them from the raw dataset). Principal Components Analysis (PCA) is a classic technique for dimensionality reduction ([*click here for a shameless plug*](http://alexhwilliams.info/itsneuronalblog/2016/03/27/pca/)).

CP decomposition extends PCA to higher-order tensors. In fact, PCA ***is*** CP decomposition on a matrix (a matrix is equivalent to a second-order tensor). As described above, multi-trial data is naturally represented as a third-order tensor. Applying CP decomposition to this tensor produces low-dimensional factors for within-trial as well as across-trial changes in neural activity, which we can then interpret.

CP decomposition is an attractive technique both because it is conceptually simple (each trial is modeled as a linear combination of latent factors) and because it has some subtle advantages (the optimal model is unique, whereas the factors identified by PCA can be rotated arbitrarily without affecting reconstruction error).

#### More background reading

* [Bader & Kolda (2009). Tensor Decompositions and Applications. *SIAM Review*.](http://www.sandia.gov/~tgkolda/pubs/pubfiles/TensorReview.pdf)

### Contents

* See [`/matlab`](/matlab) for a tutorial on fitting tensor decompositions with Sandia's [TensorToolbox](https://tensortoolbox.org/)
* [TensorLab](http://www.tensorlab.net/) is another useful toolbox for MATLAB users.
* For Python code, see [`tensortools`](https://github.com/ahwillia/tensortools) (a small library I made) and [`tensorly`](http://tensorly.org/stable/index.html) (a larger library with slightly different goals/focus).

### Contact

Please [get in touch](mailto:alex.h.willia@gmail.com?Subject=Tensor%20demo) if you have any questions/comments.
