# Docker image for the NEUROFINDER challenge

FROM debian:jessie

MAINTAINER CodeNeuro <info@codeneuro.org>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -y git vim wget build-essential python-dev ca-certificates bzip2 libsm6 && apt-get clean

ENV CONDA_DIR /opt/conda

# Install conda for the codeneuro user only (this is a single user container)
RUN echo 'export PATH=$CONDA_DIR/bin:$PATH' > /etc/profile.d/conda.sh && \
    wget --quiet https://repo.continuum.io/miniconda/Miniconda3-3.9.1-Linux-x86_64.sh && \
    /bin/bash /Miniconda3-3.9.1-Linux-x86_64.sh -b -p $CONDA_DIR && \
    rm Miniconda3-3.9.1-Linux-x86_64.sh && \
    $CONDA_DIR/bin/conda install --yes conda==3.10.1

# We run our docker images with a non-root user as a security precaution.
# codeneuro is our user
RUN useradd -m -s /bin/bash codeneuro
RUN chown -R codeneuro:codeneuro $CONDA_DIR

EXPOSE 8888

USER codeneuro
ENV HOME /home/codeneuro
ENV SHELL /bin/bash
ENV USER codeneuro
ENV PATH $CONDA_DIR/bin:$PATH
WORKDIR $HOME

RUN conda install --yes ipython-notebook terminado && conda clean -yt

RUN ipython profile create

# Workaround for issue with ADD permissions
USER root

RUN apt-get update

# Java setup
RUN apt-get install -y default-jre

# Spark setup 
RUN wget http://d3kbcqa49mib13.cloudfront.net/spark-1.3.1-bin-hadoop1.tgz 
RUN tar -xzf spark-1.3.1-bin-hadoop1.tgz
ENV SPARK_HOME $HOME/spark-1.3.1-bin-hadoop1
ENV PATH $PATH:$SPARK_HOME/bin
RUN sed 's/log4j.rootCategory=INFO/log4j.rootCategory=ERROR/g' $SPARK_HOME/conf/log4j.properties.template > $SPARK_HOME/conf/log4j.properties
ENV _JAVA_OPTIONS "-Xms512m -Xmx4g" 

# Install useful Python packages
RUN apt-get install -y libxrender1 fonts-dejavu && apt-get clean
RUN conda create --yes -q -n python2.7-env python=2.7 nose numpy pandas scikit-learn scikit-image matplotlib scipy seaborn sympy cython patsy statsmodels cloudpickle numba bokeh pillow ipython jsonschema boto
ENV PATH $CONDA_DIR/bin:$PATH
RUN conda install --yes numpy pandas scikit-learn scikit-image matplotlib scipy seaborn sympy cython patsy statsmodels cloudpickle numba bokeh pillow && conda clean -yt
RUN /bin/bash -c "source activate /opt/conda/envs/python2.7-env/ && pip install mistune"

# Thunder setup
RUN apt-get install -y git python-pip ipython gcc
RUN git clone https://github.com/thunder-project/thunder
RUN /bin/bash -c "source activate /opt/conda/envs/python2.7-env/ && pip install -r thunder/python/requirements.txt"
ENV THUNDER_ROOT $HOME/thunder
ENV PATH $PATH:$THUNDER_ROOT/python/bin
ENV PYTHONPATH $PYTHONPATH:$THUNDER_ROOT/python

# Configure Boto for S3 access
RUN printf '[s3]\ncalling_format = boto.s3.connection.OrdinaryCallingFormat' >> ~/.boto

# Add the notebooks directory
ADD notebooks $HOME/notebooks

# Set up the kernelspec
RUN /opt/conda/envs/python2.7-env/bin/ipython kernelspec install-self

RUN chown -R codeneuro:codeneuro $HOME/notebooks

USER codeneuro

WORKDIR $HOME/notebooks

CMD /bin/bash -c 'source activate /opt/conda/envs/python2.7-env/ && thunder -n --notebook-opts='--ip=0.0.0.0 --no-browser''