FROM tensorflow/syntaxnet
RUN apt-get install -y  bsdtar
RUN wget -nc -O - http://download.tensorflow.org/models/parsey_universal/German.zip | bsdtar -xvf-
ENV MODEL_DIR German
COPY syntaxnetToJson.sh syntaxnetToJson.sh

CMD /bin/bash syntaxnet/models/parsey_universal/parse.sh
