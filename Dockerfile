FROM scratch
ARG ROOTFS
COPY ${ROOTFS}/ /
CMD ["/usr/bin/bash"]
