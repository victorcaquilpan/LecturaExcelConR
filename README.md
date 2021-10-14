# Lectura Eficiente de Archivos MS Excel en R

Al utilizar R u otro lenguaje de programación similar, nos encontramos con una gran gama de opciones para llevar a cabo distintas tareas. Una labor cotidiana es la carga de documentos CSV o MS Excel. La forma más fácil de leer documentos de este tipo es utilizando ciclos `for`, no obstante, existen otras alternativas que nos permiten realizar la carga de manera más eficiente, evitando a su vez generar líneas de código extra. 

En este pequeño tutorial se verán tres formas de leer archivos, utilizando ciclos `for` (**Rbase**), funciones `map` (librería **purrr**) y `future_map` (librería **furrr**). Algunos aspectos relevantes:

- En simples palabras, **purrr** es una librería que nos permite ejecutar funciones a múltiples objetos a un mismo tiempo. Lo que podríamos hacer directamente con ciclos `for` lo podemos traducir a una función de la familia `map` para llevar a cabo el mismo proceso de manera paralela (OJO que esto no significa que se esté llevando a cabo en múltiples núcleos/hilos). 
- Por otra parte **furrr** nos permite ir un paso más allá, integrando las capacidades de **purrr** con procesamiento en paralelo a nivel de núcleo.




