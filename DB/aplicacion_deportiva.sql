-- Creación de la base de datosapp_managementapp_managementaplicacion_deportiva
DROP DATABASE IF EXISTS aplicacion_deportiva;
CREATE DATABASE aplicacion_deportiva CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE aplicacion_deportiva;

-- Tabla usuarios (para manejar los 3 roles)
CREATE TABLE usuarios (
    id_usuario INT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(100) UNIQUE NOT NULL,
    contrasena_hash VARCHAR(255) NOT NULL,
    tipo ENUM('atleta', 'entrenador', 'administrador') NOT NULL,
    fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP,
    ultimo_login DATETIME,
    activo BOOLEAN DEFAULT TRUE
) ENGINE=InnoDB;

-- Tabla perfiles_entrenadores
CREATE TABLE perfiles_entrenadores (
    id_entrenador INT PRIMARY KEY AUTO_INCREMENT,
    id_usuario INT UNIQUE NOT NULL,
    nombre_completo VARCHAR(100) NOT NULL,
    fecha_nacimiento DATE,
    especialidad VARCHAR(50),
    experiencia TEXT,
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario) ON DELETE CASCADE
) ENGINE=InnoDB;

-- Tabla perfiles_atletas
CREATE TABLE perfiles_atletas (
    id_atleta INT PRIMARY KEY AUTO_INCREMENT,
    id_usuario INT UNIQUE NOT NULL,
    nombre_completo VARCHAR(100) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    altura DECIMAL(5,2) COMMENT 'En centímetros',
    peso DECIMAL(5,2) COMMENT 'En kilogramos',
    deporte VARCHAR(50) NOT NULL,
    id_entrenador INT,
    frecuencia_cardiaca_maxima INT,
    frecuencia_cardiaca_minima INT,
    FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario) ON DELETE CASCADE,
    FOREIGN KEY (id_entrenador) REFERENCES perfiles_entrenadores(id_entrenador)
) ENGINE=InnoDB;

-- Tabla ejercicios (catálogo de ejercicios)
CREATE TABLE ejercicios (
    id_ejercicio INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    tipo ENUM('cardio', 'fuerza', 'flexibilidad', 'equilibrio'),
    instrucciones TEXT,
    video_url VARCHAR(255)
) ENGINE=InnoDB;

-- Tabla entrenamientos
CREATE TABLE entrenamientos (
    id_entrenamiento INT PRIMARY KEY AUTO_INCREMENT,
    id_entrenador INT NOT NULL,
    titulo VARCHAR(100) NOT NULL,
    descripcion TEXT,
    duracion_estimada INT COMMENT 'En minutos',
    fecha_creacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    nivel_dificultad ENUM('principiante', 'intermedio', 'avanzado'),
    FOREIGN KEY (id_entrenador) REFERENCES perfiles_entrenadores(id_entrenador)
) ENGINE=InnoDB;

-- Tabla entrenamiento_ejercicios (relación muchos a muchos)
CREATE TABLE entrenamiento_ejercicios (
    id_entrenamiento_ejercicio INT PRIMARY KEY AUTO_INCREMENT,
    id_entrenamiento INT NOT NULL,
    id_ejercicio INT NOT NULL,
    series INT,
    repeticiones INT,
    duracion INT COMMENT 'En segundos, para ejercicios de tiempo',
    orden INT NOT NULL,
    descanso INT COMMENT 'Descanso en segundos entre series',
    notas TEXT,
    FOREIGN KEY (id_entrenamiento) REFERENCES entrenamientos(id_entrenamiento) ON DELETE CASCADE,
    FOREIGN KEY (id_ejercicio) REFERENCES ejercicios(id_ejercicio)
) ENGINE=InnoDB;

-- Tabla asignaciones_atletas (para asignar entrenamientos a atletas)
CREATE TABLE asignaciones_atletas (
    id_asignacion INT PRIMARY KEY AUTO_INCREMENT,
    id_entrenamiento INT NOT NULL,
    id_atleta INT NOT NULL,
    fecha_asignacion DATETIME DEFAULT CURRENT_TIMESTAMP,
    fecha_completado DATETIME,
    estado ENUM('pendiente', 'en_progreso', 'completado', 'cancelado') DEFAULT 'pendiente',
    feedback TEXT,
    calificacion INT COMMENT 'Del 1 al 5',
    FOREIGN KEY (id_entrenamiento) REFERENCES entrenamientos(id_entrenamiento),
    FOREIGN KEY (id_atleta) REFERENCES perfiles_atletas(id_atleta)
) ENGINE=InnoDB;

-- Vista para contar atletas por entrenador
CREATE VIEW vista_entrenador_conteo_atletas AS
SELECT
    e.id_entrenador,
    e.nombre_completo AS nombre_entrenador,
    COUNT(a.id_atleta) AS cantidad_atletas
FROM
    perfiles_entrenadores e
LEFT JOIN
    perfiles_atletas a ON e.id_entrenador = a.id_entrenador
GROUP BY
    e.id_entrenador, e.nombre_completo;

-- Vista para entrenamientos asignados
CREATE VIEW vista_entrenamientos_atletas AS
SELECT
    aa.id_asignacion,
    a.id_atleta,
    a.nombre_completo AS nombre_atleta,
    e.id_entrenamiento,
    e.titulo AS titulo_entrenamiento,
    en.nombre_completo AS nombre_entrenador,
    aa.fecha_asignacion,
    aa.estado
FROM
    asignaciones_atletas aa
JOIN
    perfiles_atletas a ON aa.id_atleta = a.id_atleta
JOIN
    entrenamientos e ON aa.id_entrenamiento = e.id_entrenamiento
JOIN
    perfiles_entrenadores en ON e.id_entrenador = en.id_entrenador;

-- Datos iniciales de ejemplo

-- Insertar usuarios de ejemplo
INSERT INTO usuarios (email, contrasena_hash, tipo) VALUES
('admin@deportes.com', '$2y$10$Hx4VZJ5J5Z5Z5Z5Z5Z5Z5O', 'administrador'),
('entrenador1@deportes.com', '$2y$10$Hx4VZJ5J5Z5Z5Z5Z5Z5Z5O', 'entrenador'),
('entrenador2@deportes.com', '$2y$10$Hx4VZJ5J5Z5Z5Z5Z5Z5Z5O', 'entrenador'),
('atleta1@deportes.com', '$2y$10$Hx4VZJ5J5Z5Z5Z5Z5Z5Z5O', 'atleta'),
('atleta2@deportes.com', '$2y$10$Hx4VZJ5J5Z5Z5Z5Z5Z5Z5O', 'atleta'),
('atleta3@deportes.com', '$2y$10$Hx4VZJ5J5Z5Z5Z5Z5Z5Z5O', 'atleta');

-- Insertar perfiles de entrenadores
INSERT INTO perfiles_entrenadores (id_usuario, nombre_completo, fecha_nacimiento, especialidad) VALUES
(2, 'Carlos Méndez', '1980-05-15', 'Atletismo'),
(3, 'Ana López', '1985-08-22', 'Natación');

-- Insertar perfiles de atletas
INSERT INTO perfiles_atletas (id_usuario, nombre_completo, fecha_nacimiento, altura, peso, deporte, id_entrenador, frecuencia_cardiaca_maxima, frecuencia_cardiaca_minima) VALUES
(4, 'Juan Pérez', '1995-03-10', 175.5, 70.2, 'Atletismo', 1, 190, 60),
(5, 'María García', '1998-07-25', 165.0, 58.7, 'Natación', 2, 185, 55),
(6, 'Luis Rodríguez', '1992-11-30', 182.3, 75.4, 'Atletismo', 1, 195, 65);

-- Insertar ejercicios de ejemplo
INSERT INTO ejercicios (nombre, descripcion, tipo, instrucciones) VALUES
('Sentadillas', 'Ejercicio para fortalecer piernas y glúteos', 'fuerza', 'Pies al ancho de hombros, bajar flexionando rodillas'),
('Flexiones', 'Ejercicio para fortalecer pecho y brazos', 'fuerza', 'Mantener cuerpo recto, bajar y subir con los brazos'),
('Correr', 'Ejercicio cardiovascular', 'cardio', 'Mantener ritmo constante'),
('Estiramiento de espalda', 'Ejercicio para flexibilidad', 'flexibilidad', 'Sentado, estirar brazos hacia adelante');

-- Insertar entrenamientos de ejemplo
INSERT INTO entrenamientos (id_entrenador, titulo, descripcion, duracion_estimada, nivel_dificultad) VALUES
(1, 'Entrenamiento básico de fuerza', 'Rutina para principiantes', 45, 'principiante'),
(1, 'Entrenamiento avanzado', 'Rutina intensa para atletas experimentados', 60, 'avanzado'),
(2, 'Rutina de natación', 'Entrenamiento para mejorar técnica', 50, 'intermedio');

-- Asignar ejercicios a entrenamientos
INSERT INTO entrenamiento_ejercicios (id_entrenamiento, id_ejercicio, series, repeticiones, orden, descanso) VALUES
(1, 1, 3, 12, 1, 60),
(1, 2, 3, 10, 2, 45),
(2, 1, 4, 15, 1, 30),
(2, 2, 4, 12, 2, 30),
(3, 3, 1, NULL, 1, 0);

-- Asignar entrenamientos a atletas
INSERT INTO asignaciones_atletas (id_entrenamiento, id_atleta, estado) VALUES
(1, 1, 'pendiente'),
(1, 3, 'en_progreso'),
(3, 2, 'completado');

-- Creación de índices para mejorar el rendimiento
CREATE INDEX idx_atleta_entrenador ON perfiles_atletas(id_entrenador);
CREATE INDEX idx_asignacion_atleta ON asignaciones_atletas(id_atleta);
CREATE INDEX idx_asignacion_entrenamiento ON asignaciones_atletas(id_entrenamiento);
CREATE INDEX idx_entrenamiento_entrenador ON entrenamientos(id_entrenador);
CREATE INDEX idx_entrenamiento_ejercicio ON entrenamiento_ejercicios(id_entrenamiento, id_ejercicio);