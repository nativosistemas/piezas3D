# Contrato: interfaz mecánica ↔ firmware del ESP32

**Funcionalidad**: [../spec.md](../spec.md) | **Investigación**: [../research.md](../research.md)
(R4, R9, R11, R12)

El firmware queda **fuera de alcance**. Este contrato define lo que la mecánica le garantiza y lo que
el firmware DEBE cumplir para que el error de apuntado quede por debajo de 2° (FR-026). Si cambian
los parámetros de transmisión, los valores marcados con ⚙ se vuelven a leer de los `echo` de
`src/puntero_laser_parametros.scad`.

## 1. Lo que garantiza la mecánica

| Magnitud | Azimut | Altura |
|----------|--------|--------|
| Relación interna del motor (exacta) | 63,68395:1 | 63,68395:1 |
| Medios pasos por vuelta del motor | 4075,7728 | 4075,7728 |
| Relación de la correa ⚙ | 80/20 = 4 | 80/20 = 4 |
| **Medios pasos por vuelta del eje** ⚙ | **16 303,09** | **16 303,09** |
| **Medios pasos por grado** ⚙ | **45,2864** | **45,2864** |
| Resolución | 0,0221° | 0,0221° |
| Rango mecánico | Ilimitado (sin cables cruzando el eje) | −10° … 95° (más allá, choque) |
| Juego residual tras la reducción | 0,25–0,75° (se compensa, ver 2.2) | 0,25–0,75° (se compensa) |
| Velocidad máxima fiable | ~900 medios pasos/s en el motor ≈ 20°/s | Ídem |
| Sostén sin energía | Por rozamiento de la caja | Por rozamiento de la caja, con el láser equilibrado |

**Sentidos**: el sentido de giro depende del orden de las fases y del lado de montaje. El firmware
DEBE tener una constante de inversión por eje (`invertir_azimut` e `invertir_altura`). La guía
indica cómo calibrarla: un paso positivo debe mover el azimut hacia el este (horario visto desde
arriba) y la altura hacia arriba.

## 2. Lo que DEBE cumplir el firmware

### 2.1 Conversión

- DEBE usar **4075,7728** medios pasos por vuelta del motor (no 4096) multiplicado por la relación
  de correa. Usar 4096 introduce 1,79° de error por vuelta del eje y por sí solo consume el
  presupuesto de error.
- DEBE acumular la posición en **pasos enteros** y convertir a grados solo para mostrarla, para no
  acumular redondeos.

### 2.2 Llegada unidireccional (compensación del juego)

- Toda llegada a una posición objetivo DEBE terminar moviéndose en un **sentido fijo por eje**: el
  sentido positivo.
- Si el movimiento necesario es negativo, DEBE pasarse del objetivo en `sobrepaso` y después volver
  en sentido positivo.
- `sobrepaso` por defecto: **2,0° en el eje**, es decir, ≈ 91 medios pasos. Es mayor que el juego
  máximo esperado (0,75°) con margen.
- En los movimientos de seguimiento (cambios pequeños) DEBE mantenerse el mismo sentido o repetir el
  sobrepaso.

### 2.3 Rangos y seguridad mecánica

- Altura limitada por software a **−10° … 95°**. Fuera de ese rango, el firmware DEBE rechazar el
  objetivo.
- Azimut sin límite, con normalización a 0–360°.
- Rampas de aceleración (≥ 200 medios pasos/s²) para no perder pasos con el láser montado.
- En reposo, las bobinas DEBERÍAN desenergizarse (menos calor y consumo). Si la prueba física
  muestra deriva, se mantiene energizado solo el eje de altura.

### 2.4 Alineación y posición inicial

- Al encender, la posición es desconocida: no hay finales de carrera.
- El firmware DEBE ofrecer una **alineación con 2 estrellas**:
  1. El usuario centra el haz manualmente, con mandos de movimiento, en la estrella 1 y confirma.
  2. Repite el paso con la estrella 2.
  3. El firmware calcula la matriz de transformación entre coordenadas horizontales teóricas y
     coordenadas de los motores (por ejemplo, el método de Taki).
- La alineación absorbe la falta de nivel del trípode (±2°) y la orientación al norte. No hace falta
  brújula.
- Recomendación: estrellas separadas entre sí entre 60° y 120° en azimut y con alturas de 20° a 70°.
- Hora y ubicación: hora por **NTP** (WiFi) o RTC/GPS; latitud y longitud configurables. Un minuto
  de error en la hora equivale a 0,25° de error.

### 2.5 Láser (relé)

| Regla | Valor |
|-------|-------|
| Estado al arrancar, reiniciar o con pánico | **Apagado** |
| Encendido continuo máximo | **30 s** (configurable, ≤ 60 s) |
| Enfriamiento obligatorio | Igual al tiempo encendido |
| Bloqueo por altura | Apagado si la altura es < 10° |
| Pérdida de control | Apagado si se pierde la conexión con el mando (WiFi o BLE) durante > 2 s |
| Lógica del relé | Activa en nivel alto, con módulo compatible con 3,3 V (ver 3) |

## 3. Conexiones (esquema de referencia)

```text
Power bank USB 5V ──> interruptor general ──┬──> ESP32 5V/VIN   (GND común)
                                            ├──> ULN2003 azimut +5V
                                            ├──> ULN2003 altura +5V
                                            └──> Relé VCC

ESP32 GPIO16,17,18,19 ──> ULN2003 azimut IN1..IN4 ──> 28BYJ-48 azimut (conector JST de 5 hilos)
ESP32 GPIO25,26,27,33 ──> ULN2003 altura IN1..IN4 ──> 28BYJ-48 altura (conector JST de 5 hilos)
ESP32 GPIO23          ──> Relé IN (activo en nivel alto)
Relé COM/NA           ──> 2 × 26 AWG de silicona ──> en paralelo al pulsador del láser 303
```

- Se evitan los pines de arranque (0, 2, 12 y 15) y los de solo entrada (34–39).
- Los motores **no** se alimentan desde el pin 3V3 ni a través del USB del ESP32.

## 4. Verificación del contrato

| Prueba | Criterio |
|--------|----------|
| 360° de azimut ordenados → marca de referencia | Vuelve a la marca con un error ≤ 0,3° (si falla, la constante de pasos está mal) |
| 10 idas y vueltas de 90° con llegada unidireccional | Dispersión ≤ 0,3° (SC-004) |
| La misma prueba sin llegada unidireccional | Debe aparecer el juego (0,25–0,75°): confirma que la compensación es necesaria |
| Láser encendido 31 s | El firmware lo apaga a los 30 s |
| Altura de 5° | El láser no enciende |

Estas pruebas se detallan en el [quickstart](../quickstart.md) (escenario 9).
