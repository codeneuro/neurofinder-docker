# Neurofinder Docker image

This repo contains the Dockerfile and example notebooks for the environment used in the [Neurofinder](http://neurofinder.codeneuro.org) challenge. The environment includes scientific Python, Spark, Thunder, and the IPython notebook.

This is mainly provided as a reference image.

If you want to explore this environment interactively, we recommend using our [notebook](http://notebooks.codeneuro.org) service.

If you want to do local algorithm development, we recommend setting up a local Python environment with [Anaconda](https://store.continuum.io/cshop/anaconda/).

## Running

To run this image, if you are new to Docker, follow these instructions to get set up on (on OS X):

- Download and install [boot2docker](https://github.com/boot2docker/osx-installer/releases/tag/v1.7.1)

- Launch the `boot2docker` application from your `Applications` folder

- Type `docker run -i -t -p 8888:8888 codeneuro/neurofinder`

- Point a web browser to http://192.168.59.103:8888/
