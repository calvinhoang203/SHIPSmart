################################################################################
# Makefile for SHIPSmart
#
# Usage:
#   make help     — show this message
#   make env      — create virtualenv & install Python deps
#   make sql      — create all tables & seed policy_parameters
#   make seed     — load sample CSVs into visits/claims
#   make views    — build SQL views (visit_policy, visit_features, training_data)
#   make train    — train & evaluate the regression model
#   make test     — run pytest suite
#   make demo     — run the CLI cost‑estimate demo
#   make clean    — remove virtualenv & Python cache files
################################################################################

# Default goal
.DEFAULT_GOAL := help

# Show available targets
.PHONY: help
help:
	@echo "SHIPSmart Makefile"
	@echo "------------------"
	@echo "make env      — setup virtualenv & install dependencies"
	@echo "make sql      — apply DDL: create tables + seed policy_parameters"
	@echo "make seed     — load data/raw/visits.csv & claims.csv into DB"
	@echo "make views    — build SQL views (visit_policy, visit_features, training_data)"
	@echo "make train    — train & evaluate the cost‑estimate model"
	@echo "make test     — run all tests"
	@echo "make demo     — run the CLI demo"
	@echo "make clean    — remove virtualenv & caches"

# 1) Create Python virtualenv & install requirements
.PHONY: env
env:
	python3 -m venv Hack
	Hack/bin/pip install --upgrade pip
	Hack/bin/pip install -r requirements.txt

# 2) Create schema & seed the policy
.PHONY: sql
sql:
	@echo "▶️  Creating tables and seeding policy_parameters…"
	psql $(DB_URL) -f sql/create_tables.sql
	psql $(DB_URL) -f sql/insert_policy.sql

# 3) Bulk‑load the sample visits & claims
.PHONY: seed
seed:
	@echo "▶️  Loading sample data into visits and claims…"
	psql $(DB_URL) \
	  -c "\copy visits(student_uid,provider_npi,cpt_code,service_date,plan_year) FROM 'data/raw/visits.csv' CSV HEADER" 
	psql $(DB_URL) \
	  -c "\copy claims(visit_id,billed_amount,allowed_amount,student_pay,insurer_pay,claim_status,processed_date) FROM 'data/raw/claims.csv' CSV HEADER"

# 4) Build the feature‑engineering views
.PHONY: views
views:
	@echo "▶️  Creating views…"
	psql $(DB_URL) -f sql/create_views.sql

# 5) Train & evaluate the model
.PHONY: train
train:
	@echo "▶️  Training model…"
	Hack/bin/python src/model.py

# 6) Run tests
.PHONY: test
test:
	@echo "▶️  Running tests…"
	Hack/bin/pytest

# 7) Run the CLI demo
.PHONY: demo
demo:
	@echo "▶️  Launching demo…"
	Hack/bin/python src/demo.py

# 8) Tear down
.PHONY: clean
clean:
	@echo "🧹 Cleaning up…"
	rm -rf Hack
	find . -name "*.pyc" -delete
