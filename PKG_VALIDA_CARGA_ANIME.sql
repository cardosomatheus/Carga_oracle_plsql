--PACKAGE QUE VAI VALIDAR AS ALTERACOES NA CARGA DO ARQUIVO ANIME.CSV
create or replace  PACKAGE PKG_VALIDA_CARGA_ANIME IS
    TYPE TP_DATAS IS RECORD (MAL_ID NUMBER,
                             DT_INICIAL VARCHAR2(100),
                             DT_FINAL VARCHAR2(100));
    TYPE TB_DATAS IS TABLE OF TP_DATAS; 

    PROCEDURE SP_ALTERA_INDEFINIDOS_PARA_NULOS;
    
    -- VALIDAR DATAS
    FUNCTION FNC_VALIDA_DATAS_INICIAIS_FINAIS (PLETRAS NUMBER) RETURN TB_DATAS PIPELINED;
    PROCEDURE SP_DATAS_INICIAIS_FINAIS;
END;



-- CORPO DA PACKAGE
CREATE OR REPLACE PACKAGE BODY PKG_VALIDA_CARGA_ANIME IS
  PROCEDURE SP_ALTERA_INDEFINIDOS_PARA_NULOS AS 
    -- TRATAMENTO DE VALORES NULOS POR COLUNA
    VNULO VARCHAR2(20) := NULL;
    BEGIN
    -- TRATAMENTO DE VALORES NULOS
        UPDATE CARGA_ANIME
        SET "English name" = VNULO
        WHERE "English name" IN ('Unknown', 'NDA', 'NULL');
        
        UPDATE CARGA_ANIME
        SET "Premiered" = 'NULL'
        WHERE "Premiered" IN ('Unknown', 'NDA', 'NULL');
        
        UPDATE CARGA_ANIME
        SET "Episodes" = VNULO
        WHERE "Episodes" IN ('Unknown', 'NDA', 'NULL');
        
        UPDATE CARGA_ANIME
        SET "Type" = VNULO
        WHERE "Type" IN ('Unknown', 'NDA', 'NULL');
        
        UPDATE CARGA_ANIME
        SET "Aired" = VNULO
        WHERE "Aired" IN ('Unknown', 'NDA', 'NULL');
        
        UPDATE CARGA_ANIME
        SET "Name" = VNULO
        WHERE "Name" IN ('Unknown', 'NDA', 'NULL','9','86');
        
        UPDATE CARGA_ANIME
        SET "Score" = VNULO
        WHERE "Score" IN ('Unknown', 'NDA', 'NULL');
        
        UPDATE CARGA_ANIME
        SET "Genres" = VNULO
        WHERE "Genres" IN ('Unknown', 'NDA', 'NULL');
        
        UPDATE CARGA_ANIME
        SET "Licensors" = VNULO
        WHERE "Licensors" IN ('Unknown', 'NDA', 'NULL');
        
        UPDATE CARGA_ANIME
        SET "Studios" = VNULO
        WHERE "Studios" IN ('Unknown', 'NDA', 'NULL');
        
        UPDATE CARGA_ANIME
        SET "Genres" = VNULO
        WHERE "Genres" IN ('Unknown', 'NDA', 'NULL');
        
        UPDATE CARGA_ANIME
        SET "Source" = VNULO
        WHERE "Source" IN ('Unknown', 'NDA', 'NULL');        
        
        UPDATE CARGA_ANIME
        SET "Source" = VNULO
        WHERE "Source" IN ('Unknown', 'NDA', 'NULL');        
        
        UPDATE CARGA_ANIME
        SET "Duration" = VNULO
        WHERE "Duration" IN ('Unknown', 'NDA', 'NULL');  
        
        UPDATE CARGA_ANIME
        SET "Ranked" = VNULO
        WHERE "Ranked" IN ('Unknown', 'NDA', 'NULL');          
        
    COMMIT;
    
    END;
    
    FUNCTION FNC_VALIDA_DATAS_INICIAIS_FINAIS (PLETRAS NUMBER) RETURN TB_DATAS PIPELINED AS
        VREGISTRO PKG_VALIDA_CARGA_ANIME.TP_DATAS;
     -- O LOOP NÃO REALIZADO PELA CONSULTA JÃ? TRAZENDOS A DATA INICIAL E FINAL TRATADA E DEPOÃ?S Ã‰ RETORNADA EM UM TABELA 
     BEGIN
        FOR I IN (SELECT 
                    "MAL_ID",
                    CASE WHEN LENGTH(DATA_FINAL)> PLETRAS THEN
                            TO_CHAR(TO_DATE(DECODE(substr(DATA_FINAL,1,3),
                                                   'Jan', '01'||substr(DATA_FINAL,4),
                                                   'Feb', '02'||substr(DATA_FINAL,4),
                                                   'Mar', '03'||substr(DATA_FINAL,4),
                                                   'Apr', '04'||substr(DATA_FINAL,4),
                                                   'May', '05'||substr(DATA_FINAL,4),
                                                   'Jun', '06'||substr(DATA_FINAL,4),
                                                   'Jul', '07'||substr(DATA_FINAL,4),
                                                   'Aug', '08'||substr(DATA_FINAL,4),
                                                   'Sep', '09'||substr(DATA_FINAL,4),
                                                   'Oct', '10'||substr(DATA_FINAL,4),
                                                   'Nov', '11'||substr(DATA_FINAL,4),
                                                   'Dec', '12'||substr(DATA_FINAL,4)),'MM DD YYYY'),'DD/MM/YYYY') 
                         ELSE NULL END AS DATA_FINAL,
                    CASE WHEN LENGTH(DATA_INICIAL)> PLETRAS THEN
                                            TO_CHAR(TO_DATE(DECODE(substr(DATA_INICIAL,1,3),
                                                   'Jan', '01'||substr(DATA_INICIAL,4),
                                                   'Feb', '02'||substr(DATA_INICIAL,4),
                                                   'Mar', '03'||substr(DATA_INICIAL,4),
                                                   'Apr', '04'||substr(DATA_INICIAL,4),
                                                   'May', '05'||substr(DATA_INICIAL,4),
                                                   'Jun', '06'||substr(DATA_INICIAL,4),
                                                   'Jul', '07'||substr(DATA_INICIAL,4),
                                                   'Aug', '08'||substr(DATA_INICIAL,4),
                                                   'Sep', '09'||substr(DATA_INICIAL,4),
                                                   'Oct', '10'||substr(DATA_INICIAL,4),
                                                   'Nov', '11'||substr(DATA_INICIAL,4),
                                                   'Dec', '12'||substr(DATA_INICIAL,4)),'MM DD YYYY'),'DD/MM/YYYY') 
                         ELSE NULL END AS DATA_INICIAL 
                    
                  FROM (SELECT 
                            "MAL_ID",
                            TRIM(REPLACE(DECODE(INSTR("Aired",'to'),0,"Aired",SUBSTR("Aired",0,INSTR("Aired",'to')-1)),',')) AS DATA_INICIAL,
                            TRIM(REPLACE(DECODE(INSTR("Aired",'to'),0,NULL,SUBSTR("Aired",INSTR("Aired",'to')+2)),',')) AS DATA_FINAL
                         FROM CARGA_ANIME))
        LOOP
            VREGISTRO.DT_INICIAL := I.DATA_INICIAL; 
            VREGISTRO.DT_FINAL := I.DATA_FINAL;
            VREGISTRO.MAL_ID := I."MAL_ID";
            PIPE ROW(VREGISTRO);
             
        END LOOP;
     END; 
     
     PROCEDURE SP_DATAS_INICIAIS_FINAIS AS 
     BEGIN
        FOR I IN (SELECT A.DT_INICIAL,
                         A.DT_FINAL,
                         A.MAL_ID 
                    FROM SYSTEM.PKG_VALIDA_CARGA_ANIME.FNC_VALIDA_DATAS_INICIAIS_FINAIS(9) A 
                  JOIN CARGA_ANIME B ON A.MAL_ID = B."MAL_ID")
        LOOP
            UPDATE CARGA_ANIME A 
             SET A.DATA_INICIAL = I.DT_INICIAL,
                 A.DATA_FINAL   = I.DT_FINAL
            WHERE A."MAL_ID"  = I.MAL_ID;
        END LOOP;
        COMMIT;
     END;
    
END;