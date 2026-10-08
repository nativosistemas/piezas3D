# three.js 0.160.0 (copia fija)

Motor 3D del visor de armado (`scripts/generar_visor.py`). Se copia en el repositorio para que el
visor funcione sin internet: el generador incrusta estos archivos en `armado_3d.html` con un
*import map* de URL `data:` (ver `specs/005-visor-armado-3d/research.md`, R4).

| Archivo | Origen |
|---|---|
| `three.module.min.js` | https://cdn.jsdelivr.net/npm/three@0.160.0/build/three.module.min.js |
| `OrbitControls.js` | https://cdn.jsdelivr.net/npm/three@0.160.0/examples/jsm/controls/OrbitControls.js |
| `LICENSE` | https://cdn.jsdelivr.net/npm/three@0.160.0/LICENSE (MIT) |

Descargados el 2026-10-08. No se modifican: para cambiar de versión, reemplazar los tres archivos,
renombrar la carpeta y actualizar la ruta en `scripts/generar_visor.py`.
