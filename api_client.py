import httpx
from typing import List, Optional

class APIClient:
    def __init__(self, base_url: str):
        self.base_url = base_url
        self.client = httpx.Client(base_url=base_url)

    # ==========================
    # AUTH
    # ==========================
    def login(self, email: str, password: str):
        response = self.client.post("/auth/login", json={"email": email, "password": password})
        response.raise_for_status()
        return response.json()

    # ==========================
    # REGISTRO
    # ==========================
    def registrar_usuario(self, data: dict):
        """Registrar atleta o entrenador (según el payload)"""
        response = self.client.post("/registro/", json=data)
        response.raise_for_status()
        return response.json()

    # ==========================
    # ATLETAS
    # ==========================
    def crear_atleta(self, data: dict):
        response = self.client.post("/atletas/", json=data)
        response.raise_for_status()
        return response.json()

    def listar_atletas(self) -> List[dict]:
        response = self.client.get("/atletas/")
        response.raise_for_status()
        return response.json()

    def obtener_atleta(self, atleta_id: int):
        response = self.client.get(f"/atletas/{atleta_id}")
        response.raise_for_status()
        return response.json()

    def actualizar_atleta(self, atleta_id: int, data: dict):
        response = self.client.put(f"/atletas/{atleta_id}", json=data)
        response.raise_for_status()
        return response.json()

    def eliminar_atleta(self, atleta_id: int):
        response = self.client.delete(f"/atletas/{atleta_id}")
        response.raise_for_status()
        return response.status_code == 204

    def get_atleta_dashboard(self, id_usuario: int):
        response = self.client.get(f"/atletas/{id_usuario}")
        response.raise_for_status()
        return response.json()

    def get_atleta_basico(self, atleta_id: int):
        response = self.client.get(f"/atletas/basico/{atleta_id}")
        response.raise_for_status()
        return response.json()

    def get_atleta_by_usuario(self, id_usuario: int):
        response = self.client.get(f"/atletas/usuario/{id_usuario}")
        response.raise_for_status()
        return response.json()

    def editar_atleta(self, id_atleta: int, data: dict):
        response = self.client.put(f"/atletas/editar/{id_atleta}", json=data)
        response.raise_for_status()
        return response.json()

    # ==========================
    # ENTRENADORES
    # ==========================
    def crear_entrenador(self, data: dict):
        response = self.client.post("/entrenadores/", json=data)
        response.raise_for_status()
        return response.json()

    def listar_entrenadores(self) -> List[dict]:
        response = self.client.get("/entrenadores/")
        response.raise_for_status()
        return response.json()

    def obtener_entrenador(self, entrenador_id: int):
        response = self.client.get(f"/entrenadores/{entrenador_id}")
        response.raise_for_status()
        return response.json()

    def actualizar_entrenador(self, entrenador_id: int, data: dict):
        response = self.client.put(f"/entrenadores/{entrenador_id}", json=data)
        response.raise_for_status()
        return response.json()

    def eliminar_entrenador(self, entrenador_id: int):
        response = self.client.delete(f"/entrenadores/{entrenador_id}")
        response.raise_for_status()
        return response.status_code == 204

    # ==========================
    # COACHES
    # ==========================
    def get_coach_dashboard(self, id_usuario: int):
        response = self.client.get(f"/coaches/{id_usuario}")
        response.raise_for_status()
        return response.json()

    # ==========================
    # CERRAR CLIENTE
    # ==========================
    def close(self):
        self.client.close()


# Ejemplo de uso:
if __name__ == "__main__":
    client = APIClient("https://apifastpi-production.up.railway.app:8000")

    try:
        login = client.login("correo@example.com", "password123")
        print("Login:", login)

        atletas = client.listar_atletas()
        print("Atletas:", atletas)

    finally:
        client.close()
