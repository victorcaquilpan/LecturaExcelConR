## Lectura Eficiente de Archivos MS Excel en R

Al utilizar R u otro lenguaje de programación similar, nos encontramos con una gran gama de opciones para llevar a cabo distintas tareas. Una labor cotidiana es la carga de documentos CSV o MS Excel. La forma más fácil de leer documentos de este tipo es utilizando ciclos `for`, no obstante, existen otras alternativas que nos permiten realizar la carga de manera más eficiente, evitando a su vez generar líneas de código extra. 

En este pequeño tutorial se verán tres formas de leer archivos, utilizando ciclos `for` (**Rbase**), funciones `map` (librería **purrr**) y `future_map` (librería **furrr**). Algunos aspectos relevantes:

- En simples palabras, las funciones de la librería [purrr](https://github.com/tidyverse/purrr) nos permiten ejecutar funciones a múltiples objetos a un mismo tiempo. Lo que podríamos hacer directamente con ciclos `for` lo podemos traducir a una función de la familia `map` para llevar a cabo el mismo proceso de manera paralela (**Esto no significa que se utilicen múltiples núcleos**). 
- Por otra parte [furrr](https://github.com/DavisVaughan/furrr) nos permite ir un paso más allá, integrando las capacidades de **purrr** con procesamiento en paralelo a nivel de varios núcleos de CPU.

## Datos a utilizar

Se dispone una serie de 10 documentos MS Excel con información aleatoria. Estos documentos se encuentran en la carpeta `datos` y cuentan con alrededor de 10000 filas y una diferente cantidad de hojas cada uno. Podemos leerlos de manera individual usando `readr`.

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

Cómo podemos ver, esto se realiza sin problemas, pero a través de la ejecución de varias líneas de código y usando ciclos, los cuales no son un proceso tan rápido.

## Utilizando purrr

Ahora, podemos traducir nuestro procedimiento anterior utilizando las funciones `map` de la librería **purrr**. Estas funciones disponen de una sintaxis sencilla, lo que es una gran plus en cuanto a la capacidad de ser interpretada por otros usuarios. Dado que tenemos que iterar a través de los archivos y sus distintas hojas, podemos utilizar dos funciones `map` de la siguiente forma.

```r
library(readxl)
library(purrr)

# Leemos los archivos disponibles
Archivos <- list.files("datos",full.names = TRUE)

# Primero tenemos que identificar las hojas por cada archivo
Hojas <- map(Archivos, ~ excel_sheets(.x))

# Creamos una función para leer las hojas
LecturaExcel <- function(Archivos,Hojas) {
   map(Hojas, ~ read_excel(path = Archivos,sheet = .x),Archivos)}

# Extraemos la informacion de todas las hojas
Datos <- map2_df(Archivos,Hojas, LecturaExcel)

```

A pesar de que en general las funciones `map` nos devuelven una lista, nosotros podemos indicarle que el resultado sea un dataframe a través de `map_df` o `map2_df`.

## Transición a furrr

Cómo mencionabamos al principio podemos ir un paso más allá y paralelizar nuestro proceso a nivel de múltiples nucleos CPU. Para esto simplemente aplicaremos las funciones de la familia `future_map` de la librería **furrr**.

```r
library(readxl)
library(furrr)

# Leemos los archivos disponibles
Archivos <- list.files("datos",full.names = TRUE)

# Declaramos que correremos nuestro proceso en múltiples sesiones de R
future::plan(multisession) 

# Primero tenemos que identificar las hojas por cada archivo
Hojas <- future_map(Archivos, ~ excel_sheets(.x), .options = furrr_options(seed = T))

# Creamos una función para leer las hojas
LecturaExcel <- function(Archivos,Hojas) {
  future_map(Hojas, ~ read_excel(path = Archivos,sheet = .x),Archivos, .options = furrr_options(seed = T))}

# Extraemos la informacion de todas las hojas
Datos <- future_map2_dfr(Archivos,Hojas, LecturaExcel, .options = furrr_options(seed = T))

```

La ventaja de utilizar **furrr** es que podemos incrementar la velocidad del proceso que estamos realizando sacandole el partido a los múltiples núcleos de nuestro CPU. En ese ejemplo, se están utilizando todos los núcleos de la computadora, no obstante si queremos utilizar una cantidad menor, podemos agregar a la función `plan` el argumento `workers = numeronucleosautilizar`. Adicionalmente, si ya disponemos de una tarea con funciones `map`, simplemente tenemos que encontrar su simil a `future_map` para poder implementar estas funciones.

## Comparación de rendimiento

Podemos evaluar el rendimiento de los tres procesos a través del tiempo que demora su ejecución. Para esto, podemos utilizar la función `microbenchmark` de la librería del mismo nombre. Esta función nos permite correr varias funciones una X cantidad de veces (10 veces por defecto), y nos indica el tiempo promedio que se demora cada una.

```r
library(microbenchmark)

# Declaramos que para la paralización de furrr correremos nuestro proceso en múltiples sesiones de R
future::plan(multisession)

# Analisis
microbenchmark(ciclofor = {
  # Operacion con for
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
},  purrr = {
  # Operacion con purrr
  # Primero tenemos que identificar las hojas por cada archivo
  Hojas <- map(Archivos, ~ excel_sheets(.x))
  
  # Creamos una función para leer las hojas
  LecturaExcel <- function(Archivos,Hojas) {
    map(Hojas, ~ read_excel(path = Archivos,sheet = .x),Archivos)}
  
  # Extraemos la informacion de todas las hojas
  Datos <- map2_dfr(Archivos,Hojas, LecturaExcel)

},  furrr = {
  # Operacion con furrr
  # Primero tenemos que identificar las hojas por cada archivo
  Hojas <- future_map(Archivos, ~ excel_sheets(.x), .options = furrr_options(seed = T))
  
  # Creamos una función para leer las hojas
  LecturaExcel <- function(Archivos,Hojas) {
    future_map(Hojas, ~ read_excel(path = Archivos,sheet = .x),Archivos, .options = furrr_options(seed = T))}
  
  # Extraemos la informacion de todas las hojas
  Datos <- future_map2_dfr(Archivos,Hojas, LecturaExcel, .options = furrr_options(seed = T))
  
},times = 10)
```
En mi computador, un notebook gamer bastante básico de 8 núcleos me arroja los siguientes resultados:

```
Unit: seconds
     expr      min       lq     mean   median       uq      max neval
 ciclofor 6.148889 6.355953 6.461506 6.508588 6.513387 6.780555    10
    purrr 4.977360 5.004655 5.107406 5.078259 5.123058 5.371700    10
    furrr 1.618312 1.643370 1.976298 1.682335 1.752239 4.527035    10
```

Es posible apreciar una clara diferencia en el rendimiento entre los tres casos (`furrr` > `purrr` > `ciclo for`). 

Si se desea adquirir mayor información acerca del cómo usar **purrr** y **furrr**, al principio de este documento se encuentran los enlaces a sus repositorios en Github.
