FROM public.ecr.aws/sam/build-python3.13
WORKDIR /opt
COPY build_layer.sh .
COPY requirements.txt .
RUN chmod +x build_layer.sh
CMD ["./build_layer.sh"]
