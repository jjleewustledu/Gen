FROM            ubuntu:16.04
MAINTAINER      MIT Probabilistic Computing Project

RUN             apt-get update -qq && apt-get install -qq -y \
	                build-essential \
	                hdf5-tools \
                        python3-dev \
	                python3-tk \
	                python3-pip \
                        virtualenv \
	                wget \
	                zlib1g-dev

RUN             apt-get install -qq -y git
RUN             git config --global user.name "John J. Lee"
RUN             git config --global user.email "16329959+jjleewustledu@users.noreply.github.com"

RUN             virtualenv -p /usr/bin/python3 /venv
RUN             . /venv/bin/activate && pip install jupyter jupytext matplotlibp graphviz

RUN             mkdir /julia
RUN             mkdir /julia/gpghome

RUN             cd /julia && \
	        wget https://julialang.org/juliareleases.asc && \
	        { echo a27705bf1e5a44d1905e669da0c990ac2d7ab7c13ec299e15bacdab5dcbb8d13 juliareleases.asc | sha256sum -c; }
RUN             cd /julia && gpg --homedir gpghome --import juliareleases.asc

ENV             JULIA_TGZ=julia-1.0.5-linux-x86_64.tar.gz
ENV             JULIA_URL=https://julialang-s3.julialang.org/bin/linux/x64/1.0
RUN             cd /julia && \
	        wget "$JULIA_URL/$JULIA_TGZ" "$JULIA_URL/$JULIA_TGZ.asc" && \
	        gpg --homedir gpghome --verify "$JULIA_TGZ.asc" "$JULIA_TGZ"
RUN             cd /julia && \
	        gunzip -c < "$JULIA_TGZ" | tar -x -f - --strip-components 1
ENV             PATH="$PATH:/julia/bin"
RUN             ln -s /julia/bin/julia /usr/bin/julia

ADD             . /probcomp/Gen
ENV             JULIA_PROJECT=/probcomp/Gen

#RUN             . /venv/bin/activate && julia -e 'using Pkg; Pkg.develop(PackageSpec(path="/probcomp/Gen"))'
#RUN		. /venv/bin/activate && julia -e 'Pkg.test("Gen")'

RUN             . /venv/bin/activate && julia -e 'using Pkg; Pkg.build()'
RUN             . /venv/bin/activate && julia -e 'using Pkg; Pkg.API.precompile()'
#RUN             . /venv/bin/activate && julia -e 'using Pkg; Pkg.test()'

#RUN             . /venv/bin/activate && julia -e 'Pkg.add("FunctionalCollections")'
#RUN             . /venv/bin/activate && julia -e 'Pkg.add("Distributions")'
#RUN             . /venv/bin/activate && julia -e 'Pkg.add("PyPlot")'
#RUN             . /venv/bin/activate && julia -e 'include("/probcomp/Gen/examples/run_examples.jl")'

VOLUME          /probcomp/Gen/case-studies

WORKDIR         /probcomp/Gen

ENTRYPOINT      . /venv/bin/activate && jupyter notebook \
                    --ip='0.0.0.0' \
                    --port=8080 \
                    --no-browser \
                    --NotebookApp.token= \
                    --allow-root \
                    --NotebookApp.iopub_data_rate_limit=-1
