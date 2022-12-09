Playing with different ways of running a kvm against a docker image.


Problem: no good tooling for packaging/distributing VM disk images. OTHO we have OCI images, easy to build and distribute efficiently; plus during development they can be run on devs laptops using just docker.

Experiments:
1. Run vm from a local dir served by virtiofsd (to test the basic virtiofs setup)
2. Run vm directly from a docker image, by running virtiofsd in a container
3. Run vm on a standard disk image created from a docker image

Re. virtiofs, see https://virtio-fs.gitlab.io. 9p is too slow.

## VM files

To run a big fat VM we need files not necessarily packaged with standard distro containers.

Here I use the standard archlinux docker image, which seems to contain everything, including systemd. If using a different distro it may be necessary to install extra packages in the container.

## Boot

Since we do not have a disk with a bootloader, we boot the kvm directly from a kernel image. I am using a custom kernel with FUSE and virtiofs linked in, see `Dockerfile.kernel`.

## Thoughts
- Experiment #3 wins re. ease of management (capping of disk usage, no need for running virtiofsd). Uses more storage as no more sharing of layers, don't care (could use qcow2 backing images, ott). The disk image could be created just before starting the VM, possibly with some caching.
- If not using a disk image: we run the risk of having the VM fill an fs on the host. We'd need a way to monitor/cap disk usage.
- Test performance virtiofs vs image.
- Files persistence difference?

# Experiments

## #1 Boot from local dir

```
# make a dir with all OS files
$ ./dev virtiofsd-dir
# in new terminal, start vm
$ ./dev run-virtiofs
```

## #2 Boot from docker image

Right now the container running virtiofsd is privileged (we could use specific caps), with unconfined seccomp. This is secure since it is not possible to run any other command in this container.

```
# serve files
$ ./dev virtiofsd-container
# in new terminal, start vm
$ ./dev run-virtiofs
```

## #3 Boot from raw image made from container image

Calling qemu directly:
```
$ ./dev run-image
```
Or using libvirt:
```
$ ./dev run-image-libvirt
```

## Local testing with container running systemd

```
$ ./dev run-container
```
