-- =============================================
-- AUTHOR     : LEONEL GONZALEZ
-- DATE       :
-- DESCRIPTION:
-- =============================================
USE [Aduana]
IF EXISTS (SELECT NAME FROM SYSOBJECTS WHERE NAME = 'smidashboard_spi_asignaref' AND TYPE = 'P')
	  DROP PROCEDURE smidashboard_spi_asignaref;
GO
CREATE PROCEDURE smidashboard_spi_asignaref
(@pref VARCHAR(10)
,@impexp INT=0)
WITH ENCRYPTION
AS
BEGIN


	DECLARE @Year varchar(4),@Ceros varchar(6),@Referencia varchar(20),@Consecutivo int,@Consecutivo_str varchar(10),@PREFijo varchar(5),@Error VARCHAR(500);

	SET @Year = SUBSTRING(CONVERT(VARCHAR(4),YEAR(GETDATE())),3,2);

	/* Asignación de parametros */
	SET @PREFijo = (
		SELECT
			CASE WHEN @ImpExp = 1 /* 1 ES IMPO */ THEN
					ISNULL(Prefijo,'')
				ELSE /* 0 ES EXPO */
					ISNULL(prefijoexpo,'')
			END
		FROM tblcomp
		WHERE PREF=@PREF);


	SET @Consecutivo = (
		SELECT
			CASE WHEN @ImpExp = 1 /* 1 EX IMPO */ THEN
				BODEGA_ID + 1
			ELSE /* 0 ES EXPO */
				bodegaexpo_id + 1
			END
		FROM CONSECUTIVOS_BOD
		WHERE PREF=@PREF);

		SELECT @Ceros='00000';
		SELECT @Consecutivo_str = RIGHT(@Ceros + CAST(@Consecutivo as varchar),5);
		SELECT @Referencia = @PREFijo + @Year + @Consecutivo_str;
		

		IF @ImpExp = 1 --ES IMPO
			UPDATE CONSECUTIVOS_BOD SET BODEGA_ID=@Consecutivo WHERE PREF=@PREF;
		ELSE --ES EXPO
			UPDATE CONSECUTIVOS_BOD SET bodegaexpo_id=@Consecutivo WHERE PREF=@PREF;

	IF EXISTS(SELECT trareferencia FROM trafico WHERE trareferencia=@Referencia AND PREF=@PREF) 
	OR EXISTS(SELECT bodreferencia FROM tblbod WHERE bodreferencia=@Referencia AND PREF=@PREF)
    OR EXISTS(SELECT facgref FROM tblFactgen WHERE facgref=@Referencia AND PREF=@PREF) 
	OR EXISTS(SELECT referencia FROM tblNotaRevGen WHERE referencia=@Referencia AND PREF=@PREF)
	BEGIN
		SET @Error = N'La referencia ' + @Referencia + ' ya existe en el sistema, favor de revisar los consecutivos!!!';
		RAISERROR (@Error,18,1);
	END
	ELSE
		SELECT @Referencia;


	    
END
GO
GRANT EXEC ON smidashboard_spi_asignaref TO PUBLIC;
GO
