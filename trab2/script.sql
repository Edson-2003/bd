/*
  BASE DE DADOS	INDIA JOB MARKET
  ALUNO: EDSON AUGUSTO PEREIRA FERREIRA
  UC: BANCO DE DADOS
  PROFESSOR: EDSON DA SILVA CASTRO
	
	FUNCOES CRIADAS
	- FN_normaliza()
	- FN_Cria_view()
	- FN_Simula(INT)
	
	VIEWS CRIADAS
	- desnormaliza

*/

/* habilitando modulo de criptografia de dados*/
CREATE EXTENSION IF NOT EXISTS pgcrypto;


/* excluindo objetos */
DROP TABLE IF EXISTS entrada;
DROP TABLE IF EXISTS job_market CASCADE;
DROP TABLE IF EXISTS types CASCADE;
DROP TABLE IF EXISTS companies CASCADE;
DROP TABLE IF EXISTS job_model CASCADE;
DROP TABLE IF EXISTS location CASCADE;
DROP TABLE IF EXISTS job_portal CASCADE;
DROP TABLE IF EXISTS jobs CASCADE;
DROP TABLE IF EXISTS education CASCADE;
DROP TABLE IF EXISTS salary CASCADE;
DROP TABLE IF EXISTS tsalary; 
DROP TABLE IF EXISTS tcompanies;
DROP TABLE IF EXISTS tjob_model;
DROP TABLE IF EXISTS tjobs;
DROP TABLE IF EXISTS teducation;
DROP TABLE IF EXISTS simula;

/*
	tabelas criadas
		-jobs: job title, Education_Requirement and salary range
		-companies: name, size
		-types: job_type
		-location: name of the city		
		-job_portal: job vaccanci portal
		-salary: salary range
		-job_model: model job
*/





CREATE TABLE entrada
(
	job_id varchar(255) NOT NULL,
	job_title varchar(255) NOT NULL,
	company_name varchar(255) NOT NULL,
	job_location varchar(255) NOT NULL,
	job_type varchar(255) NOT NULL,
	salary_range varchar(255) NOT NULL,
	Experience_Required varchar(255) NOT NULL,
	Posted_Date Date NOT NULL,
	Application_Deadline Date NOT NULL,
	Job_Portal varchar(255) NOT NULL,
	Number_of_Applicants numeric(16) NOT NULL,
	Education_Requirement varchar(255) NOT NULL,
	Skills_Required varchar(255) NOT NULL,
	Remote_Onsite varchar(255) NOT NULL,
	Company_Size varchar(255) NOT NULL
);

COPY entrada  FROM '/tmp/india_job_market_dataset.csv' CSV header delimiter ',';
SELECT * into job_market FROM entrada;

CREATE OR REPLACE FUNCTION FN_encrypt()
RETURNS void
AS $$
BEGIN
	UPDATE salary SET range = pgp_sym_encrypt(range, 'salarystrongpassword'::text);
	UPDATE education SET level = pgp_sym_encrypt(level,'educationstrongpassword'::text);
	UPDATE jobs SET job_title = pgp_sym_encrypt(job_title, 'jobsstrongpassword'::text);
	UPDATE job_model SET model = pgp_sym_encrypt(model, 'modelstrongpassword'::text);
	UPDATE companies SET name = pgp_sym_encrypt(name, 'companiesstrongpassword'::text);
END;
$$ LANGUAGE plpgsql;


/*
CREATE OR REPLACE FUNCTION FN_decrypt()
RETURNS void
AS $$
BEGIN
	UPDATE salary SET range = pgp_sym_decrypt(range::bytea, 'salarystrongpassword'::text)::varchar;
	UPDATE education SET level = pgp_sym_decrypt(level::bytea,'educationstrongpassword'::text)::varchar;
	UPDATE jobs SET job_title = pgp_sym_decrypt(job_title::bytea, 'jobstrongpassword'::text)::varchar;
	UPDATE job_model SET model = pgp_sym_decrypt(model::bytea, 'modelstrongpassword'::text)::varchar;
END;
$$ LANGUAGE plpgsql;
*/

CREATE OR REPLACE FUNCTION FN_normaliza()
RETURNS void
AS $$
BEGIN
	CREATE TABLE salary (id SERIAL PRIMARY KEY, range VARCHAR(255));
	INSERT INTO salary (range) SELECT DISTINCT salary_range  FROM job_market order by 1;
	ALTER TABLE job_market ADD COLUMN range INT;
	ALTER TABLE job_market ADD CONSTRAINT FK_salary FOREIGN KEY (range) REFERENCES salary(id);
	UPDATE job_market SET range = salary.id from salary where salary_range = salary.range; 

	CREATE TABLE education (id SERIAL PRIMARY KEY, level VARCHAR(255));
	INSERT INTO education (level) SELECT DISTINCT Education_Requirement  FROM job_market ORDER BY 1;
	ALTER TABLE job_market ADD COLUMN level int;
	ALTER TABLE job_market ADD CONSTRAINT FK_education FOREIGN KEY (level) REFERENCES education(id);
	UPDATE job_market Set level = education.id from education where education.level = Education_Requirement;


	CREATE TABLE job_model (id SERIAL PRIMARY KEY, model VARCHAR(255) NOT NULL);
	INSERT INTO job_model (model) SELECT DISTINCT Remote_Onsite  FROM job_market ORDER BY 1;
	ALTER TABLE job_market ADD COLUMN model int;
	ALTER TABLE job_market ADD CONSTRAINT FK_model FOREIGN KEY (model) REFERENCES job_model(id); 
	UPDATE job_market SET model = job_model.id from job_model where Remote_Onsite = job_model.model;

	CREATE TABLE jobs (id SERIAL PRIMARY KEY, job_title VARCHAR(255) NOT NULL);
	INSERT INTO jobs (job_title) SELECT DISTINCT job_title  FROM job_market ORDER BY 1;
	ALTER TABLE job_market ADD COLUMN title_id INT;
	ALTER TABLE job_market ADD CONSTRAINT FK_job_title FOREIGN KEY (title_id) REFERENCES jobs(id);
	UPDATE job_market SET title_id = jobs.id from jobs where job_market.job_title = jobs.job_title;


	CREATE TABLE companies (id SERIAL PRIMARY KEY, name VARCHAR(255) NOT NULL, size VARCHAR(255) NOT NULL);
	INSERT INTO companies (name, size) SELECT DISTINCT company_name, company_size  FROM job_market ORDER BY 1;
	ALTER TABLE job_market ADD COLUMN company_id INT;
	ALTER TABLE job_market ADD CONSTRAINT FK_company_name FOREIGN KEY (company_id) REFERENCES companies(id);
	UPDATE job_market SET company_id = companies.id  FROM companies where company_name = companies.name;

	CREATE TABLE location (id SERIAL PRIMARY KEY, city VARCHAR(255) NOT NULL);
	INSERT INTO location (city) SELECT DISTINCT job_location FROM job_market ORDER BY 1;
	ALTER TABLE job_market ADD COLUMN city_id INT;
	ALTER TABLE job_market ADD CONSTRAINT FK_city_name FOREIGN KEY (city_id) REFERENCES location(id);
	UPDATE job_market SET city_id = location.id FROM location WHERE job_market.job_location = location.city;

	CREATE TABLE types (id SERIAL PRIMARY KEY, type VARCHAR(255) NOT NULL);
	INSERT INTO types (type) SELECT DISTINCT job_type FROM job_market ORDER BY 1;
	ALTER TABLE job_market ADD COLUMN type_id INT;
	ALTER TABLE job_market ADD CONSTRAINT FK_type FOREIGN KEY (type_id) REFERENCES types(id);
	UPDATE job_market SET type_id = types.id FROM types where job_market.job_type = types.type;


	CREATE TABLE job_portal (id SERIAL PRIMARY KEY, portal VARCHAR(255) NOT NULL);
	INSERT INTO Job_Portal (portal) SELECT DISTINCT job_market.Job_Portal FROM job_market order by 1;
	ALTER TABLE job_market ADD COLUMN portal_id INT;
	ALTER TABLE job_market ADD CONSTRAINT FK_portal FOREIGN KEY (portal_id) REFERENCES job_portal(id);
	UPDATE job_market SET portal_id = job_portal.id FROM job_portal where Job_Portal = job_portal.portal;
	
	execute 'select FN_encrypt()';

	ALTER TABLE job_market DROP COLUMN job_title;
	ALTER TABLE job_market DROP COLUMN Education_Requirement;
	ALTER TABLE job_market DROP COLUMN Job_Portal;
	ALTER TABLE job_market DROP COLUMN Remote_Onsite;
	ALTER TABLE job_market DROP COLUMN salary_range;
	ALTER TABLE job_market DROP COLUMN company_name;
	ALTER TABLE job_market DROP COLUMN company_size;
	ALTER TABLE job_market DROP COLUMN job_location;
	ALTER TABLE job_market DROP COLUMN job_type;

END;
$$ LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION FN_Cria_View()
RETURNS TABLE
(
	job_id varchar(255),
	job_title varchar(255),
	company_name varchar(255),
	job_location varchar(255),
	job_type varchar(255),
	salary_range varchar(255),
	Experience_Required varchar(255),
	Posted_Date Date,
	Application_Deadline Date,
	Job_Portal varchar(255),
	Number_of_Applicants numeric(16),
	Education_Requirement varchar(255),
	Skills_Required varchar(255),
	Remote_Onsite varchar(255),
	Company_Size varchar(255)
)
AS $$
BEGIN
	CREATE TEMPORARY TABLE tcompanies(id serial, name varchar(255) not null, size varchar(255) not null);
	insert into tcompanies (name, size) SELECT pgp_sym_decrypt(companies.name::bytea, 'companiesstrongpassword'::text)::varchar, size FROM companies;

	CREATE TEMPORARY TABLE tsalary (id SERIAL, range VARCHAR(255));
	INSERT INTO tsalary (range) SELECT pgp_sym_decrypt(salary.range::bytea, 'salarystrongpassword'::text)::varchar from salary;

	CREATE TEMPORARY TABLE teducation (id SERIAL, level VARCHAR(255));
	INSERT INTO teducation (level) SELECT pgp_sym_decrypt(education.level::bytea, 'educationstrongpassword'::text)::varchar from education;

	CREATE TEMPORARY TABLE tjobs (id SERIAL, job_title VARCHAR(255) NOT NULL);
	INSERT INTO tjobs (job_title) SELECT pgp_sym_decrypt(jobs.job_title::bytea, 'jobsstrongpassword'::text)::varchar from jobs;
	
	CREATE TEMPORARY TABLE tjob_model (id SERIAL, model VARCHAR(255) NOT NULL);
	INSERT INTO tjob_model (model) SELECT pgp_sym_decrypt(job_model.model::bytea, 'modelstrongpassword'::text)::varchar from job_model;
	
	CREATE OR REPLACE TEMPORARY VIEW desnormaliza AS
	SELECT job_id,
				 tjobs.job_title as job_title,
				 tcompanies.name as company_name,
				 location.city as job_location,
				 types.type as job_type,
				 tsalary.range as salary_range,
				 Experience_Required,
				 Posted_Date,
				 Application_Deadline,
				 job_portal.portal as Job_Portal,
				 Number_of_Applicants,
				 teducation.level as Education_Requirement,
				 Skills_Required,
				 tjob_model.model as Remote_Onsite,
				 tcompanies.size as Company_Size
	FROM job_market
	JOIN tcompanies on company_id = tcompanies.id
	JOIN location on city_id = location.id
	join types on type_id = types.id
	join job_portal on portal_id = job_portal.id
	join tjobs on job_market.title_id = tjobs.id
	join teducation on job_market.level = teducation.id
	join tjob_model on job_market.model = tjob_model.id
	join tsalary on job_market.range = tsalary.id;

	return query select * FROM desnormaliza;
END;
$$ LANGUAGE plpgsql;




CREATE OR REPLACE FUNCTION FN_GeraId(num int)
RETURNS VARCHAR(255)
AS $$
BEGIN
	RETURN 'J' || num::VARCHAR;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION FN_Gera_Title()
RETURNS int
AS $$
BEGIN
	return id from jobs order by RANDOM() limit 1;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION FN_Gera_Portal()
RETURNS int
AS $$
BEGIN
	return id from job_portal order by RANDOM() limit 1;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION FN_Gera_city()
RETURNS int
AS $$
BEGIN
	return id from location order by RANDOM() limit 1;
END;
$$ LANGUAGE plpgsql;

create temporary table simula
(
	id varchar(255),
	title int,
	portal int,
	city int
);





CREATE OR REPLACE FUNCTION FN_Simula(n int)
RETURNS void
AS $$
BEGIN
	FOR i IN 1..n LOOP
		INSERT INTO simula (id, title, portal, city) SELECT FN_GeraId(i), FN_Gera_Title(), FN_Gera_Portal(), FN_Gera_City();
	END LOOP;


END;
$$ LANGUAGE plpgsql;

SELECT FN_normaliza();
SELECT FN_Cria_view();
SELECT * FROM desnormaliza; 

select FN_Simula(5000000);
EXPLAIN ANALYSE SELECT * from simula where city = 10 and portal = 3;
CREATE INDEX city_portal_index ON simula(city, portal);
EXPLAIN ANALYSE SELECT * from simula where city = 10 and portal = 3;
