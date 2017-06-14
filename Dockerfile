# Java baseimage, for Bazel.
FROM openjdk:8

ENV SYNTAXNETDIR=/opt/tensorflow PATH=$PATH:/root/bin

# Install system packages. This doesn't include everything the TensorFlow
# dockerfile specifies, so if anything goes awry, maybe install more packages
# from there. Also, running apt-get clean before further commands will make the
# Docker images smaller.
RUN mkdir -p $SYNTAXNETDIR \
    && cd $SYNTAXNETDIR \
    && apt-get update \
    && apt-get install -y \
          file \
          git \
          graphviz \
          libcurl3-dev \
          libfreetype6-dev \
          libgraphviz-dev \
          liblapack-dev \
          libopenblas-dev \
          libpng12-dev \
          libxft-dev \
          python-dev \
          python-mock \
          python-pip \
          python2.7 \
          swig \
          vim \
          zlib1g-dev \
    && apt-get clean \
    && (rm -f /var/cache/apt/archives/*.deb \
        /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true)

# Install common Python dependencies. Similar to above, remove caches
# afterwards to help keep Docker images smaller.
RUN pip install --ignore-installed pip \
    && python -m pip install numpy \
    && rm -rf /root/.cache/pip /tmp/pip*
RUN python -m pip install \
          asciitree \
          ipykernel \
          jupyter \
          matplotlib \
          pandas \
          protobuf \
          scipy \
          sklearn \
    && python -m ipykernel.kernelspec \
    && python -m pip install pygraphviz \
          --install-option="--include-path=/usr/include/graphviz" \
          --install-option="--library-path=/usr/lib/graphviz/" \
    && python -m jupyter_core.command nbextension enable \
          --py --sys-prefix widgetsnbextension \
    && rm -rf /root/.cache/pip /tmp/pip*

# Installs the latest version of Bazel.
RUN wget --quiet https://github.com/bazelbuild/bazel/releases/download/0.4.3/bazel-0.4.3-installer-linux-x86_64.sh \
    && chmod +x bazel-0.4.3-installer-linux-x86_64.sh \
    && ./bazel-0.4.3-installer-linux-x86_64.sh \
    && rm ./bazel-0.4.3-installer-linux-x86_64.sh

COPY models/syntaxnet/WORKSPACE $SYNTAXNETDIR/syntaxnet/WORKSPACE
COPY models/syntaxnet/tools/bazel.rc $SYNTAXNETDIR/syntaxnet/tools/bazel.rc
COPY models/syntaxnet/tensorflow $SYNTAXNETDIR/syntaxnet/tensorflow

# Compile common TensorFlow targets, which don't depend on DRAGNN / SyntaxNet
# source. This makes it more convenient to re-compile DRAGNN / SyntaxNet for
# development (though not as convenient as the docker-devel scripts).
RUN cd $SYNTAXNETDIR/syntaxnet/tensorflow \
    && tensorflow/tools/ci_build/builds/configured CPU \
    && cd $SYNTAXNETDIR/syntaxnet \
    && bazel build -c opt @org_tensorflow//tensorflow:tensorflow_py

# Build the codez.
WORKDIR $SYNTAXNETDIR/syntaxnet
COPY models/syntaxnet/dragnn $SYNTAXNETDIR/syntaxnet/dragnn
COPY models/syntaxnet/syntaxnet $SYNTAXNETDIR/syntaxnet/syntaxnet
COPY models/syntaxnet/third_party $SYNTAXNETDIR/syntaxnet/third_party
COPY models/syntaxnet/util/utf8 $SYNTAXNETDIR/syntaxnet/util/utf8
RUN bazel build -c opt //dragnn/python:all //dragnn/tools:all
RUN wget -q -O - http://download.tensorflow.org/models/parsey_universal/German.zip | tartar xvzf -


CMD syntaxnetToJson.sh
