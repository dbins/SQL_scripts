select * from (
select tipo_transacao, profissao, valor 
FROM tabela_transacoes, tabela_cadastros
where tra_cadastro = cad_cod
) 
DataTable 
PIVOT 
(
 SUM(valor) 
FOR profissao 
 IN ([Profissao_1], [Profissao_2], [Profissao_3]) 
) PivotTable 
