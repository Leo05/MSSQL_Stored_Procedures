-- =============================================
-- AUTHOR     : LEONEL GONZALEZ
-- DATE       :
-- DESCRIPTION:
-- =============================================
USE [Aduana]
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME = 'smidashboard_spi_newrefcfdixml' AND TYPE = 'P')
	  DROP PROCEDURE smidashboard_spi_newrefcfdixml;
GO
CREATE PROCEDURE smidashboard_spi_newrefcfdixml
(@instpref VARCHAR(8)
,@instreferencia VARCHAR(10)
,@instpatente VARCHAR(4)
,@instaduana VARCHAR(3)
,@instpedimento VARCHAR(12)
,@instclienteid INT
,@instproveedorid INT
,@instdestinatarioid INT
,@instfechadespacho DATETIME
,@insttipoop INT
,@instregimen VARCHAR(3)
,@instdescripcion VARCHAR(250)
,@instclaveped VARCHAR(2)
,@instincoterm VARCHAR(3)
,@instmoneda VARCHAR(3)
,@instpais VARCHAR(3)
,@instbultos FLOAT
,@instpesobruto FLOAT
,@instpesoneto FLOAT
,@instma BIT
,@instmediotransporte INT
,@instnocaja VARCHAR(20)
,@instplacas VARCHAR(20)
,@instguia VARCHAR(20)
,@insttipocont INT
,@instlugararribo VARCHAR(150)
,@instarribonombre VARCHAR(150)
,@instarribodomicilio VARCHAR(1024)
,@instarribotel VARCHAR(20)
,@instarribocontacto VARCHAR(150)
,@instobsarribo VARCHAR(1024)
,@instcortransfer BIT 
,@insttransfernombre VARCHAR(150)
,@insttransferdomicilio VARCHAR(1024)
,@insttransfertel VARCHAR(20)
,@insttransfercontacto VARCHAR(150)
,@insttransfercaat VARCHAR(10)
,@insttransferscac VARCHAR(10)
,@instentrega VARCHAR(1024)
,@instbroker BIT
,@instbrokernombre VARCHAR(150)
,@instbrokerdomicilio VARCHAR(1024)
,@instbrokertel VARCHAR(20)
,@instbrokercontacto VARCHAR(150)
,@instusuarioid INT
,@instusuarionombre VARCHAR(50)
,@cfdixml VARCHAR(max))
WITH ENCRYPTION
AS
BEGIN
	
	DECLARE @ImpExp BIT=0, @NEWREF BIT=0
	IF(@instreferencia='') begin
		SET @instreferencia=dbo.SMI_FN_ASIGNAREFCFDI(@instpref,0); 
		SET @NEWREF=1;
   		IF @ImpExp = 1 --ES IMPO
			UPDATE CONSECUTIVOS_BOD SET BODEGA_ID=(BODEGA_ID+1) WHERE PREF=@instpref;
		ELSE --ES EXPO
			UPDATE CONSECUTIVOS_BOD SET bodegaexpo_id=(bodegaexpo_id+1) WHERE PREF=@instpref;			
	
	END

	--IF EXISTS(SELECT TRAREFERENCIA FROM TRAFICO WHERE TRAREFERENCIA=@INSTREFERENCIA) BEGIN
	--	DECLARE	@ERRNO  INT,
	--			@ERRMSG VARCHAR(300)
	--	SELECT @ERRNO=13005,@ERRMSG='LA REFERENCIA ' + @INSTREFERENCIA + ' YA EXISTE EN EL SISTEMA... FAVOR DE VERIFICAR'
	--	RAISERROR (@ERRMSG, 16, 1);
	--END



	INSERT INTO [smicartainst]
           ([instreferencia]
           ,[instpatente]
           ,[instaduana]
           ,[instpedimento]
           ,[instclienteid]
           ,[instproveedorid]
           ,[instdestinatarioid]
           ,[instfechadespacho]
           ,[insttipoop]
           ,[instregimen]
           ,[instdescripcion]
           ,[instclaveped]
           ,[instincoterm]
           ,[instmoneda]
           ,[instpais]
           ,[instbultos]
           ,[instpesobruto]
           ,[instpesoneto]
           ,[instma]
           ,[instmediotransporte]
           ,[instnocaja]
           ,[instplacas]
           ,[instguia]
           ,[insttipocont]
           ,[instlugararribo]
           ,[instarribonombre]
           ,[instarribodomicilio]
           ,[instarribotel]
           ,[instarribocontacto]
           ,[instobsarribo]
           ,[instcortransfer]
           ,[insttransfernombre]
           ,[insttransferdomicilio]
           ,[insttransfertel]
           ,[insttransfercontacto]
           ,[insttransfercaat]
           ,[insttransferscac]
           ,[instentrega]
           ,[instbroker]
           ,[instbrokernombre]
           ,[instbrokerdomicilio]
           ,[instbrokertel]
           ,[instbrokercontacto]
           ,[instusuarioid]
           ,[instusuarionombre])
     VALUES
           (@instreferencia
           ,@instpatente
           ,@instaduana 
           ,@instpedimento 
           ,@instclienteid 
           ,@instproveedorid 
           ,@instdestinatarioid 
           ,@instfechadespacho
           ,@insttipoop 
           ,@instregimen 
           ,@instdescripcion 
           ,@instclaveped 
           ,@instincoterm 
           ,@instmoneda 
           ,@instpais 
           ,@instbultos 
           ,@instpesobruto 
           ,@instpesoneto 
           ,@instma 
           ,@instmediotransporte 
           ,@instnocaja 
           ,@instplacas 
           ,@instguia 
           ,@insttipocont 
           ,@instlugararribo 
           ,@instarribonombre 
           ,@instarribodomicilio 
           ,@instarribotel 
           ,@instarribocontacto 
           ,@instobsarribo 
           ,@instcortransfer 
           ,@insttransfernombre 
           ,@insttransferdomicilio 
           ,@insttransfertel 
           ,@insttransfercontacto 
           ,@insttransfercaat 
           ,@insttransferscac 
           ,@instentrega 
           ,@instbroker 
           ,@instbrokernombre 
           ,@instbrokerdomicilio 
           ,@instbrokertel 
           ,@instbrokercontacto 
           ,@instusuarioid 
           ,@instusuarionombre)

	SELECT @instreferencia ref

	--inserta referencia
	EXEC smidashboard_spi_setrefcfdixml @instreferencia,@instclienteid,@instproveedorid,@cfdixml,@instpedimento,@NEWREF

	    
END
GO
GRANT EXEC ON smidashboard_spi_newrefcfdixml TO PUBLIC;
GO
