Problem: no good tooling for packaging/distributing VM disk images. OTHO we have OCI images, easy to build and distribute efficiently; plus during development they can be run on devs laptops using just docker.

Here I will be experimenting with different ways of running a kvm against a docker image.

Experiments:
1. Run vm from a local dir served by virtiofsd (to test the basic setup)
2. Run vm directly from a docker image, by running virtiofsd in a container
3. Run vm on a standard disk image created from a docker image

Re. virtiofs, see https://virtio-fs.gitlab.io. 9p is too slow.

For both setups, we need all the OS files needed to run a VM (a big fat VM running systemd etc, my current requirement). For simplicity I'm sourcing these files from a standard archlinux docker image, which seems to contain everything, including systemd. If using a different distro it may be necessary to install extra packages in the container.

To bootstrap the VM however we can't have the kernel on the fs: we need to pass a kernel image to qemu. I am using a custom kernel with FUSE and virtiofs linked in, obv that wouldn't be needed when using a raw disk image.

Tested on archlinux.

### Thoughts
- Experiment #3 wins re. ease of management (capping of disk usage, no need for running virtiofsd). Uses more storage as no more sharing of layers, don't care (could use qcow2 backing images, ott). The disk image could be created just before starting the VM, possibly with some caching.
- If not using a disk image: we run the risk of having the VM fill an fs on the host. We'd need a way to monitor/cap disk usage.
- Right now the container running virtiofsd is privileged (we could use specific caps), with unconfined seccomp. This is secure since it is not possible to run any other command in this container.
- Test performance virtiofs vs image.
- Files persistence difference?
- PXE boot, wouldn't simplify much.

## #1 Boot from local dir

```
# make a dir with all OS files
$ ./dev make-dir
# serve files
$ ./dev virtiofsd-dir
# in new terminal, start vm
$ ./dev vm-virtiofs
```

## #2 Boot from docker image

```
# make a docker image with all OS files
$ ./dev make-container
# serve files
$ ./dev virtiofsd-container
# in new terminal, start vm
$ ./dev vm-virtiofs
```

## #3 Boot from raw image made from container image

```
# make a raw image from a docker image
$ ./dev make-image
# start vm
$ ./dev vm-image
```
