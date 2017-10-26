USE ADUANA
DROP TABLE smicartainst
CREATE TABLE smicartainst(
 instid INT IDENTITY(1,1)
,instreferencia VARCHAR(10)
,instpatente VARCHAR(4)
,instaduana VARCHAR(3)
,instpedimento VARCHAR(8)
,instclienteid INT
,instproveedorid INT
,instdestinatarioid INT
,instfechadespacho DATETIME
,insttipoop INT
,instregimen VARCHAR(3)
,instdescripcion VARCHAR(250)
,instclaveped VARCHAR(2)
,instincoterm VARCHAR(3)
,instmoneda VARCHAR(3)
,instpais VARCHAR(3)
,instbultos FLOAT
,instpesobruto FLOAT
,instpesoneto FLOAT
,instma BIT
,instmediotransporte INT
,instnocaja VARCHAR(20)
,instplacas VARCHAR(20)
,instguia VARCHAR(20)
,insttipocont INT
,instlugararribo VARCHAR(150)
,instarribonombre VARCHAR(150)
,instarribodomicilio VARCHAR(1024)
,instarribotel VARCHAR(20)
,instarribocontacto VARCHAR(150)
,instobsarribo VARCHAR(1024)
,instcortransfer BIT 
,insttransfernombre VARCHAR(150)
,insttransferdomicilio VARCHAR(1024)
,insttransfertel VARCHAR(20)
,insttransfercontacto VARCHAR(150)
,insttransfercaat VARCHAR(10)
,insttransferscac VARCHAR(10)
,instentrega VARCHAR(1024)
,instbroker BIT
,instbrokernombre VARCHAR(150)
,instbrokerdomicilio VARCHAR(1024)
,instbrokertel VARCHAR(20)
,instbrokercontacto VARCHAR(150)
,instfechacreacion DATETIME DEFAULT GETDATE()
,instfechainstruccion DATETIME
,instfechaedicion DATETIME
,instusuarioid INT
,instusuarionombre VARCHAR(50)
)