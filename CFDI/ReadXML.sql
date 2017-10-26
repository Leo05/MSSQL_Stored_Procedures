USE Aduana
DECLARE @XmlCFDI XML
SET @XmlCFDI=CAST('<cfdi:Comprobante xmlns:cfdi="http://www.sat.gob.mx/cfd/3" xmlns:cce="http://www.sat.gob.mx/ComercioExterior" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.sat.gob.mx/cfd/3 http://www.sat.gob.mx/sitio_internet/cfd/3/cfdv32.xsd  http://www.sat.gob.mx/ComercioExterior http://www.sat.gob.mx/sitio_internet/cfd/ComercioExterior/ComercioExterior10.xsd" version="3.2" serie="F" folio="45360" fecha="2017-03-24T09:33:00" sello="TVjWe2/z7pCi0fmLQyFtqyPYso/H8cNGa94yzjGPIvIxkCh5vacEeNz9qY72Nw6l2AhjHlGJhCYgN+nfrBoy05A66MaD5XGP8sSxA8VyzGXTl/+jjo9ZT5k18TEXx5tHkyApDC6PLTGfxBJl7HfK+/MGi4hs1BVb8CCrthfI41o=" formaDePago="PAGO EN UNA SOLA EXHIBICION" noCertificado="00001000000300711192" certificado="MIIEWzCCA0OgAwIBAgIUMDAwMDEwMDAwMDAzMDA3MTExOTIwDQYJKoZIhvcNAQEFBQAwggGKMTgwNgYDVQQDDC9BLkMuIGRlbCBTZXJ2aWNpbyBkZSBBZG1pbmlzdHJhY2nDs24gVHJpYnV0YXJpYTEvMC0GA1UECgwmU2VydmljaW8gZGUgQWRtaW5pc3RyYWNpw7NuIFRyaWJ1dGFyaWExODA2BgNVBAsML0FkbWluaXN0cmFjacOzbiBkZSBTZWd1cmlkYWQgZGUgbGEgSW5mb3JtYWNpw7NuMR8wHQYJKoZIhvcNAQkBFhBhY29kc0BzYXQuZ29iLm14MSYwJAYDVQQJDB1Bdi4gSGlkYWxnbyA3NywgQ29sLiBHdWVycmVybzEOMAwGA1UEEQwFMDYzMDAxCzAJBgNVBAYTAk1YMRkwFwYDVQQIDBBEaXN0cml0byBGZWRlcmFsMRQwEgYDVQQHDAtDdWF1aHTDqW1vYzEVMBMGA1UELRMMU0FUOTcwNzAxTk4zMTUwMwYJKoZIhvcNAQkCDCZSZXNwb25zYWJsZTogQ2xhdWRpYSBDb3ZhcnJ1YmlhcyBPY2hvYTAeFw0xMzA4MjIxNzA2MzZaFw0xNzA4MjIxNzA2MzZaMIGnMRkwFwYDVQQDExBSRUZJQlJBIFNBIERFIENWMRkwFwYDVQQpExBSRUZJQlJBIFNBIERFIENWMRkwFwYDVQQKExBSRUZJQlJBIFNBIERFIENWMSUwIwYDVQQtExxSRUY5NjA4MjhUNzggLyBHQUxBMzkxMTEzUjE2MR4wHAYDVQQFExUgLyBHQUxBMzkxMTEzSEdUUlBEMDYxDTALBgNVBAsTBExFT04wgZ8wDQYJKoZIhvcNAQEBBQADgY0AMIGJAoGBAI9tzJ9Lmkpx5DwBDm3dab+0hm3zNB7sLnN73jQhD9MrNa+0mAvmLWBPdAPa2IYhU4l7841iApxI7UaWTfsqSUJOCEHP2CeAHv9bjCc8kupBP90xag5OUGks3d+6aRuMuJ0b/cRRwqHqZSgf1UzHjGEH6KtUxtFuakrnkbXhib2HAgMBAAGjHTAbMAwGA1UdEwEB/wQCMAAwCwYDVR0PBAQDAgbAMA0GCSqGSIb3DQEBBQUAA4IBAQCTM3BdEPDhBQmU7p+cpwmhTTUnc4wgUUPj1tjGSInp2YieT8r5Ez6kR9gTkeIJN2EwIQL46MwC22AHU6OJiaJLDUR9aspbbsGrSAfiPRsuzi1S9vxXG42+b6UJTr1dysJezuzYmdXpluEoEq+vjhKql+mxqVXW2Q0NsWqxNRq0JNyG32PLC5FvVZt9cOznmYZHzAYNbE1VB+ztOVthBUz1mvmOUM+Uv+GRSB81jRoip7fczsk2jYY7Zf3zj0kSr+hKx4k+yRIO+mmizT0vqE4Yfc8gSPt1vsmomdVRez/wGceSJ0VwLiKI0I5mtSAgzfN50WzBGrzY30lA7IzO342K" condicionesDePago="30 dias neto" subTotal="31837.00" TipoCambio="19.00" Moneda="USD" total="31837.00" tipoDeComprobante="ingreso" metodoDePago="03" LugarExpedicion="CARR. LEON SAN FRANCISCO KM 8.5 , LOMAS DE BUENA VISTA, 36468, San Francisco del Rincón, SAN FRANCISCO DEL RINCON, Guanajuato, México" NumCtaPago="NA..">
  <cfdi:Emisor rfc="REF960828T78" nombre="Refibra, S.A. de C.V.">
    <cfdi:DomicilioFiscal calle="CARR. LEON SAN FRANCISCO KM" noExterior="8.5" colonia="LOMAS DE BUENA VISTA" municipio="031" estado="GUA" pais="MEX" codigoPostal="36468"/>
    <cfdi:RegimenFiscal Regimen="Regimen General de Ley Personas Morales"/>
  </cfdi:Emisor>
  <cfdi:Receptor rfc="XEXX010101000" nombre="MONTELLO HEEL MFG. INC.">
    <cfdi:Domicilio calle="EMERSON AVENUE" noExterior="13" localidad="BROCKTON" estado="MA" pais="USA" codigoPostal="02305"/>
  </cfdi:Receptor>
  <cfdi:Conceptos>
    <cfdi:Concepto cantidad="1000.000" unidad="PIEZA" noIdentificacion="SL55" descripcion="LAMINA SUPERLEFA 5.5 MM" valorUnitario="11.49" importe="11490.00"/>
    <cfdi:Concepto cantidad="400.000" unidad="PIEZA" noIdentificacion="SL50" descripcion="LAMINA SUPERLEFA 5.0 MM" valorUnitario="10.09" importe="4036.00"/>
    <cfdi:Concepto cantidad="250.000" unidad="PIEZA" noIdentificacion="SL45" descripcion="LAMINA SUPERLEFA 4.5 MM" valorUnitario="9.58" importe="2395.00"/>
    <cfdi:Concepto cantidad="400.000" unidad="PIEZA" noIdentificacion="W55" descripcion="LAMINA LEFA W 5.5 MM" valorUnitario="11.49" importe="4596.00"/>
    <cfdi:Concepto cantidad="500.000" unidad="PIEZA" noIdentificacion="W45" descripcion="LAMINA LEFA W 4.5 MM" valorUnitario="9.58" importe="4790.00"/>
    <cfdi:Concepto cantidad="500.000" unidad="PIEZA" noIdentificacion="W40" descripcion="LAMINA LEFA W 4.0 MM" valorUnitario="9.06" importe="4530.00"/>
  </cfdi:Conceptos>
  <cfdi:Impuestos totalImpuestosTrasladados="0.00">
    <cfdi:Traslados>
      <cfdi:Traslado impuesto="IVA" tasa="0.00" importe="0.00"/>
    </cfdi:Traslados>
  </cfdi:Impuestos>
  <cfdi:Complemento>
    <tfd:TimbreFiscalDigital xmlns:tfd="http://www.sat.gob.mx/TimbreFiscalDigital" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.sat.gob.mx/TimbreFiscalDigital http://www.sat.gob.mx/TimbreFiscalDigital/TimbreFiscalDigital.xsd" selloCFD="TVjWe2/z7pCi0fmLQyFtqyPYso/H8cNGa94yzjGPIvIxkCh5vacEeNz9qY72Nw6l2AhjHlGJhCYgN+nfrBoy05A66MaD5XGP8sSxA8VyzGXTl/+jjo9ZT5k18TEXx5tHkyApDC6PLTGfxBJl7HfK+/MGi4hs1BVb8CCrthfI41o=" FechaTimbrado="2017-03-24T09:33:06" UUID="69F1500E-3094-48A9-9661-8E9E19E28CCA" noCertificadoSAT="00001000000404486074" version="1.0" selloSAT="BDSGB05k8GIdVEdvnxjtLz4NSWkkFjGDPAcoz6qLlbf3XPTiR2otX3ull/ycdeNqFhhxS6/yrU53g3/9aipV+UGPmiabu4Po1lIuJs4QhLLzd0uRLtbZtek0i1aq0xp3eAcOyWQv4pBeaHZtt048+Rmhaex7OQ8Eg84tfsLLijFeBHSPCVINZRsU2p8PYtyM/1GLSb8y41AhldxrokUYBj9iV2UGCeh5EStFJ5wI9M8JK+i0ZzgZyP0kbCCcUkUplW1Q3fQulWAWULC3hcudB3RLTnLVS2DHG0EtKO/Y79RAQh6RMCS+HU8iZu/mFKkdarlsTHGL3LIwWHhkUL0FfA=="/>
    <cce:ComercioExterior Version="1.0" TipoOperacion="2" ClaveDePedimento="A1" CertificadoOrigen="0" Incoterm="DAP" Subdivision="0" Observaciones="mercancia en buen estado" TipoCambioUSD="19.000000" TotalUSD="31837.00">
      <cce:Receptor NumRegIdTrib="042262008"/>
      <cce:Mercancias>
        <cce:Mercancia NoIdentificacion="SL55" CantidadAduana="1000.000" UnidadAduana="6" ValorUnitarioAduana="11.49" ValorDolares="11490.00">
        </cce:Mercancia>
        <cce:Mercancia NoIdentificacion="SL50" CantidadAduana="400.000" UnidadAduana="6" ValorUnitarioAduana="10.09" ValorDolares="4036.00">
        </cce:Mercancia>
        <cce:Mercancia NoIdentificacion="SL45" CantidadAduana="250.000" UnidadAduana="6" ValorUnitarioAduana="9.58" ValorDolares="2395.00">
        </cce:Mercancia>
        <cce:Mercancia NoIdentificacion="W55" CantidadAduana="400.000" UnidadAduana="6" ValorUnitarioAduana="11.49" ValorDolares="4596.00">
        </cce:Mercancia>
        <cce:Mercancia NoIdentificacion="W45" CantidadAduana="500.000" UnidadAduana="6" ValorUnitarioAduana="9.58" ValorDolares="4790.00">
        </cce:Mercancia>
        <cce:Mercancia NoIdentificacion="W40" CantidadAduana="500.000" UnidadAduana="6" ValorUnitarioAduana="9.06" ValorDolares="4530.00">
        </cce:Mercancia>
      </cce:Mercancias>
    </cce:ComercioExterior>
  </cfdi:Complemento>
</cfdi:Comprobante>' AS XML)

DECLARE @EMISORRFC VARCHAR(13),@EMISORNOMBRE VARCHAR(150)
SELECT
     @EMISORRFC=T.C.value('@rfc', 'varchar(13)')
    ,@EMISORNOMBRE=T.C.value('@nombre', 'varchar(150)')
from @XmlCFDI.nodes('declare namespace cfdi="http://www.sat.gob.mx/cfd/3"; //cfdi:Comprobante/cfdi:Emisor') T(C)

DECLARE @RECEPTORRFC VARCHAR(13),@RECEPTORNOMBRE VARCHAR(150)
SELECT
     @RECEPTORRFC=T.C.value('@rfc', 'varchar(13)')
    ,@RECEPTORNOMBRE=T.C.value('@nombre', 'varchar(150)')
from @XmlCFDI.nodes('declare namespace cfdi="http://www.sat.gob.mx/cfd/3"; //cfdi:Comprobante/cfdi:Receptor') T(C)

SELECT @RECEPTORNOMBRE
--DECLARE @CONCEPTOS TABLE(
-- id INT IDENTITY(1,1)
--,cantidad FLOAT
--,unidad VARCHAR(10)
--,noIdentificacion VARCHAR(20)
--,descripcion VARCHAR(50)
--,valorUnitario FLOAT	
--,importe FLOAT) 
--INSERT INTO @CONCEPTOS(cantidad,unidad,noIdentificacion,descripcion,valorUnitario,importe)
--SELECT
--      T.C.value('@cantidad', 'float')
--     ,T.C.value('@unidad', 'varchar(10)')
--     ,T.C.value('@noIdentificacion', 'varchar(20)')
--     ,T.C.value('@descripcion', 'varchar(50)')
--     ,T.C.value('@valorUnitario', 'float')
--     ,T.C.value('@importe', 'float')
--from @XmlCFDI.nodes('declare namespace cfdi="http://www.sat.gob.mx/cfd/3"; //cfdi:Comprobante/cfdi:Conceptos/cfdi:Concepto') T(C)

--DECLARE @BKLINE VARCHAR(6)='<br />', @HTMLLOG VARCHAR(MAX)=''
--SET @HTMLLOG += 'VALIDANDO DATOS DE EMISOR'+@BKLINE

--IF EXISTS(SELECT CLIENTE_ID FROM CLIENTES WHERE RFC=@EMISORRFC) BEGIN
--	SET @HTMLLOG += '--EL EMISOR SE ENCUENTRA EN LA BASE DE DATOS COMO: '+(SELECT NOM FROM CLIENTES WHERE RFC=@EMISORRFC)+@BKLINE
--END
--ELSE BEGIN
--	SET @EMISORNOMBRE=REPLACE(@EMISORNOMBRE,' ','.');
--	SET @HTMLLOG += '--NO SE ECONTRARON REGISTROS EN LA BASE DE DATOS'+@BKLINE
--	SET @HTMLLOG += '--POSIBLES COINCIDENCIAS'+@BKLINE
--	SET @HTMLLOG += (SELECT clientes.nom As [data()] FROM clientes
--					 WHERE clientes.nom LIKE '%'+(SELECT LEFT(@EMISORNOMBRE, CHARINDEX('.', REVERSE(@EMISORNOMBRE), 1) - 1))+'%'
--					 FOR XML PATH(''))
--END

--SET @HTMLLOG += 'VALIDANDO DATOS DE RECEPTOR'+@BKLINE
--IF EXISTS(SELECT CLIENTE_ID FROM CLIENTES WHERE RFC=@RECEPTORRFC) BEGIN
--	SET @HTMLLOG += '--EL RECEPTOR SE ENCUENTRA EN LA BASE DE DATOS COMO: '+(SELECT NOM FROM CLIENTES WHERE RFC=@RECEPTORRFC)+@BKLINE
--END
--ELSE BEGIN
--	SET @RECEPTORNOMBRE=REPLACE(@RECEPTORNOMBRE,' ','.');
--	SET @HTMLLOG += '--NO SE ECONTRARON REGISTROS EN LA BASE DE DATOS'+@BKLINE
--	SET @HTMLLOG += '--POSIBLES COINCIDENCIAS'+@BKLINE
--	SET @HTMLLOG += (SELECT procli.pronom As [data()] FROM procli
--					  WHERE procli.pronom LIKE '%'+(SELECT LEFT(@RECEPTORNOMBRE, CHARINDEX('.', REVERSE(@RECEPTORNOMBRE), 1) - 1))+'%'
--					  FOR XML PATH(''))
--END

--DECLARE @i INT=(SELECT COUNT(*) FROM @CONCEPTOS)
--WHILE @i>=0 BEGIN
--	IF EXISTS(SELECT PARTNUM FROM TBLPARTES)

--END


--SELECT @HTMLLOG