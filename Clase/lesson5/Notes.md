# Lesson 5

## Operaciones con listas

Las listas son intérnamete árboles cuya raíz es el primer elemento y el nodo final es la lista vacía  

### Folder

La idea es aplicar una transformación a la lista completa de forma
recursiva.

#### Left List.fold(list, ab, func)

Se cambia el operador cons `|` por el operador de func, esto
se hace desde el principio de la lista hasta llegar al subarbol vacío([])

#### Right List.fold([x|xs], acc)

Se utiliza un aucumulador que actua a forma de pila, cuando se
llega a la lista vacía, se pone un 0 y de forma recursiva realiza
la operación 2 a 2, el acumulado con el siguiente elemento de la pila.

### Map

```elixir

```
