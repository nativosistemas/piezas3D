# Vista de revisión de mallas STL sin OpenGL (OpenSCAD 2021.01 no exporta PNG en este entorno).
# Se ejecuta con el Python de FreeCAD, que trae matplotlib y numpy:
#
#   VISTA_ENTRADAS="a.stl:#888888;b.stl:tab:orange" VISTA_SALIDA=vista.png \
#   VISTA_VISTAS="30,-60;0,0;90,-90" .tools/bin/freecadcmd specs/002-puntero-laser-estelar/vista_stl.py
#
# VISTA_VISTAS es una lista de "elevación,azimut" (grados); se dibuja un panel por vista.
import os
import struct

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
from mpl_toolkits.mplot3d.art3d import Poly3DCollection


def leer_stl(ruta):
    with open(ruta, "rb") as f:
        datos = f.read()
    if datos[:5] == b"solid" and b"facet" in datos[:300]:
        v = [tuple(map(float, l.split()[1:4])) for l in datos.decode(errors="ignore").splitlines()
             if l.strip().startswith("vertex")]
        return np.array(v).reshape(-1, 3, 3)
    n = struct.unpack("<I", datos[80:84])[0]
    tri = np.frombuffer(datos[84:84 + n*50], dtype=np.dtype([("n", "<3f4"), ("v", "<9f4"), ("a", "<u2")]))
    return tri["v"].reshape(-1, 3, 3).astype(float)


def sombrear(tri, color, luz=np.array([0.3, -0.5, 0.8])):
    normales = np.cross(tri[:, 1] - tri[:, 0], tri[:, 2] - tri[:, 0])
    largo = np.linalg.norm(normales, axis=1, keepdims=True)
    normales = normales/np.where(largo == 0, 1, largo)
    k = 0.35 + 0.65*np.clip(np.abs(normales @ (luz/np.linalg.norm(luz))), 0, 1)
    base = np.array(matplotlib.colors.to_rgb(color))
    return np.clip(base[None, :]*k[:, None], 0, 1)


entradas = [e.rsplit(":", 1) if e.count(":") >= 1 and not e.endswith(".stl") else [e, "#9aa5b1"]
            for e in os.environ["VISTA_ENTRADAS"].split(";") if e]
vistas = [tuple(map(float, v.split(","))) for v in os.environ.get("VISTA_VISTAS", "30,-60").split(";")]
mallas = [(leer_stl(r), c) for r, c in entradas]
todos = np.concatenate([m.reshape(-1, 3) for m, _ in mallas])
lo, hi = todos.min(axis=0), todos.max(axis=0)
centro, rango = (lo + hi)/2, (hi - lo).max()/2

fig = plt.figure(figsize=(6*len(vistas), 6))
for i, (elev, azim) in enumerate(vistas):
    ax = fig.add_subplot(1, len(vistas), i + 1, projection="3d")
    for tri, color in mallas:
        ax.add_collection3d(Poly3DCollection(tri, facecolors=sombrear(tri, color), edgecolors="none"))
    for eje, c in zip("xyz", centro):
        getattr(ax, f"set_{eje}lim")(c - rango, c + rango)
    ax.set_box_aspect((1, 1, 1))
    ax.view_init(elev=elev, azim=azim)
    ax.set_xlabel("X")
    ax.set_ylabel("Y")
    ax.set_zlabel("Z")
    ax.set_title(f"elev {elev:g}°, azim {azim:g}°")
fig.tight_layout()
fig.savefig(os.environ.get("VISTA_SALIDA", "vista.png"), dpi=90)
print("VISTA_OK", os.environ.get("VISTA_SALIDA", "vista.png"), sum(len(m) for m, _ in mallas), "triángulos")
