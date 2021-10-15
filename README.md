## Lectura Eficiente de Archivos MS Excel en R

Al utilizar R u otro lenguaje de programación similar, nos encontramos con una gran gama de opciones para llevar a cabo distintas tareas. Una labor cotidiana es la carga de documentos CSV o MS Excel. La forma más fácil de leer documentos de este tipo es utilizando ciclos `for`, no obstante, existen otras alternativas que nos permiten realizar la carga de manera más eficiente, evitando a su vez generar líneas de código extra. 

En este pequeño tutorial se verán tres formas de leer archivos, utilizando ciclos `for` (**Rbase**), funciones `map` (librería **purrr**) y `future_map` (librería **furrr**). Algunos aspectos relevantes:

- En simples palabras, las funciones de la librería [purrr](https://github.com/tidyverse/purrr) nos permiten ejecutar funciones a múltiples objetos a un mismo tiempo. Lo que podríamos hacer directamente con ciclos `for` lo podemos traducir a una función de la familia `map` para llevar a cabo el mismo proceso de manera paralela (**Esto no significa que se utilicen múltiples núcleos**). 
- Por otra parte [furrr](https://github.com/DavisVaughan/furrr) nos permite ir un paso más allá, integrando las capacidades de **purrr** con procesamiento en paralelo a nivel de núcleo.

## Datos a utilizar

Se dispone una serie de 10 documentos MS Excel con información aleatoria. Estos documentos se encuentran en la carpeta `datos` y cuentan con menos de 1000 filas y una diferente cantidad de hojas cada uno. Podemos leerlos de manera individual usando `readr`.

```r
library(readxl)

read_excel(path = "datos/documento1.xlsx",sheet = 1)


```
## Probando loops

Dado que nosotros queremos leer varios archivos, los cuales contienen varias hojas, una forma fácil para hacer esto, es crear un ciclo `for` aninado dentro de otro.

```r
library(readxl)

# Leemos los archivos disponibles
Archivos <- list.files("datos",full.names = TRUE)

# Creamos una lista vacia para recojer los datos
Datos <- data.frame()

# Creamos un ciclo para recorrer los archivos
for (archivo in seq_along(Archivos)) {
  
  # Vemos las hojas disponibles en cada archivo
  Hojas <- excel_sheets(Archivos[archivo])
  
  # Creamos un ciclo para recorrer hojas
  for (hoja in seq_along(Hojas)) {
    
    # Alojamos los datos en nuestra lista
    Documento <- read_excel(path = Archivos[archivo],sheet = Hojas[hoja])
    
    # Apendizamos nuestros datos al objeto datos
    Datos <- rbind(Datos,Documento)

  }
  
}


```

## Utilizando purrr

```r
library(readxl)

# Leemos los archivos disponibles
Archivos <- list.files("datos",full.names = TRUE)

# Primero tenemos que identificar las hojas por cada archivo
Hojas <- map(Archivos, ~ excel_sheets(.x))

# Creamos una función para leer las hojas
LecturaExcel <- function(Archivos,Hojas) {
  Datos <- map_df(Hojas, ~ read_excel(path = Archivos,sheet = .x),Archivos)}

# Extraemos la informacion de todas las hojas
Datos <- map2_df(Archivos,Hojas, LecturaExcel)

```

