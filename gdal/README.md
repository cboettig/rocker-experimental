# rocker-experimental


Build docker based on `osgeo/gdal:ubuntu-full-3.7.2` [recipe](https://github.com/OSGeo/gdal/tree/master/docker/ubuntu-full).


```bash
docker build -t rocker/gdal --build-arg="TARGET_BASE_IMAGE=rocker/r-ver" -f Dockerfile .
```

```
docker run --rm -ti rocker/gdal bash
apt-get update && apt-get -y install libssl-dev libudunits2-dev sqlite3-dev
R -e "install.packages('sf', repos='https://cran.rstudio.com')"
```

Test:

```r
sf::st_drivers("all") |> dplyr::filter(name == "netCDF")
```










### staged builds

Alternately we can seperately build the the builder and runner images, such that the builder image can be re-used in independent recipes.  We can also add additional dependencies as needed

```bash
make
```

- This builds the builder recipe there as `rocker/gdal:builder` image.  
- This then starts with rocker/geospatial and 

```
docker run --rm -ti rocker/gdal:runner sf::st_drivers("all") |> dplyr::filter(name == "netCDF")
```
