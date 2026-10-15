# 📚 GUIA COMPLETO - LINHA POR LINHA

## Como todo o projeto funciona, se conecta e como você usa o banco de dados!

---

# PARTE 1: ENTENDER A ESTRUTURA GERAL

## 🎯 O Grande Quadro (Antes de entrar nos detalhes)

```
┌─────────────────────────────────────────────────────────┐
│ VOCÊ (digitando no computador)                          │
│ Exemplo: "Quero criar um campeonato"                   │
└──────────────────┬──────────────────────────────────────┘
                   │
                   ↓
┌─────────────────────────────────────────────────────────┐
│ PYTHON (seu programa - camp_guri_odbc_corrigido.py)     │
│ • Colhe os dados                                        │
│ • Monta um comando SQL                                  │
│ Exemplo:                                                │
│ "INSERT INTO campeonatos (nome, ...) VALUES (...)"     │
└──────────────────┬──────────────────────────────────────┘
                   │
                   ↓
┌─────────────────────────────────────────────────────────┐
│ ODBC (o "carteiro")                                     │
│ • Traduz Python → PostgreSQL                            │
│ • Traduz PostgreSQL → Python                            │
└──────────────────┬──────────────────────────────────────┘
                   │
                   ↓
┌─────────────────────────────────────────────────────────┐
│ PostgreSQL (Banco de Dados)                             │
│ • Executa o comando SQL                                 │
│ • Insere dados nas tabelas                              │
│ • Guarda os dados permanentemente no disco              │
└──────────────────┬──────────────────────────────────────┘
                   │
                   ↓
┌─────────────────────────────────────────────────────────┐
│ PostgreSQL (retorna resultado)                          │
│ "Campeonato criado com sucesso!"                        │
└──────────────────┬──────────────────────────────────────┘
                   │
                   ↓
┌─────────────────────────────────────────────────────────┐
│ ODBC (traduz de volta)                                  │
│ Transforma SQL response em dados Python                 │
└──────────────────┬──────────────────────────────────────┘
                   │
                   ↓
┌─────────────────────────────────────────────────────────┐
│ PYTHON (mostra para você)                               │
│ print("✅ Campeonato criado!")                          │
└──────────────────┬──────────────────────────────────────┘
                   │
                   ↓
┌─────────────────────────────────────────────────────────┐
│ VOCÊ (vê o resultado)                                   │
│ ✅ Campeonato criado!                                   │
└─────────────────────────────────────────────────────────┘
```

---

# PARTE 2: SQL EXPLICADO LINHA POR LINHA

## 📄 PROJETO_CAMP_GURI_CORRIGIDO.sql

### **SEÇÃO 1: Deletar e Criar Banco**

```sql
DROP DATABASE IF EXISTS camp_dos_guri;
```

**O que faz:**
- `DROP DATABASE` = Deleta/Remove um banco de dados
- `IF EXISTS` = Só deleta SE o banco existir (evita erro)
- `camp_dos_guri` = Nome do banco

**Por que fazer isso:**
- Você está limpando tudo
- Se o banco já existe, remove
- Assim você começa do zero toda vez
- Garante que não há dados antigos conflitando

**Analogia:**
- É como desapertar a casa antes de pintar
- Se não limpar, a tinta fica feia

---

```sql
CREATE DATABASE camp_dos_guri;
```

**O que faz:**
- `CREATE DATABASE` = Cria um novo banco de dados
- `camp_dos_guri` = Nome do novo banco (você pode mudar)

**Resultado:**
- Um novo banco vazio é criado no PostgreSQL
- Sem tabelas ainda
- Sem dados ainda

**Analogia:**
- É como construir uma casa vazia
- Paredes, piso, tudo vazio
- Agora precisa montar as tabelas (móveis)

---

```sql
\c camp_dos_guri
```

**O que faz:**
- `\c` = "Connect" (conectar)
- `camp_dos_guri` = Nome do banco

**Resultado:**
- Muda o "contexto" para o banco criado
- De agora em diante, tudo que criar vai estar NESSE banco
- Sem isso, você criaria tabelas no banco errado

**Nota importante:**
- Só funciona no terminal PostgreSQL (`psql`)
- NO pgAdmin, você não usa isso (você seleciona o banco manualmente)

**Analogia:**
- É como entrar em um cômodo da casa
- De agora em diante, tudo que fizer é nesse cômodo

---

### **SEÇÃO 2: Criar Tabelas (CREATE TABLE)**

```sql
CREATE TABLE usuarios (
    id_usuario SERIAL PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    tipo_usuario VARCHAR(50) NOT NULL,
    ativo BOOLEAN DEFAULT TRUE
);
```

**Entendendo cada linha:**

#### `CREATE TABLE usuarios (`
- `CREATE TABLE` = Criar uma nova tabela
- `usuarios` = Nome da tabela (você pode mudar)
- `(` = Abre a lista de colunas

#### `id_usuario SERIAL PRIMARY KEY,`
- `id_usuario` = Nome da coluna (identificador único)
- `SERIAL` = Tipo: número inteiro que aumenta automaticamente
  - Primeira linha = 1
  - Segunda linha = 2
  - Terceira linha = 3 (automático!)
- `PRIMARY KEY` = Este é o identificador único
  - Não pode repetir
  - Não pode ser NULL (vazio)

**Analogia:**
- É como número de matrícula na universidade
- Cada aluno tem um número único
- Nunca se repete

#### `nome VARCHAR(150) NOT NULL,`
- `nome` = Nome da coluna
- `VARCHAR(150)` = Tipo: texto até 150 caracteres
  - Se colocar 200, vai dar erro (máximo 150)
  - Se colocar 50, funciona (é menor que 150)
- `NOT NULL` = Obrigatório preencher
  - Não pode deixar vazio
  - Se tentar inserir sem nome, dá erro

**Analogia:**
- É como pedir o nome de alguém
- Não pode deixar em branco
- Máximo de caracteres permitido

#### `email VARCHAR(150) NOT NULL UNIQUE,`
- `email` = Nome da coluna
- `VARCHAR(150)` = Texto até 150 caracteres
- `NOT NULL` = Obrigatório
- `UNIQUE` = Não pode repetir!
  - Se tiver "joao@example.com" já inserido
  - Não pode inserir "joao@example.com" de novo
  - Garante que cada pessoa tem um email diferente

**Analogia:**
- É como CPF
- Cada pessoa tem um CPF diferente
- Não pode repetir

#### `tipo_usuario VARCHAR(50) NOT NULL,`
- Similar ao anterior
- Tipo: "criador", "admin", "participante"
- Obrigatório preencher

#### `ativo BOOLEAN DEFAULT TRUE`
- `ativo` = Nome da coluna
- `BOOLEAN` = Tipo: SIM ou NÃO (TRUE ou FALSE)
- `DEFAULT TRUE` = Por padrão é TRUE (verdadeiro/ativo)
  - Se não especificar, assume TRUE
  - Economiza digitação

**Exemplo:**
```sql
INSERT INTO usuarios (nome, email, tipo_usuario)
VALUES ('João', 'joao@example.com', 'criador')
-- ativo não foi preenchido, mas assume TRUE automaticamente
```

#### `);`
- `)` = Fecha a lista de colunas
- `;` = Fim do comando

**Resumo da tabela usuarios:**
- Guarda informações de pessoas
- Cada pessoa tem ID único
- Email não pode repetir
- Todos os campos são obrigatórios
- Quando criada, a pessoa é "ativa" por padrão

---

### **SEÇÃO 3: Chaves Estrangeiras (FOREIGN KEY)**

```sql
CREATE TABLE campeonatos (
    id_campeonato SERIAL PRIMARY KEY,
    nome VARCHAR(200) NOT NULL,
    id_criador INTEGER NOT NULL REFERENCES usuarios(id_usuario),
    id_modalidade INTEGER NOT NULL REFERENCES modalidades(id_modalidade),
    status VARCHAR(50) NOT NULL,
    max_participantes INTEGER NOT NULL,
    data_criacao DATE DEFAULT CURRENT_DATE
);
```

**Entendendo as chaves estrangeiras:**

#### `id_criador INTEGER NOT NULL REFERENCES usuarios(id_usuario),`
- `id_criador` = Nome da coluna (guarda o ID do criador)
- `INTEGER` = Tipo: número inteiro
- `NOT NULL` = Obrigatório preencher
- `REFERENCES usuarios(id_usuario)` = **CHAVE ESTRANGEIRA**
  - Diz: "Este número deve existir na tabela usuarios, coluna id_usuario"
  - Se tentar inserir ID 999 (que não existe em usuarios), dá erro

**O que evita:**
```sql
-- ❌ ERRADO (vai dar erro!)
INSERT INTO campeonatos (nome, id_criador, ...)
VALUES ('Meu Campeonato', 999, ...)
-- 999 não existe na tabela usuarios!

-- ✅ CERTO
INSERT INTO campeonatos (nome, id_criador, ...)
VALUES ('Meu Campeonato', 1, ...)
-- 1 existe em usuarios, funciona!
```

**Analogia:**
- É como dizer "Este campeonato foi criado por alguém"
- Esse alguém TEM que existir em usuarios
- Não pode ser uma pessoa imaginária

#### `data_criacao DATE DEFAULT CURRENT_DATE`
- `data_criacao` = Nome da coluna
- `DATE` = Tipo: data (ano-mês-dia)
- `DEFAULT CURRENT_DATE` = Por padrão, usa a data de hoje

**Exemplo:**
```sql
INSERT INTO campeonatos (nome, id_criador, ...)
VALUES ('Meu Campeonato', 1, ...)
-- data_criacao não foi preenchida
-- Assume automaticamente 2026-10-14 (hoje)
```

---

### **SEÇÃO 4: Inserir Dados (INSERT INTO)**

```sql
INSERT INTO usuarios (nome, email, tipo_usuario, ativo) VALUES
('João Silva', 'joao.silva@example.com', 'criador', TRUE),
('Maria Santos', 'maria.santos@example.com', 'criador', TRUE),
('Pedro Admin', 'pedro.admin@example.com', 'admin', TRUE);
```

**O que faz:**
- `INSERT INTO usuarios` = Insere dados NA tabela usuarios
- `(nome, email, tipo_usuario, ativo)` = Quais colunas vou preencher
- `VALUES (...)` = Quais valores vou inserir

**Linha por linha:**

```sql
('João Silva', 'joao.silva@example.com', 'criador', TRUE),
```
- Primeira coluna (nome): 'João Silva'
- Segunda coluna (email): 'joao.silva@example.com'
- Terceira coluna (tipo_usuario): 'criador'
- Quarta coluna (ativo): TRUE

**Resultado:**
- Uma nova linha é criada em usuarios
- id_usuario = 1 (automático, SERIAL)
- nome = João Silva
- email = joao.silva@example.com
- tipo_usuario = criador
- ativo = TRUE

**Próxima linha:**
```sql
('Maria Santos', 'maria.santos@example.com', 'criador', TRUE),
```
- Uma nova linha é criada
- id_usuario = 2 (automático, incrementado)
- Mesma lógica

**Vantagem de inserir múltiplas linhas:**
- Mais rápido que fazer INSERT várias vezes
- Uma linha por INSERT: 3 INSERTs = 3 operações
- Múltiplas linhas: 1 INSERT = 1 operação

---

### **SEÇÃO 5: SELECT - Ler Dados**

```sql
SELECT * FROM usuarios WHERE tipo_usuario = 'criador';
```

**Entendendo:**

#### `SELECT *`
- `SELECT` = Ler/buscar dados
- `*` = TUDO (todas as colunas)

**Alternativa:**
```sql
SELECT nome, email FROM usuarios
-- Mostra só nome e email (não mostra id_usuario, tipo_usuario, ativo)
```

#### `FROM usuarios`
- `FROM` = De qual tabela vou pegar dados
- `usuarios` = Tabela usuarios

#### `WHERE tipo_usuario = 'criador'`
- `WHERE` = Filtro/condição
- `tipo_usuario = 'criador'` = Só mostra quem é criador
- Ignora admins

**Resultado:**
```
id_usuario | nome          | email                        | tipo_usuario | ativo
-----------|---------------|------------------------------|--------------|-------
1          | João Silva    | joao.silva@example.com       | criador      | true
2          | Maria Santos  | maria.santos@example.com     | criador      | true
```

**Sem WHERE:**
```sql
SELECT * FROM usuarios
-- Mostra TODOS, incluindo admin
```

---

### **SEÇÃO 6: LIKE - Buscar por padrão**

```sql
SELECT * FROM participantes WHERE nickname LIKE 'Lucas%';
```

**O que faz:**
- `LIKE` = Buscar por padrão (não precisa ser exato)
- `'Lucas%'` = Começa com "Lucas"
  - `%` = Qualquer coisa depois
  - Encontra: "Lucas", "LucasTrainer", "LucasChamp", etc

**Outros exemplos:**

```sql
-- Termina com ".com"
SELECT * FROM usuarios WHERE email LIKE '%.com%';

-- Tem "Silva" em algum lugar
SELECT * FROM usuarios WHERE nome LIKE '%Silva%';

-- Terceira letra é 'a'
SELECT * FROM usuarios WHERE nome LIKE '__a%';
-- (__) = ignorar 2 primeiras letras
-- (a) = terceira deve ser 'a'
-- (%) = resto não importa
```

---

### **SEÇÃO 7: ORDER BY - Ordenar**

```sql
SELECT * FROM campeonatos ORDER BY nome ASC;
```

**O que faz:**
- `ORDER BY` = Ordena os resultados
- `nome` = Por qual coluna ordenar
- `ASC` = Ascendente (A→Z, 0→9)

**Resultado (ordenado A→Z):**
```
Campeonato VGC 2024
Mini Torneio
Torneio Casual
```

**Alternativa:**
```sql
SELECT * FROM campeonatos ORDER BY nome DESC;
-- DESC = Descendente (Z→A, 9→0)
```

**Resultado (ordenado Z→A):**
```
Torneio Casual
Mini Torneio
Campeonato VGC 2024
```

---

### **SEÇÃO 8: BETWEEN - Intervalo**

```sql
SELECT * FROM campeonatos WHERE max_participantes BETWEEN 30 AND 70;
```

**O que faz:**
- `BETWEEN` = Entre dois valores
- `30 AND 70` = Mínimo 30, máximo 70 (inclusive)

**Mostra:**
```
Campeonato VGC 2024 (64 vagas) ✅
Torneio Casual (32 vagas) ✅
Mini Torneio (16 vagas) ❌ (menos de 30)
```

---

### **SEÇÃO 9: COUNT, SUM, AVG - Agregações**

```sql
SELECT COUNT(*) as total_usuarios FROM usuarios;
```

**COUNT - Contar linhas:**
- `COUNT(*)` = Conta quantas linhas existem
- `as total_usuarios` = Apelidando o resultado como "total_usuarios"

**Resultado:**
```
total_usuarios
3
```

---

```sql
SELECT SUM(max_participantes) as total_vagas FROM campeonatos;
```

**SUM - Somar:**
- `SUM(max_participantes)` = Soma todos os max_participantes
- Campeonato 1: 64 vagas
- Campeonato 2: 32 vagas
- Campeonato 3: 16 vagas
- Total: 64 + 32 + 16 = **112 vagas**

---

```sql
SELECT AVG(max_participantes) as media_participantes FROM campeonatos;
```

**AVG - Média:**
- `AVG(max_participantes)` = Calcula média
- (64 + 32 + 16) / 3 = **37.33 vagas**

---

### **SEÇÃO 10: GROUP BY - Agrupar**

```sql
SELECT status, COUNT(*) as total FROM campeonatos GROUP BY status;
```

**O que faz:**
- `GROUP BY status` = Agrupa por status
- `COUNT(*)` = Para cada grupo, conta quantos tem

**Resultado:**
```
status        | total
em_progresso  | 1
inscricoes    | 1
finalizado    | 1
```

**Como funciona:**
1. Divide campeonatos em grupos por status
2. Para cada grupo, executa COUNT(*)
3. Mostra resultado para cada grupo

**Analogia:**
- É como perguntar: "Quantos campeonatos tem em cada status?"

---

### **SEÇÃO 11: INNER JOIN - Combinar tabelas**

```sql
SELECT c.nome AS campeonato, u.nome AS criador 
FROM campeonatos c 
INNER JOIN usuarios u ON c.id_criador = u.id_usuario;
```

**O que faz:**
- Combina dados de 2 tabelas
- Mostra só quando há correspondência em ambas

**Entendendo:**

#### `FROM campeonatos c`
- `FROM campeonatos` = Tabela principal
- `c` = Apelido (para não digitar "campeonatos" todo tempo)

#### `INNER JOIN usuarios u`
- `INNER JOIN` = Juntar com outra tabela
- `usuarios` = Segunda tabela
- `u` = Apelido para usuarios

#### `ON c.id_criador = u.id_usuario`
- `ON` = Condição de junção
- `c.id_criador = u.id_usuario` = "Liga quando o id_criador do campeonato é igual ao id_usuario dos usuários"

**Resultado:**
```
campeonato           | criador
Campeonato VGC 2024  | João Silva
Torneio Casual       | Maria Santos
Mini Torneio         | João Silva
```

**O que aconteceu:**
1. Pegou primeiro campeonato: id_criador = 1
2. Procurou em usuarios onde id_usuario = 1
3. Encontrou: João Silva
4. Mostrou: "Campeonato VGC 2024 foi criado por João Silva"

---

### **SEÇÃO 12: LEFT JOIN - Todos da esquerda**

```sql
SELECT c.nome, COUNT(i.id_inscricao) as participantes
FROM campeonatos c
LEFT JOIN inscricoes i ON c.id_campeonato = i.id_campeonato
GROUP BY c.id_campeonato, c.nome;
```

**Diferença do INNER JOIN:**
- **INNER JOIN**: Mostra só quando há correspondência nas DUAS tabelas
- **LEFT JOIN**: Mostra TUDO da tabela da esquerda, mesmo se não houver correspondência

**Resultado:**
```
nome                 | participantes
Campeonato VGC 2024  | 3
Torneio Casual       | 2
Mini Torneio         | 1
```

**Se houvesse um campeonato sem inscrições:**
```
nome                 | participantes
Meu Novo Campeonato  | 0  ✅ Mostra mesmo com 0 inscrições!
```

**Analogia:**
- LEFT JOIN é como dizer: "Quero VER TODOS os campeonatos"
- Mesmo que alguns não tenham inscrições, mostra com 0

---

### **SEÇÃO 13: DISTINCT - Valores únicos**

```sql
SELECT DISTINCT status FROM campeonatos;
```

**O que faz:**
- `DISTINCT` = Remove duplicatas
- Mostra só valores únicos

**Sem DISTINCT:**
```
status
em_progresso
inscricoes
finalizado
em_progresso  ← Repetido!
```

**Com DISTINCT:**
```
status
em_progresso
inscricoes
finalizado
```

---

### **SEÇÃO 14: SUBQUERY - Consulta aninhada**

```sql
SELECT nome FROM usuarios 
WHERE id_usuario IN (SELECT id_criador FROM campeonatos);
```

**Entendendo:**

#### Parte interna (executada primeiro):
```sql
SELECT id_criador FROM campeonatos
-- Retorna: 1, 2, 1
-- (IDs de quem criou campeonatos)
```

#### Parte externa (usa resultado interno):
```sql
SELECT nome FROM usuarios 
WHERE id_usuario IN (1, 2, 1)
-- Mostra usuários com ID 1 ou 2
```

**Resultado:**
```
nome
João Silva  ← Criou 2 campeonatos
Maria Santos ← Criou 1 campeonato
```

**Analogia:**
- É como fazer 2 perguntas em 1 comando
- Primeira pergunta: "Quem criou campeonatos?"
- Segunda pergunta: "Mostra esses criadores"

---

### **SEÇÃO 15: CHECK - Validação**

```sql
ALTER TABLE campeonatos 
ADD CONSTRAINT check_max_participantes CHECK (max_participantes > 0);
```

**O que faz:**
- `ALTER TABLE` = Modifica tabela existente
- `ADD CONSTRAINT` = Adiciona uma regra
- `check_max_participantes` = Nome da regra
- `CHECK (max_participantes > 0)` = A regra: max_participantes deve ser maior que 0

**Protege contra:**
```sql
-- ❌ ERRADO (vai dar erro!)
INSERT INTO campeonatos (nome, max_participantes, ...)
VALUES ('Meu Campeonato', 0, ...)
-- Viola a regra: max_participantes não é > 0!

-- ❌ ERRADO (vai dar erro!)
INSERT INTO campeonatos (nome, max_participantes, ...)
VALUES ('Meu Campeonato', -5, ...)
-- Número negativo! Viola a regra!

-- ✅ CERTO
INSERT INTO campeonatos (nome, max_participantes, ...)
VALUES ('Meu Campeonato', 10, ...)
-- 10 > 0, respeita a regra!
```

**Benefício:**
- O banco de dados protege seus dados
- Garante que campeonatos sempre têm pelo menos 1 vaga

---

### **SEÇÃO 16: TRIGGER - Ação automática**

```sql
CREATE TRIGGER trigger_log_usuarios
AFTER INSERT OR UPDATE ON usuarios
FOR EACH ROW
EXECUTE FUNCTION log_atualizacao();
```

**O que faz:**
- `CREATE TRIGGER` = Criar uma ação automática
- `trigger_log_usuarios` = Nome do trigger
- `AFTER INSERT OR UPDATE ON usuarios` = Quando inserir OU atualizar em usuarios
- `FOR EACH ROW` = Para cada linha afetada
- `EXECUTE FUNCTION log_atualizacao()` = Execute a função log_atualizacao

**O que acontece:**
```sql
-- Você insere um usuário
INSERT INTO usuarios (nome, email, ...)
VALUES ('João', 'joao@example.com', ...)

-- Automaticamente, o trigger é acionado!
-- A função log_atualizacao() é executada
-- Que insere um registro em log_alteracoes
-- Dizendo: "Usuário foi inserido em 2026-10-14 14:30"
```

**Benefício:**
- Você não precisa fazer nada extra
- O trigger registra tudo automaticamente
- Você tem um histórico de todas as mudanças

---

### **SEÇÃO 17: FUNCTION - Função**

```sql
CREATE FUNCTION contar_usuarios() 
RETURNS INTEGER AS $$
    SELECT COUNT(*) FROM usuarios;
$$ LANGUAGE SQL;
```

**O que faz:**
- `CREATE FUNCTION` = Criar uma função
- `contar_usuarios()` = Nome da função (você chama depois)
- `RETURNS INTEGER` = Retorna um número inteiro
- `SELECT COUNT(*)` = O que a função faz

**Como usar:**
```sql
SELECT contar_usuarios();
-- Retorna: 3 (tem 3 usuários)

SELECT contar_usuarios();
-- Retorna: 4 (agora tem 4)
```

**Benefício:**
- Código reutilizável
- Não precisa escrever SELECT COUNT(*) toda vez
- Só chama `contar_usuarios()`

**Em Python:**
```python
cursor.execute("SELECT contar_usuarios()")
resultado = cursor.fetchone()
print(f"Total de usuários: {resultado[0]}")
```

---

### **SEÇÃO 18: PROCEDURE - Procedimento**

```sql
CREATE PROCEDURE finalizar_campeonato(p_id_campeonato INTEGER) AS $$
BEGIN
    UPDATE campeonatos 
    SET status = 'finalizado' 
    WHERE id_campeonato = p_id_campeonato;
END;
$$ LANGUAGE plpgsql;
```

**O que faz:**
- `CREATE PROCEDURE` = Criar um procedimento
- `finalizar_campeonato(p_id_campeonato INTEGER)` = Nome e parâmetro
- `p_id_campeonato` = Você passa o ID do campeonato
- `UPDATE campeonatos SET status = 'finalizado'` = Muda status para finalizado
- `WHERE id_campeonato = p_id_campeonato` = Só o campeonato com esse ID

**Como usar:**
```sql
CALL finalizar_campeonato(1);
-- Finaliza o campeonato com ID 1

CALL finalizar_campeonato(2);
-- Finaliza o campeonato com ID 2
```

**Em Python:**
```python
cursor.execute("CALL finalizar_campeonato(?)", (1,))
conexao.commit()
print("✅ Campeonato finalizado!")
```

---

---

# PARTE 3: PYTHON EXPLICADO LINHA POR LINHA

## 🐍 camp_guri_odbc_corrigido.py

### **SEÇÃO 1: Importar bibliotecas**

```python
import pyodbc
```

**O que faz:**
- `import` = Importa uma biblioteca
- `pyodbc` = Biblioteca para conectar a banco de dados via ODBC

**O que é ODBC:**
- Sigla: "Open Database Connectivity"
- Tradução: Conexão aberta com banco de dados
- Função: Permite Python conversar com PostgreSQL

**Como funciona:**
```
Python (fala inglês) → ODBC (tradutor) → PostgreSQL (fala SQL)
```

---

### **SEÇÃO 2: Classe CampGiriDB**

```python
class CampGiriDB:
    """Classe para gerenciar conexão ODBC com banco de dados PostgreSQL"""
```

**O que é uma classe:**
- Organiza código
- Agrupa dados + funções relacionadas
- Facilita reutilização

**Analogia:**
- É como um "molde"
- Cada vez que você cria um objeto, usa o molde
- Objeto = Instância da classe

**Exemplo:**
```python
db = CampGiriDB(...)  # Cria um objeto da classe
# db agora tem todos os métodos da classe
```

---

### **SEÇÃO 3: Método __init__ (Construtor)**

```python
def __init__(self, servidor='localhost', usuario='postgres', senha='sua_senha', banco='camp_dos_guri'):
```

**O que faz:**
- `__init__` = Função especial que roda quando você cria um objeto
- `self` = Referência ao próprio objeto
- `servidor='localhost'` = Parâmetro com valor padrão
  - Se não especificar, assume 'localhost'
  - localhost = seu próprio computador

**O que é cada parâmetro:**

- `servidor='localhost'` = Onde o PostgreSQL está
  - 'localhost' = Seu computador
  - '192.168.1.100' = Outro computador na rede
  - 'banco.servidor.com' = Servidor online

- `usuario='postgres'` = Quem acessa
  - 'postgres' = Usuário padrão do PostgreSQL
  - 'seu_nome' = Seu usuário customizado

- `senha='sua_senha'` = Senha do usuário
  - ⚠️ MUDE ISSO! 'sua_senha' é apenas placeholder
  - Sua senha real do PostgreSQL

- `banco='camp_dos_guri'` = Qual banco conectar
  - 'camp_dos_guri' = Nosso banco
  - Outro banco = 'outro_nome'

---

```python
try:
    self.conexao = pyodbc.connect(
        f'Driver={{PostgreSQL Unicode}};'
        f'Server={servidor};'
        f'Database={banco};'
        f'UID={usuario};'
        f'PWD={senha};'
    )
```

**O que faz:**

#### `try:`
- Tenta executar o código
- Se der erro, pula para `except`
- Como um "escudo" para erros

#### `self.conexao = pyodbc.connect(...)`
- `self.conexao` = Salva a conexão no objeto
- `pyodbc.connect()` = Conecta ao banco

#### `f'Driver={{PostgreSQL Unicode}};'`
- `f'...'` = f-string (permite variáveis dentro)
- `Driver={...}` = Qual driver usar
- `{{...}}` = Literal `{...}` (escapa as chaves)

#### String de conexão completa:
```
'Driver={PostgreSQL Unicode};Server=localhost;Database=camp_dos_guri;UID=postgres;PWD=sua_senha;'
```

**Traduzindo:**
- "Use driver PostgreSQL Unicode"
- "Servidor em localhost"
- "Banco chamado camp_dos_guri"
- "Usuário postgres"
- "Senha sua_senha"

---

```python
    self.cursor = self.conexao.cursor()
    print(f"✅ Conectado ao banco de dados: {banco}")
```

**O que faz:**

#### `self.cursor = self.conexao.cursor()`
- `cursor` = "Lápis" para executar comandos
- É como um caneta para escrever no banco

#### `print(f"✅ Conectado ao banco de dados: {banco}")`
- Mostra mensagem de sucesso
- `{banco}` = Substitui pelo nome do banco

**Resultado:**
```
✅ Conectado ao banco de dados: camp_dos_guri
```

---

```python
except Exception as e:
    print(f"❌ Erro ao conectar: {e}")
    self.conexao = None
    self.cursor = None
```

**O que faz:**

#### `except Exception as e:`
- Pega qualquer erro (`Exception`)
- Salva erro em variável `e`

#### `print(f"❌ Erro ao conectar: {e}")`
- Mostra qual foi o erro
- `{e}` = Mensagem de erro

#### `self.conexao = None` e `self.cursor = None`
- Define como vazios
- Indica que não conectou

**Exemplo de erro:**
```
❌ Erro ao conectar: (psycopg2.OperationalError) FATAL: password authentication failed for user "postgres"
```

---

### **SEÇÃO 4: Método inserir_usuario()**

```python
def inserir_usuario(self, nome, email, tipo_usuario):
```

**Parâmetros:**
- `self` = Referência ao objeto (sempre primeiro)
- `nome` = Nome da pessoa
- `email` = Email da pessoa
- `tipo_usuario` = Tipo: 'criador' ou 'admin'

---

```python
    try:
        comando = f"""
            INSERT INTO usuarios (nome, email, tipo_usuario, ativo)
            VALUES ('{nome}', '{email}', '{tipo_usuario}', TRUE)
        """
```

**O que faz:**

#### `comando = f"""..."""`
- Cria string com comando SQL
- f"""...""" = Multi-line f-string
- Permite quebrar em várias linhas para ler melhor

#### Comando SQL:
```sql
INSERT INTO usuarios (nome, email, tipo_usuario, ativo)
VALUES ('João Silva', 'joao@example.com', 'criador', TRUE)
```

**Traduzindo:**
- "Insira em usuarios"
- "Colunas: nome, email, tipo_usuario, ativo"
- "Valores: 'João Silva', 'joao@example.com', 'criador', TRUE"

---

```python
        self.cursor.execute(comando)
        self.conexao.commit()
```

#### `self.cursor.execute(comando)`
- Executa o comando SQL
- É como digitar no banco de dados

#### `self.conexao.commit()`
- `commit` = Salva permanentemente
- Sem isso, pode ser perdido!

**Analogia:**
- execute() = Digitar o texto
- commit() = Pressionar Salvar

---

```python
        print(f"✅ Usuário '{nome}' inserido com sucesso!")
    except Exception as e:
        print(f"❌ Erro ao inserir usuário: {e}")
```

**O que faz:**
- Se funcionou: Mostra mensagem de sucesso
- Se não funcionou: Mostra mensagem de erro

---

### **SEÇÃO 5: Método listar_usuarios()**

```python
def listar_usuarios(self):
```

**Sem parâmetros (além de self):**
- Não precisa de input
- Vai listar TODOS os usuários

---

```python
    try:
        comando = "SELECT id_usuario, nome, email, tipo_usuario FROM usuarios ORDER BY nome"
        self.cursor.execute(comando)
        usuarios = self.cursor.fetchall()
```

**O que faz:**

#### `comando = "SELECT..."`
- Comando SQL para ler dados
- `SELECT id_usuario, nome, email, tipo_usuario` = Quais colunas
- `FROM usuarios` = De qual tabela
- `ORDER BY nome` = Ordena alfabeticamente

#### `self.cursor.execute(comando)`
- Executa o comando no banco

#### `usuarios = self.cursor.fetchall()`
- `fetchall()` = Pega TODOS os resultados
- `usuarios` = Salva em variável (lista de tuplas)

**Resultado:**
```python
usuarios = [
    (1, 'João Silva', 'joao.silva@example.com', 'criador'),
    (2, 'Maria Santos', 'maria.santos@example.com', 'criador'),
    (3, 'Pedro Admin', 'pedro.admin@example.com', 'admin')
]
```

---

```python
        print("\n" + "="*60)
        print("LISTA DE USUÁRIOS")
        print("="*60)
        for usuario in usuarios:
            print(f"ID: {usuario[0]} | Nome: {usuario[1]} | Email: {usuario[2]} | Tipo: {usuario[3]}")
        print("="*60 + "\n")
```

**O que faz:**

#### `print("\n" + "="*60)`
- `\n` = Nova linha
- `"="*60` = Repeat "=" 60 vezes (barra de separação)

#### `for usuario in usuarios:`
- Loop através de cada usuário

#### `print(f"ID: {usuario[0]} | ...`
- `usuario[0]` = Primeiro elemento (id_usuario = 1)
- `usuario[1]` = Segundo elemento (nome = 'João Silva')
- `usuario[2]` = Terceiro elemento (email = '...')
- `usuario[3]` = Quarto elemento (tipo = 'criador')

**Resultado visual:**
```
============================================================
LISTA DE USUÁRIOS
============================================================
ID: 1 | Nome: João Silva | Email: joao.silva@example.com | Tipo: criador
ID: 2 | Nome: Maria Santos | Email: maria.santos@example.com | Tipo: criador
ID: 3 | Nome: Pedro Admin | Email: pedro.admin@example.com | Tipo: admin
============================================================
```

---

### **SEÇÃO 6: Método listar_campeonatos()**

```python
def listar_campeonatos(self):
    try:
        comando = """
            SELECT c.id_campeonato, c.nome, u.nome AS criador, m.nome AS modalidade, c.status, c.max_participantes
            FROM campeonatos c
            INNER JOIN usuarios u ON c.id_criador = u.id_usuario
            INNER JOIN modalidades m ON c.id_modalidade = m.id_modalidade
            ORDER BY c.nome
        """
```

**O que faz:**

#### `SELECT ... FROM campeonatos c`
- `c` = Apelido para campeonatos
- Economiza digitação depois

#### `INNER JOIN usuarios u ON c.id_criador = u.id_usuario`
- Combina com usuarios
- Quando id_criador do campeonato = id_usuario do usuário
- `u` = Apelido para usuarios

#### `INNER JOIN modalidades m ON c.id_modalidade = m.id_modalidade`
- Combina com modalidades
- `m` = Apelido para modalidades

#### Colunas retornadas:
- `c.id_campeonato` = ID do campeonato
- `c.nome` = Nome do campeonato
- `u.nome AS criador` = Nome do usuário (apelidado como "criador")
- `m.nome AS modalidade` = Nome da modalidade
- `c.status` = Status
- `c.max_participantes` = Máx participantes

**Resultado:**
```
ID: 1 | Campeonato VGC 2024 | Criador: João Silva | Tipo: Pokémon VGC | Status: em_progresso | Max: 64
ID: 2 | Torneio Casual | Criador: Maria Santos | Tipo: Pokémon Casual | Status: inscricoes | Max: 32
```

---

### **SEÇÃO 7: Método atualizar_status_campeonato()**

```python
def atualizar_status_campeonato(self, id_campeonato, novo_status):
    try:
        comando = f"UPDATE campeonatos SET status = '{novo_status}' WHERE id_campeonato = {id_campeonato}"
        self.cursor.execute(comando)
        self.conexao.commit()
        print(f"✅ Status do campeonato {id_campeonato} atualizado para '{novo_status}'")
```

**O que faz:**

#### `UPDATE campeonatos SET status = '{novo_status}'`
- `UPDATE` = Modificar dados
- `campeonatos` = Em qual tabela
- `SET status = '...'` = Mude a coluna status para novo_status

#### `WHERE id_campeonato = {id_campeonato}`
- Modificação só no campeonato com esse ID

**Exemplo:**
```python
db.atualizar_status_campeonato(1, 'finalizado')
# Executa:
# UPDATE campeonatos SET status = 'finalizado' WHERE id_campeonato = 1
# Resultado: Campeonato 1 agora tem status = 'finalizado'
```

---

### **SEÇÃO 8: Método deletar_usuario()**

```python
def deletar_usuario(self, id_usuario):
    try:
        comando = f"DELETE FROM usuarios WHERE id_usuario = {id_usuario}"
        self.cursor.execute(comando)
        self.conexao.commit()
        print(f"✅ Usuário {id_usuario} deletado com sucesso")
```

**O que faz:**

#### `DELETE FROM usuarios`
- `DELETE` = Deletar/remover linhas
- `usuarios` = De qual tabela

#### `WHERE id_usuario = {id_usuario}`
- Deleta só o usuário com esse ID

**Cuidado:**
```python
# ❌ PERIGO! Deleta TODOS!
cursor.execute("DELETE FROM usuarios")

# ✅ SEGURO! Deleta só um
cursor.execute("DELETE FROM usuarios WHERE id_usuario = 1")
```

---

### **SEÇÃO 9: Agregações (COUNT, SUM, AVG)**

```python
def contar_participantes_campeonato(self, id_campeonato):
    try:
        comando = f"SELECT COUNT(*) FROM inscricoes WHERE id_campeonato = {id_campeonato}"
        self.cursor.execute(comando)
        resultado = self.cursor.fetchone()
        print(f"\n✅ Total de participantes no campeonato {id_campeonato}: {resultado[0]}")
```

**O que faz:**

#### `SELECT COUNT(*)`
- `COUNT(*)` = Conta quantas linhas
- Retorna um número

#### `WHERE id_campeonato = {id_campeonato}`
- Conta só as inscrições do campeonato especificado

#### `resultado = self.cursor.fetchone()`
- `fetchone()` = Pega UMA linha só
- `resultado` = Uma tupla com um elemento

#### `resultado[0]`
- `resultado` é uma tupla: `(3,)`
- `resultado[0]` = Primeiro (e único) elemento: `3`

**Exemplo:**
```python
db.contar_participantes_campeonato(1)
# Retorna: 3 participantes no campeonato 1
```

---

### **SEÇÃO 10: Método fechar_conexao()**

```python
def fechar_conexao(self):
    try:
        if self.cursor:
            self.cursor.close()
        if self.conexao:
            self.conexao.close()
        print("✅ Conexão fechada com sucesso")
```

**O que faz:**

#### `if self.cursor:`
- Se cursor existe (não é None)

#### `self.cursor.close()`
- Fecha o cursor
- Libera recurso

#### `if self.conexao:`
- Se conexão existe

#### `self.conexao.close()`
- Fecha a conexão
- Libera recurso do PostgreSQL

**Por que fazer isso:**
- Libera memória
- Permite que outro programa use o banco
- Boa prática

**Analogia:**
- Como fechar uma porta depois de usar
- Se não fechar, fica aberta para sempre

---

### **SEÇÃO 11: Função main()**

```python
def main():
    db = CampGiriDB(servidor='localhost', usuario='postgres', senha='sua_senha', banco='camp_dos_guri')
```

**O que faz:**

#### `db = CampGiriDB(...)`
- Cria um objeto da classe
- Conecta ao banco de dados
- Se der erro, mostra mensagem

#### Parâmetros:
- `servidor='localhost'` = Seu computador
- `usuario='postgres'` = Usuário padrão
- `senha='sua_senha'` = ⚠️ MUDE ISSO!
- `banco='camp_dos_guri'` = Nosso banco

---

```python
    if db.conexao is None:
        print("❌ Não foi possível conectar ao banco de dados!")
        return
```

**O que faz:**

#### `if db.conexao is None:`
- Se conexão é None (vazia)
- Significa que falhou em conectar

#### `return`
- Sai da função
- Não continua executando

---

```python
    db.listar_usuarios()
    db.listar_campeonatos()
    db.inserir_usuario('Novo Criador', 'novo@example.com', 'criador')
```

**O que faz:**
- Executa os métodos um por um
- Demonstra todas as operações

---

```python
    db.fechar_conexao()
```

**O que faz:**
- Fecha a conexão
- Libera recursos
- **SEMPRE fazer isso no final!**

---

### **SEÇÃO 12: Executar main()**

```python
if __name__ == "__main__":
    main()
```

**O que faz:**

#### `if __name__ == "__main__":`
- Verifica se o script está sendo executado diretamente
- NÃO é verdade se outro script importar este

#### `main()`
- Executa a função main()

**Por que fazer isso:**
```python
# Você pode fazer:
python camp_guri_odbc_corrigido.py
# Executa main()

# Ou você pode fazer (em outro script):
from camp_guri_odbc_corrigido import CampGiriDB
db = CampGiriDB(...)
# NÃO executa main() (porque __name__ ≠ "__main__")
```

---

---

# PARTE 4: COMO TUDO SE CONECTA

## 🔗 O Fluxo Completo

### **Passo 1: Arquivo SQL cria a estrutura**

```
SQL executa:
├─ CREATE DATABASE
├─ CREATE TABLE (9 tabelas)
├─ INSERT INTO (dados de teste)
├─ CREATE VIEW
├─ CREATE FUNCTION
├─ CREATE PROCEDURE
└─ CREATE TRIGGER

Resultado: PostgreSQL tem estrutura + dados prontos
```

---

### **Passo 2: Python se conecta via ODBC**

```
Python (camp_guri_odbc_corrigido.py) faz:
│
├─ Importa pyodbc
├─ Define classe CampGiriDB
└─ main() cria objeto da classe
   │
   ├─ CampGiriDB.__init__()
   │  └─ pyodbc.connect(...) → Conecta ao PostgreSQL!
   │
   └─ Agora tem cursor para executar comandos
```

---

### **Passo 3: Python executa comandos SQL**

```
Python cria comando:
│
├─ "SELECT * FROM usuarios"
├─ "INSERT INTO campeonatos (...) VALUES (...)"
├─ "UPDATE campeonatos SET status = '...' WHERE ..."
└─ "DELETE FROM usuarios WHERE id_usuario = ..."

         ↓ ODBC traduz para PostgreSQL ↓

PostgreSQL executa:
│
├─ Busca dados nas tabelas
├─ Insere novos dados
├─ Modifica dados existentes
└─ Deleta dados

         ↓ ODBC retorna resultado ↓

Python recebe resultado:
│
├─ Lista de usuários
├─ Mensagem de sucesso
├─ Número de linhas afetadas
└─ Mostra para você!
```

---

### **Passo 4: Você interage com Python**

```
Você executa: python camp_guri_odbc_corrigido.py
│
├─ Mostra lista de usuários
├─ Mostra lista de campeonatos
├─ Insere novo usuário
├─ Insere novo campeonato
├─ Atualiza status
├─ Conta participantes
├─ Calcula médias
├─ Combina tabelas (JOINs)
└─ Deleta dados

Resultado: Você vê tudo funcionando!
```

---

## 🎯 O Ciclo Completo: Um Exemplo Prático

### **Cenário: Você quer criar um novo campeonato**

#### **1. Você executa no terminal:**
```bash
python camp_guri_odbc_corrigido.py
```

#### **2. Python inicia (linha por linha):**

```python
if __name__ == "__main__":
    main()  # Chama função main
```

#### **3. main() executa:**

```python
def main():
    db = CampGiriDB(
        servidor='localhost',
        usuario='postgres',
        senha='sua_senha',
        banco='camp_dos_guri'
    )
```

#### **4. __init__ conecta ao banco:**

```python
self.conexao = pyodbc.connect(
    'Driver={PostgreSQL Unicode};'
    'Server=localhost;'
    'Database=camp_dos_guri;'
    'UID=postgres;'
    'PWD=sua_senha;'
)
```

**Python ODBC PostgreSQL**
```
Python → ODBC → PostgreSQL
(conecta!)
```

#### **5. Mostra mensagem:**

```python
print(f"✅ Conectado ao banco de dados: camp_dos_guri")
```

**Resultado na tela:**
```
✅ Conectado ao banco de dados: camp_dos_guri
```

#### **6. main() continua listando usuários:**

```python
db.listar_usuarios()
```

#### **7. listar_usuarios() executa:**

```python
comando = "SELECT id_usuario, nome, email, tipo_usuario FROM usuarios ORDER BY nome"
self.cursor.execute(comando)
usuarios = self.cursor.fetchall()
```

**Fluxo:**
```
Python → ODBC → PostgreSQL (busca dados)
PostgreSQL → ODBC → Python (retorna dados)
```

#### **8. Mostra resultado:**

```python
for usuario in usuarios:
    print(f"ID: {usuario[0]} | Nome: {usuario[1]} | Email: {usuario[2]} | Tipo: {usuario[3]}")
```

**Resultado na tela:**
```
ID: 1 | Nome: João Silva | Email: joao.silva@example.com | Tipo: criador
ID: 2 | Nome: Maria Santos | Email: maria.santos@example.com | Tipo: criador
ID: 3 | Nome: Pedro Admin | Email: pedro.admin@example.com | Tipo: admin
```

#### **9. Insere novo campeonato:**

```python
db.criar_campeonato('Campeonato Teste', 1, 1, 32)
```

#### **10. criar_campeonato() executa:**

```python
comando = f"""
    INSERT INTO campeonatos (nome, id_criador, id_modalidade, status, max_participantes, data_criacao)
    VALUES ('Campeonato Teste', 1, 1, 'inscricoes', 32, CURRENT_DATE)
"""
self.cursor.execute(comando)
self.conexao.commit()
```

**Fluxo:**
```
Python → ODBC → PostgreSQL (insere dados)
PostgreSQL insere nova linha em campeonatos
PostgreSQL → ODBC → Python (retorna confirmação)
```

#### **11. Mostra resultado:**

```python
print(f"✅ Campeonato 'Campeonato Teste' criado com sucesso!")
```

**Resultado na tela:**
```
✅ Campeonato 'Campeonato Teste' criado com sucesso!
```

#### **12. Continua com outras operações...**

```python
db.contar_participantes_campeonato(1)
db.total_vagas()
db.media_participantes()
db.campeonatos_por_status()
# ... etc
```

#### **13. Fecha conexão no final:**

```python
db.fechar_conexao()
```

**Resultado:**
```
✅ Conexão fechada com sucesso
```

---

# PARTE 5: COMO VOCÊ USA ESSE BANCO NA PRÁTICA

## 💡 Exemplos de Uso Real

### **Caso 1: Criar um novo campeonato**

```python
from camp_guri_odbc_corrigido import CampGiriDB

# Conectar
db = CampGiriDB(servidor='localhost', usuario='postgres', senha='sua_senha', banco='camp_dos_guri')

# Criar campeonato
db.criar_campeonato('Novo Torneio 2024', id_criador=1, id_modalidade=2, max_participantes=48)

# Mostrar campeonatos
db.listar_campeonatos()

# Fechar
db.fechar_conexao()
```

**Resultado:**
```
✅ Campeonato 'Novo Torneio 2024' criado com sucesso!
ID: 4 | Novo Torneio 2024 | Criador: João Silva | Tipo: Pokémon Casual | Status: inscricoes | Max: 48
```

---

### **Caso 2: Inscrever um participante**

```python
# Conectar
db = CampGiriDB(...)

# Inserir participante (se novo)
db.inserir_participante('Lucas Expert', 'LucasExp', 'lucas.expert@example.com')

# Inscrever no campeonato
db.inscrever_participante(id_campeonato=1, id_participante=6, seed=5)

# Contar inscritos
db.contar_participantes_campeonato(1)

# Fechar
db.fechar_conexao()
```

**Resultado:**
```
✅ Participante 'LucasExp' inserido com sucesso!
✅ Participante 6 inscrito no campeonato 1
✅ Total de participantes no campeonato 1: 4
```

---

### **Caso 3: Relatório de campeonatos**

```python
# Conectar
db = CampGiriDB(...)

# Listar todos os campeonatos
db.listar_campeonatos()

# Ver campeonatos por status
db.campeonatos_por_status()

# Calcular média de participantes
db.media_participantes()

# Fechar
db.fechar_conexao()
```

**Resultado:**
```
ID: 1 | Campeonato VGC 2024 | Criador: João Silva | Tipo: Pokémon VGC | Status: em_progresso | Max: 64

status        | total
em_progresso  | 1
inscricoes    | 2
finalizado    | 1

✅ Média de participantes por campeonato: 37.33
```

---

### **Caso 4: Usar direto com SQL (avançado)**

```python
# Conectar
db = CampGiriDB(...)

# Executar comando SQL customizado
cursor = db.cursor
cursor.execute("""
    SELECT c.nome, COUNT(i.id_inscricao) as inscritos
    FROM campeonatos c
    LEFT JOIN inscricoes i ON c.id_campeonato = i.id_campeonato
    GROUP BY c.id_campeonato, c.nome
    HAVING COUNT(i.id_inscricao) > 0
""")

resultados = cursor.fetchall()
for campeonato, inscritos in resultados:
    print(f"{campeonato}: {inscritos} inscritos")

db.fechar_conexao()
```

**Resultado:**
```
Campeonato VGC 2024: 3 inscritos
Torneio Casual: 2 inscritos
```

---

# PARTE 6: APRESENTAÇÃO PARA O PROFESSOR

## 📊 O que mostrar

### **Passo 1: Explicar a estrutura**

```
Professor, o projeto tem:

1. Banco de Dados (PostgreSQL)
   - 9 tabelas relacionadas
   - Dados de teste inseridos
   - Sistema de campeonatos Pokémon

2. Código SQL
   - Cria tudo do zero
   - 21+ comandos diferentes
   - Tudo o que o professor pediu

3. Código Python
   - Conecta via ODBC
   - 15 métodos para operações
   - Demonstração completa

4. Documentação
   - Explicação linha por linha
   - Exemplos de uso
   - Guia completo
```

---

### **Passo 2: Executar o SQL**

```
Professor, posso executar o arquivo SQL?
[Executa PROJETO_CAMP_GURI_CORRIGIDO.sql]

Resultado:
✅ Banco criado
✅ 9 tabelas criadas
✅ Dados inseridos
✅ Todos os comandos testados
```

---

### **Passo 3: Executar o Python**

```
Agora vou executar o código Python...
[Executa camp_guri_odbc_corrigido.py]

Resultado:
✅ Conectado ao banco de dados
✅ Listou usuários
✅ Listou campeonatos
✅ Inseriu novos dados
✅ Calculou agregações
✅ Combinou tabelas (JOINS)
```

---

### **Passo 4: Mostrar os comandos**

```
Professor, aqui estão os 16+ comandos pedidos:

✅ SELECT/WHERE - Linha X
✅ LIKE - Linha Y
✅ ORDER BY - Linha Z
✅ BETWEEN - Linha W
✅ COUNT - Linha A
✅ SUM - Linha B
✅ AVG - Linha C
✅ GROUP BY - Linha D
✅ INNER JOIN - Linha E
✅ LEFT OUTER JOIN - Linha F
✅ RIGHT OUTER JOIN - Linha G
✅ FULL OUTER JOIN - Linha H
✅ NATURAL JOIN - Linha I
✅ INTERSECTION - Linha J
✅ DISTINCT - Linha K
✅ SUBQUERY - Linha L
... E mais (CHECK, TRIGGER, FUNCTION, PROCEDURE, VIEWS)
```

---

## 🎯 Você está pronto!

Agora você entende:
- ✅ Como cada linha do SQL funciona
- ✅ Como cada linha do Python funciona
- ✅ Como Python, ODBC e PostgreSQL se conectam
- ✅ Como usar o banco de dados na prática
- ✅ Como apresentar para o professor

**Qualquer dúvida, é só reler este guia!** 💪
