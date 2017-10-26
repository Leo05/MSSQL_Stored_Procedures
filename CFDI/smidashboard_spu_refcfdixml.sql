-- =============================================
-- AUTHOR     : LEONEL GONZALEZ
-- DATE       :
-- DESCRIPTION:
-- =============================================
USE [Aduana]
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME = 'smidashboard_spu_refcfdixml' AND TYPE = 'P')
	  DROP PROCEDURE smidashboard_spu_refcfdixml;
GO
CREATE PROCEDURE smidashboard_spu_refcfdixml
(@intid int
,@instreferencia VARCHAR(10)
,@instpatente VARCHAR(4)
,@instaduana VARCHAR(3)
,@instpedimento VARCHAR(8)
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
,@instusuarionombre VARCHAR(50))
WITH ENCRYPTION
AS
BEGIN



	UPDATE [smicartainst] SET
            instreferencia=@instreferencia
           ,instpatente=@instpatente
           ,instaduana=@instaduana 
           ,instpedimento=@instpedimento 
           ,instclienteid=@instclienteid 
           ,instproveedorid=@instproveedorid 
           ,instdestinatarioid=@instdestinatarioid 
           ,instfechadespacho=@instfechadespacho
           ,insttipoop=@insttipoop 
           ,instregimen=@instregimen 
           ,instdescripcion=@instdescripcion 
           ,instclaveped=@instclaveped 
           ,instincoterm=@instincoterm 
           ,instmoneda=@instmoneda 
           ,instpais=@instpais 
           ,instbultos=@instbultos 
           ,instpesobruto=@instpesobruto 
           ,instpesoneto=@instpesoneto 
           ,instma=@instma 
           ,instmediotransporte=@instmediotransporte 
           ,instnocaja=@instnocaja 
           ,instplacas=@instplacas 
           ,instguia=@instguia 
           ,insttipocont=@insttipocont 
           ,instlugararribo=@instlugararribo 
           ,instarribonombre=@instarribonombre 
           ,instarribodomicilio=@instarribodomicilio 
           ,instarribotel=@instarribotel 
           ,instarribocontacto=@instarribocontacto 
           ,instobsarribo=@instobsarribo 
           ,instcortransfer=@instcortransfer 
           ,insttransfernombre=@insttransfernombre 
           ,insttransferdomicilio=@insttransferdomicilio 
           ,insttransfertel=@insttransfertel 
           ,insttransfercontacto=@insttransfercontacto 
           ,insttransfercaat=@insttransfercaat 
           ,insttransferscac=@insttransferscac 
           ,instentrega=@instentrega 
           ,instbroker=@instbroker 
           ,instbrokernombre=@instbrokernombre 
           ,instbrokerdomicilio=@instbrokerdomicilio 
           ,instbrokertel=@instbrokertel 
           ,instbrokercontacto=@instbrokercontacto 
           ,instusuarioid=@instusuarioid 
           ,instusuarionombre=@instusuarionombre
	WHERE instid=@intid;
	    
END
GO
GRANT EXEC ON smidashboard_spu_refcfdixml TO PUBLIC;
GO
