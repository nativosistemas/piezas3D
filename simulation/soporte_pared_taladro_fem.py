# ==========================================
# Proyecto: piezas3D
# Componente: Soporte de pared para taladro
# Descripción: análisis FEM estático lineal (FreeCAD FEM + Gmsh + CalculiX) del soporte
# ==========================================
#
# Uso, desde la raíz del repositorio:
#   .tools/bin/freecadcmd simulation/soporte_pared_taladro_fem.py
#
# Variables de entorno opcionales:
#   FEM_VARIANTE = base (por defecto) | conservadora | pesima
#     base         : avellanados fijos, cara trasera con desplazamiento Y = 0 (apoyo en pared),
#                    25 N hacia -Z repartidos en la cara superior de la bandeja.
#     conservadora : igual que base, pero el apoyo en pared se reduce a la arista inferior
#                    trasera (la placa pivota sobre su borde inferior).
#     pesima       : igual que base, pero los 25 N se aplican solo sobre las caras superiores
#                    de los labios (carga concentrada en el borde frontal).
#   FEM_MALLA_MM = tamaño máximo de elemento en mm (por defecto 2)
#   FEM_GUARDAR_RESULTADOS = 1 para guardar el .FCStd con malla y resultados (~40 MB);
#     por defecto se guarda liviano, sin malla ni resultados
#
# Requisitos: exportar antes el CSG con
#   .tools/bin/openscad -o simulation/soporte_pared_taladro.csg src/soporte_pared_taladro.scad
#
# Salida: líneas «RESULTADO …» con la tensión de von Mises máxima y la flecha del borde
# frontal; en la variante base con malla por defecto guarda simulation/soporte_pared_taladro.FCStd
# (liviano: análisis listo para mallar y resolver, sin malla ni resultados)

import os
import FreeCAD
import Fem
import Part
import ObjectsFem
import importCSG
from femmesh.gmshtools import GmshTools
from femtools import ccxtools

# --- PARÁMETROS Y CONSTANTES ---
CARGA_N = 25.0                     # carga de diseño: taladro de 2,5 kg (FR-014)
SIGMA_ADMISIBLE_MPA = 10.0         # 30 MPa (PETG impreso, R8) / factor de seguridad 3
FLECHA_ADMISIBLE_MM = 1.0          # SC-003
DISTANCIA_SINGULARIDAD_MM = 2.0    # se ignoran tensiones a menos de esta distancia de las fijaciones
TOLERANCIA_MM = 1e-4               # tolerancia geométrica para clasificar caras
MATERIAL = {
    "Name": "PETG",
    "YoungsModulus": "2000 MPa",
    "PoissonRatio": "0.38",
    "Density": "1270 kg/m^3",
}

VARIANTE = os.environ.get("FEM_VARIANTE", "base")
MALLA_MM = float(os.environ.get("FEM_MALLA_MM", "2"))
GUARDAR_RESULTADOS = os.environ.get("FEM_GUARDAR_RESULTADOS", "0") == "1"
if VARIANTE not in ("base", "conservadora", "pesima"):
    raise ValueError("FEM_VARIANTE debe ser base, conservadora o pesima (recibido: %s)" % VARIANTE)


def raiz_repositorio():
    """Raíz del repositorio: el directorio de trabajo o, si no contiene el CSG, el padre del script."""
    candidatos = [os.getcwd()]
    if "__file__" in globals():
        candidatos.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
    for c in candidatos:
        if os.path.isfile(os.path.join(c, "simulation", "soporte_pared_taladro.csg")):
            return c
    raise FileNotFoundError("No se encuentra simulation/soporte_pared_taladro.csg; exporte antes el CSG")


RAIZ = raiz_repositorio()
RUTA_CSG = os.path.join(RAIZ, "simulation", "soporte_pared_taladro.csg")
RUTA_FCSTD = os.path.join(RAIZ, "simulation", "soporte_pared_taladro.FCStd")


# --- GEOMETRÍA ---
def importar_solido():
    """Importa el CSG en un documento temporal y devuelve el sólido refinado."""
    temporal = FreeCAD.newDocument("importacion_csg")
    importCSG.insert(RUTA_CSG, temporal.Name)
    temporal.recompute()
    raices = [o for o in temporal.Objects if not o.InList]
    forma = raices[0].Shape.removeSplitter()
    FreeCAD.closeDocument(temporal.Name)
    if len(forma.Solids) != 1 or not forma.isValid():
        raise RuntimeError("El CSG no produce un único sólido válido")
    return forma.Solids[0]


def es_plana_con_normal(cara, normal):
    if not isinstance(cara.Surface, Part.Plane):
        return False
    n = cara.normalAt(*cara.Surface.parameter(cara.CenterOfMass))
    return n.isEqual(normal, 1e-6)


def caras_por_criterio(solido, criterio):
    return ["Face%d" % (i + 1) for i, c in enumerate(solido.Faces) if criterio(c)]


def deducir_geometria(solido):
    """Deduce cotas por forma, no por nombre de cara (los FaceN cambian con los parámetros)."""
    bb = solido.BoundBox
    arriba = FreeCAD.Vector(0, 0, 1)
    alturas = sorted(c.BoundBox.ZMin for c in solido.Faces
                     if es_plana_con_normal(c, arriba) and c.BoundBox.ZMin > TOLERANCIA_MM)
    return {"profundidad": bb.YMax, "espesor": alturas[0], "altura": bb.ZMax}


# --- ANÁLISIS ---
def construir_analisis(doc, pieza, geo):
    solido = pieza.Shape
    e, p = geo["espesor"], geo["profundidad"]
    arriba, atras = FreeCAD.Vector(0, 0, 1), FreeCAD.Vector(0, -1, 0)

    analisis = ObjectsFem.makeAnalysis(doc, "Analisis")
    solver = ObjectsFem.makeSolverCalculiXCcxTools(doc, "CalculiX")
    solver.AnalysisType = "static"
    solver.GeometricalNonlinearity = "linear"

    material = ObjectsFem.makeMaterialSolid(doc, "PETG")
    m = material.Material
    m.update(MATERIAL)
    material.Material = m

    # Fijación: caras cónicas de los avellanados (en la placa, Y <= espesor de la placa)
    avellanados = caras_por_criterio(solido, lambda c: isinstance(c.Surface, Part.Cone)
                                     and c.BoundBox.YMax <= e + TOLERANCIA_MM)
    fijo = ObjectsFem.makeConstraintFixed(doc, "FijacionAvellanados")
    fijo.References = [(pieza, avellanados)]

    # Apoyo en pared: solo se impide el desplazamiento perpendicular a la pared (Y)
    apoyo = ObjectsFem.makeConstraintDisplacement(doc, "ApoyoPared")
    if VARIANTE == "conservadora":
        aristas = ["Edge%d" % (i + 1) for i, a in enumerate(solido.Edges)
                   if isinstance(a.Curve, Part.Line) and a.BoundBox.YMax < TOLERANCIA_MM
                   and a.BoundBox.ZMax < TOLERANCIA_MM and a.BoundBox.XLength > TOLERANCIA_MM]
        apoyo.References = [(pieza, aristas)]
    else:
        trasera = caras_por_criterio(solido, lambda c: es_plana_con_normal(c, atras)
                                     and c.BoundBox.YMax < TOLERANCIA_MM)
        apoyo.References = [(pieza, trasera)]
    apoyo.xFree, apoyo.yFree, apoyo.zFree = True, False, True
    apoyo.yDisplacement = 0.0

    # Carga: 25 N hacia -Z
    if VARIANTE == "pesima":
        cargadas = caras_por_criterio(solido, lambda c: es_plana_con_normal(c, arriba)
                                      and c.BoundBox.ZMin > e + TOLERANCIA_MM
                                      and c.BoundBox.YMax > p - TOLERANCIA_MM)
    else:
        cargadas = caras_por_criterio(solido, lambda c: es_plana_con_normal(c, arriba)
                                      and abs(c.BoundBox.ZMin - e) < TOLERANCIA_MM)
    fuerza = ObjectsFem.makeConstraintForce(doc, "CargaTaladro")
    fuerza.References = [(pieza, cargadas)]
    fuerza.Force = "%g N" % CARGA_N
    vertical = ["Edge%d" % (i + 1) for i, a in enumerate(solido.Edges)
                if isinstance(a.Curve, Part.Line)
                and abs(abs(a.Curve.Direction.z) - 1) < 1e-9][0]
    fuerza.Direction = (pieza, [vertical])
    doc.recompute()
    if fuerza.DirectionVector.z > 0:
        fuerza.Reversed = not fuerza.Reversed
        doc.recompute()

    malla = ObjectsFem.makeMeshGmsh(doc, "Malla")
    malla.Shape = pieza
    malla.ElementOrder = "2nd"
    malla.CharacteristicLengthMax = "%g mm" % MALLA_MM

    for o in (solver, material, fijo, apoyo, fuerza, malla):
        analisis.addObject(o)
    doc.recompute()
    referencias = {"avellanados": avellanados, "apoyo": apoyo.References[0][1], "carga": cargadas}
    return analisis, solver, malla, fuerza, referencias


def evaluar(doc, pieza, malla, geo, referencias):
    resultado = [o for o in doc.Objects if o.isDerivedFrom("Fem::FemResultObject")][0]
    nodos = malla.FemMesh.Nodes
    e, p = geo["espesor"], geo["profundidad"]

    # Zonas singulares: fijaciones rígidas (y la arista de apoyo en la variante conservadora)
    singulares = [pieza.Shape.getElement(n) for n in referencias["avellanados"]]
    if VARIANTE == "conservadora":
        singulares += [pieza.Shape.getElement(n) for n in referencias["apoyo"]]
    cajas = []
    for s in singulares:
        b = FreeCAD.BoundBox(s.BoundBox)
        b.enlarge(DISTANCIA_SINGULARIDAD_MM)
        cajas.append((b, s))

    def cerca_de_singularidad(punto):
        for caja, s in cajas:
            if caja.isInside(punto) and s.distToShape(Part.Vertex(punto))[0] < DISTANCIA_SINGULARIDAD_MM:
                return True
        return False

    sigma_bruta = max(resultado.vonMises)
    sigma_util, nodo_sigma = 0.0, None
    flecha, nodo_flecha = 0.0, None
    for nodo, sigma, u in zip(resultado.NodeNumbers, resultado.vonMises, resultado.DisplacementVectors):
        punto = nodos[nodo]
        if sigma > sigma_util and not cerca_de_singularidad(punto):
            sigma_util, nodo_sigma = sigma, punto
        if punto.y >= p - 0.5 and punto.z <= e + TOLERANCIA_MM and abs(u.z) > flecha:
            flecha, nodo_flecha, uz = abs(u.z), punto, u.z
    return {
        "nodos": malla.FemMesh.NodeCount,
        "sigma_max": sigma_util, "sigma_bruta": sigma_bruta, "nodo_sigma": nodo_sigma,
        "flecha": flecha, "uz_signo": uz, "nodo_flecha": nodo_flecha,
    }


# --- EJECUCIÓN ---
def main():
    solido = importar_solido()
    geo = deducir_geometria(solido)
    doc = FreeCAD.newDocument("soporte_pared_taladro_fem")
    pieza = doc.addObject("Part::Feature", "Soporte")
    pieza.Shape = solido
    doc.recompute()

    analisis, solver, malla, fuerza, referencias = construir_analisis(doc, pieza, geo)
    print("INFO geometria: profundidad=%.2f espesor=%.2f altura=%.2f" % (geo["profundidad"], geo["espesor"], geo["altura"]))
    print("INFO referencias: avellanados=%s apoyo=%s carga=%s" % (referencias["avellanados"], referencias["apoyo"], referencias["carga"]))
    print("INFO direccion carga: %s" % fuerza.DirectionVector)
    if len(referencias["avellanados"]) != 2 or not referencias["apoyo"] or not referencias["carga"]:
        raise RuntimeError("Selección de caras inesperada; revise la geometría")

    error = GmshTools(malla).create_mesh()
    if error:
        raise RuntimeError("Gmsh: %s" % error)

    fea = ccxtools.FemToolsCcx(analisis, solver)
    fea.update_objects()
    fea.setup_working_dir()
    fea.setup_ccx()
    mensaje = fea.check_prerequisites()
    if mensaje:
        raise RuntimeError("Prerrequisitos FEM: %s" % mensaje)
    fea.purge_results()
    fea.write_inp_file()
    fea.ccx_run()
    fea.load_results()

    r = evaluar(doc, pieza, malla, geo, referencias)
    if r["uz_signo"] > 0:
        raise RuntimeError("El borde frontal sube: el sentido de la carga es incorrecto")
    cumple = r["sigma_max"] <= SIGMA_ADMISIBLE_MPA and r["flecha"] <= FLECHA_ADMISIBLE_MM
    print("INFO sigma_max en (%.1f, %.1f, %.1f) mm; flecha en (%.1f, %.1f, %.1f) mm"
          % (tuple(r["nodo_sigma"]) + tuple(r["nodo_flecha"])))
    print("RESULTADO variante=%s malla_mm=%g nodos=%d sigma_max_MPa=%.3f sigma_bruta_MPa=%.3f "
          "flecha_frontal_mm=%.4f cumple=%s"
          % (VARIANTE, MALLA_MM, r["nodos"], r["sigma_max"], r["sigma_bruta"], r["flecha"],
             "SI" if cumple else "NO"))

    if VARIANTE == "base" and MALLA_MM == 2.0:
        if not GUARDAR_RESULTADOS:
            # Versión liviana: se conserva el análisis completo (geometría, material, condiciones
            # de contorno, carga, solver y parámetros de malla) sin la malla ni los resultados,
            # que ocupan ~40 MB y se regeneran ejecutando este script
            sobrantes = [o for o in doc.Objects
                         if o.isDerivedFrom("Fem::FemResultObject")
                         or o.isDerivedFrom("Fem::FemPostObject")      # pipeline VTK y filtros
                         or o.isDerivedFrom("App::TextDocument")       # salida .dat de CalculiX
                         or (o.isDerivedFrom("Fem::FemMeshObject") and o is not malla)]
            for o in sobrantes:
                doc.removeObject(o.Name)
            malla.FemMesh = Fem.FemMesh()
            doc.recompute()
        doc.saveAs(RUTA_FCSTD)
        print("INFO guardado %s (%s)" % (os.path.relpath(RUTA_FCSTD, RAIZ),
              "con malla y resultados" if GUARDAR_RESULTADOS else "liviano, sin malla ni resultados"))


main()
