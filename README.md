# How to set up a build environment for the modem

Want to build binaries that you can run on your Quectel RM520? Here you go!

<a href="https://www.buymeacoffee.com/natecarlson" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/default-orange.png" alt="Buy Me A Coffee" height="41" width="174"></a>

## Running Docker image

I've tried many ways to build binaries for the modem, and had all sorts of issues with cross-compilation/etc. I finally have a working setup.. using Ubuntu 20.04 ARMHL running in Docker with qemu emulating the ARM instructions. Here's how you do it, assuming your host OS is a recent version of Ubuntu (in my case, 22.04 running on WSL2.)

- Install Docker, as explained at [https://docs.docker.com/engine/install/ubuntu/](https://docs.docker.com/engine/install/ubuntu/)
- Install qemu-user-static and binfmt-support: `sudo apt install qemu-user-static binfmt-support`
- Register the qemu-user-static interpreters with Docker: `docker run --rm --privileged multiarch/qemu-user-static --reset -p yes`

Now, your Docker install should be set up to run arm binaries. You can either use the plain Ubuntu image and add what you need:

```bash
docker run --name rm520-modem-buildenv -it arm32v7/ubuntu:20.04
```

Or, you can use my pre-built image, which has the build dependencies already installed:

```bash
docker run --name rm520-modem-buildenv -it ghcr.io/natecarlson/rm520-modem-buildenv:main
```

Either image will dump you to a bash prompt; when you exit the container, the container will be stopped. You can restart it with `docker start rm520-modem-buildenv` and attach to it with `docker attach rm520-modem-buildenv`. If you want to remove it, use `docker rm rm520-modem-buildenv`.

If you want an additional shell on a running instance, you can use `docker exec -it rm520-modem-buildenv bash`.

## Compiling something

Let's say you would like to compile MicroPython for the modem. Here's how you do it, starting at the root prompt you get after starting the container.. (reference [git clone https://github.com/micropython/micropython](https://docs.micropython.org/en/latest/develop/gettingstarted.html); you can add `-j<NUMTHREADS>` to the make commands to parallel build.)

```bash
git clone https://github.com/micropython/micropython
cd micropython
make -C mpy-cross/ # Build the required compiler
cd ports/unix/ # Since the module runs on Linux, use the Unix port
make submodules # Pull in the necessary submodules
make # Actually build the code
```

The compilation should end with something like:

```bash
LINK build-standard/micropython
   text    data     bss     dec     hex filename
 414905   32168    6112  453185   6ea41 build-standard/micropython
```

At which point, you can scp the module to a system that is connected to the modem via adb. (I use a Raspberry Pi 4 running Ubuntu 22.04, which is connected to the modem via USB.) If that's not an option for you, when running the docker image, you can map a local directory to _somewhere_ on the container, and then you'll be able to access the file locally; let's say you want to mount the local directory 'rm520-build' as /root/build on the container, and start in that directory. You will need to either specify the relative or absolute path to rm520-build, like `-v /home/nc/tmp/rm520-build:/root/build` or `-v c:\Users\nc\tmp\rm520-build:/root/build` depending on your OS.

```bash
docker run -v /path/to/rm520-build:/root/build -w /root/build --name rm520-modem-buildenv -it ghcr.io/natecarlson/rm520-modem-buildenv:main
```
