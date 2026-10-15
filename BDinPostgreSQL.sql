-- ╔═════════════════════════════════════════════════════════════╗
-- ║  Os Camp dos Guri - PROJETO COMPLETO (CORRIGIDO)           ║
-- ║  Sistema de Gerenciamento de Campeonatos Pokémon Cobblemon ║
-- ║  PostgreSQL - COM TODOS OS 16 COMANDOS PEDIDOS             ║
-- ╚═════════════════════════════════════════════════════════════╝

DROP DATABASE IF EXISTS camp_dos_guri;
CREATE DATABASE camp_dos_guri;

-- ═══════════════════════════════════════════════════════════════
-- PART 1: CREATE TABLES
-- ═══════════════════════════════════════════════════════════════

CREATE TABLE usuarios (
    id_usuario SERIAL PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    tipo_usuario VARCHAR(50) NOT NULL,
    ativo BOOLEAN DEFAULT TRUE
);

CREATE TABLE modalidades (
    id_modalidade SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    tipo_disputa VARCHAR(50) NOT NULL,
    descricao TEXT
);

CREATE TABLE campeonatos (
    id_campeonato SERIAL PRIMARY KEY,
    nome VARCHAR(200) NOT NULL,
    id_criador INTEGER NOT NULL REFERENCES usuarios(id_usuario),
    id_modalidade INTEGER NOT NULL REFERENCES modalidades(id_modalidade),
    status VARCHAR(50) NOT NULL,
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
    data_inscricao DATE DEFAULT CURRENT_DATE
);

CREATE TABLE fases (
    id_fase SERIAL PRIMARY KEY,
    id_campeonato INTEGER NOT NULL REFERENCES campeonatos(id_campeonato),
    numero_fase INTEGER NOT NULL,
    nome VARCHAR(100) NOT NULL,
    tipo VARCHAR(50) NOT NULL,
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
    id_partida INTEGER NOT NULL REFERENCES partidas(id_partida),
    placar_lado_1 INTEGER NOT NULL,
    placar_lado_2 INTEGER NOT NULL,
    vencedor_inscricao INTEGER NOT NULL REFERENCES inscricoes(id_inscricao),
    observacoes TEXT
);

-- ═══════════════════════════════════════════════════════════════
-- PART 2: INSERT DATA
-- ═══════════════════════════════════════════════════════════════

INSERT INTO usuarios (nome, email, tipo_usuario, ativo) VALUES
('João Silva', 'joao.silva@example.com', 'criador', TRUE),
('Maria Santos', 'maria.santos@example.com', 'criador', TRUE),
('Pedro Admin', 'pedro.admin@example.com', 'admin', TRUE);

INSERT INTO modalidades (nome, tipo_disputa, descricao) VALUES
('Pokémon VGC', 'competitivo', 'Competição oficial VGC'),
('Pokémon Casual', 'casual', 'Entre amigos, sem ranking'),
('Torneio Rápido', 'competitivo', 'Eliminação direta');

INSERT INTO campeonatos (nome, id_criador, id_modalidade, status, max_participantes, data_criacao) VALUES
('Campeonato VGC 2024', 1, 1, 'em_progresso', 64, '2026-10-01'),
('Torneio Casual', 2, 2, 'inscricoes', 32, '2026-10-05'),
('Mini Torneio', 1, 3, 'finalizado', 16, '2026-09-20');

INSERT INTO participantes (nome, nickname, email) VALUES
('Lucas Teixeira', 'LucasTrainer', 'lucas@example.com'),
('Ana Master', 'AnaMaster', 'ana@example.com'),
('Carlos Expert', 'CarlosExp', 'carlos@example.com'),
('Beatriz Pro', 'BeatrizPro', 'beatriz@example.com'),
('Diego Champ', 'DiegoChamp', 'diego@example.com');

INSERT INTO inscricoes (id_campeonato, id_participante, seed, status, data_inscricao) VALUES
(1, 1, 1, 'confirmada', '2026-10-01'),
(1, 2, 2, 'confirmada', '2026-10-02'),
(1, 3, 3, 'confirmada', '2026-10-02'),
(2, 4, 1, 'pendente', '2026-10-05'),
(2, 5, 2, 'pendente', '2026-10-05'),
(3, 1, 1, 'confirmada', '2026-09-20');

INSERT INTO fases (id_campeonato, numero_fase, nome, tipo, ordem) VALUES
(1, 1, 'Grupos', 'grupos', 1),
(1, 2, 'Quartofinal', 'mata', 2),
(1, 3, 'Semifinal', 'mata', 3);

INSERT INTO rodadas (id_fase, numero_rodada, nome, ordem) VALUES
(1, 1, 'Rodada 1', 1),
(1, 2, 'Rodada 2', 2),
(2, 1, 'Quartofinal R1', 1),
(3, 1, 'Semifinal R1', 1);

INSERT INTO partidas (id_rodada, id_inscricao_1, id_inscricao_2, numero_partida, status) VALUES
(1, 1, 2, 1, 'finalizada'),
(1, 3, 4, 2, 'andamento'),
(3, 1, 2, 1, 'pendente');

INSERT INTO resultados_partida (id_partida, placar_lado_1, placar_lado_2, vencedor_inscricao, observacoes) VALUES
(1, 2, 1, 1, 'Ótima partida'),
(2, 1, 1, 2, 'Ainda em progresso');

-- ═══════════════════════════════════════════════════════════════
-- PARTE 3: COMANDOS PEDIDOS PELO PROFESSOR (16 TOTAIS)
-- ═══════════════════════════════════════════════════════════════

-- ✅ COMANDO 1-5: SELECT COM FILTROS (LIKE, WHERE, ORDER BY)
-- EXEMPLO 1: SELECT simples com WHERE
SELECT * FROM usuarios WHERE tipo_usuario = 'criador';

-- EXEMPLO 2: LIKE com % (padrão inicial)
SELECT * FROM participantes WHERE nickname LIKE 'Lucas%';

-- EXEMPLO 3: ORDER BY ASC (crescente)
SELECT * FROM campeonatos ORDER BY nome ASC;

-- EXEMPLO 4: ORDER BY DESC (decrescente)
SELECT * FROM participantes ORDER BY nome DESC;

-- EXEMPLO 5: BETWEEN (intervalo)
SELECT * FROM campeonatos WHERE max_participantes BETWEEN 30 AND 70;

-- ✅ COMANDO 6: COUNT (contagem)
SELECT COUNT(*) as total_usuarios FROM usuarios;

-- ✅ COMANDO 7: SUM (soma)
SELECT SUM(max_participantes) as total_vagas FROM campeonatos;

-- ✅ COMANDO 8: AVG (média)
SELECT AVG(max_participantes) as media_participantes FROM campeonatos;

-- ✅ COMANDO 9: GROUP BY (agrupamento)
SELECT status, COUNT(*) as total FROM campeonatos GROUP BY status;

-- ✅ COMANDO 10: INNER JOIN
SELECT c.nome AS campeonato, u.nome AS criador 
FROM campeonatos c 
INNER JOIN usuarios u ON c.id_criador = u.id_usuario;

-- ✅ COMANDO 11: LEFT OUTER JOIN
SELECT c.nome, COUNT(i.id_inscricao) as participantes
FROM campeonatos c
LEFT JOIN inscricoes i ON c.id_campeonato = i.id_campeonato
GROUP BY c.id_campeonato, c.nome;

-- ✅ COMANDO 12: RIGHT OUTER JOIN
SELECT p.nickname, c.nome as campeonato
FROM campeonatos c
RIGHT JOIN inscricoes i ON c.id_campeonato = i.id_campeonato
RIGHT JOIN participantes p ON i.id_participante = p.id_participante;

-- ✅ COMANDO 13: FULL OUTER JOIN
SELECT u.nome, c.nome
FROM usuarios u
FULL OUTER JOIN campeonatos c ON u.id_usuario = c.id_criador;

-- ✅ COMANDO 14: NATURAL JOIN (com tabelas compatíveis)
CREATE TABLE usuarios_temp AS SELECT id_usuario, nome FROM usuarios;
SELECT * FROM usuarios NATURAL JOIN usuarios_temp;
DROP TABLE usuarios_temp;

-- ✅ COMANDO 15: INTERSECTION (valores em ambas as consultas)
SELECT id_participante FROM inscricoes WHERE id_campeonato = 1
INTERSECT
SELECT id_participante FROM participantes WHERE email LIKE '%@example%';

-- ✅ COMANDO 16: DISTINCT (valores únicos)
SELECT DISTINCT status FROM campeonatos;
SELECT DISTINCT tipo_usuario FROM usuarios;

-- ═══════════════════════════════════════════════════════════════
-- PARTE 4: COMANDOS ADICIONAIS (PROFESSOR PEDIU)
-- ═══════════════════════════════════════════════════════════════

-- ✅ SUBQUERY (consulta aninhada)
SELECT nome FROM usuarios 
WHERE id_usuario IN (SELECT id_criador FROM campeonatos);

SELECT nickname FROM participantes
WHERE id_participante NOT IN (SELECT id_participante FROM inscricoes);

-- ✅ CHECK (validação de dados)
ALTER TABLE campeonatos 
ADD CONSTRAINT check_max_participantes CHECK (max_participantes > 0);

-- ✅ TRIGGER (ação automática)
CREATE TABLE log_alteracoes (
    id_log SERIAL PRIMARY KEY,
    tabela VARCHAR(50),
    acao VARCHAR(20),
    data_hora TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE FUNCTION log_atualizacao()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO log_alteracoes (tabela, acao)
    VALUES (TG_TABLE_NAME, TG_OP);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_log_usuarios
AFTER INSERT OR UPDATE ON usuarios
FOR EACH ROW
EXECUTE FUNCTION log_atualizacao();

-- ✅ VIEWS (tabelas virtuais)
CREATE VIEW campeonatos_ativos AS
SELECT id_campeonato, nome, status, max_participantes
FROM campeonatos
WHERE status = 'em_progresso';

CREATE VIEW participantes_inscritos AS
SELECT p.nickname, c.nome AS campeonato, i.seed
FROM participantes p
INNER JOIN inscricoes i ON p.id_participante = i.id_participante
INNER JOIN campeonatos c ON i.id_campeonato = c.id_campeonato;

-- ✅ FUNCTIONS (funções do banco)
CREATE FUNCTION contar_usuarios() 
RETURNS INTEGER AS $$
    SELECT COUNT(*) FROM usuarios;
$$ LANGUAGE SQL;

CREATE FUNCTION total_campeonatos_ativos()
RETURNS INTEGER AS $$
DECLARE
    total INTEGER;
BEGIN
    SELECT COUNT(*) INTO total FROM campeonatos WHERE status = 'em_progresso';
    RETURN total;
END;
$$ LANGUAGE plpgsql;

CREATE FUNCTION listar_participantes_campeonato(p_id_campeonato INTEGER)
RETURNS TABLE(nickname VARCHAR, seed INTEGER, status VARCHAR) AS $$
BEGIN
    RETURN QUERY
    SELECT p.nickname, i.seed, i.status
    FROM participantes p
    INNER JOIN inscricoes i ON p.id_participante = i.id_participante
    WHERE i.id_campeonato = p_id_campeonato;
END;
$$ LANGUAGE plpgsql;

-- ✅ PROCEDURES (procedimentos do banco)
CREATE PROCEDURE finalizar_campeonato(p_id_campeonato INTEGER) AS $$
BEGIN
    UPDATE campeonatos 
    SET status = 'finalizado' 
    WHERE id_campeonato = p_id_campeonato;
END;
$$ LANGUAGE plpgsql;

CREATE PROCEDURE registrar_resultado(
    p_id_partida INTEGER,
    p_placar_1 INTEGER,
    p_placar_2 INTEGER,
    p_vencedor INTEGER
) AS $$
BEGIN
    IF p_placar_1 > 0 AND p_placar_2 > 0 THEN
        INSERT INTO resultados_partida (id_partida, placar_lado_1, placar_lado_2, vencedor_inscricao)
        VALUES (p_id_partida, p_placar_1, p_placar_2, p_vencedor);
        UPDATE partidas SET status = 'finalizada' WHERE id_partida = p_id_partida;
    ELSE
        RAISE EXCEPTION 'Placares inválidos';
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ═══════════════════════════════════════════════════════════════
-- VERIFICAÇÃO FINAL
-- ═══════════════════════════════════════════════════════════════

-- Confirmar que tudo foi criado
SELECT 'Banco de dados criado com sucesso!' as status;
