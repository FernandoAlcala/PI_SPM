import flet as ft
import os
from views.shared import show_login
from api_client import APIClient

def main(page: ft.Page):
    # Configuración inicial de la página
    page.title = "SPM - Sport Performance Metrics"
    page.theme_mode = ft.ThemeMode.LIGHT
    page.padding = 0
    page.fonts = {
        "Roboto": "https://fonts.googleapis.com/css2?family=Roboto:wght@400;500;700&display=swap",
        "RobotoSlab": "https://fonts.googleapis.com/css2?family=Roboto+Slab:wght@400;500;700&display=swap"
    }

    # Inicializa el cliente API
    api = APIClient(base_url="http://localhost:8000")  # <-- Ajusta el prefijo si tu API usa /api

    # Función para manejar el login
    def handle_login(email: str, password: str):
        try:
            login_data = api.login(email, password)
            page.snack_bar = ft.SnackBar(ft.Text("Inicio de sesión exitoso"), open=True)
            return login_data
        except Exception as e:
            page.snack_bar = ft.SnackBar(ft.Text(f"Error de login: {e}"), open=True)
            return None

    # Pasa el cliente API y el manejador de login a la vista
    show_login(page, api, handle_login)

# Configuración para el host
port = int(os.environ.get("PORT", 8505))  # Usa el puerto del entorno o 8505 por defecto

if __name__ == "__main__":
    ft.app(
        target=main,
        view=ft.AppView.WEB_BROWSER,
        assets_dir="assets",
        port=port
    )
