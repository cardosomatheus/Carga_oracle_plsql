-- Adicionando novos campos na tabela de carga_anime
ALTER TABLE CG_ANIMES
ADD (DATA_INICIAL DATE,
     DATA_FINAL DATE);

-- Execultando as procedures e functinos da package
EXEC PKG_VALIDA_CARGA.SP_VALIDA_VALORES_NULO;
EXEC PKG_VALIDA_CARGA.SP_DATAS_INICIAIS_FINAIS;
SELECT * FROM TABLE(PKG_VALIDA_CARGA.FNC_VALIDA_DATAS_INICIAIS_FINAIS);


-- atualizando valores 
UPDATE CG_ANIMES
    SET "Score" = NULL
WHERE "Score" LIKE '%"%';