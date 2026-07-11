-- Prototipo: Personaje + Estadísticas + Nivel
-- Las tablas Personaje / Estadistica / PersonajeEstadistica / MejoraNivelPersonaje
-- YA EXISTEN (creadas a mano, esquema más completo pensando en arena/combate a
-- futuro: CopasArena, VictoriasArena, DerrotasArena, Estado). No se crea nada nuevo,
-- solo se agrega la constraint de negocio que falta y se siembra el catálogo.

-- 1) REQUERIDO: un Usuario tiene como máximo un Personaje (regla de negocio dura).
--    Hoy Personaje.IDUsuario tiene FK pero no UNIQUE, así que nada impide duplicar
--    personajes para el mismo usuario. La tabla está vacía, así que esto es seguro.
ALTER TABLE Personaje
    ADD CONSTRAINT UQ_Personaje_IDUsuario UNIQUE (IDUsuario);

-- 2) REQUERIDO: sembrar el catálogo de estadísticas (la tabla está vacía).
--    Se identifica cada estadística por Nombre (no hay columna Codigo en tu esquema).
INSERT INTO Estadistica (Nombre, Descripcion, Estado) VALUES
    ('Vida',         'Puntos de vida del personaje',   1),
    ('Fuerza',       'Poder de ataque físico',         1),
    ('Agilidad',     'Velocidad de reacción y esquiva',1),
    ('Velocidad',    'Rapidez de movimiento y turno',  1),
    ('Inteligencia', 'Poder de ataque mágico/especial',1);

-- 3) OPCIONAL (recomendado): evita duplicar historial de mejora de nivel si
--    GanarExperiencia se reintenta después de una falla parcial a mitad de camino.
ALTER TABLE MejoraNivelPersonaje
    ADD CONSTRAINT UQ_MejoraNivelPersonaje UNIQUE (IDPersonaje, NivelAlAplicar, IDEstadistica);
