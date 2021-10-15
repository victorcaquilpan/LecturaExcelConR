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
  Datos <- map_df(Hojas, ~ read_excel(path = Archivos,sheet = .x),Archivos)}

# Extraemos la informacion de todas las hojas
Datos <- map2_df(Archivos,Hojas, LecturaExcel)

