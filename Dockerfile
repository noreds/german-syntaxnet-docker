FROM marcobeyer/syntaxnet-base
RUN apt-get install -y  bsdtar
RUN wget -nc -O - http://download.tensorflow.org/models/parsey_universal/German.zip | bsdtar -xvf-
CMD syntaxnetToJson.sh
