## DPoD-P11Tool

This Example builds the p11tool from Thales for simple cli testing and manipulation of a HSM device.  

To Accomplish that, the following artifacts are in here:

- [x] `docker/Dockerfile.dpod` that expects a DPoD Client Zip file to be extracted in the `clients` directory of this repo... you'll want to modify any paths to match yours.
- [x] `charts/dpod-p11tool` Helm Chart to Deploy the generated image
- [x] Skaffold.yaml entries for building and deploying of the Docker Image and URL


## Quick usage

If you want to do something funny