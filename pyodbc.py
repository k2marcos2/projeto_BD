"""
Os Camp dos Guri - acesso ao PostgreSQL pelo ODBC (biblioteca pyodbc).

ANTES DE RODAR:
  1. Execute o PROJETO_CAMP_GURI_FINAL_v2.sql no banco camp_dos_guri.
  2. Troque SENHA pela senha do usuário postgres.
  3. Confira o nome do driver em odbcad32 (aba Drivers) e ajuste DRIVER.

Cada execução do main() é segura de repetir: o participante de teste
é inserido e depois removido. A procedure finalizar_campeonato(3) não
muda nada (o campeonato 3 já está finalizado), mas o trigger de log
registra a alteração a cada execução.
"""

import pyodbc


# =====================================================================
# CONFIGURAÇÃO
# =====================================================================

DRIVER = "PostgreSQL Unicode(x64)"   # ou "PostgreSQL Unicode", conforme o odbcad32
SERVIDOR = "localhost"
BANCO = "camp_dos_guri"
USUARIO = "postgres"
SENHA = "k2marcos"


# =====================================================================
# CONEXÃO (ODBC)
# =====================================================================

def conectar():
    """Abre a conexão ODBC com o PostgreSQL."""
    return pyodbc.connect(
        f"DRIVER={{{DRIVER}}};"
        f"SERVER={SERVIDOR};"
        f"DATABASE={BANCO};"
        f"UID={USUARIO};"
        f"PWD={SENHA};"
    )


def consultar(sql, parametros=()):
    """Executa um SELECT e devolve todas as linhas."""
    conexao = conectar()
    try:
        cursor = conexao.cursor()
        cursor.execute(sql, parametros)
        return cursor.fetchall()
    finally:
        conexao.close()


def alterar(sql, parametros=()):
    """Executa INSERT, UPDATE, DELETE ou CALL e salva com commit."""
    conexao = conectar()
    try:
        cursor = conexao.cursor()
        cursor.execute(sql, parametros)
        conexao.commit()
        return cursor.rowcount
    finally:
        conexao.close()


# =====================================================================
# SELECT (tabelas, JOIN e agregações)
# =====================================================================

def listar_usuarios():
    """SELECT simples com ORDER BY."""
    sql = "SELECT id_usuario, nome, email, tipo_usuario FROM usuarios ORDER BY nome"
    for id_usuario, nome, email, tipo in consultar(sql):
        print(f"{id_usuario} | {nome} | {email} | {tipo}")


def listar_participantes():
    """SELECT com ORDER BY."""
    sql = "SELECT id_participante, nome, nickname FROM participantes ORDER BY nome"
    for id_part, nome, nickname in consultar(sql):
        print(f"{id_part} | {nome} | {nickname}")


def listar_campeonatos():
    """INNER JOIN: campeonato + criador + modalidade."""
    sql = """
        SELECT c.nome, u.nome, m.nome, c.status, c.max_participantes
        FROM campeonatos c
        INNER JOIN usuarios u    ON c.id_criador = u.id_usuario
        INNER JOIN modalidades m ON c.id_modalidade = m.id_modalidade
        ORDER BY c.nome
    """
    for campeonato, criador, modalidade, status, vagas in consultar(sql):
        print(f"{campeonato} | criador: {criador} | {modalidade} | {status} | {vagas} vagas")


def listar_partidas():
    """JOIN em cadeia: de qual campeonato é cada partida."""
    sql = """
        SELECT p.id_partida, c.nome, f.nome, r.nome
        FROM partidas p
        JOIN rodadas r     ON p.id_rodada = r.id_rodada
        JOIN fases f       ON r.id_fase = f.id_fase
        JOIN campeonatos c ON f.id_campeonato = c.id_campeonato
        ORDER BY p.id_partida
    """
    for id_partida, campeonato, fase, rodada in consultar(sql):
        print(f"Partida {id_partida} | {campeonato} | {fase} | {rodada}")


def inscritos_por_campeonato():
    """LEFT JOIN + GROUP BY: todos os campeonatos, com 0 se não tiver inscrições."""
    sql = """
        SELECT c.nome, COUNT(i.id_inscricao)
        FROM campeonatos c
        LEFT JOIN inscricoes i ON c.id_campeonato = i.id_campeonato
        GROUP BY c.id_campeonato, c.nome
        ORDER BY c.nome
    """
    for nome, total in consultar(sql):
        print(f"{nome}: {total} inscrito(s)")


def estatisticas():
    """COUNT, SUM, AVG, MIN e MAX na mesma consulta."""
    sql = """
        SELECT COUNT(*), SUM(max_participantes), AVG(max_participantes),
               MIN(max_participantes), MAX(max_participantes)
        FROM campeonatos
    """
    total, soma, media, menor, maior = consultar(sql)[0]
    print(f"Campeonatos: {total}")
    print(f"Total de vagas (SUM): {soma}")
    print(f"Média de vagas (AVG): {media:.1f}")
    print(f"Menor (MIN): {menor} | Maior (MAX): {maior}")


# =====================================================================
# VIEW, FUNCTION e PROCEDURE (objetos criados no SQL)
# =====================================================================

def listar_campeonatos_ativos():
    """SELECT em uma VIEW: a view já tem o filtro salvo no banco."""
    for nome, vagas in consultar("SELECT nome, max_participantes FROM campeonatos_ativos"):
        print(f"{nome} | {vagas} vagas")


def total_inscritos_pela_funcao(id_campeonato):
    """Chama a função SQL total_inscritos(). CAST evita erro de tipo (int x bigint)."""
    total = consultar(
        "SELECT total_inscritos(CAST(? AS INTEGER))", (id_campeonato,)
    )[0][0]
    return total


def listar_inscritos_pela_funcao(id_campeonato):
    """Chama a função que devolve uma TABELA: listar_inscritos()."""
    sql = "SELECT * FROM listar_inscritos(CAST(? AS INTEGER))"
    for apelido, seed, situacao in consultar(sql, (id_campeonato,)):
        print(f"Seed {seed} | {apelido} | {situacao}")


def finalizar_campeonato(id_campeonato):
    """Chama a PROCEDURE finalizar_campeonato() com CALL e salva."""
    alterar("CALL finalizar_campeonato(CAST(? AS INTEGER))", (id_campeonato,))


def listar_log(limite=5):
    """Mostra as últimas linhas do log, preenchido pelo trigger trg_log_campeonatos."""
    sql = """
        SELECT tabela, acao, data_hora
        FROM log_alteracoes
        ORDER BY id_log DESC
        LIMIT ?
    """
    for tabela, acao, data_hora in consultar(sql, (limite,)):
        print(f"{data_hora} | {tabela} | {acao}")


# =====================================================================
# INSERT, UPDATE e DELETE
# =====================================================================

def inserir_participante(nome, nickname, email):
    """INSERT com parâmetros (?). Se já existir, não faz nada."""
    sql = """
        INSERT INTO participantes (nome, nickname, email)
        VALUES (?, ?, ?)
        ON CONFLICT DO NOTHING
    """
    return alterar(sql, (nome, nickname, email))


def criar_campeonato(nome, id_criador, id_modalidade, max_participantes):
    """INSERT de campeonato novo, começando com status 'inscricoes'."""
    sql = """
        INSERT INTO campeonatos
            (nome, id_criador, id_modalidade, status, max_participantes, data_criacao)
        VALUES (?, ?, ?, 'inscricoes', ?, CURRENT_DATE)
    """
    return alterar(sql, (nome, id_criador, id_modalidade, max_participantes))


def inscrever_participante(id_campeonato, id_participante, seed):
    """INSERT de uma inscrição. O banco recusa repetida (UNIQUE) e sem vaga (trigger)."""
    sql = """
        INSERT INTO inscricoes
            (id_campeonato, id_participante, seed, status, data_inscricao)
        VALUES (?, ?, ?, 'pendente', CURRENT_DATE)
    """
    return alterar(sql, (id_campeonato, id_participante, seed))


def atualizar_status(id_campeonato, novo_status):
    """UPDATE do status de um campeonato."""
    sql = "UPDATE campeonatos SET status = ? WHERE id_campeonato = ?"
    return alterar(sql, (novo_status, id_campeonato))


def remover_participante(nickname):
    """DELETE de um participante pelo nickname."""
    sql = "DELETE FROM participantes WHERE nickname = ?"
    return alterar(sql, (nickname,))


# =====================================================================
# PROGRAMA PRINCIPAL
# =====================================================================

def main():
    print("=== CAMPEONATOS (INNER JOIN) ===")
    listar_campeonatos()

    print("\n=== PARTIDAS E SEU CAMPEONATO (JOIN em cadeia) ===")
    listar_partidas()

    print("\n=== ESTATÍSTICAS (COUNT, SUM, AVG, MIN, MAX) ===")
    estatisticas()

    print("\n=== INSCRITOS POR CAMPEONATO (LEFT JOIN + GROUP BY) ===")
    inscritos_por_campeonato()

    print("\n=== VIEW: campeonatos em andamento ===")
    listar_campeonatos_ativos()

    print("\n=== FUNCTION: total de inscritos do campeonato 1 ===")
    print(f"Total: {total_inscritos_pela_funcao(1)}")

    print("\n=== FUNCTION que devolve tabela: inscritos do campeonato 1 ===")
    listar_inscritos_pela_funcao(1)

    print("\n=== PROCEDURE + TRIGGER: finaliza o campeonato 3 e mostra o log ===")
    finalizar_campeonato(3)
    listar_log()

    print("\n=== INSERT, depois DELETE de um participante de teste ===")
    inserir_participante("Fabio Teste", "FabioTeste", "fabio.teste@example.com")
    remover_participante("FabioTeste")
    print("Participante de teste inserido e removido.")

    print("\n=== UPDATE (mantém o mesmo valor, só para demonstrar) ===")
    atualizar_status(2, "inscricoes")
    print("Status do campeonato 2 atualizado.")


if __name__ == "__main__":
    main()
