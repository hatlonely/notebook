FROM ubuntu:22.04

RUN apt-get update && apt-get install -y wget git gcc g++ libfst-dev

RUN mkdir -p ~/miniconda3 && \
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh && \
    bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3 && \
    rm -rf ~/miniconda3/minicond

ENV PATH="/root/miniconda3/bin:${PATH}"

RUN git clone -b 1.0.2 https://github.com/wenet-e2e/WeTextProcessing.git && \
    cd WeTextProcessing && \
    sed -i 's/pynini==2.1.5/pynini==2.1.6/g' requirements.txt && \
    sed -i 's/pynini==2.1.5/pynini==2.1.6/g' setup.py && \
    python setup.py install --install-option="1.0.2"
RUN pip install Cython gradio torch numba omegaconf vocos \
    pybase16384 vector_quantize_pytorch transformers
RUN git clone https://github.com/2noise/ChatTTS && \
    cd ChatTTS && \
    sed -i 's/pynini==2.1.5/pynini==2.1.6/g' requirements.txt && \
    pip install -r requirements.txt || true

EXPOSE 8080

WORKDIR /ChatTTS
CMD [ "python", "examples/web/webui.py" ]
