
main:
	docker build -t rocker/gdal --build-arg="TARGET_BASE_IMAGE=rocker/r-ver" -f Dockerfile .


runner: builder
	docker build --no-cache -t rocker/gdal:runner -f Dockerfile.rocker .

builder:
	docker build -t rocker/gdal:builder -f Dockerfile.builder .


