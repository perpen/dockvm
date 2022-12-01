FROM archlinux
RUN pacman -Syu --noconfirm \
    && pacman -S --noconfirm \
        sudo vim base-devel xmlto kmod inetutils bc libelf git cpio perl tar xz make flex bison
RUN mkdir /usr/src/linux \
    && curl -s https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.0.10.tar.xz \
    | tar xJf - -C /usr/src/linux --strip-components=1
COPY kernel-6.0.10.config /usr/src/linux/.config
RUN cd /usr/src/linux \
    && make -j$(nproc) \
    && make -j$(nproc) bzImage \
    && make -j $(nproc) modules \
    && make -j $(nproc) modules_install \
    && mv arch/x86/boot/bzImage /boot
RUN echo -e 'secret\nsecret' | passwd \
    && ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime
