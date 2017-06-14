FROM marcobeyer/syntaxnet-base
RUN wget -q -O - http://download.tensorflow.org/models/parsey_universal/German.zip | tartar xvzf -
COPY syntaxnetToJson.sh syntaxnetToJson.sh

CMD syntaxnetToJson.sh
