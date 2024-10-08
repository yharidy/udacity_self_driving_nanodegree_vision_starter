# Instructions

## Requirements

* NVIDIA GPU with the latest driver installed
* docker / nvidia-docker

This build has been tested with Nvidia Drivers 470.256.02 and CUDA 11.4 on a Ubutun 20.04 machine.
Please update the base image if you plan on using older versions of CUDA.

## Build
Build the image with:
```
docker build -t udacity-self-driving-vision-proj -f Dockerfile .
```

Create a container with:
```
docker run --gpus all -v <PATH TO LOCAL PROJECT FOLDER>:/app/project/ --network=host -ti udacity-self-driving-vision-proj bash
```
and any other flag you find useful to your system (eg, `--shm-size`).

Alternatively, you can build and start a devcontainer in VS Code using the Remote Explorer extension and the devcontainer.json file.

## Set up

Once in container, you will need to auth using:
```
gcloud auth login
```

## Debug
* Follow this [tutorial](https://tensorflow-object-detection-api-tutorial.readthedocs.io/en/latest/install.html#tensorflow-object-detection-api-installation) if you run into any issue with the installation of the
tf object detection api

## Updating the instructions
Feel free to submit PRs or issues should you see a scope for improvement.
