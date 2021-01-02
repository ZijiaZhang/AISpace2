FROM node:10
COPY . /app
WORKDIR /app
RUN make clone
RUN make install-dep
ENTRYPOINT ["jupyter", "lab" ,"--no-browser", "--port", "80", "--ip", "0.0.0.0", "--allow-root", "--LabApp.token=''"]