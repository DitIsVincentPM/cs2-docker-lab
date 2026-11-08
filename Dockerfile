FROM docker:29-dind
RUN apk add --no-cache bash vim nano curl jq tree less python3 ttyd caddy
ENV PATH="/opt/cs2/bin:${PATH}" DOCKER_TLS_CERTDIR=""
COPY opt /opt/cs2
COPY seed /opt/cs2/seed
RUN chmod +x /opt/cs2/bin/* /opt/cs2/start.sh && ln -s /opt/cs2/bin/* /usr/local/bin/ \
 && printf '%s\n' 'cd /work/oefeningen 2>/dev/null' 'PS1="\[\e[1;36m\]cs2lab\[\e[0m\]:\w\$ "' 'alias ll="ls -la"' > /root/.bashrc
WORKDIR /work
ENTRYPOINT ["/opt/cs2/start.sh"]
