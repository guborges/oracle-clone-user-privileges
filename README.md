# Oracle Clone User Privileges (GRANT generator)

This repository provides a SQL*Plus script that clones privileges from one Oracle user to another by **generating GRANT statements**, without executing them automatically.

The script reads Oracle data dictionary views and produces a single, reviewable `.sql` file containing all necessary privileges for the destination user.

This approach is designed to be safe, auditable and suitable for production environments.

---

## Overview

The goal of this script is to replicate permissions from a source user to a destination user in a controlled way.

Instead of applying grants directly, the script **only generates** the GRANT commands, allowing DBAs to review and validate them before execution.

---

## What this script generates

- Roles (DBA_ROLE_PRIVS)
- System privileges (DBA_SYS_PRIVS)
- Object privileges (DBA_TAB_PRIVS)
- Column-level privileges (DBA_COL_PRIVS, aggregated with LISTAGG)

---

## Safety model

- Generates GRANT statements only
- Does not execute any privilege changes automatically
- Output must be reviewed and applied manually

---

## Requirements

- SQL*Plus
- Access to dictionary views (typically SYSDBA or SELECT_CATALOG_ROLE)
- Compatible with Oracle 11g / 12c / 19c / 21c+

---

## Usage

```sql
sqlplus / as sysdba @clone_permissoes.sql USUARIO_ORIGEM USUARIO_DESTINO
```
## The script will generate an output file:

clone_USUARIO_ORIGEM_to_USUARIO_DESTINO.sql

---
## After reviewing, you can apply it manually:

@clone_USUARIO_ORIGEM_to_USUARIO_DESTINO.sql

Example output

```sql
GRANT "DBA" TO "USUARIO_DESTINO";
GRANT CREATE SESSION TO "USUARIO_DESTINO";
GRANT UNLIMITED TABLESPACE TO "USUARIO_DESTINO";
GRANT SELECT ON "SCHEMA"."TABELA" TO "USUARIO_DESTINO";
```
---
## Extensions (ideas)

This model can be extended to also clone:

Tablespace quotas

Profiles

Proxy connect

Custom security policies / specific grants

---
## File structure
oracle-clone-user-privileges/
├── clone_permissoes.sql
└── README.md
