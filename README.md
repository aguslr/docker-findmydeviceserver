[aguslr/docker-findmydeviceserver][1]
=====================================

[![docker-pulls](https://img.shields.io/docker/pulls/aguslr/findmydeviceserver)](https://hub.docker.com/r/aguslr/findmydeviceserver) [![image-size](https://img.shields.io/docker/image-size/aguslr/findmydeviceserver/latest)](https://hub.docker.com/r/aguslr/findmydeviceserver)


This *Docker* image sets up *FindMyDeviceServer* inside a docker container.

> **[FindMyDeviceServer][2]** is a server  able to communicate with FMD and save
> the latest location encrypted on it.


Installation
------------

To use *docker-findmydeviceserver*, follow these steps:

1. Clone and start the container:

       docker run -p 8080:8080 -v "${PWD}"/data:/data \
         docker.io/aguslr/findmydeviceserver:latest

2. Register your device with your *FindMyDeviceServer*'s IP address on port
   `8080` using the [Android app][3].


Build locally
-------------

Instead of pulling the image from a remote repository, you can build it locally:

1. Clone the repository:

       git clone https://github.com/aguslr/docker-findmydeviceserver.git

2. Change into the newly created directory and use `docker-compose` to build and
   launch the container:

       cd docker-findmydeviceserver && docker-compose up --build -d


[1]: https://github.com/aguslr/docker-findmydeviceserver
[2]: https://gitlab.com/Nulide/findmydeviceserver
[3]: https://gitlab.com/Nulide/findmydevice
