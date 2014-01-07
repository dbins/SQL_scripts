/****** Object:  UserDefinedFunction [dbo].[usf_valida_cnpj]    Script Date: 01/07/2014 13:03:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 
ALTER FUNCTION [dbo].[usf_valida_cnpj](@cnpjx varchar(14)) RETURNS bit
AS
-- Nome Artefato/Programa..: usf_valida_cnpj.sql
-- Autor(es)...............: Emerson Hermann (emersonhermann [at] gmail.com) O Peregrino (http://www.emersonhermann.blogspot.com) baseado em Script feito por:
-- ........................: Baseado em código de Fernando Jacinto da Silva em http://www.devmedia.com.br
-- Data Inicio ............: 18/09/2011
-- Data Atualizacao........: 19/09/2012
-- Versao..................: 0.02
-- Compilador/Interpretador: T-SQL (Transact SQL) 
-- Sistemas Operacionais...: Windows
-- SGBD....................: MS SQL Server 2005/2008
-- Kernel..................: Nao informado!
-- Finalidade..............: Store Procedure (Function) para validar o numero do CNPJ
-- OBS.....................: A entrada é um varchar e o retorno é um bit, 1 para válido, 0 para inválido e null para nulos 
-- ........................: 
--  
BEGIN

DECLARE
        @cnpj   varchar(14) 
      , @indice int
      , @soma   int
      , @dig1   int
      , @dig2   int
      , @var1   int
      , @var2   int
      , @resultado bit

    SET @cnpj = @cnpjx 
    SET @soma = 0
    SET @indice = 1
    SET @resultado = 0

    -- pre-validacao 1, se e nulo, entao retorna nulo
    IF @cnpj IS NULL BEGIN
        SET @resultado = NULL
        RETURN (@resultado)  
    END --fim_se      
 
    -- pre-validacao 2, se e maior que 11 digitos , entao retorna 0 
    IF LEN(@cnpj) > 14 BEGIN
        SET @resultado = 0 
        RETURN (@resultado)
    END --fim_se
   
    -- pre-validacao 3, se e tem alguma letra no cpf, entao retorna 0 
    IF (SELECT CASE WHEN patindex('%[^0-9]%', @cnpj) > 0 THEN 1 ELSE 0 END) = 1 BEGIN
       SET @resultado = 0
       RETURN (@resultado)
    END --fim_se   
 
    -- pre-validacao 4, se e menor que 11 digitos , pode ser oriundo de bigint, então fazer tratamento de zeros 
    IF LEN(@cnpj) < 14 BEGIN
        SET @cnpj = REPLICATE('0',14-LEN(@cnpj))+@cnpj
    END --fim se 
 
    /* algorítimo para o primeiro dígito 543298765432 */
    /* cálculo do 1º dígito */
    /* cálculo da 1ª parte do algorítiom 5432 */

    SET @var1 = 5 /* 1a parte do algorítimo começando de "5" */

    WHILE (@indice <= 4) BEGIN

        SET @soma = @soma + CONVERT(int,SUBSTRING(@cnpj,@indice,1)) * @var1

        SET @indice = @indice + 1 /* navegando um-a-um até < = 4, as quatro primeira posições */

        SET @var1 = @var1 - 1  /* subtraindo o algorítimo de 5 até 2 */

    END

    /* cálculo da 2ª parte do algorítiom 98765432 */

    SET @var2 = 9

    WHILE (@indice <= 12) BEGIN

        SET @soma = @soma + CONVERT(int,SUBSTRING(@cnpj,@indice,1)) * @var2

        SET @indice = @indice + 1

        SET @var2 = @var2 - 1            
    END

    SET @dig1 = (@soma % 11)

    /* se o resto da divisão for < 2, o digito = 0 */

    IF @dig1 < 2 BEGIN

        SET @dig1 = 0

    END ELSE BEGIN /* se o resto da divisão não for < 2*/

        SET @dig1 = 11 - (@soma % 11)
    END

    /* cálculo do 2º dígito */
    /* zerando o indice e a soma para começar a calcular o 2º dígito*/   

    SET @indice = 1
    SET @soma = 0

    /* cálculo da 1ª parte do algorítiom 65432 */

    SET @var1 = 6 /* 2a parte do algorítimo começando de "6" */

    SET @resultado = 0  

    WHILE (@indice <= 5) BEGIN
  
        SET @soma = @soma + CONVERT(int,SUBSTRING(@cnpj,@indice,1)) * @var1
        SET @indice = @indice + 1 /* navegando um-a-um até < = 5, as quatro primeira posições */
        SET @var1 = @var1 - 1       /* subtraindo o algorítimo de 6 até 2 */

    END

    /* cálculo da 2ª parte do algorítiom 98765432 */
    SET @var2 = 9

    WHILE (@indice <= 13) BEGIN

        SET @soma = @soma + CONVERT(int,SUBSTRING(@cnpj,@indice,1)) * @var2
        SET @indice = @indice + 1
        SET @var2 = @var2 - 1            

    END
 
    SET @dig2 = (@soma % 11) 

    /* se o resto da divisão for < 2, o digito = 0 */

    IF @dig2 < 2 BEGIN

        SET @dig2 = 0

    END ELSE BEGIN /* se o resto da divisão não for < 2*/

        SET @dig2 = 11 - (@soma % 11)
    END
 
    -- validando

    IF (@dig1 = SUBSTRING(@cnpj,LEN(@cnpj)-1,1)) AND (@dig2 = SUBSTRING(@cnpj,LEN(@cnpj),1)) BEGIN

        SET @resultado = 1

    END ELSE BEGIN

        SET @resultado = 0 
  
    END 

RETURN (@resultado)

END;
