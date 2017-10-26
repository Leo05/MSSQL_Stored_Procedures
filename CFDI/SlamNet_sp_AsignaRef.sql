USE Aduana
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].SlamNet_sp_AsignaRef
(
	@Embarcador_id INT,
	@Cli INT,
	@Procli INT,
	@Usuario INT,
	@Consigna_id INT,
	@PREF VARCHAR(10),
	@ImpExp INT=1,
	@RefManual VARCHAR(10)='' ,
	@referenciagl CHAR(100)='',
	@PREFIJOAA VARCHAR(10)=''
)
WITH ENCRYPTION
AS 
BEGIN

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
SET XACT_ABORT ON
SET NOCOUNT ON
BEGIN TRY

	DECLARE @Referencia VARCHAR(10), @ServerTime VARCHAR(10), @Embarcador VARCHAR(100), @Error NVARCHAR(MAX), @BODNOM144 BIT
	
	DECLARE @PARAM105 TINYINT
	SET @PARAM105  = ISNULL((SELECT VALOR FROM SLAMNET_PARAMETROS WHERE CLAVE=105),0)				
	SET @ServerTime = SUBSTRING(CONVERT(VARCHAR(20),GETDATE(),9),13,5) + ' ' + SUBSTRING(CONVERT(VARCHAR(30),GETDATE(),9),25,2)

	SET @PREFIJOAA = LTRIM(RTRIM(@PREFIJOAA))

	/*ASIGNACION DE REFERENCIA*/
	IF OBJECT_ID('tempdb..#TEMP') IS NOT NULL 
		DROP TABLE #TEMP;
	CREATE TABLE #TEMP (campo varchar(100))
	INSERT INTO #TEMP
	EXEC dbo.SlamNetImp_sp_GetReferencia @PREF,@RefManual,@ImpExp,@PREFIJOAA,@Cli;
	SET @Referencia=(SELECT campo FROM #TEMP);
	/*ASIGNACION DE REFERENCIA*/

	/* REFERENCIA LOAD CONTROL */
	DECLARE @isccia varchar(3);
	SET @isccia = ISNULL((SELECT ISNULL([valordefault],'0') FROM [slamnet_parametros] WHERE [clave] = 0),'0')
	IF (@isccia = '27' OR @isccia = '1') AND (@referenciagl = '')
	BEGIN
		DECLARE @consecutivo bigint
		SET @consecutivo = ((SELECT ISNULL(CONSECUTIVO,0) FROM PREFIJO_TRAFICO WHERE PREF = @pref AND LTRIM(RTRIM(PREFIJO)) = SUBSTRING(@Referencia,1,2)) + 1);
		UPDATE PREFIJO_TRAFICO SET CONSECUTIVO = @consecutivo WHERE PREF = @pref AND LTRIM(RTRIM(PREFIJO)) = SUBSTRING(@Referencia,1,2);
		
		SET @referenciagl = (SELECT CASE 
								WHEN SUBSTRING(@Referencia,1,2) = 'BF' 
									THEN 'BMF' + SUBSTRING(CONVERT(VARCHAR(4),YEAR(GETDATE())),3,2) + '-' + RIGHT('00000' + CAST(@consecutivo as varchar),5)
								WHEN SUBSTRING(@Referencia,1,2) = 'KL' 
									THEN 'SFI' + SUBSTRING(CONVERT(VARCHAR(4),YEAR(GETDATE())),3,2) + '-' + RIGHT('00000' + CAST(@consecutivo as varchar),5)
								WHEN SUBSTRING(@Referencia,1,2) = 'BC' 
									THEN 'BMC' + SUBSTRING(CONVERT(VARCHAR(4),YEAR(GETDATE())),3,2) + '-' + RIGHT('00000' + CAST(@consecutivo as varchar),5)
								WHEN SUBSTRING(@Referencia,1,2) = 'KC' 
									THEN 'SFC' + SUBSTRING(CONVERT(VARCHAR(4),YEAR(GETDATE())),3,2) + '-' + RIGHT('00000' + CAST(@consecutivo as varchar),5)
								END)
	END
	/* REFERENCIA LOAD CONTROL */

	/*CONTRUCCION DE TRAFICO*/
	IF NOT EXISTS(SELECT BODREFERENCIA FROM TBLBOD WHERE UPPER(BODREFERENCIA)=UPPER(@Referencia) AND PREF=@PREF ) 
	BEGIN
		IF @Referencia IS NOT NULL OR @Referencia <> '' 
		BEGIN
			SET @Embarcador = ( SELECT SUBSTRING(PRONOM,1,35) FROM PROCLI WHERE proveedor_id=@Embarcador_id )
			SET @BODNOM144 = ( SELECT VALOR FROM SLAMNET_PARAMETROS WHERE CLAVE = 53 )
		
			/* FILL TBLBOD */
			INSERT  INTO [dbo].[tblBod]
/*01*/              ( [bodEntrada] ,
						[bodReferencia] ,
						[bodNumRef] ,
						[BODEMB] ,
						[bodtipemb] ,
						[bodtiptra]
/*02*/ ,
						[bodcli] ,
						[bodprocli] ,
						[bodfecha] ,
						[bodfle] ,
						[bodimpfle] ,
						[bodtipfle]
/*03*/ ,
						[bodCHEQUE] ,
						[bodCOD] ,
						[bodtipCOD] ,
						[bodchequeCOD] ,
						[bodbno] ,
						[bodcaja]
/*04*/ ,
						[bodhora] ,
						[bodfechac] ,
						[bodhorac] ,
						[boddescmer] ,
						[bodvalmer] ,
						[bodnopedido]
/*05*/ ,
						[bodbultos] ,
						[bodpesolbs] ,
						[bodseccion] ,
						[bodUsuario] ,
						[bodDescargo] ,
						[bodVerifico]
/*06*/ ,
						[bodcomen1] ,
						[bodcomen2] ,
						[bodAnota1] ,
						[bodfoto1] ,
						[bodfoto2] ,
						[bodBandera]
/*07*/ ,
						[bodfoto] ,
						[bodCancelado] ,
						[bodUsada] ,
						[BodDescCaja] ,
						[BodRevisado] ,
						[BodMercTran]
/*08*/ ,
						[BODINBOND] ,
						[BODDESTINO] ,
						[BODSALES] ,
						[BODSHIPPING] ,
						[BODLORIGEN] ,
						[BODFORIGEN]
/*09*/ ,
						[CON_PROD] ,
						[EMBALAJE] ,
						[LOTES] ,
						[CERTIFICADO] ,
						[TEMPERATURA] ,
						[BODCONSIGNA_ID]
/*10*/ ,
						[ULTIMA_MOD] ,
						[PORLLEGAR] ,
						[CLIPROV] ,
						[BODVIRTUAL] ,
						[BODTLC] ,
						[BODRECIBIDO]
/*11*/ ,
						[BODTURNO] ,
						[BODESTATUS] ,
						[BODGUIAP] ,
						[BODORIGEN] ,
						[BODCONCARGA] ,
						[BODSHIPID]
/*12*/ ,
						[BODFALTALE] ,
						[BODFALTAFAC] ,
						[BODFALTAPER] ,
						[BODFALTANOM] ,
						[BODFALTAORDEN] ,
						[BODLLEGODAN]
/*13*/ ,
						[BODLLEGOINC] ,
						[BODPRECIOINC] ,
						[BODCARTDAN] ,
						[BODGO] ,
						[BODINBOND2] ,
						[BODPEDIMENTO]
/*14*/ ,
						[BODPORIGEN] ,
						[BODSIMULADOR] ,
						[BODADUANA] ,
						[BODMERCAFAL] ,
						[BODCODIGO] ,
						[BODPACKLIST]
/*15*/ ,
						[BODSHIPMENT] ,
						[BODHCERTIFICA] ,
						[BODNAFTA] ,
						[BODMSDS] ,
						[BODRCERTIFICA] ,
						[BODCOA]
/*16*/ ,
						[BODRRECEPCION] ,
						[BODFNOTIFICA] ,
						[BODFCERTIFICA] ,
						[BODHNOTIFICA] ,
						[BODRNOTIFICA] ,
						[BODRCARGA]
/*17*/ ,
						[BODFENTRADA] ,
						[BODHENTRADA] ,
						[BODRENTRADA] ,
						[BODRELABORACION] ,
						[BODRPAGO] ,
						[BODRSALBOD]
/*18*/ ,
						[BODRSALPATIO] ,
						[BODRCRUCE] ,
						[BODRSALADUANA] ,
						[BODRENTREGA] ,
						[BODCOMPRADOR] ,
						[BODRUTA]
/*19*/ ,
						[BODLOCALIDAD] ,
						[BODMARCA] ,
						[BODFEXPFURGON] ,
						[PREF] ,
						[FEPUNTO] ,
						[FSPUNTO]
/*20*/ ,
						[BODCATEGORIA] ,
						[BODEMBARCADOR_ID] ,
						[BODMATPEL] ,
						[BODDISTRIBUCION] ,
						[BODMONEDA] ,
						[BOCOMEN2]
/*21*/ ,
						[FECHABILL] ,
						[TIPOIMPO] ,
						[DESC_TIPOIMPO] ,
						[BODSYMBOLS] ,
						[BODNOMMT] ,
						[BODCLASEMT]
/*22*/ ,
						[BODGEMT] ,
						[BODIDMT] ,
						[CODE_GV] ,
						[QUANTITY_GV] ,
						[BODHORARECIBO] ,
						[BODCLASIFICADO]
/*23*/ ,
						[BODFECHAFONDEO] ,
						[RECHAZADA] ,
						[LIBERADA] ,
						[CONDLIMPIEZA] ,
						[FAUNANOCIVA] ,
						[TEMPCAJA]
/*24*/ ,
						[PIEZAS] ,
						[BODCONTROL] ,
						[BODPROICA] ,
						[BODCDESTINO] ,
						[BODCDIVISION] ,
						[BODNOM144]
/*25*/ ,
						[BODPERTENECEA_ID] ,
						[BODPERTENECEA] ,
						[referenciagl]
					)
			VALUES  /*01*/
					( NULL ,
						UPPER(@Referencia) ,
						UPPER(@Referencia) ,
						@Embarcador ,
						NULL ,
						NULL
/*02*/ ,
						@Cli ,
						@Procli ,
						CAST(FLOOR(CAST(GETDATE() AS FLOAT)) AS DATETIME) ,
						0 ,
						0.0 ,
						NULL
/*03*/ ,
						NULL ,
						0.0 ,
						NULL ,
						NULL ,
						NULL ,
						NULL
/*04*/ ,
						NULL ,
						CAST(FLOOR(CAST(GETDATE() AS FLOAT)) AS DATETIME) ,
						@ServerTime ,
						NULL ,
						0.0 ,
						NULL
/*05*/ ,
						0 ,
						0.0 ,
						NULL ,
						@Usuario ,
						NULL ,
						NULL
/*06*/ ,
						'' ,
						'' ,
						'' ,
						NULL ,
						NULL ,
						1
/*07*/ ,
						0 ,
						0 ,
						0 ,
						NULL ,
						0 ,
						0
/*08*/ ,
						NULL ,
						NULL ,
						NULL ,
						NULL ,
						NULL ,
						NULL
/*09*/ ,
						NULL ,
						NULL ,
						NULL ,
						NULL ,
						0 ,
						@Consigna_id
/*10*/ ,
						CAST(FLOOR(CAST(GETDATE() AS FLOAT)) AS DATETIME) ,
						0 ,
						NULL ,
						0 ,
						NULL ,
						0
/*11*/ ,
						NULL ,
						NULL ,
						NULL ,
						NULL ,
						0 ,
						NULL
/*12*/ ,
						0 ,
						0 ,
						0 ,
						0 ,
						0 ,
						0
/*13*/ ,
						0 ,
						0 ,
						0 ,
						NULL ,
						NULL ,
						NULL
/*14*/ ,
						NULL ,
						NULL ,
						NULL ,
						0 ,
						NULL ,
						0
/*15*/ ,
						NULL ,
						NULL ,
						0 ,
						0 ,
						NULL ,
						0
/*16*/ ,
						NULL ,
						NULL ,
						NULL ,
						NULL ,
						NULL ,
						NULL
/*17*/ ,
						NULL ,
						NULL ,
						NULL ,
						NULL ,
						NULL ,
						NULL
/*18*/ ,
						NULL ,
						NULL ,
						NULL ,
						NULL ,
						NULL ,
						NULL
/*19*/ ,
						NULL ,
						NULL ,
						NULL ,
						@PREF ,
						NULL ,
						NULL
/*20*/ ,
						NULL ,
						@Embarcador_id ,
						0 ,
						0 ,
						NULL ,
						NULL
/*21*/ ,
						NULL ,
						NULL ,
						NULL ,
						NULL ,
						NULL ,
						NULL
/*22*/ ,
						NULL ,
						NULL ,
						NULL ,
						0 ,
						NULL ,
						0
/*23*/ ,
						NULL ,
						0 ,
						0 ,
						NULL ,
						NULL ,
						NULL
/*24*/ ,
						0 ,
						NULL ,
						NULL ,
						NULL ,
						NULL ,
						ISNULL(@BODNOM144,0)--0
/*25*/ ,
						0 ,
						NULL ,
						@referenciagl
					)

			/* FILL TRAFICO */
			INSERT  INTO [dbo].[Trafico]
/*01*/              ( [traReferencia],
						[traFechaAct] ,
						[traCli] ,
						[traProCli] ,
						[traRelacion] ,
						[traFechaCruce]
/*02*/ ,
						[traHora] ,
						[traNumCaja] ,
						[traFechaProg] ,
						[traLineaMex] ,
						[traTalon] ,
						[traPedimento]
/*03*/ ,
						[traNoAnti] ,
						[traTotImp] ,
						[traFechaClas] ,
						[traAnti] ,
						[traFechaSol] ,
						[traFechaAnti]
/*04*/ ,
						[traRecAnti] ,
						[traImpExp] ,
						[traDescripcion] ,
						[traStatus] ,
						[traUsuario] ,
						[traNOBORRAR]
/*05*/ ,
						[traConsolidado] ,
						[traObservaciones] ,
						[traCuenta] ,
						[traPrincipal] ,
						[TRASUB] ,
						[trasagar]
/*06*/ ,
						[TRAFECHADOC] ,
						[TRASALDADO] ,
						[TRAFECHACTA] ,
						[TRAIMPCTA] ,
						[SHIPPER] ,
						[CERTIFICADO]
/*07*/ ,
						[TRAFENTREGA] ,
						[TRAHENTREGA] ,
						[TRACONSIGNA_ID] ,
						[TIPO_IND] ,
						[ULTIMA_MOD] ,
						[TRAIMPTALON]
/*08*/ ,
						[TRATALONCHEQUE] ,
						[TRATALONFECHA] ,
						[TRAHORACLAS] ,
						[TRAHORASOL] ,
						[TRAHORARECANT] ,
						[TRACUENTAMEX]
/*09*/ ,
						[TRAFECHACTAMEX] ,
						[TRAIMPCTAMEX] ,
						[TRAROJO] ,
						[TRAREGIMEN] ,
						[TRAREGIMEN_ARTEVA] ,
						[TRASELLO1]
/*10*/ ,
						[TRASELLO2] ,
						[TRASELLO3] ,
						[TRADESCCAJA] ,
						[TRAFECHAPAGO] ,
						[TRAROJO2] ,
						[TRACHOFER]
/*11*/ ,
						[TRANSFER] ,
						[TRAQUIMICOS] ,
						[TRASININSTRUCCION] ,
						[TRAFECHAUNIKO] ,
						[TRAHORAUNIKO] ,
						[ULTIMOREQUISITOUNIKO]
/*12*/ ,
						[TRAFSALIDA] ,
						[TRAHSALIDA] ,
						[TRAPDESTINO] ,
						[PEDREC] ,
						[ENVIO] ,
						[TRAOBSRECON]
/*13*/ ,
						[TRAHORACARR] ,
						[TRACAMION_ID] ,
						[MULTIPROV] ,
						[TRAANTIREC] ,
						[NOEMBARQUE] ,
						[TRAADUANA] ,
						[ADUANA_ENTRADA]
/*14*/ ,
						[TRAHORAPAGO] ,
						[TRAUSUARIO2] ,
						[TRAFGSSHIPDATE] ,
						[TRABORDEREDA] ,
						[TRABORDERETA] ,
						[TRANOTIFICATIONDATE]
/*15*/ ,
						[TRANOTIFICATIONTIME] ,
						[TRADATEDELIVERYMXCARRIER] ,
						[TRATIMEDELIVERYMXCARRIER] ,
						[TRARDCEDA] ,
						[TRARDCETA] ,
						[TRARDCADA]
/*16*/ ,
						[TRARDCATA] ,
						[TRARDCUNLOADDATE] ,
						[TRARDCUNLOADTIME] ,
						[TRAHORAACT] ,
						[TRASELLO4] ,
						[PREF]
/*17*/ ,
						[TRATRENNUM] ,
						[TRAFECHASL] ,
						[TRACERRADO] ,
						[TRAFECHAINICARGA] ,
						[TRAFECHAFINCARGA] ,
						[TRAHORAINICARGA]
/*18*/ ,
						[TRAHORAFINCARGA] ,
						[TRAROJO1FE] ,
						[TRAROJO1HE] ,
						[TRAROJO1FS] ,
						[TRAROJO1HS] ,
						[TRAROJO2FE]
/*19*/ ,
						[TRAROJO2HE] ,
						[TRAROJO2FS] ,
						[TRAROJO2HS] ,
						[TRARCUMPF] ,
						[TRARCUMPH] ,
						[TRARELCARGA]
/*20*/ ,
						[TRAHORADOC] ,
						[CERTIFICADODEANALISIS] ,
						[EDETYEM] ,
						[TRAPARTETD] ,
						[TRACANTIDADTD] ,
						[TRAPRECIOTD]
/*21*/ ,
						[TRACONTENEDOR] ,
						[DOW_MODAL] ,
						[DOW_FSHIPMENTCONS] ,
						[DOW_HSHIPMENTCONS] ,
						[DOW_COMEN1] ,
						[DOW_COMEN2]
/*22*/ ,
						[DOW_MED1] ,
						[DOW_MED2] ,
						[TRAINCI1] ,
						[TRAINCI2] ,
						[RELFACNO] ,
						[FIRMAELECPREVIO]
/*23*/ ,
						[TRADESCTRAFICO] ,
						[MANIFIESTO] ,
						[PERSONAFIRMA] ,
						[FCARGADOGEN] ,
						[TRADESCARGA] ,
						[TRAHTTRANSBORDO]
/*24*/ ,
						[TRAHERRTIGUIA] ,
						[TRAHPR] ,
						[HTTRANSBORDO] ,
						[HERRTIGUIA] ,
						[HPR] ,
						[TRACHOFERLC]
/*25*/ ,
						[TRATRANSFERLC] ,
						[TRADESADUANADO] ,
						[TRAFEMATRACK] ,
						[TRAFLLEGADAGANCHAR] ,
						[TRAHLLEGADAGANCHAR] ,
						[TRAFROJOMEX]
/*26*/ ,
						[TRAHROJOMEX] ,
						[TRAFVERDEMEX] ,
						[TRAHVERDEMEX] ,
						[TRAFROJOAME] ,
						[TRAHROJOAME] ,
						[TRAFVERDEAME]
/*27*/ ,
						[TRAHVERDEAME] ,
						[TRAFENTREGAFINAL] ,
						[TRAHENTREGAFINAL] ,
						[TRAQUIENRECIBE] ,
						[TRASELLOS] ,
						[traValor]
/*28*/ ,
						[TRADESTINA] ,
						[TRAFECHAOFICINA] ,
						[TRAFECHAFRONTERA] ,
						[TRAHORAOFICINA] ,
						[TRAHORAFRONTERA] ,
						[TRAHORAENTREGA]
/*29*/ ,
						[TRADESPACHO] ,
						[TRASTATUSMANUAL] ,
						[TRAFAVISO] ,
						[TRAHAVISO] ,
						[TRAFPREFILE] ,
						[TRAHPREFILE]
/*30*/ ,
						[BROKENSEAL] ,
						[NEWSEAL] ,
						[SEALCOLOR] ,
						[ARRIVALDATECUSTOM] ,
						[TRAENTMANI] ,
						[TRARECMANI]
/*31*/ ,
						[TRAAAA] ,
						[MUESTREADO] ,
						[PRODMUES] ,
						[DETENIDO] ,
						[OBSPUNTO] ,
						[FDARELEASE]
/*32*/ ,
						[FDARELEASEH] ,
						[ENVIOBL] ,
						[FSFFEDEST] ,
						[HSFFEDEST] ,
						[FLLDEST] ,
						[HLLDEST]
/*33*/ ,
						[TRADATESLP] ,
						[TRADATENOTI] ,
						[TRATRANSFER] ,
						[ARRIVALTIMECUSTOM] ,
						[SEALRECIEVEDBY] ,
						[LDOFWHSE]
/*34*/ ,
						[TRATIPOCONTENEDOR] ,
						[LDOHWHSE] ,
						[sealwasbroken] ,
						[TRAFSALPLA] ,
						[TRAHSALPLA] ,
						[plantaemb]
/*35*/ ,
						[TRAHORARECMANI] ,
						[PIDI] ,
						[TRARECHMANI] ,
						[TRAENTHMANI] ,
						[NO_ENTRY] ,
						[PLACAS]
/*36*/ ,
						[ESTADO_CAJA] ,
						[SERIE] ,
						[REFCLIENTE] ,
						[INBOND] ,
						[TRASELLONUEVO] ,
						[FACTURA]
/*37*/ ,
						[OFECHASAL] ,
						[OHORASAL] ,
						[OFECHA_A26] ,
						[OHORA_A26] ,
						[OFECHA_OFICINA] ,
						[OHORA_OFICINA]
/*38*/ ,
						[OPERADOR] ,
						[UNIDAD] ,
						[SCAC_CODE] ,
						[TRASELLOS_TRACKING] ,
						[SUCURSAL_TRACKING] ,
						[CITA_FECHACARGA_TRACKING]
/*39*/ ,
						[CITA_HORACARGA_TRACKING] ,
						[PISTAS] ,
						[DOBLE_OPERADOR] ,
						[PAIS_CAJA] ,
						[TRADESTINO] ,
						[CONSM3],						
						[TRAUSUARIOCAPTURA]
					)
			VALUES  /*01*/
					( UPPER(@Referencia) ,
						CAST(FLOOR(CAST(GETDATE() AS FLOAT)) AS DATETIME) ,
						@Cli ,
						@Procli ,
						NULL ,
						NULL
/*02*/ ,
						NULL ,
						NULL ,
						NULL ,
						0 ,
						NULL ,
						NULL
/*03*/ ,
						NULL ,
						0.0 ,
						NULL ,
						0.0 ,
						NULL ,
						NULL
/*04*/ ,
						0 ,
						@ImpExp,
						NULL ,
						'FALTA FACTURA' ,
						@Usuario ,
						0
/*05*/ ,
						0 ,
						NULL ,
						NULL ,
						0 ,
						0 ,
						0
/*06*/ ,
						NULL ,
						0 ,
						NULL ,
						0.0 ,
						0 ,
						0
/*07*/ ,
						NULL ,
						NULL ,
						@Consigna_id ,
						NULL ,
						CAST(FLOOR(CAST(GETDATE() AS FLOAT)) AS DATETIME) ,
						0.0
/*08*/ ,
						NULL ,
						NULL ,
						NULL ,
						NULL ,
						NULL ,
						NULL
/*09*/ ,
						NULL ,
						0.0 ,
						0 ,
						NULL ,
						NULL ,
						NULL
/*10*/ ,
						NULL ,
						NULL ,
						NULL ,
						NULL ,
						0 ,
						NULL
/*11*/ ,
						0 ,
						0 ,
						0 ,
						NULL ,
						NULL ,
						NULL
/*12*/ ,
						NULL ,
						NULL ,
						NULL ,
						NULL ,
						NULL ,
						NULL
/*13*/ ,
						NULL ,
						NULL ,
						0 ,
						0 ,
						NULL ,
						0 ,
						0
/*14*/ ,
						NULL ,
						@Usuario ,
						NULL ,
						NULL ,
						NULL ,
						NULL
/*15*/ ,
						NULL ,
						NULL ,
						NULL ,
						NULL ,
						NULL ,
						NULL
/*16*/ ,
						NULL ,
						NULL ,
						NULL ,
						NULL ,
						NULL ,
						@PREF
/*17*/ ,
						NULL ,
						NULL ,
						0 ,
						NULL ,
						NULL ,
						NULL
/*18*/ ,
						NULL ,
						NULL ,
						NULL ,
						NULL ,
						NULL ,
						NULL
/*19*/ ,
						NULL ,
						NULL ,
						NULL ,
						NULL ,
						NULL ,
						0
/*20*/ ,
						NULL ,
						0 ,
						0 ,
						NULL ,
						NULL ,
						0
/*21*/ ,
						NULL ,
						NULL ,
						NULL ,
						NULL ,
						NULL ,
						NULL
/*22*/ ,
						NULL ,
						NULL ,
						NULL ,
						NULL ,
						0 ,
						NULL
/*23*/ ,
						NULL ,
						NULL ,
						NULL ,
						NULL ,
						NULL ,
						NULL
/*24*/ ,
						NULL ,
						NULL ,
						NULL ,
						NULL ,
						NULL ,
						NULL
/*25*/ ,
						NULL ,
						0 ,
						NULL ,
						NULL ,
						NULL ,
						NULL
/*26*/ ,
						NULL ,
						NULL ,
						NULL ,
						NULL ,
						NULL ,
						NULL
/*27*/ ,
						NULL ,
						NULL ,
						NULL ,
						NULL ,
						NULL ,
						0
/*28*/ ,
						0 ,
						NULL ,
						NULL ,
						NULL ,
						NULL ,
						NULL
/*29*/ ,
						NULL ,
						0 ,
						NULL ,
						NULL ,
						NULL ,
						NULL
/*30*/ ,
						NULL ,
						NULL ,
						NULL ,
						NULL ,
						NULL ,
						NULL
/*31*/ ,
						NULL ,
						0 ,
						NULL ,
						0 ,
						NULL ,
						NULL
/*32*/ ,
						NULL ,
						NULL ,
						NULL ,
						NULL ,
						NULL ,
						NULL
/*33*/ ,
						NULL ,
						NULL ,
						NULL ,
						NULL ,
						NULL ,
						NULL
/*34*/ ,
						NULL ,
						NULL ,
						0 ,
						NULL ,
						NULL ,
						NULL
/*35*/ ,
						NULL ,
						NULL ,
						NULL ,
						NULL ,
						NULL ,
						NULL
/*36*/ ,
						NULL ,
						NULL ,
						NULL ,
						NULL ,
						NULL ,
						NULL
/*37*/ ,
						NULL ,
						NULL ,
						NULL ,
						NULL ,
						NULL ,
						NULL
/*38*/ ,
						0 ,
						NULL ,
						NULL ,
						NULL ,
						NULL ,
						NULL
/*39*/ ,
						NULL ,
						NULL ,
						NULL ,
						NULL ,
						NULL ,
						0,
						@Usuario
					)

			/* IDENTIFICADORES DE TRAFICO CONSTRUIDO */
			UPDATE tblbod SET BODBANDERA=1 WHERE bodreferencia=UPPER(@Referencia) AND PREF=@PREF
		END
		ELSE 
		BEGIN
			SET @Error = N'Fallo al asignar referencia favor de verificar!!!';
			RAISERROR (@Error,18,1); 
		END	
	END
	ELSE 
	BEGIN
		SET @Error = N'La referencia ya existe en la base de datos!!!';
		RAISERROR (@Error,18,1); 
	END

	IF @PREF='T3959800' -- VALIDACION PARA EXPORTACION SOLO IMOPORTEX
		UPDATE TRAFICO SET [traImpExp]=0 WHERE TRAREFERENCIA=@Referencia AND PREF=@PREF; 

	IF @PARAM105 = 1 -- VALIDACION PARA EXPORTACION SOLO IMOPORTEX
		UPDATE referencias_enlace set  Asignada = 1
		Where REFERENCIA= @Referencia AND PREF=@PREF and Asignada = 0; 

	SELECT  @Referencia AS spReferencia
	
	RETURN(1);    
END TRY
BEGIN CATCH
		PRINT 'ERROR'
		PRINT 'ERROR_NUMBER: ' + CONVERT(VARCHAR,ERROR_NUMBER())
		PRINT 'ERROR_SEVERITY: ' + CONVERT(VARCHAR,ERROR_SEVERITY())
		PRINT 'ERROR_STATE: ' + CONVERT(VARCHAR,ERROR_STATE())
		PRINT 'ERROR_LINE: ' + CONVERT(VARCHAR,ERROR_LINE())
		PRINT 'ERROR_PROCEDURE: ' + ERROR_PROCEDURE()
		PRINT 'ERROR_MESSAGE: ' + ERROR_MESSAGE()
		
		IF (XACT_STATE()) = -1
			ROLLBACK TRANSACTION

		IF (XACT_STATE()) = 1
			COMMIT TRANSACTION 
		
		SET @Error = 'Error: ' + ERROR_MESSAGE();
		RAISERROR (@Error,18,1); 

		RETURN(0);
					 
END CATCH;	    
END
GO
