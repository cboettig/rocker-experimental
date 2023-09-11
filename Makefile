runner: builder
	docker build -t rocker/gdal:runner -f Dockerfile.rocker .

builder:
	docker build -t rocker/gdal:builder -f Dockerfile.builder .


