# Modelo de datos (Fase 1): Puntero láser estelar motorizado (alt-az)

**Funcionalidad**: [spec.md](spec.md) | **Investigación**: [research.md](research.md) |
**Contrato**: [contracts/interfaz_generador.md](contracts/interfaz_generador.md)

Los "datos" de este diseño son los parámetros de OpenSCAD, los valores que se derivan de ellos, las
reglas que los validan y las piezas que producen. Todo lo compartido vive en
`src/puntero_laser_parametros.scad`. Unidades: mm, salvo que se indique otra cosa.

---

## Entidad 1: Parámetros compartidos editables

Son públicos y aparecen en el Customizer con anotación de rango. Están agrupados.

### Grupo `Componentes comprados` (medir el ejemplar real)

| Parámetro | Por defecto | Rango | Origen |
|-----------|-------------|-------|--------|
| `diametro_laser` | 30 | 20 – 40 | FR-018 |
| `largo_laser` | 190 | 120 – 260 | FR-018 |
| `distancia_trasera_centro_masa` | 95 | 40 % – 60 % de `largo_laser` | FR-018 |
| `masa_laser_g` | 180 | 80 – 400 | R9 (solo para los cálculos impresos con `echo`) |
| `powerbank_largo` / `_ancho` / `_alto` | 100 / 65 / 25 | ≤ 150 / ≤ 75 / ≤ 30 | FR-018 |
| `esp32_largo` / `_ancho` | 55 / 28 | 48 – 60 / 25 – 32 | FR-018 |
| `rele_largo` / `_ancho` | 50 / 26 | 35 – 55 / 17 – 30 | FR-018 |
| `uln2003_largo` / `_ancho` | 35 / 32 | 30 – 42 / 20 – 35 | Supuesto de la especificación |
| `altura_placas` | 18 | 10 – 25 | Altura máxima de una placa con componentes |

### Grupo `Transmisión`

| Parámetro | Por defecto | Rango | Origen |
|-----------|-------------|-------|--------|
| `dientes_polea_motriz` | 20 | fijo (comprada) | R3 |
| `dientes_polea_conducida` | 80 | 80 – 100 | FR-005 (relación ≥ 1:4), FR-018 |
| `largo_correa` | 200 | 160 – 240 | R3 (largo cerrado comercial) |
| `ancho_correa` | 6 | 6 – 9 | R3 |
| `recorrido_tensor` | 3 | 2 – 6 | FR-006 |
| `ajuste_diente_gt2` | 0 | −0,15 – 0,15 | R3 |

### Grupo `Holguras`

| Parámetro | Por defecto | Rango |
|-----------|-------------|-------|
| `holgura_encastre` | 0,25 | 0,1 – 0,5 |
| `holgura_tornillo_m3` | 0,3 | 0,1 – 0,6 |
| `holgura_tuerca` | 0,2 | 0,1 – 0,4 |
| `holgura_perno_m8` | 0,4 | 0,2 – 0,8 |
| `ajuste_608` | 0,10 | −0,10 – 0,30 |
| `holgura_barrido` | 8 | 5 – 20 |

### Grupo `Estructura`

| Parámetro | Por defecto | Rango |
|-----------|-------------|-------|
| `espesor_plataforma` | 4 | 3 – 6 |
| `espesor_brazo` | 10 | 10 – 14 (≥ `rod608_ancho + labio_608`) |
| `ancho_brazo` | 36 | 30 – 45 |
| `pared_tubo_cuna` | 3 | 2 – 4 |
| `largo_tubo_cuna` | 100 | 70 – 140 |
| `holgura_colimacion` | 2 | 1 – 3 (por lado) |
| `separacion_608_azimut` | 16 | 10 – 30 (resalte entre rodamientos) |
| `diametro_apoyo_tripode` | 72 | 60 – 90 |
| `con_contrapeso` | true | bool |
| `con_ventana_pulsador` | true | bool |

### Grupo `Calidad`

| Parámetro | Por defecto |
|-----------|-------------|
| `$fn` | 64 (vista previa: 32) |

---

## Entidad 2: Constantes de componentes estándar (`/* [Hidden] */`)

Son medidas normalizadas, por eso no se editan. Van con nombre, nunca como número suelto.

| Constante | Valor | Componente |
|-----------|-------|------------|
| `rod608_d_ext`, `rod608_d_int`, `rod608_ancho`, `rod608_d_aro_int` | 22, 8, 7, 12,1 | Rodamiento 608ZZ |
| `m8_cabeza_ec`, `m8_cabeza_alto`, `m8_tuerca_ec`, `m8_autoblocante_alto` | 13, 5,3, 13, 8 | Perno y tuerca M8 |
| `m3_tuerca_ec`, `m3_tuerca_alto`, `m3_cabeza_d` | 5,5, 2,4, 5,5 | M3 |
| `tuerca_3_8_ec`, `tuerca_3_8_alto`, `rosca_3_8_d` | 14,29, 8,33, 9,525 | Tuerca 3/8"-16 UNC |
| `motor_d_cuerpo`, `motor_alto_cuerpo`, `motor_entre_orejas`, `motor_d_agujero_oreja` | 28, 19, 35, 4,2 | 28BYJ-48 |
| `motor_desplazamiento_eje`, `motor_d_resalte`, `motor_alto_resalte`, `motor_largo_eje` | 8, 9, 1,5, 9,5 | 28BYJ-48 |
| `motor_saliente_tapa` | 17 × 3 | Tapa azul de los cables del 28BYJ-48 |
| `polea20_d_brida`, `polea20_alto_total`, `polea20_alto_cubo`, `polea20_d_cubo` | 18, 16, 7, 13 | Polea GT2 20T con agujero de 5 mm |
| `paso_gt2`, `profundidad_diente_gt2`, `pld_gt2` | 2, 0,75, 0,254 | Perfil GT2 |
| `relacion_motor` | (32/9)·(22/11)·(26/9)·(31/10) = 63,68395 | 28BYJ-48 |
| `medios_pasos_motor` | 64 | 28BYJ-48 (32 pasos completos) |

---

## Entidad 3: Valores derivados (`/* [Hidden] */`)

| Derivado | Fórmula | Valor por defecto |
|----------|---------|-------------------|
| `d_primitivo_motriz` | `dientes_polea_motriz · paso_gt2 / PI` | 12,732 |
| `d_primitivo_conducida` | `dientes_polea_conducida · paso_gt2 / PI` | 50,930 |
| `d_exterior_conducida` | `d_primitivo_conducida − 2·pld_gt2` | 50,422 |
| `distancia_centros` | Solución numérica de la ecuación de correa abierta (función recursiva por bisección) | 45,97 |
| `relacion_correa` | `dientes_polea_conducida / dientes_polea_motriz` | 4 |
| `pasos_por_vuelta_eje` | `relacion_motor · medios_pasos_motor · relacion_correa` | 16 303,09 |
| `pasos_por_grado` | `pasos_por_vuelta_eje / 360` | 45,286 |
| `grados_por_paso` | `360 / pasos_por_vuelta_eje` | 0,0221 |
| `diametro_interior_cuna` | `diametro_laser + 2·holgura_colimacion` | 34 |
| `radio_exterior_cuna` | `diametro_interior_cuna/2 + pared_tubo_cuna` | 20 |
| `largo_munon` | `m8_cabeza_alto + holgura_tuerca − pared_tubo_cuna + piso_munon` (`piso_munon` = 2,2): el piso que retiene la cabeza M8 nunca baja de 2,2 en todo el rango | 4,7 |
| `semiancho_interior_horquilla` | `radio_exterior_cuna + largo_munon + holgura_munon_brazo` (0,5) | 25,2 |
| `l_trasero`, `l_delantero` | `distancia_trasera_centro_masa`, `largo_laser − l_trasero` | 95, 95 |
| `radio_barrido` | `max(l_trasero, l_delantero) + diametro_laser/2·sin(5°)` | 96,3 |
| `altura_eje` | `radio_barrido + holgura_barrido + altura_libre_central (5)` (sobre la cara superior de la plataforma) | ≈ 110 |
| `alto_brazo` | `altura_eje + rod608_d_ext/2 + 6` | ≈ 127 |
| `alto_pilar_motor` | `motor_alto_cuerpo + 1 + 1` (oreja + holgura) | 21 |
| `plano_correa_altura` | X del centro de los dientes de la 20T en el lado del motor | ≈ 68,5 |
| `largo_cubo_polea_altitud` | `plano_correa_altura − ancho_correa/2 − 1 − (semiancho_interior_horquilla + espesor_brazo)` | ≈ 29,5 |
| `z_plano_correa_azimut` | Z del centro de los dientes de la 20T bajo la plataforma | Derivado del motor y del carro |
| `largo_plataforma`, `ancho_plataforma` | Envolvente de las zonas de R5 | ≤ 196 |
| `masa_estimada_g`, `x_centro_masa_plataforma` | Suma de las masas de R9 | ≈ 980 g, ≈ −14 mm |
| `par_disponible_mNm` | `par_motor_mNm (34) · relacion_correa · rendimiento_correa (0,9)` | 122 |
| `par_desbalance_10_mNm`, `par_desbalance_20_mNm` | `(masa_laser_g + masa_cuna_g)/1000 · 9,81 · {10, 20}` (FR-024) | 23,5; 47,1 (factor de seguridad 5,2 y 2,6) |

Al renderizar el archivo de parámetros, los derivados clave se imprimen con `echo`, en especial los
que necesita el firmware: `pasos_por_grado`, `distancia_centros` y `altura_eje`.

---

## Reglas de validación

Son `assert` en `_parametros.scad`, salvo las que se indica que van en el ensamblaje. Cada mensaje
empieza con el nombre del parámetro, su valor y el límite, igual que en la funcionalidad 001.

| ID | Regla | Mensaje (resumen) |
|----|-------|-------------------|
| V-01 | Cada parámetro editable está dentro de su rango (Entidad 1) | `"<param>=<v>: fuera de rango [mín, máx]"` |
| V-02 | `0,4·largo_laser ≤ distancia_trasera_centro_masa ≤ 0,6·largo_laser` | El centro de masa no está cerca del medio; revisar la medición |
| V-03 | `largo_plataforma ≤ 196` y `ancho_plataforma ≤ 196`, y cada pieza ≤ 200 × 200 en su orientación de impresión | "No entra en la cama"; reducir el componente o el `largo_correa` |
| V-04 | `alto_brazo ≤ 196` (el brazo se imprime plano, así que su largo cuenta en la cama) | Láser demasiado largo para la horquilla |
| V-05 | `distancia_centros − motor_desplazamiento_eje − motor_d_cuerpo/2 ≥ d_exterior_conducida/2 + 2` en azimut, para que el cuerpo del motor no toque la polea fija | Correa demasiado corta |
| V-06 | Separación entre la 20T y la 80T: `distancia_centros ≥ (d_exterior_conducida + polea20_d_brida)/2 + 3` | Correa demasiado corta |
| V-07 | El barrido del láser (radio `radio_barrido` en la franja central) no toca la plataforma ni las piezas de la franja en todo el rango −10° … 95° (ensamblaje) | Subir `holgura_barrido` o equilibrar distinto |
| V-08 | El power bank, las placas y el motor de azimut caben en sus zonas sin solaparse y con 2 mm de separación (ensamblaje) | Componente demasiado grande para su zona |
| V-09 | Plano de la correa de altura: el centro de los dientes de la 20T y de la 80T difieren ≤ 0,5 mm; lo mismo en azimut | Planos de correa desalineados |
| V-10 | Eje del motor dentro del cubo de la polea 20T: ≥ 5 mm (en los dos ejes) | El eje no alcanza la polea |
| V-11 | Todas las holguras son > 0; `espesor_brazo ≥ rod608_ancho + labio_608`; cada entrada de `espesores_minimos` (lista por pieza, T025) es ≥ 1,2. El piso del muñón vale `piso_munon` = 2,2 por construcción | Pared insuficiente (nombra el parámetro que define esa pared) |
| V-12 | Corrección de colimación: `atan(2·holgura_colimacion / (largo_tubo_cuna − 8)) ≥ 1°` | No alcanza la corrección del haz |
| V-13 | `\|x_centro_masa_plataforma\| ≤ 20` (aviso con `echo` si > 5 sin contrapeso) | Plataforma desbalanceada |
| V-14 | Separación entre las caras exteriores de los 608 de azimut ≥ 20 | Demasiada inclinación posible |

---

## Entidad 4: Piezas impresas y módulos

Cada archivo `src/puntero_laser_<pieza>.scad` tiene encabezado estándar, `include` de los parámetros,
`module pieza_<pieza>()` modelado en la orientación de impresión y `ensamblaje_principal()`, que
llama al módulo de la pieza.

| Archivo | Módulo principal | Submódulos previstos | Orientación de impresión | STL |
|---------|------------------|----------------------|--------------------------|-----|
| `puntero_laser_adaptador_tripode.scad` | `pieza_adaptador_tripode()` | `cuerpo_base`, `alojamiento_tuerca_tripode`, `camara_tuerca_m8`, `ventana_llave`, `cubo_rodamientos`, `dentado_gt2(dientes, alto)` (compartido), `pestanas_polea` | Apoyo sobre la cama | `exports/puntero_laser_adaptador_tripode.stl` |
| `puntero_laser_plataforma_azimut.scad` | `pieza_plataforma_azimut()` | `placa_nervada`, `cubo_central`, `rebaje_brazo(lado)`, `asiento_carro`, `abertura_polea_azimut`, `bolsillo_powerbank`, `soporte_placa(l, a)`, `canal_cables`, `guias_tapa`, `alojamiento_contrapeso` | Cara inferior sobre la cama | `exports/puntero_laser_plataforma_azimut.stl` |
| `puntero_laser_brazo_horquilla.scad` (`lado = "motor"` / `"cable"`) | `pieza_brazo_horquilla(lado)` | `cuerpo_brazo`, `alojamiento_608`, `pie_brazo`, `pilares_motor`, `ranuras_carro`, `canal_cable_laser` | Cara interior sobre la cama (los pilares hacia arriba) | `exports/puntero_laser_brazo_horquilla_motor.stl`, `exports/puntero_laser_brazo_horquilla_cable.stl` |
| `puntero_laser_cuna_laser.scad` | `pieza_cuna_laser()` | `tubo`, `anillo_colimacion(z)`, `munon(lado)`, `ventana_pulsador`, `ranura_cable` | De pie, con el eje del tubo vertical; muñones con forma de gota | `exports/puntero_laser_cuna_laser.stl` |
| `puntero_laser_polea_altitud.scad` | `pieza_polea_altitud()` | `dentado_gt2`, `pestanas_polea`, `cubo_largo`, `alojamiento_tuerca_m8` | Cubo hacia arriba | `exports/puntero_laser_polea_altitud.stl` |
| `puntero_laser_carro_motor.scad` | `pieza_carro_motor()` | `placa_carro`, `agujeros_orejas`, `ranuras_fijacion`, `oreja_tensor` | Plano | `exports/puntero_laser_carro_motor.stl` (imprimir 2) |
| `puntero_laser_separador_azimut.scad` | `pieza_separador_azimut()` | — | De pie | `exports/puntero_laser_separador_azimut.stl` |
| `puntero_laser_tapa_electronica.scad` | `pieza_tapa_electronica()` | `cascara`, `rejillas_ventilacion`, `abertura_usb`, `encastres` | Techo sobre la cama | `exports/puntero_laser_tapa_electronica.stl` |
| `puntero_laser_probeta_ajuste_608.scad` | `pieza_probeta_ajuste_608()` | — | Plana | `exports/puntero_laser_probeta_ajuste_608.stl` |
| `puntero_laser_ensamblaje.scad` | `ensamblaje_principal()` | `componentes_comprados()`, `posicionar_<pieza>()`, `laser_en(angulo)` | — (solo para revisar) | **No se exporta** |

`dentado_gt2()` y `pestanas_polea()` se definen en `_parametros.scad` como módulos utilitarios
compartidos, para que la polea fija de la base y la polea de altura tengan exactamente el mismo
perfil.

---

## Entidad 5: Uniones entre piezas

| Unión | Piezas | Tipo | Holgura o ajuste |
|-------|--------|------|------------------|
| U-01 | Trípode ↔ adaptador | Tuerca 3/8"-16 embebida (cargada desde arriba) | `+holgura_tuerca` en el hexágono |
| U-02 | Adaptador ↔ 608 (×2) | A presión | `ajuste_608` |
| U-03 | Plataforma ↔ eje de azimut | Perno M8 con la cabeza en un hexágono de la plataforma, el cubo sobre el aro interior y la autoblocante en la cámara | `holgura_perno_m8` |
| U-04 | Plataforma ↔ brazos (×2) | Pie en un rebaje (guía de alineación) + 2 × M3 desde abajo con tuerca embebida en el pie | `holgura_encastre` en el rebaje |
| U-05 | Carro ↔ motor (×2) | 2 × M3 autorroscantes en las orejas | `diametro_autorroscante_m3` |
| U-06 | Carro ↔ plataforma o pilares | 2 × M3 en ranuras ± `recorrido_tensor` + M3 de empuje | `holgura_tornillo_m3` |
| U-07 | Brazos ↔ 608 (×2) | A presión desde la cara exterior, con labio interior | `ajuste_608` |
| U-08 | Cuna ↔ ejes de altura | Cabeza M8 en el hexágono del muñón; anillo que toca solo el aro interior | `holgura_tuerca` |
| U-09 | Polea de altura ↔ eje | Tuerca autoblocante M8 en el hexágono de la polea; cubo sobre el aro interior | `holgura_tuerca` |
| U-10 | Cuna ↔ láser | Deslizante + 6 × M3 radiales con tuerca embebida | `holgura_colimacion` |
| U-11 | Tapa ↔ plataforma | Guías de encastre + 2 × M3 | `holgura_encastre` |
| U-12 | Placas ↔ plataforma | Soportes con labio, a presión | `holgura_encastre` |

---

## Entidad 6: Componentes comprados (BOM)

Es la fuente de la lista de materiales de la guía.

| Cant. | Componente |
|-------|------------|
| 1 | ESP32 DevKit (30 o 38 pines) |
| 2 | Motor 28BYJ-48 de 5 V |
| 2 | Driver ULN2003 (placa) |
| 1 | Módulo relé de 1 canal compatible con lógica de 3,3 V |
| 1 | Puntero láser verde "303" |
| 1 | Power bank USB de 5 V y ≥ 2 A |
| 1 | Cable USB-A con salida a bornes + interruptor de palanca miniatura (rosca M6, tipo MTS-102), montado en la pared del bolsillo del power bank |
| 2 | Polea GT2 20T, agujero de 5 mm, para correa de 6 mm |
| 2 | Correa GT2 cerrada de 200 mm × 6 mm |
| 4 | Rodamiento 608ZZ |
| 1 | Perno M8 × 50 cabeza hexagonal |
| 1 | Perno M8 × 60 cabeza hexagonal |
| 1 | Perno M8 × 30 cabeza hexagonal |
| 3 | Tuerca autoblocante M8 |
| 4 | Arandela M8 (más arandelas de ajuste si hace falta) |
| 1 | Tuerca 3/8"-16 UNC |
| 6 | Tornillo M3 × 12 (colimación) + 6 tuercas M3 |
| 4 | Tornillo M3 × 8 (orejas de los motores, autorroscantes en el carro) |
| 4 + 2 | Tornillo M3 × 10 (fijación de los carros) + M3 × 16 (tensores) con sus tuercas M3 |
| 4 | Tornillo M3 × 12 (pies de los brazos) + 4 tuercas M3 |
| 2 | Tornillo M3 × 10 (tapa) + 2 tuercas M3 |
| — | Cable de silicona de 2 × 26 AWG (~40 cm), cables Dupont, sujetacables |

La guía de producción la confirma con los largos finales que dan los `echo` de los derivados.

---

## Entidad 7: Presupuesto de error

Lo calcula el ensamblaje con `echo`, a partir de los valores de [research.md](research.md#r4-presupuesto-de-error-de-apuntado-fr-016-fr-017-sc-003-sc-004).

- **Atributos**: lista de `[fuente, valor_grados, controlada_por]`, `error_rss` y `error_peor_caso`.
- **Regla**: `error_peor_caso < 2` (assert) y `error_rss ≤ 1` (aviso con `echo`).

---

## Estados del artefacto (ciclo de vida)

```text
parámetros editados ──> render de cada pieza sin advertencias ──> ensamblaje sin choques (asserts)
      ──> justificación estructural vigente (R10) ──> STL regenerados (todos) ──> guía actualizada
```

Si cambia cualquier parámetro compartido, todos los STL vuelven al estado "desactualizado" y hay que
regenerarlos juntos (skill §4).

---

## Cambios introducidos en la implementación

Lo que sigue prevalece sobre las tablas anteriores cuando difieren. El detalle de cada desviación
está en las «Notas de implementación» de [tasks.md](tasks.md).

### Disposición en planta (corrige R5)

| Zona | Antes (plan) | Implementado | Motivo |
|------|--------------|--------------|--------|
| Motor de azimut | +X, a `distancia_centros` del eje | **+Y** (eje en `[0, distancia_centros]`) | En +X el carro chocaba con el pie del brazo del motor. La franja +Y no la barre el extremo trasero del láser (solo llega a y ≤ 23 mm, cuando apunta a 95°) |
| Placas (ESP32, relé, 2 × ULN2003) | −X, junto al power bank | **+X**, en 2 columnas bajo el motor de altura | En −X no entraban junto al power bank y el centro de masa quedaba a ~23 mm del eje. Ahora queda a ≈ 4 mm |
| Power bank | −X | −X, centrado en Y para equilibrar el motor de azimut (`y_pb_c`) | — |
| Tapa | Cubría el lado −X | Cubre el lado +X (placas, interruptor y sobrante de cable) | Sigue a las placas |
| Interruptor general | Pared del bolsillo del power bank | **Soporte propio dentro de la tapa**; la palanca sale por una ranura de la tapa abierta desde abajo | Detrás de las paredes del bolsillo no hay espacio para el cuerpo del interruptor |
| Sobrante de cable | Hueco ≥ 40 × 25 mm en −X | `zona_sobrante_cables` (≈ 69 × 25 mm) al final de las columnas de placas, bajo la tapa | Sigue a las placas |

### Constantes añadidas (`/* [Hidden] */` de `puntero_laser_parametros.scad`)

| Constante | Valor | Uso |
|-----------|-------|-----|
| `d_contacto_aro` | **11,5** (antes 11) | Anillos y arandelas que apoyan solo en el aro interior. Con 11 la arandela bajaba a 1,1 mm de pared con `holgura_perno_m8 = 0.8` |
| `sobre_anillo_colim` | **3,5** (antes 5) | Engrosamiento de los anillos de colimación (ver R7 corregido) |
| `largo_prisionero`, `holgura_anillo_brazo` | 8, 1,5 | Colimación con prisioneros M3 × 8 embutidos; separación mínima entre anillo y brazo |
| `holgura_pcb` | 0,2 | Holgura vertical de las placas bajo el labio de sus soportes |
| `espesor_soporte_interruptor`, `ancho_soporte_interruptor`, `alto_interruptor` | 3, 20, 12 | Soporte del interruptor dentro de la tapa |
| `alto_sobrante_cables` | 25 | Alto (en Y) del hueco del cable sobrante |
| `largo_oreja_tapa`, `ancho_oreja_tapa`, `espesor_oreja_tapa` | 7, 10, 3 | Orejas M3 de la tapa |
| `largo_puente_brida`, `ancho_puente_brida`, `alto_puente_brida`, `paso_brida`, `x_puente_brida_az` | 8, 4, 3,5, 2,3, 20 | Puente para la brida del cable del motor de azimut |
| Base, plataforma, brazos, cuna y polea | ver archivo | `piso_base`, `libre_tornillo_tripode`, `d_camara`, `ancho_ventana`, `alto_brida_sup`, `pared_marco`, `alto_marco`, `alto_bolsillo`, `elevacion_esp32`, `pared_alojamiento_608`, `d_pilar`, `d_munon`, etc. |

### Derivados añadidos

| Derivado | Fórmula (resumen) | Por defecto |
|----------|-------------------|-------------|
| `largo_perno_azimut`, `largo_perno_alt_motor`, `largo_perno_alt_cable` | Largo comercial (múltiplo de 5) que cubre cada pila | M8 × 50, M8 × 55, M8 × 30 |
| `altura_camara` | Sobrante del perno de azimut + `libre_tornillo_tripode` | 21,5 |
| `z_tope_base`, `z_plataforma_inf`, `z_plataforma_sup`, `z_eje_altura` | Pila vertical de la base y la plataforma | 64,03; 66,53; 70,53; 179,84 |
| `alto_arandela_contacto` | Separación entre la base y la plataforma | 2,5 |
| `carro_x_min`, `carro_x_max`, `ranura_carro_x`, `ranura_carro_y`, `carro_semiancho` | Geometría del carro | −7,75; 27; 8; 27,5; 33 |
| `r_tope_int`, `r_tope_ext` | Tope tensor, medido desde el eje conducido (deja `recorrido_tensor` + 2 mm al carro) | 25,2; 33,2 |
| `x_centro_masa_plataforma`, `y_centro_masa_plataforma` | Centro de masa de la parte giratoria | ≈ 3,0; ≈ 3,0 |

### Reglas modificadas

- **V-05** pasa a ser: «entre el carro y el eje conducido entran el tope tensor y el alojamiento
  del 608» (`r_tope_int ≥ rod608_d_ext/2 + pared_alojamiento_608 + 2`). La versión original
  restaba el desplazamiento del eje del motor con el signo cambiado y fallaba con los valores por
  defecto, aunque no había choque real.
- **V-07** se evalúa en el archivo de parámetros, de forma analítica, sobre todas las zonas de la
  plataforma: secciones del láser y del tubo de la cuna cada 5 mm, de −10° a 95°. El ensamblaje
  agrega pruebas de intersección pieza a pieza.
- **V-11** usa la lista `espesores_minimos = [parámetro, valor, pared, espesor]`. El mensaje empieza
  por el parámetro que define la pared, por ejemplo
  `holgura_perno_m8=0.8: pared del separador = 0.85 mm`.
- Agregados: separación anillo–brazo ≥ 1,5 mm; prisionero embutido con el láser centrado;
  `d_contacto_aro < rod608_d_aro_int`; soporte del interruptor y hueco del sobrante; cuerpo de la base
  lejos de la polea 20T; cono de la base por encima de la cámara.
