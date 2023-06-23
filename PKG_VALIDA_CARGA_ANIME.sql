--PACKAGE QUE VAI VALIDAR AS ALTERACOES NA CARGA DO ARQUIVO ANIME.CSV
create or replace  PACKAGE PKG_VALIDA_CARGA IS
    TYPE TP_DATAS IS RECORD (MAL_ID NUMBER,
                             DT_INICIAL VARCHAR2(100),
                             DT_FINAL VARCHAR2(100));
    TYPE TB_DATAS IS TABLE OF TP_DATAS; 

PROCEDURE SP_VALIDA_VALROES_NULO;

-- VALIDAR DATAS
FUNCTION FNC_VALIDA_DATAS_INICIAIS_FINAIS RETURN TB_DATAS PIPELINED;
PROCEDURE SP_DATAS_INICIAIS_FINAIS;
END;


-- CORPO DA PACKAGE
create or replace NONEDITIONABLE PACKAGE BODY PKG_VALIDA_CARGA IS

    PROCEDURE SP_VALIDA_VALORES_NULO AS 
        -- TRATAMENTO DE VALORES NULOS PARA AS COLUNAS DE TABELAS DE CARGA 'CG_'
    BEGIN    
        FOR I IN (SELECT TABLE_NAME, '"'||COLUMN_NAME||'"' AS COLUMN_NAME FROM ALL_TAB_COLUMNS WHERE TABLE_NAME  LIKE 'CG_%') LOOP
            EXECUTE IMMEDIATE 'UPDATE '|| I.TABLE_NAME ||
                                ' SET '|| I.COLUMN_NAME || '= NULL 
                                WHERE ' || I.COLUMN_NAME ||' IN (''Unknown'')';
        END LOOP;
        COMMIT;
    END;

    
    FUNCTION FNC_VALIDA_DATAS_INICIAIS_FINAIS RETURN TB_DATAS PIPELINED IS
        VREGISTRO PKG_VALIDA_CARGA.TP_DATAS;
        BEGIN
        FOR I IN (SELECT "MAL_ID",
                            CASE WHEN LENGTH(DATA_FINAL)> 9 THEN
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
                            CASE WHEN LENGTH(DATA_INICIAL)> 9 THEN
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
                            FROM SYSTEM.CG_ANIMES))
        LOOP
            VREGISTRO.DT_INICIAL := I.DATA_INICIAL; 
            VREGISTRO.DT_FINAL   := I.DATA_FINAL;
            VREGISTRO.MAL_ID     := I."MAL_ID";
            PIPE ROW(VREGISTRO);
        END LOOP;
        END; 
        
        PROCEDURE SP_DATAS_INICIAIS_FINAIS AS 
    -- Atualiza as datas finais e inicias dos animes
        BEGIN
        FOR I IN (SELECT A.DT_INICIAL,
                            A.DT_FINAL,
                            A.MAL_ID 
                    FROM TABLE(PKG_VALIDA_CARGA.FNC_VALIDA_DATAS_INICIAIS_FINAIS) A 
                    JOIN SYSTEM.CG_ANIMES B ON A.MAL_ID = B."MAL_ID")
        LOOP
            UPDATE SYSTEM.CG_ANIMES A 
                SET A.DATA_INICIAL = I.DT_INICIAL,
                    A.DATA_FINAL   = I.DT_FINAL
                WHERE A."MAL_ID"  = I.MAL_ID;
        END LOOP;
        COMMIT;
        END;
    
END;