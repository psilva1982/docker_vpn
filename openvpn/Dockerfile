FROM alpine:3.21

RUN apk add --no-cache openvpn iproute2 \
    && mkdir -p /etc/openvpn /var/lib/openvpn

# The supplied profile contains its PKI inline, so no certificate extraction is
# necessary.  Its Windows-only auth.bat accepts every credential; /bin/true
# preserves that test-only behavior when the server runs on Linux.
COPY artifacts/server.ovpn /etc/openvpn/server.conf
RUN sed -i 's|^auth-user-pass-verify auth\.bat via-file$|auth-user-pass-verify /bin/true via-file|' /etc/openvpn/server.conf

WORKDIR /var/lib/openvpn

EXPOSE 1194/udp

CMD ["openvpn", "--config", "/etc/openvpn/server.conf"]
