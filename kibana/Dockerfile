FROM docker.elastic.co/kibana/kibana:5.5.1
RUN bin/kibana-plugin remove x-pack && \
    kibana 2>&1 | grep -m 1 "Optimization of .* complete"
COPY config/kibana.yml /usr/share/kibana/config/kibana.yml
