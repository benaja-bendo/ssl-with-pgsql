FROM postgres:latest

# Copy the scripts into the container
COPY generate_certs.sh /usr/local/bin/generate_certs.sh
COPY custom-entrypoint.sh /usr/local/bin/custom-entrypoint.sh

# Set permissions
RUN chmod +x /usr/local/bin/generate_certs.sh /usr/local/bin/custom-entrypoint.sh

# Switch to the 'postgres' user
USER postgres

# Set the entrypoint
ENTRYPOINT ["/usr/local/bin/custom-entrypoint.sh"]
CMD ["postgres"]
