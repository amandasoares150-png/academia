create table alunos (
id serial primary key,
nome varchar (100) not null,
email varchar (50) unique not null,
cpf varchar (11) unique not null,
telefone varchar (13) not null,
data_cadastro timestamp default current_timestamp
);

create table planos (
id serial primary key,
nome_plano varchar (100) unique not null,
valor_mensal_base numeric (10,2) not null check (valor_mensal_base >0)
);

create table modalidades (
id serial primary key,
plano_id int not null,
nome_aula varchar (100) not null,
sala varchar (100) not null,
capacidade_maxima int not null check (capacidade_maxima >0),
disponivel boolean default true,
CONSTRAINT fk_modalidades_plano
FOREIGN KEY (plano_id)
REFERENCES planos(id)
);

create table matriculas (
id serial primary key,
aluno_id int not null,
data_inicio timestamp default current_timestamp, 
status varchar (50) default 'ativa' check (status in ('ativo', 'cancelada', 'trancada')),
CONSTRAINT fk_matriculas_aluno
FOREIGN KEY (aluno_id)
REFERENCES alunos(id)
);

create table itens_matriculas ( 
id serial primary key, 
matricula_id int not null, 
modalidade_id int not null, 
duracao_meses int not null check (duracao_meses > 0), 
valor_mensal_aplicado decimal not null check (valor_mensal_aplicado > 0), 
taxa_adesao decimal (10,2) check (taxa_adesao >= 0.00),
foreign key (matricula_id) references matriculas(id), 
foreign key (modalidade_id) references modalidades(id) 
);

insert into alunos (nome, email, cpf, telefone) values
('Amanda Moretti', 'amanda_moretti.200@gmail.com', '19728735490', '(48)9988-1180'),
('Felipe Couto', 'felipe_cout0@gmail.com', '23756907364', '(48)6742-8756'),
('Selma Soares', 'selmasoares3@gmail.com', '72890254683', '(48)9735-1254')

insert into planos (nome_plano,valor_mensal_base) values
('musculação e fit dance', 319.99),
('musculação', 260.00),
('crossfit', 240.00)

insert into modalidades (plano_id, nome_aula, sala, capacidade_maxima, disponivel) values
(2, 'musculação', 'sala 2', 60, true),
(1, 'fit dance', 'sala 5', 25, true),
(3, 'crossfit', 'sala 3', 15, true)

insert into matriculas (aluno_id, status) values
(1, 'ativo'),
(2, 'trancada'),
(2, 'ativo'),
(3, 'ativo')

insert into itens_matriculas (matricula_id, modalidade_id, duracao_meses, valor_mensal_aplicado, taxa_adesao) values
(2, 1, 12, 319.99, 30.00),
(3, 2, 6, 260.00, 50.00),
(3, 2, 12, 260.00, 50.00),
(4, 3, 12, 240.00, 30.00)

create view vw_modalidades_custo_estimado as
select
    m.nome_aula as modalidade,
    m.sala,
    p.nome_plano,
    p.valor_mensal_base * 1.10 as valor_mensal_ajustado
from modalidades m
join planos p on m.plano_id = p.id
order by valor_mensal_ajustado desc;

create view vw_matriculas_ativas as
select
    a.nome,
    a.cpf,
    mo.nome_aula as modalidade,
    mo.sala,
    i.duracao_meses,
    ma.data_inicio
from alunos a
join matriculas ma on a.id = ma.aluno_id
join itens_matriculas i on ma.id = i.matricula_id
join modalidades mo on i.modalidade_id = mo.id
where ma.status = 'ativo';

create view vw_alunos_vip as
select
    a.nome,
    count(distinct ma.id) as quantidade_contratos_ativos,
    sum((i.valor_mensal_aplicado * i.duracao_meses) + i.taxa_adesao) as valor_total_investido
from alunos a
join matriculas ma on a.id = ma.aluno_id
join itens_matriculas i on ma.id = i.matricula_id
where ma.status = 'ativo'
group by a.id, a.nome
having sum((i.valor_mensal_aplicado * i.duracao_meses) + i.taxa_adesao) > 1000;

select
    m.nome_aula as modalidade,
    m.sala,
    m.capacidade_maxima,
    p.nome_plano,
    p.valor_mensal_base,
    m.disponivel
from modalidades m
join planos p on m.plano_id = p.id
where m.capacidade_maxima >= 15
and p.valor_mensal_base > 100
and m.disponivel = true;

create view vw_faturamento_medio_plano as
select
    p.nome_plano,
    sum((i.valor_mensal_aplicado * i.duracao_meses) + i.taxa_adesao) as faturamento_total_acumulado,
    avg(i.duracao_meses) as media_duracao_contratos
from planos p
join modalidades mo on p.id = mo.plano_id
join itens_matriculas i on mo.id = i.modalidade_id
join matriculas ma on i.matricula_id = ma.id
where ma.status = 'ativo'
group by p.id, p.nome_plano;

select
    m.nome_aula as modalidade,
    m.sala,
    m.capacidade_maxima,
    p.nome_plano,
    p.valor_mensal_base,
    m.disponivel
from modalidades m
join planos p on m.plano_id = p.id
where m.capacidade_maxima >= 15
and p.valor_mensal_base > 100
and m.disponivel = true;