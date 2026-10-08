# Investigación (Fase 0): Caja con tapa a presión para 4 pilas AA

## R1. Medidas de la pila AA

- **Decisión**: diámetro 14,5 mm y largo 50,5 mm, los máximos de IEC 60086-2 para LR6 (el rango
  es 13,5–14,5 mm × 49,2–50,5 mm). Cada alojamiento suma `holgura("suelto")` (0,40 mm) al diámetro y
  al largo: 14,9 × 50,9 mm.
- **Justificación**: la pila tiene que entrar por su peso y caer al dar vuelta la caja (escenarios 2
  y 6 de la historia 1). Con la medida máxima más la holgura "suelto" entran todas las marcas; las más
  chicas quedan con ≤ 1,4 mm de juego, que los tabiques y la tapa contienen.
- **Alternativas descartadas**: diámetro nominal 14,0 mm (una pila de 14,5 mm con etiqueta gruesa no
  entraría); holgura "justo" (la pila quedaría trabada y no caería al dar vuelta la caja).

## R2. Disposición de las pilas

- **Decisión**: acostadas en una fila de 4, con el eje de cada pila paralelo a Y y tabiques de
  1,2 mm entre alojamientos.
- **Justificación**: es la caja más chata (≈ 27 mm cerrada) y la que mejor entra en un bolsillo; el
  piso grande va sobre la cama y no hay voladizos.
- **Alternativas descartadas**: 2 × 2 de pie (caja de ≈ 60 mm de alto, la tapa necesita una pollera
  larga y las pilas cuestan sacarlas de a una); 2 × 2 acostadas (cada pila tapa a la de abajo).

## R3. Tipo de encastre

- **Decisión**: la tapa es una placa con una **pollera interior** que entra en la caja. En el centro
  de cada pared larga, la pollera tiene una **pestaña en voladizo** separada por dos ranuras
  verticales, con un **reborde** trapezoidal hacia afuera cerca de la punta. El reborde engancha en una
  **ranura** horizontal en la cara interior de la pared larga de la caja.
- **Justificación**:
  - Una pestaña recortada flexiona como una viga en voladizo y su deformación se puede calcular
    (R4); un reborde continuo en toda la pollera trabaja contra las esquinas rígidas y su esfuerzo no
    se puede predecir.
  - Los flancos del reborde y de la ranura a 45° sirven a la vez de entrada (cierra empujando) y de
    retención que se vence a mano (abre tirando), y se imprimen sin soportes en las dos piezas.
  - Las dos pestañas están en el centro de las paredes largas, así que la tapa encastra igual girada
    180° (FR-005).
- **Alternativas descartadas**: pollera exterior (agranda la caja y la pestaña queda expuesta a
  engancharse en la mochila); tapa deslizante en rieles (no es "a presión" y necesita un voladizo
  horizontal); bisagra impresa (fuera de alcance y frágil en PETG).

## R4. Precálculo del encastre (justificación de la fase 2)

Pestaña como viga en voladizo de sección rectangular empotrada en la placa de la tapa. Deformación
máxima en la raíz al cerrar:

ε = 1,5 · t · y / L²

| Símbolo | Significado | Valor por defecto |
|---|---|---|
| t | Espesor de la pollera | 1,2 mm |
| L | Distancia de la raíz al centro del reborde | 8,0 − 1,0 = 7,0 mm |
| y | Flecha al pasar el reborde = saliente del reborde − holgura lateral de la pollera | 0,50 − 0,125 = 0,375 mm |
| ε | Deformación en la raíz | 1,5 · 1,2 · 0,375 / 49 = **1,38 %** |

- **Límite**: deformación admisible de 1,5 % para PETG impreso en uso repetido (≈ 60 % de la
  deformación de fluencia, ≈ 2,5 %, con E ≈ 2000 MPa y σ ≈ 50 MPa). Margen 1,5 / 1,38 = 1,09.
- **Fuerza de cierre**: P = 3·E·I·y / L³ con I = b·t³/12 = 20 · 1,2³ / 12 = 2,88 mm⁴
  → P = 3 · 2000 · 2,88 · 0,375 / 343 ≈ **19 N por pestaña** en la flecha máxima. Con el flanco a 45°
  y rozamiento μ ≈ 0,3, la fuerza para cerrar es ≈ 19 · (0,3 + 1)/(1 − 0,3) ≈ 35 N por pestaña: se
  cierra con el pulgar. La fuerza para abrir es la misma porque el flanco de retención también está a
  45°, y se aplica desde la muesca.
- **Conclusión**: la única carga es la flexión de la pestaña al abrir y cerrar, y la verifica una
  fórmula cerrada. La simulación FEM **no aplica**. El generador recalcula ε con los parámetros
  actuales y rechaza cualquier combinación con ε > 1,5 % (regla V-05), así que el rango validado es
  todo el rango que el generador acepta.
- **Con PLA**: E ≈ 3500 MPa y deformación admisible ≈ 1 %; con los valores por defecto ε = 1,38 % la
  supera. La guía avisa que en PLA hay que bajar `saliente_reborde` a 0,35 mm (ε ≈ 0,92 %).

## R5. Que las pilas no salten de alojamiento

- **Decisión**: tabiques de 10 mm de alto (≈ 0,69 · diámetro).
- **Justificación**: con la caja cerrada, una pila puede subir hasta tocar la tapa: el juego vertical
  es la holgura del alojamiento más el alto de la pollera, 0,4 + 8,0 = 8,4 mm. Para pasar al
  alojamiento vecino tendría que levantar su parte inferior por encima del tabique, así que basta con
  que el tabique sea más alto que ese juego (regla V-06). Un tabique más bajo que el diámetro deja ver
  y tomar la pila por arriba.
- **Alternativas descartadas**: tabiques de alto completo (más plástico y nada más); costillas en la
  tapa que aprieten las pilas (dependen del diámetro real de cada marca).

## R6. Muesca de apertura

- **Decisión**: muesca de 16 mm de ancho y 2,5 mm de profundidad, con fondo redondeado, en el borde
  superior de una pared corta de la caja. Deja libre el borde de la tapa para meter la uña.
- **Justificación**: está en la pared corta, lejos de las ranuras del encastre (paredes largas), y
  solo corta la zona de la pollera, no la de las pilas.

## R7. Orientación de impresión y bordes

- **Decisión**: caja con la abertura hacia arriba; tapa con su cara exterior sobre la cama y la
  pollera hacia arriba. Chaflán de 0,6 mm en los bordes que tocan la cama (evita la "pata de
  elefante" que agrandaría la tapa y endurecería el encastre).
- **Justificación**: las dos caras planas grandes van sobre la cama, los flancos a 45° del reborde y de
  la ranura se imprimen sin soportes y el reborde queda en la dirección de las capas más resistente
  (la pestaña flexiona en el plano de las capas, no las separa).

## R8. Material y componentes

- **Decisión**: PETG. La lista de materiales solo tiene filamento.
- **Justificación**: el PETG admite más deformación repetida que el PLA en las pestañas (R4). No hay
  tornillería ni componentes comprados: las pilas son el contenido, no parte del diseño.
