-- +-------------------------------------------------------------------------------------------+
-- | Objetivo   : Clonar usuario Origem x Destino                                              |
-- | Criador    : Gustavo Borges Evangelista                                                   |
-- | Exemplo    : @clone_permissoes.sql usuarioOrigem usuarioDestino                           |
-- | Arquivo    : clone_permissoes.sql                                                         |
-- +-------------------------------------------------------------------------------------------+

-- clone_permissoes.sql (gera os GRANTs; não executa)
SET PAGES 0 LINES 500 FEEDBACK OFF HEADING OFF VERIFY OFF ECHO OFF SERVEROUTPUT OFF TERMOUT OFF TRIMSPOOL ON

COLUMN SRC_U NEW_VALUE SRC_U
COLUMN DST_U NEW_VALUE DST_U

-- Define variáveis (NÃO está em spool ainda)
SELECT COALESCE((SELECT username FROM dba_users WHERE username = UPPER('&1')), UPPER('&1')) SRC_U FROM dual;
SELECT COALESCE((SELECT username FROM dba_users WHERE username = UPPER('&2')), UPPER('&2')) DST_U FROM dual;

-- começa a gravar o arquivo
SPOOL clone_&SRC_U._to_&DST_U..sql

---------------
-- ROLES
---------------
SELECT 'GRANT "'||granted_role||'" TO "'||'&DST_U'||'";' FROM dba_role_privs WHERE grantee='&SRC_U' ORDER  BY granted_role;

---------------
-- SYSTEM PRIVS
---------------
SELECT 'GRANT '||privilege||' TO "'||'&DST_U'||'";' FROM   dba_sys_privs WHERE  grantee='&SRC_U' ORDER  BY privilege;

---------------
-- OBJECT PRIVS
---------------
SELECT 'GRANT '||privilege||' ON "'||owner||'"."'||table_name||'" TO "'||'&DST_U'||'";' FROM   dba_tab_privs WHERE  grantee='&SRC_U' ORDER  BY owner, table_name, privilege;

---------------
-- COLUMN PRIVS
---------------
WITH cols AS (
  SELECT privilege, owner, table_name,
         '"'||REPLACE(column_name,'"','""')||'"' AS col_q
  FROM   dba_col_privs
  WHERE  grantee='&SRC_U'
)
SELECT 'GRANT '||privilege||' ('||
       LISTAGG(col_q, ', ') WITHIN GROUP (ORDER BY col_q)||
       ') ON "'||owner||'"."'||table_name||'" TO "'||'&DST_U'||'";'
FROM cols
GROUP BY privilege, owner, table_name
ORDER BY owner, table_name, privilege;

SPOOL OFF
SET TERMOUT ON
