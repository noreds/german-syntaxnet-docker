FROM marcobeyer/syntaxnet-base
RUN wget -q -O - http://download.tensorflow.org/models/parsey_universal/German.zip | tartar xvzf -


CMD syntaxnetToJson.sh
