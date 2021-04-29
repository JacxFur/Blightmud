FROM gitpod/workspace-full

# Install custom tools, runtime, etc.
RUN sudo cargo build && sudo cargo run
