import requests
from urllib3.util.retry import Retry
from requests.adapters import HTTPAdapter
import logging
import json

# Configurar logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

BASE_URL = "https://wger.de/api/v2/exerciseinfo/?language=2&limit=10"


def get_exercises(limit: int = 10, language: int = 2):
    """Obtiene ejercicios de la API de wger con manejo adecuado de traducciones"""
    session = requests.Session()
    retries = Retry(
        total=10,
        backoff_factor=1,
        status_forcelist=[502, 503, 504],
        allowed_methods=["GET"]
    )
    session.mount("https://", HTTPAdapter(max_retries=retries))

    params = {
        "language": language,
        "limit": limit
    }

    try:
        response = session.get(BASE_URL, params=params, timeout=10)
        response.raise_for_status()
        data = response.json()

        logger.info("✅ Datos obtenidos de la API:")

        # Procesar ejercicios para obtener nombres correctamente
        exercises = []
        for exercise in data.get("results", []):
            # El nombre está en las traducciones
            translations = exercise.get("translations", [])
            name = None

            # Buscar la traducción en el idioma especificado
            for translation in translations:
                if translation.get("language") == language:
                    name = translation.get("name")
                    break

            # Si no encontramos traducción, usar el primer nombre disponible
            if not name and translations:
                name = translations[0].get("name")

            # Si aún no hay nombre, usar un valor por defecto
            exercise_data = {
                "name": name or "Ejercicio sin nombre",
                "id": exercise.get("id"),
                "description": next(
                    (t.get("description") for t in translations
                     if t.get("language") == language),
                    None
                ) if translations else None,
                "category": exercise.get("category", {}).get("name"),
                "muscles": [m.get("name") for m in exercise.get("muscles", [])]
            }

            exercises.append(exercise_data)

            # Log solo los primeros 3 para debug
            if len(exercises) <= 3:
                logger.info(f"- {exercise_data['name']} (ID: {exercise_data['id']})")

        return {
            "count": data.get("count", 0),
            "next": data.get("next"),
            "previous": data.get("previous"),
            "results": exercises
        }

    except requests.exceptions.RequestException as e:
        logger.error(f"❌ Error al obtener ejercicios: {e}")
        return {"error": str(e)}


if __name__ == "__main__":
    # Ejemplo de uso
    print("=== Prueba de la API ===")
    print("\nObteniendo 5 ejercicios en español:")
    result_es = get_exercises(limit=5, language=2)
    print(json.dumps(result_es, indent=2, ensure_ascii=False))

    print("\nObteniendo 3 ejercicios en inglés:")
    result_en = get_exercises(limit=3, language=1)
    print(json.dumps(result_en, indent=2, ensure_ascii=False))