# Especificación de Funcionalidad: Espacio para conectores y cableado del puntero láser

**Rama de la funcionalidad**: `009-espacio-conectores`

**Creada**: 2026-10-15

**Estado**: Implementada (pendiente: armado real con los componentes, SC-002 y SC-003)

**Corrige**: [002-puntero-laser-estelar](../002-puntero-laser-estelar/spec.md) (electrónica bajo la
tapa)

**Entrada**: Descripción del usuario: "¿Es necesario contemplar los cables que se conectan los
componentes?". Propuesta acordada: el ensamblaje modela las placas (ESP32 elevado con los pines hacia
abajo, relé, dos ULN2003 y regulador) como bloques hasta `altura_placas` y no reserva lugar para los
conectores Dupont rectos, la curva de los cables, los conectores JST de los motores en los ULN2003 ni
el acceso al USB del ESP32 para cargar el firmware. Con medidas típicas, la tapa (interior ≈ 25,6 mm)
no cerraría sobre Dupont rectos verticales y los Dupont bajo el ESP32 (elevado 15 mm) tocarían la
plataforma. Agregar volúmenes de conector paramétricos (largo del Dupont, radio de curva del cable,
JST-XH, acceso USB) a las comprobaciones de choque existentes; derivar de ellos la altura interior de
la tapa y la elevación del ESP32; comprobar que los cables de los motores 28BYJ-48 (≈ 25 cm) alcanzan
por el recorrido de la guía; reflejar los cambios en las piezas, sus STL, la guía y la web y el visor.

## Aclaraciones

### Sesión 2026-10-15

- P: ¿Con qué tipo de conexión se dimensiona el espacio bajo la tapa? → R: Dupont hembra-hembra
  rectos (los de la lista de materiales); la tapa y el ESP32 crecen lo necesario.

## Escenarios de usuario y pruebas *(obligatorio)*

### Historia de usuario 1 - Conectar todo y cerrar la tapa (Prioridad: P1)

Una persona imprimió las piezas y compró los componentes de la lista de materiales, con cables Dupont
hembra-hembra comunes (conectores rectos). Encaja las placas en sus soportes, conecta los Dupont a los
pines del ESP32, del relé y de los ULN2003, enchufa los motores en sus ULN2003 y pone la tapa. La tapa
apoya en su reborde y se atornilla sin apretar ningún conector ni doblar un cable más de lo que
admite.

**Por qué esta prioridad**: es el problema detectado. Si la tapa no cierra o los conectores del ESP32
tocan la plataforma, el aparato no se puede terminar sin modificar piezas a mano.

**Prueba independiente**: en el ensamblaje, con los volúmenes de conector dibujados, las
comprobaciones de choque pasan y la distancia de cada conector a la tapa y a la plataforma es al
menos la holgura fijada; una persona arma la electrónica con la guía y cierra la tapa al primer
intento.

**Escenarios de aceptación**:

1. **Dado** el diseño con los valores por defecto, **cuando** se valida el ensamblaje, **entonces**
   ningún volumen de conector (Dupont con la curva de su cable, enchufe de cada motor) se solapa con
   la tapa, la plataforma, los soportes ni otra placa.
2. **Dado** que una persona cambia el largo del conector o el radio de curva del cable por los de sus
   cables reales, **cuando** se valida, **entonces** la altura de la tapa y la elevación del ESP32 se
   recalculan solas y la validación sigue pasando, o falla con un mensaje que dice qué medida no entra.
3. **Dado** el ESP32 en su soporte, **cuando** se conectan los Dupont a sus pines desde abajo,
   **entonces** el conector y la curva del cable quedan por encima de la plataforma, con holgura.

---

### Historia de usuario 2 - Cargar el firmware sin desarmar (Prioridad: P2)

Con el aparato armado y la tapa puesta, la persona enchufa un cable USB al ESP32 por la abertura de la
tapa para cargar o actualizar el firmware.

**Por qué esta prioridad**: el firmware se carga muchas veces durante la puesta a punto; si hace falta
sacar la tapa cada vez, se desconectan cables.

**Prueba independiente**: en el ensamblaje, el volumen del enchufe USB con su funda atraviesa la
abertura de la tapa sin tocar sus bordes, con el ESP32 en su nueva elevación.

**Escenarios de aceptación**:

1. **Dado** el ESP32 a su elevación calculada, **cuando** se valida, **entonces** el volumen del
   enchufe USB pasa por la abertura de la tapa con holgura en todo su contorno.

---

### Historia de usuario 3 - Que los cables de los motores lleguen (Prioridad: P3)

La persona lleva el cable de cada motor por el recorrido de la guía (el de altura por el canal del
brazo motor; el de azimut con una brida al puente de la plataforma y por la pared −X de la tapa) y lo
enchufa en su ULN2003 sin estirarlo.

**Por qué esta prioridad**: el cable del 28BYJ-48 viene de fábrica con un largo fijo; si no alcanza,
hay que empalmarlo, pero es un problema menos probable que el de la tapa.

**Prueba independiente**: la guía o el plan informan el largo de cada recorrido calculado desde el
diseño y la reserva que queda respecto del largo del cable.

**Escenarios de aceptación**:

1. **Dado** el largo del cable del motor (parámetro), **cuando** se valida el ensamblaje,
   **entonces** cada recorrido, en todo el rango de movimiento del eje de altura, es menor que el
   largo del cable menos una reserva para el enchufe y la curva; si no lo es, la validación falla
   nombrando el motor.

---

### Casos límite

- Un conector de otra marca, más largo: se cambia el parámetro y la tapa crece; si al crecer choca
  con el carro o el motor de altura, la validación lo dice (ya existe esa comprobación de la tapa).
- Cables soldados en lugar de Dupont (regulador, interruptor): ocupan menos que un Dupont; su espacio
  queda cubierto por el de los conectores de las placas vecinas o por el hueco del cable sobrante.
- El ESP32 más alto deja menos espacio entre su módulo y la tapa: la altura de la tapa sale del mayor
  de los dos requisitos (conectores de arriba de las placas bajas y módulo del ESP32).
- El relé con borneras de tornillo: los cables de salida entran de costado y no suman altura.
- Un ESP32 con pines soldados hacia arriba (otra versión): fuera de alcance; la guía indica que los
  pines van hacia abajo, como vienen de fábrica.

## Requisitos *(obligatorio)*

### Requisitos funcionales

- **FR-001**: El diseño DEBE tener parámetros para los conectores reales: largo del cuerpo del Dupont,
  alto de la tira de pines, largo del pin, radio mínimo de curva del cable, medidas del enchufe del
  motor en el ULN2003 y medidas del enchufe USB con su funda, con valores típicos por defecto y la
  indicación de medirlos.
- **FR-002**: El ensamblaje DEBE representar como volúmenes el espacio de cada conector conectado con
  la curva de su cable: los Dupont de los ULN2003 y del relé (hacia arriba), los del ESP32 (hacia
  abajo), el enchufe de cada motor en su ULN2003 y el enchufe USB del ESP32.
- **FR-003**: Las comprobaciones de choque del ensamblaje DEBEN incluir esos volúmenes contra la tapa,
  la plataforma, los soportes y las otras placas, con una holgura mínima, y fallar con un mensaje que
  nombre el conector y la pieza.
- **FR-004**: La altura interior de la tapa DEBE calcularse a partir de los volúmenes de conector y del
  módulo del ESP32, no fijarse a mano.
- **FR-005**: La elevación del ESP32 DEBE calcularse para que sus Dupont con la curva del cable quepan
  sobre la plataforma con la holgura mínima.
- **FR-006**: La abertura USB de la tapa DEBE seguir la nueva elevación del ESP32 y dejar pasar el
  enchufe con su funda con holgura en todo el contorno.
- **FR-007**: El diseño DEBE calcular el largo del recorrido del cable de cada motor hasta su ULN2003
  por el camino de la guía, en todo el rango de altura, y fallar si supera el largo del cable menos
  una reserva.
- **FR-008**: Si la tapa más alta choca con el carro o el motor de altura, o deja de entrar en la cama,
  la validación DEBE fallar (las comprobaciones existentes siguen vigentes) y el diseño DEBE ajustarse
  hasta que pasen.
- **FR-009**: Las piezas que cambian (como mínimo la plataforma, por el soporte del ESP32, y la tapa)
  DEBEN regenerar sus STL, y las demás DEBEN quedar iguales.
- **FR-010**: La guía DEBE actualizar las medidas que cambian (alto de la tapa, masa), indicar que los
  pines del ESP32 van hacia abajo y la orientación de los Dupont, y listar los parámetros nuevos en la
  tabla de adaptación; las vistas explotadas, la web y el visor DEBEN regenerarse.
- **FR-011**: Los volúmenes de conector NO DEBEN exportarse como piezas ni aparecer como piezas
  compradas en la lista de materiales; el visor PUEDE mostrarlos en el paso de cableado como
  referencia transparente.

### Entidades clave

- **Conector**: lo que se enchufa a una placa (Dupont, enchufe del motor, enchufe USB) con el espacio
  de la curva de su cable; tiene placa, posición, sentido (arriba, abajo, de costado) y medidas.
- **Recorrido de cable**: camino de un cable desde su componente hasta su placa, con su largo y el
  largo disponible.

## Criterios de éxito *(obligatorio)*

### Resultados medibles

- **SC-001**: Con los valores por defecto, el 100 % de los conectores y enchufes del aparato caben con
  la holgura mínima entre la plataforma y la tapa, comprobado por el diseño y no a ojo.
- **SC-002**: Una persona arma la electrónica siguiendo la guía y cierra la tapa al primer intento,
  sin doblar cables contra el techo ni recortar conectores.
- **SC-003**: El firmware se puede cargar con la tapa puesta.
- **SC-004**: Cada cable de motor llega a su placa con una reserva informada de al menos 20 mm.
- **SC-005**: Cambiar una medida de conector y volver a validar indica en una sola pasada si el diseño
  sigue entrando y, si no, qué medida falla.

## Supuestos

- Se usan Dupont hembra-hembra **rectos** comunes, que son los de la lista de materiales; los
  conectores o pines a 90° quedan como alternativa que la persona puede reflejar con los parámetros.
- Medidas típicas por defecto (a confirmar en el plan): cuerpo del Dupont ≈ 14 mm, tira de pines
  ≈ 2,5 mm, radio mínimo de curva del cable ≈ 5 mm, cable del 28BYJ-48 ≈ 25 cm.
- Los pines macho de los ULN2003 y del relé son verticales, como vienen de fábrica; los del ESP32
  DevKit, hacia abajo.
- La tapa no soporta cargas: no hace falta simulación FEM por hacerla más alta (justificación en el
  plan).
- El firmware sigue fuera de alcance; solo importa poder enchufar el USB.
- Un diagrama de conexiones nuevo queda fuera de alcance: la guía ya tiene el esquema de la
  sección 5.4 y la tabla de recorridos.
