# Use the official LiteLLM image as a base
FROM ghcr.io/berriai/litellm:main-stable

# Install the optional 'caching' dependencies, which includes 'diskcache'
RUN pip install "litellm[caching]"

# Set the entrypoint to run litellm with your config file
ENTRYPOINT ["litellm", "--config", "/app/config.yaml"]
