# Contrato: cambios en la interfaz con el firmware

**Funcionalidad**: [../spec.md](../spec.md) | **Contrato base**:
[002 interfaz_firmware.md](../../002-puntero-laser-estelar/contracts/interfaz_firmware.md)

El contrato de la 002 sigue vigente: pasos por grado, llegada unidireccional, rangos y reglas del
láser. Cambian el circuito del láser y algunas garantías.

## 2.5 Láser (relé): lo que garantiza el hardware y lo que debe hacer el firmware

| Situación | Lo garantiza | Resultado |
|---|---|---|
| ESP32 sin energía, arrancando, reiniciándose, sin programa o en sueño profundo | **Hardware** (contacto NA + resistencia de 10 kΩ IN → GND) | Láser apagado, sin destellos |
| Cable entre el GPIO23 y el relé suelto | **Hardware** | Láser apagado |
| Firmware colgado con el GPIO23 en alto | **Firmware** | Debe usar un *watchdog* de tarea que, al dispararse, reinicie el ESP32; al reiniciar, el hardware apaga el láser |
| Encendido continuo, bloqueo por altura y pérdida del mando | **Firmware** (como en la 002) | Sin cambios: 30 s, < 10° y > 2 s |

Reglas nuevas o reforzadas:

- El GPIO23 DEBE quedar como salida en **bajo** en la primera línea de `setup()`, antes de iniciar
  el WiFi o los motores.
- El firmware NO DEBE activar pull-ups internos en el GPIO23.
- El firmware DEBE activar el *watchdog* de tareas del ESP32 (`esp_task_wdt`) con ≤ 5 s.
- Al encender el láser hay un retardo de ≈ 50 ms (arranque del regulador y del láser). El firmware no
  debe dar por encendido el haz antes de ese tiempo.

## 3. Conexiones (reemplaza el esquema de la 002)

```text
Power bank USB 5V ──> interruptor general ──┬──> ESP32 5V/VIN   (GND común)
                                            ├──> ULN2003 azimut +5V
                                            ├──> ULN2003 altura +5V
                                            ├──> Relé VCC
                                            └──> Relé COM
ESP32 GPIO16,17,18,19 ──> ULN2003 azimut IN1..IN4 ──> 28BYJ-48 azimut
ESP32 GPIO25,26,27,33 ──> ULN2003 altura IN1..IN4 ──> 28BYJ-48 altura
ESP32 GPIO23          ──> Relé IN (activo en nivel alto) ──[10 kΩ]──> GND
Relé NA               ──> Regulador MP1584 IN+          (IN− a GND)
Regulador OUT+ (3,7 V) ──> hilo rojo 26 AWG  ──> pila falsa (+, tornillo de la punta)
Regulador OUT−         ──> hilo negro 26 AWG ──> prisionero de la tapa trasera (−, cuerpo del láser)
```

## 4. Verificación (se suma a la de la 002)

| Prueba | Criterio |
|--------|----------|
| ESP32 sin programa (borrado) y el interruptor general cerrado | 0 V en la pila falsa |
| GPIO23 desconectado del relé | 0 V en la pila falsa |
| 10 arranques seguidos del ESP32 mirando el láser | Ningún destello |
| Firmware con un bucle infinito de prueba y el láser encendido | El *watchdog* reinicia el ESP32 en ≤ 5 s y el láser se apaga |
