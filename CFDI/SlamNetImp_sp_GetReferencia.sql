USE Aduana
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE SlamNetImp_sp_GetReferencia
(
	@PREF char(8)='',
	@RefManual varchar(10)='',
	@ImpExp BIT=1,
	@PREFIJOAA varchar(10)='',
	@Clienteid int=0
)
WITH ENCRYPTION
AS
BEGIN
BEGIN TRY

	DECLARE @Year varchar(4), @Ceros varchar(6)
			, @Referencia varchar(20), @Clave int
			, @Consecutivo int, @Consecutivo_str varchar(10)
			, @Numero_str varchar(10), @PREFijo varchar(5)
			, @Error NVARCHAR(500), @OPCION varchar(5)
			, @CONSECUTIVOCTE  NUMERIC(9), @NUMEROCTE  VARCHAR(4)
			, @isccia varchar(3), @snp_59_value bit
			, @snp_58_value bit;
	SET @CONSECUTIVOCTE = 0;

	SET @Year = SUBSTRING(CONVERT(VARCHAR(4),YEAR(GETDATE())),3,2);
	SET @Clave = (SELECT [Clave] FROM [SEGURIDAD] WHERE [PREF] = @PREF);

	/* Asignación de parametros */
	--Compañia - Parametro 0
	SET @isccia = ISNULL((SELECT ISNULL([valordefault],'0') FROM [slamnet_parametros] WHERE [clave] = 0),'0')

	--Parametro 58
	SET @snp_58_value = ISNULL((SELECT ISNULL([valor],0) FROM [slamnet_parametros] WHERE [clave] = 58),0)

	--Parametro 59
	SET @snp_59_value = ISNULL((SELECT ISNULL([valor],0) FROM [slamnet_parametros] WHERE [clave] = 59),0)

	/* Asignación de parametros */

	IF ISNULL(@PREFIJOAA,'') = ''
	BEGIN
		SET @PREFijo = (
			SELECT
				CASE WHEN @snp_59_value = 1 THEN
					CASE WHEN @ImpExp = 1 /* 1 ES IMPO */ THEN
							ISNULL(Prefijo,'')
						ELSE /* 0 ES EXPO */
							ISNULL(prefijoexpo,'')
						END
				ELSE
					ISNULL(Prefijo,'')
				END
			FROM tblcomp
			WHERE PREF=@PREF);
	END
	ELSE
		SET @PREFijo = @PREFIJOAA

	SET @Consecutivo = (
		SELECT
			CASE
				WHEN @snp_59_value = 1 AND (@isccia = '10' AND PREF IN ('T1683160')) THEN
					BODEGA_ID + 1
				WHEN @snp_59_value = 1 THEN
					CASE WHEN @ImpExp = 1 /* 1 EX IMPO */ THEN
						BODEGA_ID + 1
					ELSE /* 0 ES EXPO */
						bodegaexpo_id + 1
					END
				ELSE
					BODEGA_ID + 1
			END
		FROM CONSECUTIVOS_BOD
		WHERE PREF=@PREF);

	IF @RefManual=''
	BEGIN
		IF @Clave=1
		BEGIN
			SELECT @Ceros='00000';
			SELECT @Consecutivo_str = RIGHT(@Ceros + CAST(@Consecutivo as varchar),5);
			SELECT @Referencia = LEFT(@PREFijo,2) + @Consecutivo_str + '/' + @Year;
		END
		ELSE IF @Clave=2
		BEGIN
			SELECT @Ceros='00000';
			SELECT @Consecutivo_str = RIGHT(@Ceros + CAST(@Consecutivo as varchar),5);
			SELECT @Referencia = @PREFijo + @Consecutivo_str + @Year;
		END
		ELSE IF @Clave=3
		BEGIN
			SELECT @Ceros='0000';
			SELECT @Consecutivo_str = RIGHT(@Ceros + CAST(@Consecutivo as varchar),4);
			SELECT @Referencia = @PREFijo + @Consecutivo_str + '/' + @Year;
		END
		ELSE IF @Clave=4
		BEGIN
			SELECT @Ceros='00000';
			SELECT @Consecutivo_str = RIGHT(@Ceros + CAST(@Consecutivo as varchar),5);
			SELECT @Referencia = @PREFijo + @Year + @Consecutivo_str;
		END
		ELSE IF @Clave=5
		BEGIN
			--GRIN - AUTOMATICAMENTE POR MES SE REINICIA EL CONSECUTIVO
			SELECT  @Ceros = '0000'
			SELECT  @Consecutivo_str = RIGHT(@Ceros + CAST(@Consecutivo AS VARCHAR),4)
			IF NOT EXISTS (SELECT TOP 1 bodreferencia FROM tblbod WHERE bodreferencia LIKE CONVERT(VARCHAR(2),@Year) + '-' + Right('0' + CONVERT(VARCHAR(2),MONTH(GETDATE())),2) + '-%' AND PREF = @PREF)
			BEGIN
				SELECT @Consecutivo = 1
				SELECT @Consecutivo_str = RIGHT(@Ceros+ CAST(@Consecutivo AS VARCHAR),4)
			END
			SELECT  @Referencia = CONVERT(VARCHAR(2),@Year) + '-' + Right('0' + CONVERT(VARCHAR(2),MONTH(GETDATE())),2) + '-' + @Consecutivo_str
		END
		ELSE IF @Clave=6
		BEGIN
			SELECT @Ceros='00000';
			SELECT @Consecutivo_str = RIGHT(@Ceros + CAST(@Consecutivo as varchar),5);
			SELECT @Referencia = @PREFijo + @Consecutivo_str + '-' + SUBSTRING(@Year,2,1);
		END
		ELSE IF @Clave=7
		BEGIN
			--Si es Zayro las exportaciones colocara un E al inicio
			IF EXISTS(SELECT pref FROM tblcomp WHERE pref='T3485240' AND @ImpExp=0)
			BEGIN
				SELECT  @Ceros = '000000'
				SELECT  @Consecutivo_str = RIGHT(@Ceros	+ CAST(@Consecutivo AS VARCHAR),6)
				SELECT  @Referencia = 'E' + @PREFijo+ @Consecutivo_str
			END
			ELSE
			BEGIN
				IF EXISTS(SELECT pref FROM tblcomp WHERE pref IN ('T3485240','A3485470','M3485430'))
				BEGIN
					SELECT  @Ceros = '000000'
					SELECT  @Consecutivo_str = RIGHT(@Ceros	+ CAST(@Consecutivo AS VARCHAR),6)
				END
				ELSE
				--Si es OF  las exportaciones colocara un EX al inicio
				IF EXISTS (SELECT pref FROM tblcomp WHERE pref='T3608240')
				BEGIN
					SELECT  @Ceros = '000000'
					SELECT  @Consecutivo_str = RIGHT(@Ceros	+ CAST(@Consecutivo AS VARCHAR),6)
					SELECT  @Referencia =  @PREFijo+ @Consecutivo_str
				END
				ELSE
				BEGIN
					SELECT  @Ceros = '0000000'
					SELECT  @Consecutivo_str = RIGHT(@Ceros	+ CAST(@Consecutivo AS VARCHAR),7)
				END

				SELECT  @Referencia = @PREFijo + @Consecutivo_str
			END
		END
		ELSE IF @Clave=8
		BEGIN
			IF EXISTS(SELECT pref FROM tblcomp WHERE pref='T3485240' AND @ImpExp=0)
			BEGIN
				SELECT  @Ceros = '00000'
				SELECT  @Consecutivo_str = RIGHT(@Ceros + CAST(@Consecutivo AS VARCHAR),5)
				SELECT  @Referencia = 'E' + SUBSTRING(@PREFijo,1, 3) + @Consecutivo_str + '/' + @Year
			END
			ELSE
			BEGIN
				SELECT  @Ceros = '00000'
				SELECT  @Consecutivo_str = RIGHT(@Ceros	+ CAST(@Consecutivo AS VARCHAR),5)
				SELECT  @Referencia = SUBSTRING(@PREFijo,1, 3) + @Consecutivo_str + '/' + @Year
			END
		END
		ELSE IF @Clave=9
		BEGIN
			SELECT @Ceros='000000';
			SELECT @Consecutivo_str = RIGHT(@Ceros + CAST(@Consecutivo as varchar),6);
			SELECT @Referencia = SUBSTRING(@PREFijo,1,2) + @Consecutivo_str + @Year;
		END
		ELSE IF @Clave=10
		BEGIN
			SELECT @Ceros='00000';
			SELECT @Consecutivo_str = RIGHT(@Ceros + CAST(@Consecutivo as varchar),5);
			SELECT @Referencia = SUBSTRING(@PREFijo,1,2) + @Consecutivo_str + '/' + @Year;
		END
		ELSE IF @Clave=11
		BEGIN
			SELECT @Ceros='000000';
			SELECT @Consecutivo_str = RIGHT(@Ceros + CAST(@Consecutivo as varchar),6);
			SELECT @Referencia = SUBSTRING(@PREFijo,1,4) + @Consecutivo_str;
		END
		ELSE IF @Clave=12
		BEGIN
			SELECT @Ceros='00000';
			SELECT @Consecutivo_str = RIGHT(@Ceros + CAST(@Consecutivo as varchar),5);
			SELECT @Referencia = SUBSTRING(@PREFijo,1,3) + SUBSTRING(@Year,2,1) + @Consecutivo_str;
		END
		ELSE IF @Clave=13
		BEGIN
			SELECT @Ceros='0000';
			SELECT @Consecutivo_str = RIGHT(@Ceros + CAST(@Consecutivo as varchar),4);
			SELECT @Referencia = @PREFijo + @Consecutivo_str + '-' + @Year;
		END
		ELSE IF @Clave=14
		BEGIN
			IF @ImpExp = 0
			BEGIN
				SELECT @Ceros='00000';
				SELECT @Consecutivo_str = RIGHT(@Ceros + CAST(@Consecutivo as varchar),5);
				SELECT @Referencia = SUBSTRING(@PREFijo,1,3) + 'E' + RIGHT(@Year,1) + @Consecutivo_str

			END
			ELSE
			BEGIN
				SELECT @Ceros='00000';
				SELECT @Consecutivo_str = RIGHT(@Ceros + CAST(@Consecutivo as varchar),5);
				SELECT @Referencia = SUBSTRING(@PREFijo,1,3) + 'I' + RIGHT(@Year,1) + @Consecutivo_str
			END
		END
		ELSE IF @Clave=15
		BEGIN
			SELECT @Ceros='0000';
			SELECT @Consecutivo_str = RIGHT(@Ceros + CAST(@Consecutivo as varchar),4);
			SELECT @Referencia = @PREFijo + RIGHT(@Year,1) + @Consecutivo_str;
		END
		ELSE IF @Clave=16
		BEGIN
			--GRIN - AUTOMATICAMENTE POR MES SE REINICIA EL CONSECUTIVO
			SELECT  @Ceros = '0000'
			SELECT  @Consecutivo_str = RIGHT(@Ceros + CAST(@Consecutivo AS VARCHAR),4)

			SELECT  @Referencia = @PREFijo+CONVERT(VARCHAR(2),@Year) +  Right('0' + CONVERT(VARCHAR(2),MONTH(GETDATE())),2) + @Consecutivo_str
		END
		ELSE IF @Clave=17
		BEGIN
			SELECT @Ceros='0000';
			SELECT @Consecutivo_str = RIGHT(@Ceros + CAST(@Consecutivo as varchar),4);
			SELECT @Referencia = @PREFijo + @Year + @Consecutivo_str;
		END
		ELSE IF @Clave=18
		BEGIN
				SET  @CONSECUTIVOCTE= (SELECT (ISNULL(CONSECUTIVO,0)+1) FROM CLIENTES WHERE CLIENTE_ID=@Clienteid)
				SET  @NUMEROCTE= (SELECT ISNULL(NUMERO,'') FROM CLIENTES WHERE CLIENTE_ID=@Clienteid)

				SELECT @Ceros='0000';
				SELECT @Consecutivo_str = RIGHT(@Ceros + CAST(@CONSECUTIVOCTE as varchar),4);
				SELECT @Numero_str=  RIGHT(@Ceros + CAST(@NUMEROCTE as varchar),4);
				SELECT @Referencia = SUBSTRING(@PREFijo,1,2) + @Numero_str + @Consecutivo_str
		END
		ELSE IF @Clave=20
		BEGIN
				SELECT @Ceros='000000';
				SELECT @Consecutivo_str = RIGHT(@Ceros + CAST(@Consecutivo as varchar),6);
				SELECT @Referencia = SUBSTRING(@PREFijo,1,2) + @Year + @Consecutivo_str;
		END
		ELSE IF @Clave=19
			BEGIN
				IF NOT EXISTS (select * from CONSECUTIVO_REFCLIENTES WHERE PREF=@PREF AND cliente_id=@Clienteid)
				BEGIN
					INSERT INTO CONSECUTIVO_REFCLIENTES(PREF,cliente_id,consecutivo_impo,consecutivo_expo)
					VALUES (@PREF,@Clienteid,0,0)
				END

				SET  @CONSECUTIVOCTE= (
				CASE
					WHEN @ImpExp = 1 THEN (SELECT (ISNULL(consecutivo_impo,0)+1) FROM CONSECUTIVO_REFCLIENTES WHERE cliente_id=@Clienteid AND PREF=@PREF)
					ELSE  (SELECT (ISNULL(consecutivo_expo,0)+1) FROM CONSECUTIVO_REFCLIENTES WHERE cliente_id=@Clienteid AND PREF=@PREF)
				END)

				SET @NUMEROCTE= (SELECT ISNULL(NUMERO,'') FROM CLIENTES WHERE CLIENTE_ID=@Clienteid)
				SET @PREFijo = (
				CASE
					WHEN @ImpExp = 1 THEN (SELECT prefijo FROM tblcomp WHERE pref=@PREF)
					ELSE (SELECT prefijoexpo FROM tblcomp WHERE pref=@PREF)
				END)

				SELECT @Ceros='0000';
				SELECT @Consecutivo_str = RIGHT(@Ceros + CAST(@CONSECUTIVOCTE as varchar),4);
				SELECT @Numero_str=  RIGHT(@Ceros + CAST(@NUMEROCTE as varchar),4);
				SELECT @Referencia = SUBSTRING(@PREFijo,1,2) + @Numero_str + @Consecutivo_str
		END
		ELSE IF @Clave=21
		BEGIN
			SELECT @Ceros='00000';
			SELECT @Consecutivo_str = RIGHT(@Ceros + CAST(@Consecutivo as varchar),5);
			SELECT @Referencia = @PREFijo + @Year + '-'  + @Consecutivo_str;
		END
		ELSE IF @Clave=22
		BEGIN
			SELECT @Ceros='0000';
			SELECT @Consecutivo_str = RIGHT(@Ceros + CAST(@Consecutivo as varchar),4);
			SELECT @Referencia =  @Year + '-'  + @Consecutivo_str + @PREFijo;
		END
		ELSE IF @Clave=23
		BEGIN
			SELECT @Ceros='00000';
			SELECT @Consecutivo_str = RIGHT(@Ceros + CAST(@Consecutivo as varchar),5);
			SELECT @Referencia = LEFT(@PREFijo,3) + RIGHT(@Year,1) + @Consecutivo_str
		END
		ELSE IF @Clave=24
		BEGIN
			SELECT @Ceros='00000';
			SELECT @Consecutivo_str = RIGHT(@Ceros + CAST(@Consecutivo as varchar),5);
			SELECT @Referencia = @Year + '-' +  @Consecutivo_str + LEFT(@PREFijo,2)
		END
		ELSE IF @Clave=25
		BEGIN
			SELECT @Ceros='00000';
			SELECT @Consecutivo_str = RIGHT(@Ceros + CAST(@Consecutivo as varchar),5);
			SELECT @Referencia = @PREFijo + @Consecutivo_str + '-' + @Year
		END
		ELSE IF @Clave=26
		BEGIN
			SELECT @Ceros='000000';
			SELECT @Consecutivo_str = RIGHT(@Ceros + CAST(@Consecutivo as varchar),6);
			IF @ImpExp = 0
			BEGIN
				SELECT @Referencia = @PREFijo + SUBSTRING(@Year,2,1) + @Consecutivo_str + 'E'
			END
			ELSE
			BEGIN
				SELECT @Referencia = @PREFijo + SUBSTRING(@Year,2,1) + @Consecutivo_str 
			END
		END
		ELSE IF @Clave=27
		BEGIN
			SELECT @Ceros = '0000';
			SELECT @Consecutivo_str = RIGHT(@Ceros + CAST(@Consecutivo as varchar),4);
			-- Año || Oficina || Impo / Expo || Consecutivo || Subdivisión
			--  99 ||    2    ||      1      ||     9999    ||     00     
			IF @ImpExp = 0
			BEGIN
				SELECT @Referencia = @Year + @PREFijo + '2' + @Consecutivo_str + '00'
			END
			ELSE
			BEGIN
				SELECT @Referencia = @Year + @PREFijo + '1' + @Consecutivo_str + '00'
			END
		END
		ELSE IF @Clave = 28
		BEGIN
			SELECT @Ceros='0000';
			SELECT @Consecutivo_str = RIGHT(@Ceros + CAST(@Consecutivo as varchar),4);
			SELECT @Referencia = @PREFijo + SUBSTRING(@Year,2,1) + @Consecutivo_str;
		END
		ELSE IF @Clave = 29
		BEGIN
			SELECT @Ceros='0000';
			SELECT @Consecutivo_str = RIGHT(@Ceros + CAST(@Consecutivo as varchar),4);
			SELECT @Referencia = @PREFijo + '-' + @Consecutivo_str + '/' + @Year;
		END
		ELSE
			BEGIN
			SELECT @Ceros='00000';
			SELECT @Consecutivo_str = RIGHT(@Ceros + CAST(@Consecutivo as varchar),5);
			SELECT @Referencia = @PREFijo + @Consecutivo_str + '/' + @Year;
		END

		/* Actializar consecutivos */
		IF @Clave=19
		BEGIN
			IF EXISTS (select * from CONSECUTIVO_REFCLIENTES WHERE PREF=@PREF AND cliente_id=@Clienteid)
			BEGIN
				DECLARE @consecutivorefcte int;
				IF @ImpExp = 1
				BEGIN
					SET @consecutivorefcte = (select (consecutivo_impo) + 1 from CONSECUTIVO_REFCLIENTES WHERE PREF=@PREF AND cliente_id=@Clienteid)
					UPDATE  CONSECUTIVO_REFCLIENTES set consecutivo_impo=@consecutivorefcte where cliente_id=@Clienteid AND PREF=@PREF
				END
				ELSE
				BEGIN
					SET @consecutivorefcte = (select (consecutivo_expo) + 1 from CONSECUTIVO_REFCLIENTES WHERE PREF=@PREF AND cliente_id=@Clienteid )
					UPDATE  CONSECUTIVO_REFCLIENTES set consecutivo_expo=@consecutivorefcte where cliente_id=@Clienteid AND PREF=@PREF
				END
			END
		END
		ELSE IF @snp_59_value = 1 AND (@isccia = '10' AND @PREF IN ('T1683160'))
		BEGIN
			UPDATE CONSECUTIVOS_BOD SET BODEGA_ID=@Consecutivo WHERE PREF=@PREF;
		END
		ELSE IF @snp_59_value = 1 --EXPO EN LA MISMA CIA
		BEGIN
			IF @ImpExp = 1 --ES IMPO
				UPDATE CONSECUTIVOS_BOD SET BODEGA_ID=@Consecutivo WHERE PREF=@PREF;
			ELSE --ES EXPO
				UPDATE CONSECUTIVOS_BOD SET bodegaexpo_id=@Consecutivo WHERE PREF=@PREF;
		END
		ELSE
		BEGIN
			UPDATE CONSECUTIVOS_BOD SET BODEGA_ID=@Consecutivo WHERE PREF=@PREF;
		END

		IF @Clave=18
		BEGIN
			UPDATE CLIENTES SET CONSECUTIVO=@CONSECUTIVOCTE WHERE CLIENTE_ID=@CLIENTEID;
		END
		/* Actializar consecutivos */
	END
	ELSE
	BEGIN
			SELECT @Referencia=@RefManual;
	END

	IF EXISTS(SELECT trareferencia FROM trafico WHERE trareferencia=@Referencia AND PREF=@PREF) OR EXISTS(SELECT bodreferencia FROM tblbod WHERE bodreferencia=@Referencia AND PREF=@PREF)
     OR EXISTS(SELECT facgref FROM tblFactgen WHERE facgref=@Referencia AND PREF=@PREF) OR EXISTS(SELECT referencia FROM tblNotaRevGen WHERE referencia=@Referencia AND PREF=@PREF)
	BEGIN
		IF @snp_58_value = 1
		BEGIN
			SET @Error = N'La referencia ' + @Referencia + ' ya existe en el sistema, favor de revisar!!!';
		END
		ELSE
		BEGIN
			SET @Error = N'La referencia ' + @Referencia + ' ya existe en el sistema, favor de revisar los consecutivos!!!';
		END

		RAISERROR (@Error,18,1);
	END
	ELSE
		SELECT @Referencia;

	--COMMIT TRANSACTION
END TRY
BEGIN CATCH
		PRINT 'ERROR'
		PRINT 'ERROR_NUMBER: ' + CONVERT(VARCHAR,ERROR_NUMBER())
		PRINT 'ERROR_SEVERITY: ' + CONVERT(VARCHAR,ERROR_SEVERITY())
		PRINT 'ERROR_STATE: ' + CONVERT(VARCHAR,ERROR_STATE())
		PRINT 'ERROR_LINE: ' + CONVERT(VARCHAR,ERROR_LINE())
		PRINT 'ERROR_PROCEDURE: ' + ERROR_PROCEDURE()
		PRINT 'ERROR_MESSAGE: ' + ERROR_MESSAGE()

		SET @Error = ERROR_MESSAGE();
		RAISERROR (@Error,18,1);
END CATCH
END
GO
