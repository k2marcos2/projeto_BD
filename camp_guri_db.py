#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
╔═══════════════════════════════════════════════════════════╗
║  Os Camp dos Guri - ODBC Connection (CORRIGIDO)          ║
║  Conecta ao PostgreSQL usando ODBC                        ║
║  Operações: INSERT, SELECT, UPDATE, DELETE                ║
╚═══════════════════════════════════════════════════════════╝
"""

import pyodbc
import os

class CampGiriDB:

    def __init__(
        self,
        servidor='localhost',
        usuario='postgres',
        senha=None,
        banco='camp_dos_guri'
        ):
        import getpass

        if senha is None:
            senha = getpass.getpass("Senha do PostgreSQL: ")

        try:
            self.conexao = pyodbc.connect(
                'DRIVER={PostgreSQL Unicode(x64)};'
                f'SERVER={servidor};'
                'PORT=5432;'
                f'DATABASE={banco};'
                f'UID={usuario};'
                f'PWD={senha};',
                timeout=5
            )

            self.cursor = self.conexao.cursor()
            print(f"✅ Conectado ao banco: {banco}")

        except pyodbc.Error as erro:
            print(f"❌ Erro ao conectar: {erro}")
            self.conexao = None
            self.cursor = None
   
    
    def criar_campeonato(
    self,
    nome,
    id_criador,
    id_modalidade,
    max_participantes,
    formato="eliminacao_simples"
    ):
        try:
            comando = """
                INSERT INTO campeonatos
                (
                    nome,
                    id_criador,
                    id_modalidade,
                    formato,
                    status,
                    max_participantes,
                    data_criacao
                )
                VALUES (?, ?, ?, ?, 'rascunho', ?, CURRENT_TIMESTAMP)
                RETURNING id_campeonato
            """

            self.cursor.execute(
                comando,
                nome,
                id_criador,
                id_modalidade,
                formato,
                max_participantes
            )

            id_novo = self.cursor.fetchone()[0]
            self.conexao.commit()

            print(f"✅ Campeonato criado! ID: {id_novo}")

        except pyodbc.Error as erro:
            self.conexao.rollback()
            print(f"❌ Erro ao criar campeonato: {erro}")

    def inserir_participante(self, nome, nickname, email):
        try:
            comando = """
                INSERT INTO participantes
                (nome, nickname, email)
                VALUES (?, ?, ?)
            """

            self.cursor.execute(
                comando, nome, nickname, email
            )

            self.conexao.commit()
            print(f"✅ Participante {nickname} inserido!")

        except pyodbc.Error as e:
            self.conexao.rollback()
            print(f"❌ Erro: {e}")
    
    # ═══════════════════════════════════════════════════════════════
    # SELECT - Ler dados
    # ═══════════════════════════════════════════════════════════════
    
    def listar_usuarios(self):
        """Lista todos os usuários"""
        try:
            comando = "SELECT id_usuario, nome, email, tipo_usuario FROM usuarios ORDER BY nome"
            self.cursor.execute(comando)
            usuarios = self.cursor.fetchall()
            
            print("\n" + "="*60)
            print("LISTA DE USUÁRIOS")
            print("="*60)
            for usuario in usuarios:
                print(f"ID: {usuario[0]} | Nome: {usuario[1]} | Email: {usuario[2]} | Tipo: {usuario[3]}")
            print("="*60 + "\n")
        except Exception as e:
            print(f"❌ Erro ao listar usuários: {e}")
    
    def listar_campeonatos(self):
        """Lista todos os campeonatos com INNER JOIN"""
        try:
            comando = """
                SELECT c.id_campeonato, c.nome, u.nome AS criador, m.nome AS modalidade, c.status, c.max_participantes
                FROM campeonatos c
                INNER JOIN usuarios u ON c.id_criador = u.id_usuario
                INNER JOIN modalidades m ON c.id_modalidade = m.id_modalidade
                ORDER BY c.nome
            """
            self.cursor.execute(comando)
            campeonatos = self.cursor.fetchall()
            
            print("\n" + "="*80)
            print("LISTA DE CAMPEONATOS (COM INNER JOIN)")
            print("="*80)
            for camp in campeonatos:
                print(f"ID: {camp[0]} | {camp[1]} | Criador: {camp[2]} | Tipo: {camp[3]} | Status: {camp[4]} | Max: {camp[5]}")
            print("="*80 + "\n")
        except Exception as e:
            print(f"❌ Erro ao listar campeonatos: {e}")

    def inserir_usuario(self, nome, email, tipo_usuario):
        try:
            comando = """
                INSERT INTO usuarios
                (nome, email, tipo_usuario, ativo)
                VALUES (?, ?, ?, TRUE)
                ON CONFLICT (email) DO NOTHING
            """

            self.cursor.execute(
                comando, nome, email, tipo_usuario
            )

            quantidade = self.cursor.rowcount
            self.conexao.commit()

            if quantidade > 0:
                print("✅ Usuário inserido com sucesso!")
            else:
                print("⚠️ Usuário já cadastrado!")

        except pyodbc.Error as erro:
            self.conexao.rollback()
            print(f"❌ Erro ao inserir usuário: {erro}")
    
    def listar_participantes(self):
        """Lista todos os participantes"""
        try:
            comando = "SELECT id_participante, nome, nickname, email FROM participantes ORDER BY nickname"
            self.cursor.execute(comando)
            participantes = self.cursor.fetchall()
            
            print("\n" + "="*70)
            print("LISTA DE PARTICIPANTES")
            print("="*70)
            for part in participantes:
                print(f"ID: {part[0]} | Nome: {part[1]} | Nickname: {part[2]} | Email: {part[3]}")
            print("="*70 + "\n")
        except Exception as e:
            print(f"❌ Erro ao listar participantes: {e}")
    
    # ═══════════════════════════════════════════════════════════════
    # UPDATE - Atualizar dados
    # ═══════════════════════════════════════════════════════════════
    
    def atualizar_status_campeonato(self, id_campeonato, novo_status):
        """Atualiza status do campeonato"""
        try:
            comando = f"UPDATE campeonatos SET status = '{novo_status}' WHERE id_campeonato = {id_campeonato}"
            self.cursor.execute(comando)
            self.conexao.commit()
            print(f"✅ Status do campeonato {id_campeonato} atualizado para '{novo_status}'")
        except Exception as e:
            print(f"❌ Erro ao atualizar campeonato: {e}")
    
    
    def inscrever_participante(self, id_campeonato, id_participante, seed):
        """Inscreve um participante no campeonato"""

        try:
            comando = """
                INSERT INTO inscricoes
                    (id_campeonato, id_participante, seed, status)
                VALUES (?, ?, ?, 'pendente')
                ON CONFLICT (id_campeonato, id_participante)
                DO NOTHING
            """

            self.cursor.execute(
                comando,
                id_campeonato,
                id_participante,
                seed
            )

            quantidade = self.cursor.rowcount
            self.conexao.commit()

            if quantidade > 0:
                print("✅ Participante inscrito com sucesso!")
            else:
                print("⚠️ Participante já está inscrito!")

        except pyodbc.Error as erro:
            self.conexao.rollback()
            print(f"❌ Erro ao inscrever participante: {erro}")

    
    # ═══════════════════════════════════════════════════════════════
    # DELETE - Deletar dados
    # ═══════════════════════════════════════════════════════════════
    
    def deletar_usuario(self, id_usuario):
        """Deleta um usuário"""
        try:
            comando = f"DELETE FROM usuarios WHERE id_usuario = {id_usuario}"
            self.cursor.execute(comando)
            self.conexao.commit()
            print(f"✅ Usuário {id_usuario} deletado com sucesso")
        except Exception as e:
            print(f"❌ Erro ao deletar usuário: {e}")
    
    # ═══════════════════════════════════════════════════════════════
    # AGGREGATES - COUNT, SUM, AVG, etc
    # ═══════════════════════════════════════════════════════════════
    
    def contar_participantes_campeonato(self, id_campeonato):
        """Conta participantes de um campeonato (COUNT)"""
        try:
            comando = f"SELECT COUNT(*) FROM inscricoes WHERE id_campeonato = {id_campeonato}"
            self.cursor.execute(comando)
            resultado = self.cursor.fetchone()
            print(f"\n✅ Total de participantes no campeonato {id_campeonato}: {resultado[0]}")
        except Exception as e:
            print(f"❌ Erro ao contar participantes: {e}")
    
    def media_participantes(self):
        """Calcula média de participantes por campeonato (AVG)"""
        try:
            comando = "SELECT AVG(max_participantes) as media FROM campeonatos"
            self.cursor.execute(comando)
            resultado = self.cursor.fetchone()
            print(f"\n✅ Média de participantes por campeonato: {resultado[0]:.2f}")
        except Exception as e:
            print(f"❌ Erro ao calcular média: {e}")
    
    def total_vagas(self):
        """Calcula total de vagas em todos os campeonatos (SUM)"""
        try:
            comando = "SELECT SUM(max_participantes) as total FROM campeonatos"
            self.cursor.execute(comando)
            resultado = self.cursor.fetchone()
            print(f"\n✅ Total de vagas em todos campeonatos: {resultado[0]}")
        except Exception as e:
            print(f"❌ Erro ao calcular total: {e}")
    
    # ═══════════════════════════════════════════════════════════════
    # QUERIES AVANÇADAS
    # ═══════════════════════════════════════════════════════════════
    
    def campeonatos_por_status(self):
        """Agrupa campeonatos por status (GROUP BY)"""
        try:
            comando = "SELECT status, COUNT(*) as total FROM campeonatos GROUP BY status"
            self.cursor.execute(comando)
            resultados = self.cursor.fetchall()
            
            print("\n" + "="*40)
            print("CAMPEONATOS POR STATUS (GROUP BY)")
            print("="*40)
            for status, total in resultados:
                print(f"{status}: {total} campeonato(s)")
            print("="*40 + "\n")
        except Exception as e:
            print(f"❌ Erro ao agrupar por status: {e}")
    
    def listar_campeonatos_com_left_join(self):
        """Lista campeonatos com LEFT JOIN"""
        try:
            comando = """
                SELECT c.nome, COUNT(i.id_inscricao) as total_inscritos
                FROM campeonatos c
                LEFT JOIN inscricoes i ON c.id_campeonato = i.id_campeonato
                GROUP BY c.id_campeonato, c.nome
            """
            self.cursor.execute(comando)
            resultados = self.cursor.fetchall()
            
            print("\n" + "="*50)
            print("CAMPEONATOS COM INSCRIÇÕES (LEFT JOIN)")
            print("="*50)
            for nome, total in resultados:
                print(f"{nome}: {total} inscrições")
            print("="*50 + "\n")
        except Exception as e:
            print(f"❌ Erro ao listar com LEFT JOIN: {e}")
    
    # ═══════════════════════════════════════════════════════════════
    # CONTROLE DE CONEXÃO
    # ═══════════════════════════════════════════════════════════════
    
    def fechar_conexao(self):
        """Fecha a conexão com o banco"""
        try:
            if self.cursor:
                self.cursor.close()
            if self.conexao:
                self.conexao.close()
            print("✅ Conexão fechada com sucesso")
        except Exception as e:
            print(f"❌ Erro ao fechar conexão: {e}")



def main():
    """Função principal - Exemplos de uso de TODOS os comandos"""
    
    print("╔═══════════════════════════════════════════════════════════╗")
    print("║  Os Camp dos Guri - DEMONSTRAÇÃO COMPLETA                ║")
    print("║  Com INSERT, SELECT, UPDATE, DELETE, COUNT, AVG, etc     ║")
    print("╚═══════════════════════════════════════════════════════════╝\n")
    
    # Conectar ao banco de dados
    db = CampGiriDB(
    servidor='localhost',
    usuario='postgres',
    banco='camp_dos_guri'
    )

    if db.conexao is None:
        print("❌ Não foi possível conectar ao banco de dados!")
        return
    
    # ═══════════════════════════════════════════════════════════════
    # 1. SELECT - Listar dados existentes
    # ═══════════════════════════════════════════════════════════════
    
    print("\n📋 1. LISTANDO DADOS EXISTENTES (SELECT)...")
    db.listar_usuarios()
    db.listar_campeonatos()
    db.listar_participantes()
    
    # ═══════════════════════════════════════════════════════════════
    # 2. INSERT - Inserir dados
    # ═══════════════════════════════════════════════════════════════
    
    print("\n➕ 2. INSERINDO NOVOS DADOS (INSERT)...")
    db.inserir_usuario('Novo Criador', 'novo@example.com', 'criador')
    db.inserir_participante('João Champion', 'JoaoChamp', 'joaochamp@example.com')
    db.criar_campeonato('Campeonato Teste', 1, 1, 32)
    
    # ═══════════════════════════════════════════════════════════════
    # 3. UPDATE - Atualizar dados
    # ═══════════════════════════════════════════════════════════════
    
    print("\n✏️ 3. ATUALIZANDO DADOS (UPDATE)...")
    db.atualizar_status_campeonato(2, 'em_progresso')
    db.inscrever_participante(1, 6, 10)
    
    # ═══════════════════════════════════════════════════════════════
    # 4. AGGREGATES - COUNT, SUM, AVG
    # ═══════════════════════════════════════════════════════════════
    
    print("\n📊 4. CALCULANDO AGREGAÇÕES (COUNT, SUM, AVG)...")
    db.contar_participantes_campeonato(1)
    db.total_vagas()
    db.media_participantes()
    
    # ═══════════════════════════════════════════════════════════════
    # 5. GROUP BY - Agrupar dados
    # ═══════════════════════════════════════════════════════════════
    
    print("\n📈 5. AGRUPANDO DADOS (GROUP BY)...")
    db.campeonatos_por_status()
    
    # ═══════════════════════════════════════════════════════════════
    # 6. JOINS - Combinar tabelas
    # ═══════════════════════════════════════════════════════════════
    
    print("\n🔗 6. COMBINANDO TABELAS (INNER JOIN, LEFT JOIN)...")
    db.listar_campeonatos()
    db.listar_campeonatos_com_left_join()
    
    # ═══════════════════════════════════════════════════════════════
    # 7. DELETE - Deletar dados
    # ═══════════════════════════════════════════════════════════════
    
    print("\n🗑️ 7. DELETANDO DADOS (DELETE)...")
    print("   (Exemplo: deletar usuário com ID 999 - se não existir, é seguro)")
    db.deletar_usuario(999)
    
    # ═══════════════════════════════════════════════════════════════
    # Final: Listar dados após mudanças
    # ═══════════════════════════════════════════════════════════════
    
    print("\n📋 8. LISTANDO DADOS APÓS MUDANÇAS (SELECT NOVAMENTE)...")
    db.listar_usuarios()
    db.listar_campeonatos()
    
    # Fechar conexão
    print("\n🔴 9. FECHANDO CONEXÃO...")
    db.fechar_conexao()
    
    print("\n✅ DEMONSTRAÇÃO COMPLETA!")
    print("   Todos os comandos foram executados com sucesso!")


if __name__ == "__main__":
    main()

