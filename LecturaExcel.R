# Cargamos librerias a utilizar ----
library(readxl)
library(purrr)
library(furrr)

# Prueba utilizando loops ----

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

# Prueba utilizando purrr ----

# Leemos los archivos disponibles
Archivos <- list.files("datos",full.names = TRUE)

# Primero tenemos que identificar las hojas por cada archivo
Hojas <- map(Archivos, ~ excel_sheets(.x))

# Creamos una función para leer las hojas
LecturaExcel <- function(Archivos,Hojas) {
   map(Hojas, ~ read_excel(path = Archivos,sheet = .x),Archivos)}

# Extraemos la informacion de todas las hojas
Datos <- map2_dfr(Archivos,Hojas, LecturaExcel)

# Prueba utilizando furrr ----

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

