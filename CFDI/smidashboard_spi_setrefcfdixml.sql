-- =============================================
-- AUTHOR     : LEONEL GONZALEZ
-- DATE       :
-- DESCRIPTION:
-- =============================================
USE [Aduana]
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME = 'smidashboard_spi_setrefcfdixml' AND TYPE = 'P')
	  DROP PROCEDURE smidashboard_spi_setrefcfdixml;
GO
CREATE PROCEDURE smidashboard_spi_setrefcfdixml(@TXTREF VARCHAR(10),@CLIENTE_ID INT, @PROVEEDOR_ID INT, @XmlFile VARCHAR(MAX),@instpedimento varchar(12),@newref BIT)
WITH ENCRYPTION
AS
BEGIN

	IF @CLIENTE_ID=0
		SET @CLIENTE_ID=2026

	IF @PROVEEDOR_ID=0
		SET @PROVEEDOR_ID=4131
			
	DECLARE @XmlCFDI XML = CAST(@XmlFile AS XML)
	DECLARE @EMISORRFC VARCHAR(13),@EMISORNOMBRE VARCHAR(150),@CLIENTENOM VARCHAR(150),@CLIENTENUM VARCHAR(15)
	SELECT
		 @EMISORRFC=T.C.value('@rfc', 'varchar(13)')
		,@EMISORNOMBRE=T.C.value('@nombre', 'varchar(150)')
	from @XmlCFDI.nodes('declare namespace cfdi="http://www.sat.gob.mx/cfd/3"; //cfdi:Comprobante/cfdi:Emisor') T(C)

	DECLARE @RECEPTORRFC VARCHAR(13),@RECEPTORNOMBRE VARCHAR(150)
	SELECT
		 @RECEPTORRFC=T.C.value('@rfc', 'varchar(13)')
		,@RECEPTORNOMBRE=T.C.value('@nombre', 'varchar(150)')
	from @XmlCFDI.nodes('declare namespace cfdi="http://www.sat.gob.mx/cfd/3"; //cfdi:Comprobante/cfdi:Receptor') T(C)

	DECLARE @FECHAFAC SMALLDATETIME,@TOTAL MONEY, @MONEDA VARCHAR(3)
	SELECT
		 @FECHAFAC=CAST(T.C.value('@fecha', 'varchar(40)') AS SMALLDATETIME)
		,@TOTAL=CAST(T.C.value('@total', 'varchar(40)') AS MONEY)
		,@MONEDA=T.C.value('@Moneda', 'varchar(40)')
	from @XmlCFDI.nodes('declare namespace cfdi="http://www.sat.gob.mx/cfd/3"; //cfdi:Comprobante') T(C)

	DECLARE @NOFACTURA VARCHAR(40)
	SELECT
		 @NOFACTURA=T.C.value('@UUID', 'varchar(40)')
	from @XmlCFDI.nodes('declare namespace cfdi="http://www.sat.gob.mx/cfd/3"; declare namespace tfd="http://www.sat.gob.mx/TimbreFiscalDigital"; //cfdi:Comprobante/cfdi:Complemento/tfd:TimbreFiscalDigital') T(C)

		DECLARE @ClaveDePedimento VARCHAR(5), @INCOTERM VARCHAR(5)
	SELECT
		 @ClaveDePedimento=ISNULL(T.C.value('@ClaveDePedimento', 'varchar(40)'),'')
		,@INCOTERM=ISNULL(T.C.value('@Incoterm', 'varchar(40)'),'')
	from @XmlCFDI.nodes('declare namespace cfdi="http://www.sat.gob.mx/cfd/3"; declare namespace cce="http://www.sat.gob.mx/ComercioExterior"; //cfdi:Comprobante/cfdi:Complemento/cce:ComercioExterior') T(C)

	DECLARE @CONCEPTOS TABLE(
	 id INT IDENTITY(1,1)
	,cantidad FLOAT
	,unidad VARCHAR(10)
	,noIdentificacion VARCHAR(20)
	,descripcion VARCHAR(250)
	,valorUnitario FLOAT	
	,importe FLOAT) 
	INSERT INTO @CONCEPTOS(cantidad,unidad,noIdentificacion,descripcion,valorUnitario,importe)
	SELECT
		  ISNULL(T.C.value('@cantidad', 'float'),0)
		 ,ISNULL(T.C.value('@unidad', 'varchar(10)'),'')
		 ,ISNULL(T.C.value('@noIdentificacion', 'varchar(20)'),'')
		 ,ISNULL(T.C.value('@descripcion', 'varchar(250)'),'')
		 ,ISNULL(T.C.value('@valorUnitario', 'float'),0)
		 ,ISNULL(T.C.value('@importe', 'float'),0)
	from @XmlCFDI.nodes('declare namespace cfdi="http://www.sat.gob.mx/cfd/3"; //cfdi:Comprobante/cfdi:Conceptos/cfdi:Concepto') T(C)

	DECLARE @Referencia VARCHAR(10)=UPPER(@txtref),@PREF VARCHAR(8)='T3035240',@Embarcador_id INT=@PROVEEDOR_ID,@embarcador VARCHAR(150),@BODNOM144 BIT,
			@Cli INT=@Cliente_id,@ProCli INT=@proveedor_id,@ServerTime VARCHAR(10),@Error NVARCHAR(1024)
			SET @ServerTime = SUBSTRING(CONVERT(VARCHAR(20),GETDATE(),9),13,5) + ' ' + SUBSTRING(CONVERT(VARCHAR(30),GETDATE(),9),25,2)
	IF NOT EXISTS(SELECT BODREFERENCIA FROM TBLBOD WHERE UPPER(BODREFERENCIA)=UPPER(@Referencia) AND PREF=@PREF ) 
	BEGIN
		IF DATALENGTH(@Referencia)>0 
		BEGIN
			SET @Embarcador = ( SELECT SUBSTRING(PRONOM,1,35) FROM PROCLI WHERE proveedor_id=@Embarcador_id )
			SET @BODNOM144 = ( SELECT VALOR FROM SLAMNET_PARAMETROS WHERE CLAVE = 53 )
		
			/* FILL TBLBOD */
			INSERT  INTO [TBLBOD]
	            ([BODENTRADA],[BODREFERENCIA],[BODNUMREF],[BODEMB],[BODTIPEMB],[BODTIPTRA],[BODCLI],[BODPROCLI],[BODFECHA],[BODFLE],[BODIMPFLE],[BODTIPFLE]
	            ,[BODCHEQUE],[BODCOD],[BODTIPCOD],[BODCHEQUECOD],[BODBNO],[BODCAJA],[BODHORA],[BODFECHAC],[BODHORAC],[BODDESCMER],[BODVALMER],[BODNOPEDIDO]
	            ,[BODBULTOS],[BODPESOLBS],[BODSECCION],[BODUSUARIO],[BODDESCARGO],[BODVERIFICO],[BODCOMEN1],[BODCOMEN2],[BODANOTA1],[BODFOTO1],[BODFOTO2]
				,[BODBANDERA],[BODFOTO],[BODCANCELADO],[BODUSADA],[BODDESCCAJA],[BODREVISADO],[BODMERCTRAN],[BODINBOND],[BODDESTINO],[BODSALES],[BODSHIPPING]
				,[BODLORIGEN],[BODFORIGEN],[CON_PROD],[EMBALAJE],[LOTES],[CERTIFICADO],[TEMPERATURA],[BODCONSIGNA_ID],[ULTIMA_MOD],[PORLLEGAR],[CLIPROV]
				,[BODVIRTUAL],[BODTLC],[BODRECIBIDO],[BODTURNO],[BODESTATUS],[BODGUIAP],[BODORIGEN],[BODCONCARGA],[BODSHIPID],[BODFALTALE],[BODFALTAFAC]
				,[BODFALTAPER],[BODFALTANOM],[BODFALTAORDEN],[BODLLEGODAN],[BODLLEGOINC],[BODPRECIOINC],[BODCARTDAN],[BODGO],[BODINBOND2],[BODPEDIMENTO]
	            ,[BODPORIGEN],[BODSIMULADOR],[BODADUANA],[BODMERCAFAL],[BODCODIGO],[BODPACKLIST],[BODSHIPMENT],[BODHCERTIFICA],[BODNAFTA],[BODMSDS]
				,[BODRCERTIFICA],[BODCOA],[BODRRECEPCION],[BODFNOTIFICA],[BODFCERTIFICA],[BODHNOTIFICA],[BODRNOTIFICA],[BODRCARGA],[BODFENTRADA],[BODHENTRADA]
				,[BODRENTRADA],[BODRELABORACION],[BODRPAGO],[BODRSALBOD],[BODRSALPATIO],[BODRCRUCE],[BODRSALADUANA],[BODRENTREGA],[BODCOMPRADOR],[BODRUTA]
				,[BODLOCALIDAD],[BODMARCA],[BODFEXPFURGON],[PREF],[FEPUNTO],[FSPUNTO],[BODCATEGORIA],[BODEMBARCADOR_ID],[BODMATPEL],[BODDISTRIBUCION],[BODMONEDA]
				,[BOCOMEN2],[FECHABILL],[TIPOIMPO],[DESC_TIPOIMPO],[BODSYMBOLS],[BODNOMMT],[BODCLASEMT],[BODGEMT],[BODIDMT],[CODE_GV],[QUANTITY_GV],[BODHORARECIBO]
				,[BODCLASIFICADO],[BODFECHAFONDEO],[RECHAZADA],[LIBERADA],[CONDLIMPIEZA],[FAUNANOCIVA],[TEMPCAJA],[PIEZAS],[BODCONTROL],[BODPROICA],[BODCDESTINO]
				,[BODCDIVISION],[BODNOM144],[BODPERTENECEA_ID],[BODPERTENECEA],[REFERENCIAGL])
			VALUES
			    (NULL,UPPER(@Referencia),UPPER(@Referencia),@Embarcador,NULL,NULL,@Cli,@Procli,CAST(FLOOR(CAST(GETDATE() AS FLOAT)) AS DATETIME),0,0.0,NULL
				,NULL,0.0,NULL,NULL,NULL,NULL,NULL,CAST(FLOOR(CAST(GETDATE() AS FLOAT)) AS DATETIME),@ServerTime,NULL,0.0,NULL
				,0,0.0,NULL,0,NULL,NULL,'','','',NULL,NULL
				,1,0,0,0,NULL,0,0,NULL,NULL,NULL,NULL,NULL
				,NULL,NULL,NULL,NULL,NULL,0,0,CAST(FLOOR(CAST(GETDATE() AS FLOAT)) AS DATETIME),0,NULL
				,0,NULL,0,NULL,NULL,NULL,NULL,0,NULL,0,0
				,0,0,0,0,0,0,0,NULL,NULL,NULL
				,NULL,NULL,NULL,0,NULL,0,NULL,NULL,0,0
				,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
				,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
				,NULL,NULL,NULL,@PREF,NULL,NULL,NULL,@Embarcador_id,0,0,NULL
				,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL
				,0,NULL,0,0,NULL,NULL,NULL,0,NULL,NULL,NULL
				,NULL,ISNULL(@BODNOM144,0),0,NULL,NULL)

			/* FILL TRAFICO */
			INSERT  INTO [TRAFICO]
	          ([TRAREFERENCIA],[TRAFECHAACT],[TRACLI],[TRAPROCLI],[TRARELACION],[TRAFECHACRUCE],[TRAHORA],[TRANUMCAJA],[TRAFECHAPROG],[TRALINEAMEX],[TRATALON]
			  ,[TRAPEDIMENTO],[TRANOANTI],[TRATOTIMP],[TRAFECHACLAS],[TRAANTI],[TRAFECHASOL],[TRAFECHAANTI],[TRARECANTI],[TRAIMPEXP],[TRADESCRIPCION],[TRASTATUS]
			  ,[TRAUSUARIO],[TRANOBORRAR],[TRACONSOLIDADO],[TRAOBSERVACIONES],[TRACUENTA],[TRAPRINCIPAL],[TRASUB],[TRASAGAR],[TRAFECHADOC],[TRASALDADO],[TRAFECHACTA]
			  ,[TRAIMPCTA],[SHIPPER],[CERTIFICADO],[TRAFENTREGA],[TRAHENTREGA],[TRACONSIGNA_ID],[TIPO_IND],[ULTIMA_MOD],[TRAIMPTALON],[TRATALONCHEQUE],[TRATALONFECHA]
			  ,[TRAHORACLAS],[TRAHORASOL],[TRAHORARECANT],[TRACUENTAMEX],[TRAFECHACTAMEX],[TRAIMPCTAMEX],[TRAROJO],[TRAREGIMEN],[TRAREGIMEN_ARTEVA],[TRASELLO1],[TRASELLO2]
			  ,[TRASELLO3],[TRADESCCAJA],[TRAFECHAPAGO],[TRAROJO2],[TRACHOFER],[TRANSFER],[TRAQUIMICOS],[TRASININSTRUCCION],[TRAFECHAUNIKO],[TRAHORAUNIKO]
			  ,[ULTIMOREQUISITOUNIKO],[TRAFSALIDA],[TRAHSALIDA],[TRAPDESTINO],[PEDREC],[ENVIO],[TRAOBSRECON],[TRAHORACARR],[TRACAMION_ID],[MULTIPROV],[TRAANTIREC]
			  ,[NOEMBARQUE],[TRAADUANA],[ADUANA_ENTRADA],[TRAHORAPAGO],[TRAUSUARIO2],[TRAFGSSHIPDATE],[TRABORDEREDA],[TRABORDERETA],[TRANOTIFICATIONDATE]
			  ,[TRANOTIFICATIONTIME],[TRADATEDELIVERYMXCARRIER],[TRATIMEDELIVERYMXCARRIER],[TRARDCEDA],[TRARDCETA],[TRARDCADA],[TRARDCATA],[TRARDCUNLOADDATE]
			  ,[TRARDCUNLOADTIME],[TRAHORAACT],[TRASELLO4],[PREF],[TRATRENNUM],[TRAFECHASL],[TRACERRADO],[TRAFECHAINICARGA],[TRAFECHAFINCARGA],[TRAHORAINICARGA]
			  ,[TRAHORAFINCARGA],[TRAROJO1FE],[TRAROJO1HE],[TRAROJO1FS],[TRAROJO1HS],[TRAROJO2FE],[TRAROJO2HE],[TRAROJO2FS],[TRAROJO2HS],[TRARCUMPF],[TRARCUMPH]
			  ,[TRARELCARGA],[TRAHORADOC],[CERTIFICADODEANALISIS],[EDETYEM],[TRAPARTETD],[TRACANTIDADTD],[TRAPRECIOTD],[TRACONTENEDOR],[DOW_MODAL]
			  ,[DOW_FSHIPMENTCONS],[DOW_HSHIPMENTCONS],[DOW_COMEN1],[DOW_COMEN2],[DOW_MED1],[DOW_MED2],[TRAINCI1],[TRAINCI2],[RELFACNO],[FIRMAELECPREVIO]
			  ,[TRADESCTRAFICO],[MANIFIESTO],[PERSONAFIRMA],[FCARGADOGEN],[TRADESCARGA],[TRAHTTRANSBORDO],[TRAHERRTIGUIA],[TRAHPR],[HTTRANSBORDO],[HERRTIGUIA]
			  ,[HPR],[TRACHOFERLC],[TRATRANSFERLC],[TRADESADUANADO],[TRAFEMATRACK],[TRAFLLEGADAGANCHAR],[TRAHLLEGADAGANCHAR],[TRAFROJOMEX],[TRAHROJOMEX]
			  ,[TRAFVERDEMEX],[TRAHVERDEMEX],[TRAFROJOAME],[TRAHROJOAME],[TRAFVERDEAME],[TRAHVERDEAME],[TRAFENTREGAFINAL],[TRAHENTREGAFINAL],[TRAQUIENRECIBE]
			  ,[TRASELLOS],[TRAVALOR],[TRADESTINA],[TRAFECHAOFICINA],[TRAFECHAFRONTERA],[TRAHORAOFICINA],[TRAHORAFRONTERA],[TRAHORAENTREGA],[TRADESPACHO]
			  ,[TRASTATUSMANUAL],[TRAFAVISO],[TRAHAVISO],[TRAFPREFILE],[TRAHPREFILE],[BROKENSEAL],[NEWSEAL],[SEALCOLOR],[ARRIVALDATECUSTOM],[TRAENTMANI]
			  ,[TRARECMANI],[TRAAAA],[MUESTREADO],[PRODMUES],[DETENIDO],[OBSPUNTO],[FDARELEASE],[FDARELEASEH],[ENVIOBL],[FSFFEDEST],[HSFFEDEST],[FLLDEST]
			  ,[HLLDEST],[TRADATESLP],[TRADATENOTI],[TRATRANSFER],[ARRIVALTIMECUSTOM],[SEALRECIEVEDBY],[LDOFWHSE],[TRATIPOCONTENEDOR],[LDOHWHSE],[SEALWASBROKEN]
			  ,[TRAFSALPLA],[TRAHSALPLA],[PLANTAEMB],[TRAHORARECMANI],[PIDI],[TRARECHMANI],[TRAENTHMANI],[NO_ENTRY],[PLACAS],[ESTADO_CAJA],[SERIE],[REFCLIENTE]
			  ,[INBOND],[TRASELLONUEVO],[FACTURA],[OFECHASAL],[OHORASAL],[OFECHA_A26],[OHORA_A26],[OFECHA_OFICINA],[OHORA_OFICINA],[OPERADOR],[UNIDAD]
			  ,[SCAC_CODE],[TRASELLOS_TRACKING],[SUCURSAL_TRACKING],[CITA_FECHACARGA_TRACKING],[CITA_HORACARGA_TRACKING],[PISTAS],[DOBLE_OPERADOR]
			  ,[PAIS_CAJA],[TRADESTINO],[CONSM3],[TRAUSUARIOCAPTURA],[SMITRACFDI])
			VALUES
			  (UPPER(@Referencia),CAST(FLOOR(CAST(GETDATE() AS FLOAT)) AS DATETIME),@Cli,@Procli,NULL,NULL,NULL,NULL,NULL,0,NULL
			  ,@instpedimento,NULL,0.0,NULL,0.0,NULL,NULL,0,0,NULL,'PENDIENTE SOLICITAR ANTICIPO'
			  ,0,0,0,NULL,NULL,0,0,0,NULL,0,NULL
			  ,0.0,0,0,NULL,NULL,0,NULL,CAST(FLOOR(CAST(GETDATE() AS FLOAT)) AS DATETIME),0.0,NULL,NULL
			  ,NULL,NULL,NULL,NULL,NULL,0.0,0,@ClaveDePedimento,NULL,NULL,NULL
			  ,NULL,NULL,NULL,0,NULL,0,0,0,NULL,NULL
			  ,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,0
			  ,NULL,0,0,NULL,0,NULL,NULL,NULL,NULL
			  ,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
			  ,NULL,NULL,NULL,@PREF,NULL,NULL,0,NULL,NULL,NULL
			  ,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
			  ,0,NULL,0,0,NULL,NULL,0,NULL,NULL
			  ,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL
			  ,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
			  ,NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL
			  ,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
			  ,NULL,0,0,NULL,NULL,NULL,NULL,NULL,NULL
			  ,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
			  ,NULL,NULL,0,NULL,0,NULL,NULL,NULL,NULL,NULL,NULL,NULL
			  ,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0
			  ,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
			  ,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,0,NULL
			  ,NULL,NULL,NULL,NULL,NULL,NULL,NULL
			  ,NULL,NULL,0,0,1)


			DECLARE @bul INT,@pesolbs FLOAT
            SELECT  @bul=smicartainst.instbultos,@pesolbs=smicartainst.instpesobruto
			FROM smicartainst WHERE instreferencia=@Referencia

			/* IDENTIFICADORES DE TRAFICO CONSTRUIDO */
			UPDATE tblbod SET tblbod.BODBANDERA=1
							,tblbod.bodbultos=@bul
							,tblbod.bodpesolbs=@pesolbs
			WHERE tblbod.bodreferencia=@Referencia AND tblbod.PREF=@PREF

			UPDATE trafico SET trafico.traaduana=smicartainst.instaduana
							  ,trafico.TRAREGIMEN=smicartainst.instclaveped
							  ,trafico.traNumCaja=smicartainst.instnocaja
							  ,trafico.traplacas=smicartainst.instplacas
							  ,trafico.TRATIPOREGIMEN=smicartainst.instregimen
			FROM trafico
			LEFT JOIN smicartainst ON smicartainst.instreferencia=trafico.traReferencia
			WHERE trafico.trareferencia=@Referencia AND trafico.PREF=@PREF

			INSERT INTO tblBultos(bulref,bulControl,bulmarcas,bulcanti,bulnumero,bulclase,ULTIMA_MOD,PREF)
			VALUES  (@Referencia,@Referencia,'S/M',@bul,'S/N','BULTOS',GETDATE(),@PREF)
		END
	END
	IF @NOFACTURA<>'' BEGIN

		DECLARE @PAIS AS VARCHAR(4)
		SET @PAIS =(SELECT PROPAIS FROM PROCLI WHERE PROVEEDOR_ID=@PROVEEDOR_ID)
		-- INSERT STATEMENTS FOR PROCEDURE HERE
	
		INSERT INTO TBLFACTGEN(FACGNOFAC,FOLIO_CFDI,FACGREF,FACGFEFAC,FACGVALOR,FACGMONEDA,FACGPAIS,FACGPROV,FACGCLI,FACGVALORMERC
		,FACGSUBDIVISION,FACGUSUARIO,PREF,FACGBANDERA,FACGCLASIFICADA,FACGSUCURSAL,NOMOSTRARENINVENTARIO,VIN,FACGINCOTERM,SMIFACCFDI)
		VALUES	(@NOFACTURA,@NOFACTURA,@REFERENCIA,@FECHAFAC,@TOTAL,@MONEDA,@PAIS,@PROVEEDOR_ID,@CLIENTE_ID,@TOTAL,0,0,@PREF,0,0,0,0,0,@INCOTERM,1)

		DECLARE @FACID INT=(SELECT FACTURA_ID FROM TBLFACTGEN WHERE FACGREF=@REFERENCIA AND FACGNOFAC=@NOFACTURA)

		DECLARE @i INT=(SELECT COUNT(*) FROM @CONCEPTOS),@x INT=1
		DECLARE @PARTNUM VARCHAR(25), @PARTDESC VARCHAR(250)
		WHILE @x<=@I BEGIN

			INSERT INTO TBLCLASIFICA(FACTURA_ID,FACTURA,REFERENCIA,RENGLON,NUMPARTE,DESCFRA,CANTFAC,CANTIDAD,PESOLBS,PESOKGS,PREUNITARIO,TOTAL,CC,VPR,USUARIO,NUMFRACCION,FECHA,ULTIMA_MOD,PaisOrigen,UNIMEDFAC) 
			SELECT @FACID,@NOFACTURA,@REFERENCIA,@x,noIdentificacion,descripcion,cantidad,cantidad,0,0,valorUnitario,importe,0,0,1,'',GETDATE(),GETDATE(),'MEX','' FROM @CONCEPTOS WHERE ID=@x

			SET @x +=1;
		END

		UPDATE tblclasifica SET 
		numfraccion=tblpartes.partframex
		,PaisOrigen=tblpartes.partpais
		,ua=tblpartes.partmedida
		,UniMedFac=tblpartes.partmedida
		--,descfra=tblpartes.partdescesp
		,tlc=tblpartes.parttlc
		,prosec='N'
		,Usuario=0
		,MA='N'
		,industria=''
		FROM tblclasifica
		LEFT JOIN tblpartes ON partcli=@CLIENTE_ID AND tblpartes.partnum=tblclasifica.numparte
		WHERE factura_id=@FACID;

		UPDATE tblclasifica SET umfac=tblUdc.clave
		FROM tblclasifica
		LEFT JOIN tblUdc ON tblUdc.Abreviacion=tblclasifica.ua
		WHERE factura_id=@FACID

		UPDATE tblclasifica SET umumf=tblUnidad.clave
		FROM tblclasifica
		LEFT JOIN tblUnidad ON tblUnidad.Abreviacion=tblclasifica.ua
		WHERE factura_id=@FACID

			            
		SELECT
			renglon
			,numparte
			,'999999999' numfraccion 
			,descfra
			,paisorigen
			,unimedfac
			,pesokgs
			,cantfac
			,preunitario
			,total
			,case when numfraccion is null then 'red' else '' end colorname
		FROM tblclasifica
		WHERE factura_id=@FACID;

		update tblclasifica set numfraccion='99999999',numparte='SIN CLASIFICAR' WHERE factura_id=@FACID AND numfraccion IS NULL;
	END		    
END
GO
GRANT EXEC ON smidashboard_spi_setrefcfdixml TO PUBLIC;
GO
