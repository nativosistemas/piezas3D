# Contrato: la página del visor

`specs/<NNN>/web/armado_3d.html`: un solo archivo, sin recursos externos.

## Direcciones

| Dirección | Efecto |
|---|---|
| `armado_3d.html` | Abre en el paso 1 y reproduce su movimiento |
| `armado_3d.html#paso-N` | Abre en el paso N de la guía (lo usan los enlaces de la web) |
| `armado_3d.html?paso=N&t=0.5` | Paso N congelado en ese punto del movimiento (revisión y capturas) |

Un paso que no existe abre el paso 1.

## Enlaces desde la web (`index.html`)

- Antes de la lista de pasos: "Ver el armado en 3D" → `armado_3d.html`.
- En cada paso con piezas: "Ver en 3D" → `armado_3d.html#paso-N`.
- Desde el visor: "Volver a la guía" → `index.html#instrucciones-paso-a-paso`.

## Controles

| Control | Mouse / teclado | Tacto |
|---|---|---|
| Girar | Arrastrar con el botón izquierdo | Un dedo |
| Acercar | Rueda | Pellizcar |
| Desplazar | Botón derecho o Mayús + arrastrar | Dos dedos |
| Paso siguiente / anterior | Botones, `→` / `←` | Botones |
| Ir a un paso | Selector de paso | Selector de paso |
| Repetir | Botón, `Espacio` | Botón |
| Recorrer el movimiento | Deslizador | Deslizador |
| Vista inicial (encuadra lo que se ve en el paso actual: lo ya armado y las piezas nuevas, en su lugar y separadas; al abrir, la del paso abierto) | Botón, `Inicio` | Botón |

## Datos incrustados

Un `<script type="application/json" id="datos-visor">` con el objeto descrito en
[../data-model.md](../data-model.md#2-datos-incrustados-en-el-visor-json):

```json
{
  "version": 1,
  "diseno": "puntero_laser",
  "huella": "sha256:…",
  "fn": 32,
  "pasos": [
    { "n": 8, "titulo": "Horquilla a la plataforma", "texto": "Colocar una tuerca M3…",
      "entradas": [ { "e": "tuercas_pie_motor", "d": [35, 0, 50], "r": true, "o": [0, 0, 50], "g": null } ],
      "contexto": ["cuna", "brazo_motor"] }
  ],
  "elementos": { "brazo_motor": { "color": "SteelBlue", "malla": "<base64 de Float32 x,y,z>" } }
}
```

El texto de cada paso conserva las negritas de la guía (`**…**`), que el visor muestra como negrita.

## Sin gráficos 3D

Si el navegador no puede crear el contexto 3D, la página muestra: "Este navegador no puede mostrar
el visor 3D." y un enlace a la web de armado con las capturas.
