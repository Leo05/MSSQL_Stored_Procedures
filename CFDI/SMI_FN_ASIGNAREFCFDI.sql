IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.ROUTINES WHERE ROUTINE_NAME = 'SMI_FN_ASIGNAREFCFDI' AND ROUTINE_TYPE = 'FUNCTION')
BEGIN
	DROP FUNCTION SMI_FN_ASIGNAREFCFDI;
END
GO
CREATE FUNCTION SMI_FN_ASIGNAREFCFDI
(@pref VARCHAR(10)
,@impexp INT=0)
RETURNS VARCHAR(10) 
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
		

	RETURN @Referencia;

END;
GO
GRANT EXEC ON SMI_FN_ASIGNAREFCFDI TO Public;
GO