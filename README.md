# Lectura Eficiente de Archivos MS Excel en R

Al utilizar R u otro lenguaje de programación similar, nos encontramos con una gran gama de opciones para llevar a cabo distintas tareas. Una labor cotidiana es la carga de documentos CSV o MS Excel. La forma más fácil de leer documentos de este tipo es utilizando ciclos `for`, no obstante, existen otras alternativas que nos permiten realizar la carga de manera más eficiente, evitando a su vez generar líneas de código extra. 

En este pequeño tutorial se verán tres formas de leer archivos, utilizando ciclos `for` (**Rbase**), funciones `map` (librería **purrr***) y `future_map` (librería **furrr**).



