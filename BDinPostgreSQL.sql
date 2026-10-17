DROP TABLE IF EXISTS log_alteracoes, resultados_partida, partidas, rodadas,
                     fases, inscricoes, participantes, campeonatos,
                     modalidades, usuarios CASCADE;

DROP DOMAIN IF EXISTS dominio_status;

CREATE DOMAIN dominio_status AS VARCHAR(50)
    CHECK (VALUE IN ('inscricoes', 'em_progresso', 'finalizado'));

CREATE TABLE usuarios (
    id_usuario SERIAL PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    tipo_usuario VARCHAR(50)  NOT NULL,
    ativo BOOLEAN DEFAULT TRUE
);

CREATE TABLE modalidades (
    id_modalidade SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    tipo_disputa VARCHAR(50)  NOT NULL,
    descricao TEXT
);

CREATE TABLE campeonatos (
    id_campeonato SERIAL PRIMARY KEY,
    nome VARCHAR(200) NOT NULL,
    id_criador INTEGER NOT NULL REFERENCES usuarios(id_usuario),
    id_modalidade INTEGER NOT NULL REFERENCES modalidades(id_modalidade),
    status dominio_status NOT NULL,
    max_participantes INTEGER NOT NULL,
    data_criacao DATE DEFAULT CURRENT_DATE
);

CREATE TABLE participantes (
    id_participante SERIAL PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    nickname VARCHAR(100) NOT NULL UNIQUE,
    email VARCHAR(150) NOT NULL UNIQUE
);

CREATE TABLE inscricoes (
    id_inscricao SERIAL PRIMARY KEY,
    id_campeonato INTEGER NOT NULL REFERENCES campeonatos(id_campeonato),
    id_participante INTEGER NOT NULL REFERENCES participantes(id_participante),
    seed INTEGER NOT NULL,
    status VARCHAR(50) NOT NULL,
    data_inscricao DATE DEFAULT CURRENT_DATE,
    UNIQUE (id_campeonato, id_participante)   -- ninguém se inscreve 2x no mesmo campeonato
);

CREATE TABLE fases (
    id_fase SERIAL PRIMARY KEY,
    id_campeonato INTEGER NOT NULL REFERENCES campeonatos(id_campeonato),
    numero_fase INTEGER NOT NULL,
    nome VARCHAR(100) NOT NULL,
    tipo VARCHAR(50)  NOT NULL,
    ordem INTEGER NOT NULL
);

CREATE TABLE rodadas (
    id_rodada SERIAL PRIMARY KEY,
    id_fase INTEGER NOT NULL REFERENCES fases(id_fase),
    numero_rodada INTEGER NOT NULL,
    nome VARCHAR(100) NOT NULL,
    ordem INTEGER NOT NULL
);

CREATE TABLE partidas (
    id_partida SERIAL PRIMARY KEY,
    id_rodada INTEGER NOT NULL REFERENCES rodadas(id_rodada),
    id_inscricao_1 INTEGER NOT NULL REFERENCES inscricoes(id_inscricao),
    id_inscricao_2 INTEGER NOT NULL REFERENCES inscricoes(id_inscricao),
    numero_partida INTEGER NOT NULL,
    status VARCHAR(50) NOT NULL
);

CREATE TABLE resultados_partida (
    id_resultado SERIAL PRIMARY KEY,
    id_partida INTEGER NOT NULL UNIQUE REFERENCES partidas(id_partida),
    placar_lado_1 INTEGER NOT NULL,
    placar_lado_2 INTEGER NOT NULL,
    vencedor_inscricao INTEGER NOT NULL REFERENCES inscricoes(id_inscricao),
    observacoes TEXT
);

CREATE TABLE log_alteracoes (
    id_log SERIAL PRIMARY KEY,
    tabela VARCHAR(50),
    acao VARCHAR(20),
    data_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ALTER TABLE, CHECK, INDEX

ALTER TABLE campeonatos
    ADD CONSTRAINT ck_max_participantes CHECK (max_participantes > 0);

ALTER TABLE partidas
    ADD CONSTRAINT ck_lados_diferentes CHECK (id_inscricao_1 <> id_inscricao_2);

-- INDEX: deixa as buscas por campeonato e por rodada mais rápidas
CREATE INDEX idx_inscricoes_campeonato ON inscricoes(id_campeonato);
CREATE INDEX idx_partidas_rodada       ON partidas(id_rodada);

-- INSERT

INSERT INTO usuarios (nome, email, tipo_usuario, ativo) VALUES
    ('João Silva',   'joao.silva@example.com',   'criador', TRUE),
    ('Maria Santos', 'maria.santos@example.com', 'criador', TRUE),
    ('Pedro Admin',  'pedro.admin@example.com',  'admin',   TRUE);

INSERT INTO modalidades (nome, tipo_disputa, descricao) VALUES
    ('Pokémon VGC',     'competitivo', 'Competição oficial VGC'),
    ('Pokémon Casual',  'casual',      'Entre amigos, sem ranking'),
    ('Torneio Rápido',  'competitivo', 'Eliminação direta');

INSERT INTO campeonatos (nome, id_criador, id_modalidade, status, max_participantes, data_criacao) VALUES
    ('Campeonato VGC 2024', 1, 1, 'em_progresso', 64, '2026-10-01'),
    ('Torneio Casual',      2, 2, 'inscricoes',   32, '2026-10-05'),
    ('Mini Torneio',        1, 3, 'finalizado',   16, '2026-09-20');

INSERT INTO participantes (nome, nickname, email) VALUES
    ('Lucas Teixeira', 'LucasTrainer', 'lucas@example.com'),
    ('Ana Master',     'AnaMaster',    'ana@example.com'),
    ('Carlos Expert',  'CarlosExp',    'carlos@example.com'),
    ('Beatriz Pro',    'BeatrizPro',   'beatriz@example.com'),
    ('Diego Champ',    'DiegoChamp',   'diego@example.com'),
    ('Eduardo Novato', 'Novato',       'novato@example.com');   

INSERT INTO inscricoes (id_campeonato, id_participante, seed, status, data_inscricao) VALUES
    (1, 1, 1, 'confirmada', '2026-10-01'),   
    (1, 2, 2, 'confirmada', '2026-10-02'),   
    (1, 3, 3, 'confirmada', '2026-10-02'),   
    (1, 4, 4, 'confirmada', '2026-10-03'),   
    (2, 4, 1, 'pendente',   '2026-10-05'),   
    (2, 5, 2, 'pendente',   '2026-10-05'),   
    (3, 1, 1, 'confirmada', '2026-09-20');   

INSERT INTO fases (id_campeonato, numero_fase, nome, tipo, ordem) VALUES
    (1, 1, 'Grupos',      'grupos', 1),
    (1, 2, 'Quartofinal', 'mata',   2),
    (1, 3, 'Semifinal',   'mata',   3),
    (1, 4, 'Final',       'mata',   4);

INSERT INTO rodadas (id_fase, numero_rodada, nome, ordem) VALUES
    (1, 1, 'Rodada 1',       1),
    (1, 2, 'Rodada 2',       2),
    (2, 1, 'Quartofinal R1', 1),
    (3, 1, 'Semifinal R1',   1),
    (4, 1, 'Final R1',       1);

INSERT INTO partidas (id_rodada, id_inscricao_1, id_inscricao_2, numero_partida, status) VALUES
    (1, 1, 2, 1, 'finalizada'),   
    (1, 3, 4, 2, 'finalizada'),   
    (2, 1, 3, 1, 'pendente');     

INSERT INTO resultados_partida (id_partida, placar_lado_1, placar_lado_2, vencedor_inscricao, observacoes) VALUES
    (1, 2, 1, 1, NULL),                    
    (2, 1, 2, 4, 'Virada na última rodada');  

-- SELECT, WHERE, LIKE, BETWEEN, ORDER BY, NULL)

SELECT * FROM usuarios;
SELECT nome, email FROM usuarios;

SELECT * FROM usuarios WHERE tipo_usuario = 'criador';
SELECT nome, max_participantes FROM campeonatos
WHERE status = 'em_progresso' AND max_participantes > 30;

SELECT nickname FROM participantes WHERE nickname LIKE 'Lucas%';
SELECT nome FROM participantes WHERE nome LIKE '_na%';

SELECT nome, max_participantes FROM campeonatos
WHERE max_participantes BETWEEN 30 AND 70;

SELECT nome FROM campeonatos ORDER BY nome ASC;
SELECT nome FROM participantes ORDER BY nome DESC;

SELECT id_resultado, observacoes FROM resultados_partida
WHERE observacoes IS NULL;

SELECT DISTINCT status FROM campeonatos;

-- COUNT, SUM, AVG, MIN, MAX

SELECT COUNT(*) AS total_usuarios        FROM usuarios;
SELECT SUM(max_participantes) AS total_vagas FROM campeonatos;
SELECT AVG(max_participantes) AS media_vagas FROM campeonatos;
SELECT MIN(max_participantes) AS menor_torneio,
       MAX(max_participantes) AS maior_torneio
FROM campeonatos;

SELECT status, COUNT(*) AS total
FROM campeonatos
GROUP BY status;

SELECT id_campeonato, COUNT(*) AS inscritos
FROM inscricoes
GROUP BY id_campeonato
HAVING COUNT(*) >= 3;

-- INNER, LEFT, RIGHT, FULL, NATURAL

SELECT c.nome AS campeonato, u.nome AS criador
FROM campeonatos c
INNER JOIN usuarios u ON c.id_criador = u.id_usuario;

SELECT c.nome AS campeonato, COUNT(i.id_inscricao) AS inscritos
FROM campeonatos c
LEFT JOIN inscricoes i ON c.id_campeonato = i.id_campeonato
GROUP BY c.id_campeonato, c.nome
ORDER BY c.nome;

SELECT p.nome, p.nickname, i.seed
FROM inscricoes i
RIGHT JOIN participantes p ON i.id_participante = p.id_participante;

SELECT c.nome AS campeonato, f.nome AS fase
FROM campeonatos c
FULL OUTER JOIN fases f ON c.id_campeonato = f.id_campeonato;

SELECT * FROM inscricoes NATURAL JOIN participantes;

SELECT p.id_partida,
       c.nome AS campeonato,
       f.nome AS fase,
       r.nome AS rodada
FROM partidas p
JOIN rodadas r     ON p.id_rodada = r.id_rodada
JOIN fases f       ON r.id_fase = f.id_fase
JOIN campeonatos c ON f.id_campeonato = c.id_campeonato;

-- UNION, INTERSECT, EXCEPT, IN, SOME, ALL, EXISTS, NOT EXISTS

SELECT nome FROM usuarios
UNION
SELECT nome FROM participantes;

SELECT id_participante FROM inscricoes WHERE id_campeonato = 1
INTERSECT
SELECT id_participante FROM inscricoes WHERE id_campeonato = 2;

SELECT id_participante FROM inscricoes WHERE id_campeonato = 1
EXCEPT
SELECT id_participante FROM inscricoes WHERE id_campeonato = 2;

SELECT nome FROM participantes
WHERE id_participante IN (SELECT id_participante FROM inscricoes
                          WHERE status = 'pendente');

SELECT nome FROM participantes
WHERE id_participante = SOME (SELECT id_participante FROM inscricoes
                              WHERE id_campeonato = 2);

SELECT nome, max_participantes FROM campeonatos
WHERE max_participantes > ALL (SELECT max_participantes FROM campeonatos
                               WHERE status = 'finalizado');

SELECT u.nome FROM usuarios u
WHERE EXISTS (SELECT 1 FROM campeonatos c WHERE c.id_criador = u.id_usuario);

SELECT u.nome FROM usuarios u
WHERE NOT EXISTS (SELECT 1 FROM campeonatos c WHERE c.id_criador = u.id_usuario);


-- VIEWS (tabelas virtuais salvas)


CREATE VIEW campeonatos_ativos AS
SELECT id_campeonato, nome, max_participantes
FROM campeonatos
WHERE status = 'em_progresso';

CREATE VIEW partidas_detalhadas AS
SELECT p.id_partida, c.nome AS campeonato, f.nome AS fase, r.nome AS rodada
FROM partidas p
JOIN rodadas r     ON p.id_rodada = r.id_rodada
JOIN fases f       ON r.id_fase = f.id_fase
JOIN campeonatos c ON f.id_campeonato = c.id_campeonato;

SELECT * FROM campeonatos_ativos;
SELECT * FROM partidas_detalhadas;



-- CREATE FUNCTION


CREATE OR REPLACE FUNCTION total_inscritos(p_campeonato INTEGER)
RETURNS INTEGER AS $$
    SELECT COUNT(*)::INTEGER FROM inscricoes WHERE id_campeonato = p_campeonato;
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION categoria_campeonato(p_vagas INTEGER)
RETURNS TEXT AS $$
DECLARE
    categoria TEXT;
BEGIN
    IF p_vagas >= 50 THEN
        categoria := 'Grande';
    ELSIF p_vagas >= 20 THEN
        categoria := 'Médio';
    ELSE
        categoria := 'Pequeno';
    END IF;
    RETURN categoria;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION listar_inscritos(p_campeonato INTEGER)
RETURNS TABLE (apelido VARCHAR, posicao_seed INTEGER, situacao VARCHAR) AS $$
BEGIN
    RETURN QUERY
    SELECT p.nickname, i.seed, i.status
    FROM inscricoes i
    JOIN participantes p ON p.id_participante = i.id_participante
    WHERE i.id_campeonato = p_campeonato
    ORDER BY i.seed;
END;
$$ LANGUAGE plpgsql;

SELECT nome, total_inscritos(id_campeonato) AS inscritos FROM campeonatos;
SELECT nome, categoria_campeonato(max_participantes) AS categoria FROM campeonatos;
SELECT * FROM listar_inscritos(1);



-- CREATE PROCEDURE + CALL

CREATE OR REPLACE PROCEDURE finalizar_campeonato(p_campeonato INTEGER)
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE campeonatos
    SET status = 'finalizado'
    WHERE id_campeonato = p_campeonato;
END;
$$;

CREATE OR REPLACE PROCEDURE registrar_resultado(
    p_partida  INTEGER,
    p_placar_1 INTEGER,
    p_placar_2 INTEGER,
    p_vencedor INTEGER
)
LANGUAGE plpgsql AS $$
BEGIN
    IF p_placar_1 < 0 OR p_placar_2 < 0 THEN
        RAISE EXCEPTION 'Placar não pode ser negativo';
    END IF;

    INSERT INTO resultados_partida
        (id_partida, placar_lado_1, placar_lado_2, vencedor_inscricao)
    VALUES
        (p_partida, p_placar_1, p_placar_2, p_vencedor);

    UPDATE partidas SET status = 'finalizada' WHERE id_partida = p_partida;
END;
$$;



-- 13. TRIGGERS ações automáticas

CREATE OR REPLACE FUNCTION registra_log() RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO log_alteracoes (tabela, acao) VALUES (TG_TABLE_NAME, TG_OP);
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_log_campeonatos
AFTER INSERT OR UPDATE OR DELETE ON campeonatos
FOR EACH ROW EXECUTE FUNCTION registra_log();

CREATE OR REPLACE FUNCTION verifica_vagas() RETURNS TRIGGER AS $$
DECLARE
    total_atual INTEGER;
    vagas       INTEGER;
BEGIN
    SELECT COUNT(*) INTO total_atual
    FROM inscricoes WHERE id_campeonato = NEW.id_campeonato;

    SELECT max_participantes INTO vagas
    FROM campeonatos WHERE id_campeonato = NEW.id_campeonato;

    IF total_atual >= vagas THEN
        RAISE EXCEPTION 'Campeonato % sem vagas', NEW.id_campeonato;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_limite_vagas
BEFORE INSERT ON inscricoes
FOR EACH ROW EXECUTE FUNCTION verifica_vagas();



-- PERMISSÕES (CREATE ROLE, GRANT, REVOKE)


DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'organizador') THEN
        CREATE ROLE organizador NOLOGIN;
    END IF;
END
$$;

GRANT SELECT ON campeonatos, participantes TO organizador;
GRANT SELECT, INSERT, DELETE ON inscricoes TO organizador;

-- REVOKE: tira a permissão de apagar inscrições
REVOKE DELETE ON inscricoes FROM organizador;



-- DEMONSTRAÇÕES DE INSERT, UPDATE, DELETE, ALTER TABLE e DROP TABLE


-- INSERT, UPDATE e DELETE
INSERT INTO participantes (nome, nickname, email)
VALUES ('Teste Aluno', 'TesteAluno', 'teste@example.com');

UPDATE participantes
SET nome = 'Teste Aluno Editado'
WHERE nickname = 'TesteAluno';

DELETE FROM participantes WHERE nickname = 'TesteAluno';

CREATE TABLE teste_temporario (
    id   SERIAL PRIMARY KEY,
    nota INTEGER
);

ALTER TABLE teste_temporario ADD COLUMN comentario VARCHAR(100);

DROP TABLE teste_temporario;

CALL finalizar_campeonato(3);

SELECT * FROM log_alteracoes;
SELECT
    table_schema,
    table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_type = 'BASE TABLE'
ORDER BY table_name;



SELECT id_modalidade, nome
FROM modalidades
ORDER BY id_modalidade;

INSERT INTO campeonatos
    (nome, id_criador, id_modalidade, status,
     max_participantes, data_criacao)
VALUES
    ('Campeonato VGC 2024', 1, 4, 'em_progresso', 64, '2026-10-01'),
    ('Torneio Casual', 2, 5, 'inscricoes', 32, '2026-10-05'),
    ('Mini Torneio', 1, 6, 'finalizado', 16, '2026-09-20')
RETURNING id_campeonato, nome, id_modalidade;



SELECT id_usuario, nome
FROM usuarios
ORDER BY id_usuario;


SELECT id_campeonato, nome
FROM campeonatos
ORDER BY id_campeonato;
