import flet as ft
import os
from views.shared import show_login
from api_client import ApiClient
# from database import DatabaseManager

def main(page: ft.Page):
    # Configuración inicial de la página
    page.title = "SportPro - Gestión Deportiva"
    page.theme_mode = ft.ThemeMode.LIGHT
    page.padding = 0
    page.fonts = {
        "Roboto": "https://fonts.googleapis.com/css2?family=Roboto:wght@400;500;700&display=swap",
        "RobotoSlab": "https://fonts.googleapis.com/css2?family=Roboto+Slab:wght@400;500;700&display=swap"
    }

    # Inicializa el cliente API
    api = ApiClient(base_url="http://localhost:8000/api")  # <--- apunta a tu API

    # Pasa el cliente API en lugar de la base de datos
    show_login(page, api)
    
    # Muestra la pantalla de login inicial
    show_login(page, db)

# Configuración para el host
port = int(os.environ.get("PORT", 8505))  # Usa el puerto del entorno o 8505 por defecto

if __name__ == "__main__":
    ft.app(
        target=main,
        view=ft.AppView.WEB_BROWSER,
        assets_dir="assets",
        port=port
    )