ALTER PROCEDURE [dbo].[RANKING]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

  declare @cad_nome varchar(50)
	declare @cad_cartao_func 	numeric(11,3)
	declare @total_cadastros	numeric(11,3)
	declare @mes int
	declare @ano int
	declare @cad_cod int
	declare @cad_arq_ori 	int
	declare @cad_status 	int
	Set @mes = MONTH(getdate())
	Set @ano = YEAR(getdate())
	DECLARE @MyCursor CURSOR 

	DELETE FROM dbo.ranking WHERE mes = @Mes AND ano = @Ano


	SET @MyCursor = CURSOR FAST_FORWARD 
	FOR 
	SELECT  b.cad_cod, a.cad_cartao_func, b.cad_nome, b.cad_arq_ori, b.cad_status, COUNT(*) 
	AS total
	FROM dbo.cadastros AS a LEFT OUTER JOIN
	dbo.cadastros AS b ON CONVERT(varchar, a.cad_cartao_func) = b.cad_cod_ext
	WHERE     (a.cad_tipo = 7) AND (b.cad_status = 2476) AND (YEAR(a.cad_data_cad) = @ano) AND 
	(MONTH(a.cad_data_cad) = @mes) 
	GROUP BY b.cad_cod, a.cad_cartao_func, b.cad_nome, b.cad_arq_ori, b.cad_status

	OPEN @MyCursor
	FETCH NEXT FROM @MyCursor
	INTO @cad_cod, @cad_cartao_func, @cad_nome, @cad_arq_ori, @cad_status, @total_cadastros
	WHILE @@FETCH_STATUS = 0 
	BEGIN 
	INSERT INTO RANKING (mes, ano, cad_cod, cad_cartao_func, cad_nome, cad_arq_ori, cad_status, total_cadastros) 
	values	(@mes, @ano, @cad_cod, @cad_cartao_func, @cad_nome, @cad_arq_ori, @cad_status, @total_cadastros) 
	FETCH NEXT FROM @MyCursor
	INTO @cad_cod, @cad_cartao_func, @cad_nome, @cad_arq_ori, @cad_status, @total_cadastros
	END 

	CLOSE @MyCursor
	DEALLOCATE @MyCursor
	
END
