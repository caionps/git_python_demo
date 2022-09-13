create or replace PACKAGE BODY    pk_fat_mc_clc is
--
function f_busca_ultimas_disciplinas(p_matricula in number) return ca.pk_fat_mc_plt.ar_mc_disciplina as
  cursor c_ultimas_disciplinas is
    SELECT d.CD_DISCIPLINA, d.CD_TURMA, d.CD_CURSO , d.CD_HABILITACAO , d.NR_CREDITOS_TEORICOS , d.NR_CREDITOS_PRATICOS ,
            d.CD_DISCIPLINA_EQUIVALENTE, d.NR_CARGA_HORARIA, d.NR_CARGA_HORARIA_SEM_ONUS, 
            d.CD_DOMINIO_SITUACAO_DISCIPLINA, d.CD_FAIXA_SITUACAO_DISCIPLINA, d.CD_DOMINIO_TIPO_COBRANCA , d.CD_FAIXA_TIPO_COBRANCA,
            d.ID_GRUPO_DISCIPLINA, d.CD_FAIXA_TIPO_CALCULO_HAB_DISCIPLINA,
            d.TP_INDICE_HAB_DISCIPLINA, d.VL_INDICE_HAB_DISCIPLINA, d.VL_HORA_HAB_DISCIPLINA, d.CD_OCORRENCIA_REGRA
      FROM ca.FAT_MC_ALUNO a INNER JOIN ca.FAT_MC_DISCIPLINA d ON a.ID_MC_ALUNO = d.ID_MC_ALUNO
     WHERE a.FG_MC_ALUNO = 'S'
       AND a.NR_MATRICULA = p_matricula;
  wrec_disciplina c_ultimas_disciplinas%rowtype;
  v_disciplinas ca.pk_fat_mc_plt.ar_mc_disciplina;
  windex number :=0;
begin
    open c_ultimas_disciplinas;
    fetch c_ultimas_disciplinas into wrec_disciplina;
    while c_ultimas_disciplinas%found loop
        windex := windex +1;
        v_disciplinas(windex).cd_disciplina                  := wrec_disciplina.cd_disciplina;
        v_disciplinas(windex).cd_turma                       := wrec_disciplina.cd_turma;
        v_disciplinas(windex).cd_curso                       := wrec_disciplina.cd_curso;
        v_disciplinas(windex).cd_habilitacao                 := wrec_disciplina.cd_habilitacao;
        v_disciplinas(windex).nr_creditos_teoricos           := wrec_disciplina.nr_creditos_teoricos;
        v_disciplinas(windex).nr_creditos_praticos           := wrec_disciplina.nr_creditos_praticos;
        v_disciplinas(windex).cd_disciplina_equivalente      := wrec_disciplina.cd_disciplina_equivalente;
        v_disciplinas(windex).nr_carga_horaria               := wrec_disciplina.nr_carga_horaria;
        v_disciplinas(windex).nr_carga_horaria_sem_onus      := wrec_disciplina.nr_carga_horaria_sem_onus;
        v_disciplinas(windex).cd_dominio_situacao_disciplina := wrec_disciplina.cd_dominio_situacao_disciplina;
        v_disciplinas(windex).cd_faixa_situacao_disciplina   := wrec_disciplina.cd_faixa_situacao_disciplina;
        v_disciplinas(windex).cd_dominio_tipo_cobranca       := wrec_disciplina.cd_dominio_tipo_cobranca;
        v_disciplinas(windex).cd_faixa_tipo_cobranca         := wrec_disciplina.cd_faixa_tipo_cobranca;        
        v_disciplinas(windex).id_grupo_disciplina            := wrec_disciplina.id_grupo_disciplina;
        v_disciplinas(windex).CD_FAIXA_TIPO_CALCULO_HAB_DISCIPLINA := wrec_disciplina.CD_FAIXA_TIPO_CALCULO_HAB_DISCIPLINA;
        v_disciplinas(windex).TP_INDICE_HAB_DISCIPLINA       := wrec_disciplina.TP_INDICE_HAB_DISCIPLINA;
        v_disciplinas(windex).VL_INDICE_HAB_DISCIPLINA       := wrec_disciplina.VL_INDICE_HAB_DISCIPLINA;
        v_disciplinas(windex).VL_HORA_HAB_DISCIPLINA         := wrec_disciplina.VL_HORA_HAB_DISCIPLINA;
        v_disciplinas(windex).CD_OCORRENCIA_REGRA            := wrec_disciplina.CD_OCORRENCIA_REGRA;
        
        fetch c_ultimas_disciplinas into wrec_disciplina;
    end loop;
    close c_ultimas_disciplinas;
    return v_disciplinas;
end f_busca_ultimas_disciplinas;
-- 
-- !!* Aqui - 
--
-- -----------------------------------------------------------------------------
/*
PROCEDURE: p_memoria_calculo_gr
DESENVOLVEDOR: Helane, Haroldo, Lucas e José Leitão 
OBJETIVO: Gerar memória de cálculo da graduação
PARÂMETROS:
1 - p_tp_operacao  
    V - Validar
    S - Simular
    P - (Re)Calcular/Persitir 
2 - p_fg_exibir
    S-Sim   N-Não
3 - p_rec_aluno
4 - p_array_disciplina
5 - p_array_modalidade_regra
6 - p_array_titulo
7 - p_fg_retorno
    Sucesso do procesamento
    S-Sim   N-Não
8 - p_ds_retorno
9 - p_dt_processamento
    Data de referência para processamento - identifica a competência

*** Incluir parâmetro para efetuar simulações com modalidades não persistidas
*/
-- -----------------------------------------------------------------------------
procedure p_memoria_calculo_gr
( p_tp_operacao             in     varchar2  
, p_fg_exibir               in     varchar2 default 'N'
, p_rec_mc_aluno            in out nocopy   ca.pk_fat_mc_plt.rec_mc_aluno 
, p_vt_mc_disciplina        in out nocopy   ca.pk_fat_mc_plt.ar_mc_disciplina 
, p_vt_regra_academica      in              ca.pk_fat_mc_plt.ar_mc_regra_academica 
, p_vt_titulo_gerado        out    nocopy   ca.pk_fat_mc_plt.ar_mc_titulo   
, p_modalidades             in              CA.PK_FAT_MC_PLT.vt_financeiro_modalidade
, p_fg_retorno              out    varchar2
, p_ds_retorno              out    clob
, p_dt_processamento        in     date default sysdate ) is
--                              
cursor cr_modalidade( p_id_modalidade      in ca.fat_modalidade.id_modalidade%type ) is 
select mt.nm_modalidade_tipo
  from ca.fat_modalidade_tipo mt
     , ca.fat_modalidade m
 where m.id_modalidade        =     p_id_modalidade
   and m.fg_ativo             =     'S'
   and mt.id_modalidade_tipo  =     m.id_modalidade_tipo 
   and mt.fg_ativo            =     'S';
--
l_rec_financeiro                 ca.pk_fat_mc_plt.rec_financeiro;
l_vt_mc_disciplina_modalidade    ca.pk_fat_mc_plt.ar_mc_disciplina_modalidade;  
l_vt_titulos_aux                 ca.pk_fat_mc_plt.vt_titulo_aux;
l_vt_titulos_gerados_aux         ca.pk_fat_mc_plt.vt_titulo_aux;
l_vt_titulos_preservados_aux     ca.pk_fat_mc_plt.vt_titulo_aux;
l_vt_titulos_modalidade_aux      ca.pk_fat_mc_plt.vt_titulo_modalidade;
l_vt_financeiro_modalidade_aux   ca.pk_fat_mc_plt.vt_fin_modalidade_aux; 
l_vt_modalidade_competencia_aux  ca.pk_fat_mc_plt.vt_modalidade_competencia; 
l_vt_mensalidade_pg              ca.pk_fat_mc_plt.ar_mensalidade_pg;      
--           
l_ind_ret                        number(4) := 0;
l_qt_titulos_por_competencia_modalidade     number(2); 
l_dt_processamento               date; 
--
l_rec_fat_mc_log                 ca.fat_mc_log%rowtype;
l_dt_hr_inicio                   timestamp := localtimestamp; 
l_fg_retorno                     varchar2(1);
l_ds_retorno                     varchar2(4000);
--
begin
--
if p_dt_processamento is null then
   l_dt_processamento := sysdate; 
else
   l_dt_processamento := p_dt_processamento; 
end if;
--
-- !!* Aqui - Qual a finalidade ?
delete ca.fat_mc_log1
where nr_matricula = p_rec_mc_aluno.nr_matricula;
commit; 
--   
p_rec_mc_aluno.cd_estabelecimento :=  nvl( p_rec_mc_aluno.cd_estabelecimento, 0);
p_rec_mc_aluno.cd_est_operador    :=  nvl( p_rec_mc_aluno.cd_est_operador, 999);
p_rec_mc_aluno.nr_mat_operador    :=  nvl( p_rec_mc_aluno.nr_mat_operador, 9999999); 
--
-- !!* Aqui - Obter informação cadastrada em ca.fat_nome_parametro 
-- processamento só deverá ser iniciado para aluno com dados de cadastro válidos
if p_rec_mc_aluno.id_pessoa_aluno is null then
   p_rec_mc_aluno.id_pessoa_aluno := ca.pk_pessoa.f_consulta_pessoa( lpad(p_rec_mc_aluno.cd_estabelecimento,3,'0') || 
                                                                     lpad(p_rec_mc_aluno.nr_matricula,7,'0'),'1',1); 
end if;
--
-- varificar se os dados do período acadêmico foram enviados
-- 
if p_rec_mc_aluno.nr_matricula is null or
   p_rec_mc_aluno.cd_periodo is null or
   p_rec_mc_aluno.tp_arquivo is null or
   p_rec_mc_aluno.tp_periodo is null or
   p_rec_mc_aluno.cd_curso is null or
   p_rec_mc_aluno.cd_habilitacao is null then
--
   dbms_output.put_line ('<< Faltam parâmetros para processamento >>');
-- 
   raise ex_erro_memoria_calculo;
--
else
--   
   p_complementar_dados ( p_rec_mc_aluno );
-- valiar se os campos foram populados
--
end if;
--
if p_tp_operacao in ('V','S','P') then --teste
-- V - Validação das críticas necessárias para geração da MC
-- ======================================================================
   -- Obter ID_FINANCEIRO  
   -- dbms_output.put_line ('Antes de p_popular_financeiro_vetor_mc_aluno ');

   p_popular_financeiro_vetor_mc_aluno( p_rec_mc_aluno 
                                      , p_fg_retorno     
                                      , p_ds_retorno );

-- goto SAIDA;
--
   -- dbms_output.put_line ('Depois de p_popular_financeiro_vetor_mc_aluno ');
--      
   if f_modalidades_homologadas( p_rec_mc_aluno.id_nome_parametro     
                               , p_rec_mc_aluno.id_academico 
                               , p_rec_mc_aluno.tp_arquivo     ) = 'N' then
      p_ds_retorno   := 'Grupo de modalidades associadas ao aluno/(GR ou PG ) não foi homologada.' ; 
         -- !!* Aqui -  - retirar comentario abaixo
         --raise ex_erro_memoria_calculo;
   end if;
--                                             
   l_rec_financeiro.pc_fator_limite := 1 ;
      -- Monstar array
      -- o record 'l_rec_financeiro' não é utilizado apos a chamada 
      -- dessa procedure. Não tem sentido chamar essa procedure quando
      -- a operacao for 'V'-Verificacao
      -- p_array_financeiro_modalidade( p_rec_mc_aluno 
      --                              , p_vt_regra_academica 
      --                              , l_rec_financeiro ); 
   p_processar( p_rec_mc_aluno                 
              , p_vt_mc_disciplina           
              , l_vt_mc_disciplina_modalidade 
              , p_dt_processamento
              , p_fg_exibir            
              , p_fg_retorno                 
              , p_ds_retorno  );
--
-- dbms_output.put_line ('p_rec_mc_aluno.un_financeiro: '||p_rec_mc_aluno.un_financeiro || ' / '||' p_rec_mc_aluno.vl_financeiro: '|| p_rec_mc_aluno.vl_financeiro );

--
   if p_fg_retorno = 'N'  then
      --dbms_output.put_line( 'p_processar erro:' || p_ds_retorno );
      raise ex_erro_memoria_calculo;
   end if;  
--      
   p_fg_retorno :=  'S';
   p_ds_retorno :=  'Validação ok.'  ;
--                              
   if p_tp_operacao in ( 'S', 'P' ) then
   -- S - Simulação da MC
   -- P - Persistência da MC
   -- ======================================================================
   --
   
      l_dt_hr_inicio         := localtimestamp;

      -- desativar MC anteriores
      -- Verifica se o retorno de Validação MC foi realizado
      -- Os campos ID_FINANCEIRO e ID_ACADEMICOS estão populados
      if  p_rec_mc_aluno.id_financeiro      is null
      or  p_rec_mc_aluno.id_academico       is null then
          p_ds_retorno                      :=  'Operação requer a execução da validaçao da Memória de Cálculo.';
          raise ex_erro_memoria_calculo; 
      end if;
  
      dbms_output.put_line ('antes l_rec_financeiro.vl_financeiro: '|| l_rec_financeiro.vl_financeiro );
      dbms_output.put_line ('antes l_rec_financeiro.titulo.count: '|| l_rec_financeiro.titulo.count() );
      p_array_financeiro_modalidade( p_rec_mc_aluno 
                                   , p_vt_regra_academica 
                                   , l_rec_financeiro ); 
 dbms_output.put_line ('depois l_rec_financeiro.vl_financeiro: '|| l_rec_financeiro.vl_financeiro );
 dbms_output.put_line ('depois l_rec_financeiro.titulo.count: '|| l_rec_financeiro.titulo.count() );
 
      if p_modalidades.count > 0 then
        l_rec_financeiro.modalidade := p_modalidades;
      end if;
        
      -- Cálculo da distribuição dos títulos a receber
/*
      p_calculo( p_rec_mc_aluno       
               , p_vt_mc_disciplina 
               , p_vt_regra_academica
               , l_vt_mc_disciplina_modalidade
               , p_fg_exibir      
               , l_rec_financeiro
               , l_vt_financeiro_modalidade_aux    -- Sera populado em 'p_calculo'
               , l_vt_titulos_aux
               , l_vt_titulos_gerados_aux
               , l_vt_titulos_preservados_aux
               , l_vt_titulos_modalidade_aux
               , l_vt_modalidade_competencia_aux
               , l_vt_mensalidade_pg  -- null
               , l_qt_titulos_por_competencia_modalidade 
               , l_dt_processamento
               , p_fg_retorno        
               , p_ds_retorno   
               );
*/

	  dbms_output.put_line ('Titulos : '|| l_vt_titulos_aux.count() || '; Titulos gerados: '||l_vt_titulos_gerados_aux.count()||'; Titulos preservados: '|| l_vt_titulos_preservados_aux.count());
      p_calculo( p_rec_mc_aluno                  => p_rec_mc_aluno
               , p_vt_mc_disciplina              => p_vt_mc_disciplina
               , p_vt_mc_disciplina_modalidade   => l_vt_mc_disciplina_modalidade
               , p_rec_financeiro                => l_rec_financeiro
               , p_vt_financeiro_modalidade_aux  => l_vt_financeiro_modalidade_aux
               , p_vt_titulos_aux                => l_vt_titulos_aux
               , p_vt_titulos_gerados_aux        => l_vt_titulos_gerados_aux
               , p_vt_titulos_preservados_aux    => l_vt_titulos_preservados_aux
               , p_vt_titulos_modalidade_aux     => l_vt_titulos_modalidade_aux
               , p_vt_modalidade_competencia_aux => l_vt_modalidade_competencia_aux
               , p_qt_titulos_por_competencia_modalidade => l_qt_titulos_por_competencia_modalidade
               , p_vt_mensalidade_pg             => l_vt_mensalidade_pg
               , p_vt_regra_academica            => p_vt_regra_academica
               , p_tp_operacao                   => p_tp_operacao
               , p_fg_exibir                     => p_fg_exibir
               , p_fg_titulo_oferta              => 'N'
               , p_dt_processamento              => l_dt_processamento
               , p_fg_retorno                    => p_fg_retorno
               , p_ds_retorno                    => p_ds_retorno
               );
--                   
      dbms_output.put_line ('Titulos após o calculo');
	  dbms_output.put_line ('Titulos : '|| l_vt_titulos_aux.count() || '; Titulos gerados: '||l_vt_titulos_gerados_aux.count()||'; Titulos preservados: '|| l_vt_titulos_preservados_aux.count());              
      if p_fg_retorno                         =   'N'  then
         raise ex_erro_memoria_calculo;
      end if;  
--       
-- Persistir memória de cálculo e titulos
-- -------------------------------------------------------------------------
--     
      if p_tp_operacao = 'P' then
         p_mc_persistir_tabela_gr( p_tp_operacao
                                 , p_rec_mc_aluno
                                 , p_vt_mc_disciplina  
                             --    , p_vt_regra_academica
                                 , l_vt_mc_disciplina_modalidade
                                 , l_rec_financeiro
                                 , l_vt_titulos_aux
                                 , l_vt_titulos_modalidade_aux
                                 , l_vt_modalidade_competencia_aux 
                                 , l_qt_titulos_por_competencia_modalidade
                                 , p_fg_exibir
                                 , 'N' -- p_fg_titulo_oferta
                                 , l_dt_processamento
                                 , p_fg_retorno
                                 , p_ds_retorno ) ;
--
         if p_fg_retorno                         =   'N'  then
            raise ex_erro_memoria_calculo;
         end if;
      else 
        p_atualiza_titulos(l_rec_financeiro);
      end if;  
     
      -- Popular o array de titulo a ser retornado na chamanda da memória de cáculo
      p_vt_titulo_gerado.delete;
      for tit in ( select * 
                   from   table(l_vt_titulos_aux) 
                   order by nr_competencia
                          , id_pessoa_cobranca  ) loop
          l_ind_ret                                            :=  l_ind_ret + 1; 
          
          open cr_modalidade( tit.id_modalidade  );
          fetch cr_modalidade into p_vt_titulo_gerado(l_ind_ret).nm_modalidade_cobranca;
          close cr_modalidade ;
          
-- !!* Aqui 
--        p_vt_titulo_gerado(l_ind_ret).dt_vencimento              :=  nvl( tit.dt_vencimento, add_months( sysdate, l_ind_ret - 1 ) );   --tit.dt_vencimento;  
          p_vt_titulo_gerado(l_ind_ret).dt_vencimento              :=  nvl( tit.dt_vencimento, add_months( l_dt_processamento, l_ind_ret - 1 ) );   --tit.dt_vencimento;  
          p_vt_titulo_gerado(l_ind_ret).vl_titulo                  :=  tit.vl_titulo;        
          p_vt_titulo_gerado(l_ind_ret).vl_desconto_incondicional  :=  tit.vl_desconto_incondicional;  
          p_vt_titulo_gerado(l_ind_ret).vl_bolsa                   :=  tit.vl_bolsa; 
          p_vt_titulo_gerado(l_ind_ret).vl_titulo_liquido          :=  tit.vl_titulo 
                                                                   -   abs( tit.vl_desconto_incondicional )    
                                                                   -   abs( tit.vl_bolsa );   
          p_vt_titulo_gerado(l_ind_ret).vl_desconto_condicional    :=  tit.vl_desconto_condicional;
          p_vt_titulo_gerado(l_ind_ret).vl_apresentacao            :=  p_vt_titulo_gerado(l_ind_ret).vl_titulo_liquido
                                                                   -   abs( tit.vl_desconto_condicional );
      end loop;  
--   
      --------------------------- 
      if p_fg_retorno                       =   'F' then 
      -- Finalizar processamento sem erros
         p_fg_retorno                      :=  'S';
      else
         p_fg_retorno                      :=  'S';
          
         if p_tp_operacao                  =   'S'   then
            p_ds_retorno                   :=  'Simulação do cálculo efetuada.'  ;
         else
            p_ds_retorno                   :=  'Memória de cálculo( ' || p_rec_mc_aluno.id_mc_aluno || ' ) gerada.' ; 
         end if;
      end if;    
    
   end if;
end if;       


    if p_tp_operacao = 'P' then
           -- !!* Aqui - . Retirar commit apos os teste. deixar somente na API
        commit;   
        
        -- Persistir log de execução da memoria de calculo
        l_rec_fat_mc_log.dt_hr_fim                        :=  localtimestamp;
        l_rec_fat_mc_log.id_financeiro                    :=  p_rec_mc_aluno.id_financeiro;
        l_rec_fat_mc_log.id_mc_aluno                      :=  p_rec_mc_aluno.id_mc_aluno; 
        l_rec_fat_mc_log.nr_matricula                     :=  p_rec_mc_aluno.nr_matricula;       
        l_rec_fat_mc_log.tp_aluno                         :=  1; -- Graduação
        l_rec_fat_mc_log.dt_hr_inicio                     :=  l_dt_hr_inicio; 
        l_rec_fat_mc_log.qt_segundos_execucao             :=  f_diferenca_segundos( l_dt_hr_inicio
                                                                                 , l_rec_fat_mc_log.dt_hr_fim  );        
        l_rec_fat_mc_log.fg_retorno_execucao              :=  p_fg_retorno;
        l_rec_fat_mc_log.tp_operacao                      :=  p_tp_operacao;
        l_rec_fat_mc_log.ds_erro_execucao                 :=  p_ds_retorno;
           
        pk_fat_mc_dml.p_add_fat_mc_log( l_rec_fat_mc_log    
                                      , l_fg_retorno    
                                      , l_ds_retorno  )  ;  
        commit;
    end if;
    
        --if p_tp_operacao = 'S' then
            p_ds_retorno := ca.PK_FAT_MC_JSN.simula(p_rec_mc_aluno, 
                                                    p_vt_mc_disciplina, 
                                                    p_vt_titulo_gerado, 
                                                    l_vt_titulos_modalidade_aux,
                                                    l_rec_financeiro);
         --end if;
        
--
-- <<SAIDA>>
-- dbms_output.put_line ('<< Saida >>');
--
exception
   when ex_erro_memoria_calculo then
        begin
            rollback;
            p_fg_retorno                                      := 'N';
            l_rec_fat_mc_log.id_financeiro                    :=  p_rec_mc_aluno.id_financeiro;
            l_rec_fat_mc_log.id_mc_aluno                      :=  p_rec_mc_aluno.id_mc_aluno; 
            l_rec_fat_mc_log.nr_matricula                     :=  p_rec_mc_aluno.nr_matricula;
            l_rec_fat_mc_log.tp_aluno                         :=   1;
            l_rec_fat_mc_log.dt_hr_inicio                     :=  l_dt_hr_inicio; 
            l_rec_fat_mc_log.dt_hr_fim                        :=  localtimestamp;
            l_rec_fat_mc_log.qt_segundos_execucao             :=  f_diferenca_segundos( l_dt_hr_inicio
                                                                                      , l_rec_fat_mc_log.dt_hr_fim  ); 
            l_rec_fat_mc_log.fg_retorno_execucao              :=  p_fg_retorno;
            l_rec_fat_mc_log.tp_operacao                      :=  p_tp_operacao;
            l_rec_fat_mc_log.ds_erro_execucao                 :=  p_ds_retorno;
            
            pk_fat_mc_dml.p_add_fat_mc_log( l_rec_fat_mc_log    
                                          , l_fg_retorno    
                                          , l_ds_retorno  )  ;     
            commit; 
--            exception
--              when others then 
--                   null;
       end ;    

   when others then  
        p_fg_retorno := 'N'; 
        p_ds_retorno := g_nm_pacote || '.P_MEMORIA_CALCULO_GR - Erro: '  || dbms_utility.format_error_backtrace || ' - '||dbms_utility.format_error_stack ;  
        begin
            rollback;
            l_rec_fat_mc_log.id_financeiro                 :=  p_rec_mc_aluno.id_financeiro;
            l_rec_fat_mc_log.id_mc_aluno                      :=  p_rec_mc_aluno.id_mc_aluno; 
            l_rec_fat_mc_log.nr_matricula                     :=  p_rec_mc_aluno.nr_matricula;
            l_rec_fat_mc_log.tp_aluno                         :=   1;
            l_rec_fat_mc_log.dt_hr_inicio                  :=  l_dt_hr_inicio; 
            l_rec_fat_mc_log.dt_hr_fim                     :=  localtimestamp;
            l_rec_fat_mc_log.qt_segundos_execucao          :=  f_diferenca_segundos( l_dt_hr_inicio
                                                                                  , l_rec_fat_mc_log.dt_hr_fim  ); 
            l_rec_fat_mc_log.fg_retorno_execucao              :=  p_fg_retorno;
            l_rec_fat_mc_log.tp_operacao                      :=  p_tp_operacao;
            l_rec_fat_mc_log.ds_erro_execucao                 :=  p_ds_retorno; 

            pk_fat_mc_dml.p_add_fat_mc_log( l_rec_fat_mc_log    
                                          , l_fg_retorno    
                                          , l_ds_retorno  )  ;    
            commit;
--            exception
--             when others then 
--                   null; 
       end ;   

end p_memoria_calculo_gr;

procedure p_atualiza_titulos(p_rec_financeiro in out nocopy ca.pk_fat_mc_plt.rec_financeiro) as
  v_indice_titulo number := 0;
  v_indice_comp number := 0;
  v_competencia number :=0;
begin

  for v_indice_titulo in 1..p_rec_financeiro.titulo.count() loop
    v_competencia := p_rec_financeiro.titulo(v_indice_titulo).nr_competencia;
    for v_indice_comp in 1 ..p_rec_financeiro.competencia.count() loop
      if p_rec_financeiro.competencia(v_indice_comp).nr_competencia = v_competencia then
        p_rec_financeiro.titulo(v_indice_titulo).dt_competencia  := p_rec_financeiro.competencia(v_indice_comp).dt_competencia; 
        p_rec_financeiro.titulo(v_indice_titulo).dt_vencimento   := p_rec_financeiro.competencia(v_indice_comp).dt_competencia + (p_rec_financeiro.nr_dia_vencimento_padrao-1); 
      end if;
    end loop;
  end loop;

end p_atualiza_titulos;

-- 
-- -----------------------------------------------------------------------------
/*
PROCEDURE: p_memoria_calculo_pg
DESENVOLVEDOR: Helane, Haroldo, Lucas e José Leitão 
OBJETIVO: Gerar memória de cálculo da pós-graduacao
PARÂMETROS:
   1 - p_cd_estab_operador
   2 - p_nr_matric_operador 
   3 - p_tp_operacao
       S-Simular  P-persistir
   4 - p_fg_exibir
       S-Sim   N-Não
   5 - p_array_aluno
   6 - p_array_disciplina
   7 - p_vt_titulo_gerado
   8 - p_fg_retorno
   9 - p_ds_retorno
*/
-- -----------------------------------------------------------------------------
procedure p_memoria_calculo_pg
( p_tp_operacao              in     varchar2  
, p_fg_exibir                in     varchar2 default 'N'
, p_dt_vencto_1a_mensalidade in     date
, p_rec_aluno_pg             in out nocopy ca.pk_fat_mc_plt.rec_mc_aluno_pg  
, p_array_mensalidade_pg     in     ca.pk_fat_mc_plt.ar_mensalidade_pg          
, p_fg_retorno               out    varchar2
, p_ds_retorno               out    varchar2 ) is 
--
cursor cr_aluno_pg( pc_id_financeiro     in ca.fat_financeiro.id_financeiro%type ) is
select f.cd_faixa_motivo_inativacao 
     , a.nr_matricula
  from pg.aluno a
     , ca.fat_financeiro f 
 where f.id_financeiro       =  pc_id_financeiro  
   and a.nr_matricula(+)     =  f.nr_matricula;
--             
l_rec_mc_aluno                   ca.pk_fat_mc_plt.rec_mc_aluno; 
l_vt_mc_disciplina               ca.pk_fat_mc_plt.ar_mc_disciplina;
l_vt_regra_academica             ca.pk_fat_mc_plt.ar_mc_regra_academica;
l_vt_mc_disciplina_modalidade    pk_fat_mc_plt.ar_mc_disciplina_modalidade; 
l_rec_financeiro                 ca.pk_fat_mc_plt.rec_financeiro;
l_vt_titulos_aux                 ca.pk_fat_mc_plt.vt_titulo_aux; 
l_vt_titulos_gerados_aux         ca.pk_fat_mc_plt.vt_titulo_aux;
l_vt_titulos_preservados_aux     ca.pk_fat_mc_plt.vt_titulo_aux;
l_vt_titulos_modalidade_aux      ca.pk_fat_mc_plt.vt_titulo_modalidade;
l_vt_financeiro_modalidade_aux   ca.pk_fat_mc_plt.vt_fin_modalidade_aux; 
l_vt_modalidade_competencia_aux  ca.pk_fat_mc_plt.vt_modalidade_competencia; 
--
l_st_aluno_pg                    cr_aluno_pg%rowtype;
l_qt_titulos_por_competencia_modalidade    number(2);  
l_dt_primeira_mensalidade_pg     date;
l_dt_processamento               date  := sysdate;         -- !!* Aqui        
l_ind_ret                        number(4) := 0;
--    
l_dt_hr_inicio                   timestamp := localtimestamp ; 
l_rec_fat_mc_log                 ca.fat_mc_log%rowtype;
l_fg_retorno                     varchar2(1);
l_ds_retorno                     varchar2(4000); 
--
begin
--
open  cr_aluno_pg ( p_rec_aluno_pg.id_financeiro ); 
fetch cr_aluno_pg into l_st_aluno_pg;
if cr_aluno_pg%found then
   if l_st_aluno_pg.cd_faixa_motivo_inativacao  is not null then
      p_ds_retorno                      := 'ID Financeiro ' ||  p_rec_aluno_pg.id_financeiro ||
                                           ' informado está cancelado.';
      raise ex_erro_memoria_calculo; 
   end if;
-- 
   if l_st_aluno_pg.nr_matricula       is  null then
      p_ds_retorno                      := 'ID Financeiro ' ||  p_rec_aluno_pg.id_financeiro ||
                                           ' informado não é de aluno da PG.';
      raise ex_erro_memoria_calculo; 
   end if;
--
   if p_rec_aluno_pg.nr_matricula       <>  l_st_aluno_pg.nr_matricula then
      p_ds_retorno                      :=  'Matrícula ' || p_rec_aluno_pg.nr_matricula || 
                                           ' informada não está associada ao ID Financeiro ' ||  p_rec_aluno_pg.id_financeiro ||
                                           ' informado.';
      raise ex_erro_memoria_calculo; 
   end if; 
else
   p_ds_retorno                         :=  'ID Financeiro ' || p_rec_aluno_pg.id_financeiro || 
                                            ' informado não identificado.';
   raise ex_erro_memoria_calculo; 
end if;
close cr_aluno_pg; 
--  
l_dt_primeira_mensalidade_pg                 := p_dt_vencto_1a_mensalidade; 
--   
-- Mover os dados do arrray de aluno PG para o array de aluno MC
l_rec_mc_aluno.cd_est_operador               := p_rec_aluno_pg.cd_est_operador;  
l_rec_mc_aluno.nr_mat_operador               := p_rec_aluno_pg.nr_mat_operador;  
l_rec_mc_aluno.cd_estabelecimento            := p_rec_aluno_pg.cd_estabelecimento;  
l_rec_mc_aluno.nr_matricula                  := p_rec_aluno_pg.nr_matricula;        
l_rec_mc_aluno.tp_arquivo                    := 3;
l_rec_mc_aluno.tp_periodo                    := 'P';  -- Pós-graduação
l_rec_mc_aluno.cd_dominio_categoria_aluno    := s_pl_dominio_codigo( 'MATRIC_DISC_001' );  
l_rec_mc_aluno.cd_faixa_categoria_aluno      := 1;    -- Padrão
l_rec_mc_aluno.id_financeiro                 := p_rec_aluno_pg.id_financeiro;
--  
p_array_financeiro_modalidade( l_rec_mc_aluno 
                             , l_vt_regra_academica 
                             , l_rec_financeiro ); 
--
-- Cálculo da distribuição dos títulos a receber 
/*
p_calculo( l_rec_mc_aluno       
         , l_vt_mc_disciplina 
         , l_vt_regra_academica
         , l_vt_mc_disciplina_modalidade
         , p_fg_exibir  
         , l_rec_financeiro    
         , l_vt_financeiro_modalidade_aux
         , l_vt_titulos_aux
         , l_vt_titulos_gerados_aux
         , l_vt_titulos_preservados_aux
         , l_vt_titulos_modalidade_aux
         , l_vt_modalidade_competencia_aux
         , p_array_mensalidade_pg
         , l_qt_titulos_por_competencia_modalidade 
         , l_dt_processamento 
         , p_fg_retorno        
         , p_ds_retorno    );
*/
--
p_calculo( p_rec_mc_aluno                  => l_rec_mc_aluno
         , p_vt_mc_disciplina              => l_vt_mc_disciplina
         , p_vt_mc_disciplina_modalidade   => l_vt_mc_disciplina_modalidade
         , p_rec_financeiro                => l_rec_financeiro
         , p_vt_financeiro_modalidade_aux  => l_vt_financeiro_modalidade_aux
         , p_vt_titulos_aux                => l_vt_titulos_aux
         , p_vt_titulos_gerados_aux        => l_vt_titulos_gerados_aux
         , p_vt_titulos_preservados_aux    => l_vt_titulos_preservados_aux
         , p_vt_titulos_modalidade_aux     => l_vt_titulos_modalidade_aux
         , p_vt_modalidade_competencia_aux => l_vt_modalidade_competencia_aux
         , p_qt_titulos_por_competencia_modalidade => l_qt_titulos_por_competencia_modalidade
         , p_vt_mensalidade_pg             => p_array_mensalidade_pg
         , p_vt_regra_academica            => l_vt_regra_academica
         , p_tp_operacao                   => p_tp_operacao
         , p_fg_exibir                     => p_fg_exibir
         , p_fg_titulo_oferta              => 'N'
         , p_dt_processamento              => l_dt_processamento
         , p_fg_retorno                    => p_fg_retorno
         , p_ds_retorno                    => p_ds_retorno 
         );
--
if p_fg_retorno                         =   'N'  then
   raise ex_erro_memoria_calculo;
end if;  
-- Persistir memória de cálculo e titulos
-- -------------------------------------------------------------------------
if p_tp_operacao                       =  'P'  then
   -- Atualizar o financeiro e suas modalidade associadas
   p_persistir_financeiro( l_rec_mc_aluno  
                         , l_rec_financeiro 
                         , p_fg_retorno     
                         , p_ds_retorno   )  ; 

   if p_fg_retorno     =   'N'  then 
      raise  ex_erro_memoria_calculo; 
   end if;  
end if;
--     
if p_tp_operacao                       in ( 'S', 'P' )  then
   p_titulo_persistir( p_tp_operacao
                     , l_rec_mc_aluno 
                     , l_vt_titulos_aux
                     , l_vt_titulos_modalidade_aux
                     , p_fg_exibir 
                     , rc0.id_pessoa_aluno          --   in
                     , l_rec_financeiro             --   in    
                     , l_qt_titulos_por_competencia_modalidade         
                     , l_dt_processamento    
                     , l_dt_primeira_mensalidade_pg
                     , p_fg_retorno                 --   out 
                     , p_ds_retorno );              --   out  
--                     
   if p_fg_retorno     =   'N'  then 
      raise ex_erro_memoria_calculo; 
   end if;
end if; 

-- Persistir log de execução da memoria de calculo
l_rec_fat_mc_log.dt_hr_fim                     :=  localtimestamp;
l_rec_fat_mc_log.id_financeiro                 :=  l_rec_mc_aluno.id_financeiro;
l_rec_fat_mc_log.id_mc_aluno                   :=  l_rec_mc_aluno.id_mc_aluno; 
l_rec_fat_mc_log.nr_matricula                  :=  l_rec_mc_aluno.nr_matricula;       
l_rec_fat_mc_log.tp_aluno                      :=  2; -- PósGraduação
l_rec_fat_mc_log.dt_hr_inicio                  :=  l_dt_hr_inicio; 
l_rec_fat_mc_log.qt_segundos_execucao          :=  f_diferenca_segundos( l_dt_hr_inicio 
                                                                             , l_rec_fat_mc_log.dt_hr_fim  );        
l_rec_fat_mc_log.fg_retorno_execucao           :=  p_fg_retorno;
l_rec_fat_mc_log.tp_operacao                   :=  p_tp_operacao;
l_rec_fat_mc_log.ds_erro_execucao              :=  null;
--  
pk_fat_mc_dml.p_add_fat_mc_log( l_rec_fat_mc_log    
                              , l_fg_retorno    
                              , l_ds_retorno  );  
if l_fg_retorno                         =   'N'  then
   raise ex_erro_memoria_calculo;
end if;
--
p_fg_retorno                      :=  'S';
--
if p_tp_operacao                  =   'S'   then
   p_ds_retorno                   :=  'Simulação do cálculo efetuada.'  ;
else
   p_ds_retorno                   :=  'Cálculo PG gerada.' ; 
end if;   
--
exception
when ex_erro_memoria_calculo then
    p_fg_retorno                                      := 'N';
    --dbms_output.put_line( 'ex_erro_memoria_calculo:' || p_ds_retorno );
    begin
        l_rec_fat_mc_log.id_financeiro                    :=  l_rec_mc_aluno.id_financeiro;
        l_rec_fat_mc_log.id_mc_aluno                      :=  l_rec_mc_aluno.id_mc_aluno; 
        l_rec_fat_mc_log.nr_matricula                     :=  l_rec_mc_aluno.nr_matricula;
        l_rec_fat_mc_log.tp_aluno                         :=  2;
        l_rec_fat_mc_log.dt_hr_inicio                     :=  l_dt_hr_inicio; 
        l_rec_fat_mc_log.dt_hr_fim                        :=  localtimestamp;
        l_rec_fat_mc_log.qt_segundos_execucao             :=  f_diferenca_segundos( l_dt_hr_inicio
                                                                                  , l_rec_fat_mc_log.dt_hr_fim  ); 
        l_rec_fat_mc_log.fg_retorno_execucao              :=  p_fg_retorno;
        l_rec_fat_mc_log.tp_operacao                      :=  p_tp_operacao;
        l_rec_fat_mc_log.ds_erro_execucao                 :=  p_ds_retorno; 

        pk_fat_mc_dml.p_add_fat_mc_log( l_rec_fat_mc_log    
                                      , l_fg_retorno    
                                      , l_ds_retorno  )  ;    
    exception
      when others then 
           null;
   end ;                
--
when others then 
    p_fg_retorno := 'N';
    p_ds_retorno := g_nm_pacote || '.P_MEMORIA_CALCULO_PG - Erro: '  || dbms_utility.format_error_backtrace || ' error - '||dbms_utility.format_error_stack ;  
    begin
        l_rec_fat_mc_log.id_financeiro                    :=  l_rec_mc_aluno.id_financeiro;
        l_rec_fat_mc_log.id_mc_aluno                      :=  l_rec_mc_aluno.id_mc_aluno; 
        l_rec_fat_mc_log.nr_matricula                     :=  l_rec_mc_aluno.nr_matricula;
        l_rec_fat_mc_log.tp_aluno                         :=  2;
        l_rec_fat_mc_log.dt_hr_inicio                     :=  l_dt_hr_inicio; 
        l_rec_fat_mc_log.dt_hr_fim                        :=  localtimestamp;
        l_rec_fat_mc_log.qt_segundos_execucao             :=  f_diferenca_segundos( l_dt_hr_inicio
                                                                              , l_rec_fat_mc_log.dt_hr_fim  ); 
        l_rec_fat_mc_log.fg_retorno_execucao              :=  p_fg_retorno;
        l_rec_fat_mc_log.tp_operacao                      :=  p_tp_operacao;
        l_rec_fat_mc_log.ds_erro_execucao                 :=  p_ds_retorno; 

        pk_fat_mc_dml.p_add_fat_mc_log( l_rec_fat_mc_log    
                                      , l_fg_retorno    
                                      , l_ds_retorno  )  ;    
    exception
      when others then 
           null;
   end ; 
--               
end p_memoria_calculo_pg;


-- -----------------------------------------------------------------------------
/*
PROCEDURE: p_popular_financeiro_vetor_mc_aluno
DESENVOLVEDOR: Helane, Haroldo, Lucas e José Leitão 
OBJETIVO:  
PARÂMETROS:
    1 - p_rec_mc_aluno  
    2 - p_fg_retorno
    3 - p_ds_retorno
*/
-- -----------------------------------------------------------------------------
procedure p_popular_financeiro_vetor_mc_aluno( p_rec_mc_aluno  in out nocopy ca.pk_fat_mc_plt.rec_mc_aluno 
                                             , p_fg_retorno       out    varchar2     
                                             , p_ds_retorno       out    varchar2 ) is
--
-- !!* Aqui - Identificação de Id_pessoa poderia ser feita aqui
-- A ausencia do retorno do cursor pode não ser por falta do financeiro  
--
cursor cr_financeiro( pc_nr_matricula     in number 
                    , pc_id_pessoa_aluno  in number
                    , pc_id_academico     in number ) is
select f.id_financeiro 
     , np.tp_indice 
     , ti.cd_dominio_tipo_calculo 
     , ti.cd_faixa_tipo_calculo
     , ac.id_academico
     , ac.cd_dominio_regime 
     , ac.cd_faixa_regime 
     , tr.ds_tp_aluno  || ' - ' ||  tr.ds_apresentacao ds_regime
     , a.st_academica 
     , np.id_nome_parametro
  from ca.v_fat_tipo_indice    ti
     , ca.fat_financeiro       f
     , ca.fat_nome_parametro   np
     , ca.aluno                a
     , ca.fat_academico        ac
     , ca.v_fat_tipo_regime    tr
 where ac.id_academico       = pc_id_academico
   and ac.cd_dominio_regime  = tr.cd_dominio
   and ac.cd_faixa_regime    = tr.cd_faixa
   and ac.fg_ativo           = 'S' 
   and a.nr_matricula        = pc_nr_matricula
  
   and np.nr_matricula       = a.nr_matricula
   and np.id_pessoa_aluno    = pc_id_pessoa_aluno  
   and np.fg_ativo           = 'S'
  
   and f.nr_matricula        = np.nr_matricula
   and f.id_nome_parametro   = np.id_nome_parametro
   and f.id_pessoa_aluno     = np.id_pessoa_aluno
   and f.cd_faixa_motivo_inativacao is  null
   and f.id_academico        = ac.id_academico  

   and ti.tp_indice          = f.tp_indice 
   and ti.fg_ativo           = 'S';
--
begin
--
-- dbms_output.put_line ('p_rec_mc_aluno.nr_matricula: '||p_rec_mc_aluno.nr_matricula);   
-- dbms_output.put_line ('p_rec_mc_aluno.id_pessoa_aluno: '||p_rec_mc_aluno.id_pessoa_aluno);
-- dbms_output.put_line ('p_rec_mc_aluno.tp_arquivo: '||p_rec_mc_aluno.tp_arquivo);
-- dbms_output.put_line ('p_rec_mc_aluno.tp_periodo: '||p_rec_mc_aluno.tp_periodo);
-- dbms_output.put_line ('p_rec_mc_aluno.cd_periodo: '||p_rec_mc_aluno.cd_periodo);
-- dbms_output.put_line ('p_rec_mc_aluno.cd_periodo_especial: '||p_rec_mc_aluno.cd_periodo_especial);
-- dbms_output.put_line ('p_rec_mc_aluno.id_academico: '||p_rec_mc_aluno.id_academico);
--
open  cr_financeiro( p_rec_mc_aluno.nr_matricula  
                   , p_rec_mc_aluno.id_pessoa_aluno
                   , p_rec_mc_aluno.id_academico );
fetch cr_financeiro into p_rec_mc_aluno.id_financeiro        
                       , p_rec_mc_aluno.tp_indice    
                       , p_rec_mc_aluno.cd_dominio_tipo_calculo   
                       , p_rec_mc_aluno.cd_faixa_tipo_calculo  
                       , p_rec_mc_aluno.id_academico    
                       , p_rec_mc_aluno.cd_dominio_regime 
                       , p_rec_mc_aluno.cd_faixa_regime
                       , p_rec_mc_aluno.ds_regime
                       , p_rec_mc_aluno.st_academica
                       , p_rec_mc_aluno.id_nome_parametro ;
--
if cr_financeiro%notfound  then
   if p_rec_mc_aluno.tp_periodo  =   'N' then
      -- Período especial de férias 
      -- Criar linha ca.fat_financeiro
-- !!* Aqui - E se for solicitado uma validação ou simulação?

      p_fat_financeiro_incluir( p_rec_mc_aluno 
                              , p_fg_retorno
                              , p_ds_retorno );
      if p_fg_retorno   = 'N' then
         raise ex_erro_memoria_calculo;
      end if;
   else             
      p_ds_retorno := 'Financeiro do aluno não encontrado. ';
      raise ex_erro_memoria_calculo;
   end if;
end if;
close  cr_financeiro;
--
--<<SAIDA>>
-- dbms_output.put_line ('<<SAIDA>>');
--
exception
   when ex_erro_memoria_calculo then 
        p_fg_retorno := 'N';  
-- dbms_output.put_line ('Erro '||p_ds_retorno);
end p_popular_financeiro_vetor_mc_aluno;
--
-----------------------------------------------------------------------------
/*
PROCEDURE: p_mc_persistir_tabela_gr
DESENVOLVEDOR: Helane, Haroldo, Lucas e José Leitão 
OBJETIVO: persistir tabelas da memória de cálculo
PARÂMETROS:
    1 - p_fg_exibir
    2 - p_fg_retorno
    3 - p_ds_retorno
*/
-- -----------------------------------------------------------------------------
procedure p_mc_persistir_tabela_gr
( p_tp_operacao                   in     varchar2
, p_rec_mc_aluno                  in out nocopy ca.pk_fat_mc_plt.rec_mc_aluno 
, p_vt_mc_disciplina              in out nocopy ca.pk_fat_mc_plt.ar_mc_disciplina 
, p_vt_mc_disciplina_modalidade   out    nocopy ca.pk_fat_mc_plt.ar_mc_disciplina_modalidade 
, p_rec_financeiro                in out nocopy ca.pk_fat_mc_plt.rec_financeiro
, p_vt_titulos_aux                in out nocopy ca.pk_fat_mc_plt.vt_titulo_aux 
, p_vt_titulos_modalidade_aux     in out nocopy ca.pk_fat_mc_plt.vt_titulo_modalidade                              
, p_vt_modalidade_competencia_aux in out nocopy ca.pk_fat_mc_plt.vt_modalidade_competencia  
, p_qt_titulos_por_competencia_modalidade
                                  in     number   
, p_fg_exibir                     in     varchar2
, p_fg_titulo_oferta              in     varchar2
, p_dt_processamento              in     date                 
, p_fg_retorno                    out    varchar2     
, p_ds_retorno                    out    varchar2 ) is
--
begin 
--
if p_tp_operacao      =    'P' then
   -- Desativar as memórias de calculo anteriores e ctr_titulo associado
   -- a memória de cálculo
   -- !!* Aqui - Atualizações efetuadas
   ca.pk_fat_mc_dml.p_mc_aluno_desativar( p_rec_mc_aluno.id_financeiro
                                        , p_rec_mc_aluno.id_academico
                                        , p_fg_retorno    
                                        , p_ds_retorno  );   
   if p_fg_retorno = 'N'  then
      p_ds_retorno := 'Exceção em ca.pk_fat_mc_dml.p_mc_aluno_desativar';
      raise ex_erro_memoria_calculo;
   end if;    

   -- Persistir tabela ca.fat_mc_aluno
   p_mc_aluno_incluir( p_rec_financeiro.vl_financeiro_preservado
                     , p_rec_mc_aluno    
                     , p_fg_retorno        
                     , p_ds_retorno   );
   if p_fg_retorno     =   'N'  then 
      p_ds_retorno := 'Exceção em ca.pk_fat_mc_clc.p_mc_aluno_incluir';
      raise  ex_erro_memoria_calculo; 
   end if; 
  
   -- Persistir tabelas ca.fat_mc_disciplina e ca.fat_mc_disciplina
   if p_fg_titulo_oferta = 'N' then
      p_mc_disciplina_incluir( p_rec_mc_aluno.id_mc_aluno
                             , p_vt_mc_disciplina
                             , p_vt_mc_disciplina_modalidade
                             , p_fg_retorno        
                             , p_ds_retorno   );
                                  
      if p_fg_retorno = 'N' then 
         p_ds_retorno := 'Exceção em ca.pk_fat_mc_clc.p_mc_disciplina_incluir';
         raise ex_erro_memoria_calculo; 
      end if; 
   end if;

   -- Persistir tabelas ca.fat_mc_modalidade_regra e ca.fat_mc_disciplina_regra 
   p_mc_modalidade_regra_incluir( p_rec_mc_aluno.id_mc_aluno   
                                , p_rec_financeiro  -- p_vt_regra_academica 
                                , p_fg_retorno         
                                , p_ds_retorno    ) ;      
   if p_fg_retorno     =   'N'  then 
      raise  ex_erro_memoria_calculo; 
   end if; 

   -- Atualizar o financeiro e suas modalidade associadas
   p_persistir_financeiro( p_rec_mc_aluno  
                         , p_rec_financeiro
                         , p_fg_retorno     
                         , p_ds_retorno   )  ; 
   if p_fg_retorno     =   'N'  then 
      p_ds_retorno := 'Exceção em ca.pk_fat_mc_clc.p_persistir_financeiro';
      raise  ex_erro_memoria_calculo; 
   end if; 
end if;

if p_tp_operacao      in ( 'S', 'P' ) then
   -- S-Simular    P-Permistr
   -- Persistir tabelas ca.ctr_titulo, ca.fat_mc_titulo e ca.fat_mc_titulo_competencia  
   -- Montar vetor de títulos gerados MC ( p_vt_titulos_gerados_aux ) a 
   -- partir de p_rec_financeiro.titulo
   -- !!* Aqui - Ver Jean opcao SIMULAR

   p_titulo_persistir( p_tp_operacao
                     , p_rec_mc_aluno   
                     , p_vt_titulos_aux 
                     , p_vt_titulos_modalidade_aux
                     , p_fg_exibir 
                     , rc0.id_pessoa_aluno          
                     , p_rec_financeiro          
                     , p_qt_titulos_por_competencia_modalidade   
                     , p_dt_processamento 
                     , null
                     , p_fg_retorno                 --   out  
                     , p_ds_retorno );              --   out  
--
   if p_fg_retorno     =   'N'  then 
      p_ds_retorno := 'Exceção em ca.pk_fat_mc_clc.p_titulo_persistir' || nvl(p_ds_retorno, '');
      raise ex_erro_memoria_calculo; 
   end if;
end if;

if p_tp_operacao      =    'P' then
   -- Persistir tabela ca.fat_mc_valor_competência  
   p_mc_valor_competencia_incluir( p_rec_financeiro
                                 , p_rec_mc_aluno
                                 , p_fg_retorno          --   out 
                                 , p_ds_retorno );       --   out  
--
   if p_fg_retorno     =   'N'  then  
      p_ds_retorno := 'Exceção em ca.pk_fat_mc_clc.p_mc_valor_competencia_incluir';
      raise ex_erro_memoria_calculo; 
   end if;       
 --  
   -- Persistir tabela ca.fat_mc_modalidade_competencia  
   p_mc_modalidade_competencia_incluir( p_rec_mc_aluno
                                      , p_rec_financeiro
                                      , p_vt_modalidade_competencia_aux    -- out
                                      , p_fg_retorno     -- out
                                      , p_ds_retorno  ); -- out
   if p_fg_retorno     =   'N'  then 
      p_ds_retorno := 'Exceção em ca.pk_fat_mc_clc.p_mc_modalidade_competencia_incluir';
      raise ex_erro_memoria_calculo; 
   end if;       
end if;
--
p_fg_retorno        :=  'S';
--
exception
when ex_erro_memoria_calculo then 
     p_fg_retorno := 'N';
end p_mc_persistir_tabela_gr;

-- 
-- -----------------------------------------------------------------------------
/*
PROCEDURE: p_mc_aluno_incluir
DESENVOLVEDOR: Helane, Haroldo, Lucas e José Leitão 
OBJETIVO: persistir ttabela ca.fat_mc_aluno
PARÂMETROS:
   1 - p_fg_retorno
   2 - p_ds_retorno
*/
-- -----------------------------------------------------------------------------
procedure p_mc_aluno_incluir
( p_vl_financeiro_preservado in number
, p_rec_mc_aluno             in out nocopy ca.pk_fat_mc_plt.rec_mc_aluno 
, p_fg_retorno               out varchar2
, p_ds_retorno               out varchar2 ) is
--
l_rec_mc_aluno                     ca.fat_mc_aluno%rowtype;
--
begin 
--
l_rec_mc_aluno.id_mc_aluno                   := null;
l_rec_mc_aluno.cd_est_operador               := p_rec_mc_aluno.cd_est_operador;
l_rec_mc_aluno.nr_mat_operador               := p_rec_mc_aluno.nr_mat_operador;
l_rec_mc_aluno.dt_registro                   := sysdate;
l_rec_mc_aluno.cd_estabelecimento            := p_rec_mc_aluno.cd_estabelecimento;
l_rec_mc_aluno.nr_matricula                  := p_rec_mc_aluno.nr_matricula;
l_rec_mc_aluno.id_academico                  := p_rec_mc_aluno.id_academico;
l_rec_mc_aluno.cd_dominio_regime             := p_rec_mc_aluno.cd_dominio_regime;
l_rec_mc_aluno.cd_faixa_regime               := p_rec_mc_aluno.cd_faixa_regime;
l_rec_mc_aluno.cd_periodo_regular            := p_rec_mc_aluno.cd_periodo_regular;
l_rec_mc_aluno.cd_periodo_especial           := p_rec_mc_aluno.cd_periodo_especial;
l_rec_mc_aluno.cd_curso                      := p_rec_mc_aluno.cd_curso;
l_rec_mc_aluno.cd_habilitacao                := p_rec_mc_aluno.cd_habilitacao;
l_rec_mc_aluno.cd_dominio_categoria_aluno    := p_rec_mc_aluno.cd_dominio_categoria_aluno;
l_rec_mc_aluno.cd_faixa_categoria_aluno      := p_rec_mc_aluno.cd_faixa_categoria_aluno;
l_rec_mc_aluno.nr_semestre_referencia        := p_rec_mc_aluno.nr_semestre_referencia;
l_rec_mc_aluno.nr_hora_optativa_habilitacao  := p_rec_mc_aluno.nr_hora_optativa_habilitacao;
l_rec_mc_aluno.nr_hora_optativa_utilizada    := p_rec_mc_aluno.nr_hora_optativa_utilizada;
l_rec_mc_aluno.nr_hora_optativa_sem_onus     := p_rec_mc_aluno.nr_hora_optativa_sem_onus;
l_rec_mc_aluno.id_financeiro                 := p_rec_mc_aluno.id_financeiro;
l_rec_mc_aluno.tp_indice                     := p_rec_mc_aluno.tp_indice;
l_rec_mc_aluno.vl_indice                     := p_rec_mc_aluno.vl_indice;
l_rec_mc_aluno.tp_indice_habilitacao         := p_rec_mc_aluno.tp_indice_habilitacao;
l_rec_mc_aluno.vl_indice_habilitacao         := p_rec_mc_aluno.vl_indice_habilitacao;
l_rec_mc_aluno.vl_hora_habilitacao           := p_rec_mc_aluno.vl_hora_habilitacao;
l_rec_mc_aluno.un_financeira                 := p_rec_mc_aluno.un_financeiro;
l_rec_mc_aluno.vl_financeiro                 := p_rec_mc_aluno.vl_financeiro 
                                            - p_vl_financeiro_preservado;
--
l_rec_mc_aluno.ds_mensagem_01                := p_rec_mc_aluno.ds_mensagem_01;
l_rec_mc_aluno.ds_mensagem_02                := p_rec_mc_aluno.ds_mensagem_02;
l_rec_mc_aluno.ds_mensagem_03                := p_rec_mc_aluno.ds_mensagem_03;
--
l_rec_mc_aluno.cd_ocorrencia_regra           := p_rec_mc_aluno.cd_ocorrencia_regra;
l_rec_mc_aluno.fg_mc_aluno                   := 'S' ;   -- Ativado
l_rec_mc_aluno.id_mc_versao                  := 5; -- !!* Aqui -  p_array_aluno(1).id_mc_versao;
--
-- !!* Aqui - Atualização de dados
pk_fat_mc_dml.p_add_fat_mc_aluno( l_rec_mc_aluno
                               , p_fg_retorno 
                               , p_ds_retorno );
if p_fg_retorno                              = 'S' then 
  p_rec_mc_aluno.id_mc_aluno                :=  l_rec_mc_aluno.id_mc_aluno; 
end if;
--
p_fg_retorno                                 := 'S';
--
exception
when ex_erro_memoria_calculo then
    p_fg_retorno := 'N';
end p_mc_aluno_incluir;

-- 
-- -----------------------------------------------------------------------------
/* 
PROCEDURE: P_MC_DISCIPLINA_INCLUIR
DESENVOLVEDOR: Helane, Haroldo, Lucas e José Leitão 
OBJETIVO: persistir ttabela ca.fat_mc_disciplina
PARÂMETROS:
   1 - p_array_disciplina
   2 - p_id_mc_aluno 
   3 - p_fg_retorno
   4 - p_ds_retorno
*/
-- -----------------------------------------------------------------------------
procedure p_mc_disciplina_incluir
( p_id_mc_aluno                     in     ca.fat_mc_aluno.id_mc_aluno%type
, p_vt_mc_disciplina                in out nocopy ca.pk_fat_mc_plt.ar_mc_disciplina 
, p_vt_mc_disciplina_modalidade     in out nocopy pk_fat_mc_plt.ar_mc_disciplina_modalidade
, p_fg_retorno                      out    varchar2
, p_ds_retorno                      out    varchar2 ) is
--
l_rec_mc_disciplina                     ca.fat_mc_disciplina%rowtype;
--
begin 
--
for ind in p_vt_mc_disciplina.first  .. p_vt_mc_disciplina.last loop
   l_rec_mc_disciplina.id_mc_disciplina                        := null;
   l_rec_mc_disciplina.id_mc_aluno                             := p_id_mc_aluno;
   l_rec_mc_disciplina.cd_disciplina                           := p_vt_mc_disciplina(ind).cd_disciplina;
   l_rec_mc_disciplina.cd_turma                                := p_vt_mc_disciplina(ind).cd_turma;
   l_rec_mc_disciplina.cd_curso                                := p_vt_mc_disciplina(ind).cd_curso;
   l_rec_mc_disciplina.cd_habilitacao                          := p_vt_mc_disciplina(ind).cd_habilitacao;
   l_rec_mc_disciplina.cd_horario                              := p_vt_mc_disciplina(ind).cd_horario;
   l_rec_mc_disciplina.nr_creditos_teoricos                    := p_vt_mc_disciplina(ind).nr_creditos_teoricos;
   l_rec_mc_disciplina.nr_creditos_praticos                    := p_vt_mc_disciplina(ind).nr_creditos_praticos;
   l_rec_mc_disciplina.cd_disciplina_equivalente               := p_vt_mc_disciplina(ind).cd_disciplina_equivalente;
   l_rec_mc_disciplina.nr_carga_horaria                        := p_vt_mc_disciplina(ind).nr_carga_horaria;
   l_rec_mc_disciplina.nr_carga_horaria_sem_onus               := p_vt_mc_disciplina(ind).nr_carga_horaria_sem_onus;
   l_rec_mc_disciplina.cd_dominio_situacao_disciplina          := p_vt_mc_disciplina(ind).cd_dominio_situacao_disciplina;
   l_rec_mc_disciplina.cd_faixa_situacao_disciplina            := p_vt_mc_disciplina(ind).cd_faixa_situacao_disciplina;
   l_rec_mc_disciplina.cd_dominio_tipo_cobranca                := p_vt_mc_disciplina(ind).cd_dominio_tipo_cobranca;
   l_rec_mc_disciplina.cd_faixa_tipo_cobranca                  := p_vt_mc_disciplina(ind).cd_faixa_tipo_cobranca;
   l_rec_mc_disciplina.id_grupo_disciplina                     := p_vt_mc_disciplina(ind).id_grupo_disciplina;
   l_rec_mc_disciplina.cd_dominio_tipo_calculo_hab_disciplina  := p_vt_mc_disciplina(ind).cd_dominio_tipo_calculo_hab_disciplina;
   l_rec_mc_disciplina.cd_faixa_tipo_calculo_hab_disciplina    := p_vt_mc_disciplina(ind).cd_faixa_tipo_calculo_hab_disciplina;
   l_rec_mc_disciplina.tp_indice_hab_disciplina                := p_vt_mc_disciplina(ind).tp_indice_hab_disciplina;
   l_rec_mc_disciplina.vl_indice_hab_disciplina                := p_vt_mc_disciplina(ind).vl_indice_hab_disciplina;
   l_rec_mc_disciplina.vl_hora_hab_disciplina                  := p_vt_mc_disciplina(ind).vl_hora_hab_disciplina;
   l_rec_mc_disciplina.nr_conversao_acad_finan                 := p_vt_mc_disciplina(ind).nr_conversao_acad_finan;
   l_rec_mc_disciplina.nr_unidade_financeira                   := p_vt_mc_disciplina(ind).nr_unidade_financeira;
   l_rec_mc_disciplina.vl_indice_disciplina                    := p_vt_mc_disciplina(ind).vl_indice_disciplina;
   l_rec_mc_disciplina.vl_disciplina                           := p_vt_mc_disciplina(ind).vl_disciplina;
   l_rec_mc_disciplina.ds_disciplina_equivalente               := p_vt_mc_disciplina(ind).ds_disciplina_equivalente;
   l_rec_mc_disciplina.ds_situacao_disciplina                  := p_vt_mc_disciplina(ind).ds_situacao_disciplina;
   l_rec_mc_disciplina.ds_complemento_situacao                 := p_vt_mc_disciplina(ind).ds_complemento_situacao;
   l_rec_mc_disciplina.ds_cobranca                             := p_vt_mc_disciplina(ind).ds_cobranca;
   l_rec_mc_disciplina.cd_ocorrencia_regra                     := p_vt_mc_disciplina(ind).cd_ocorrencia_regra;
--
--   !!* Aqui - Atualização de dados
   pk_fat_mc_dml.p_add_fat_mc_disciplina( l_rec_mc_disciplina
                                        , p_fg_retorno 
                                        , p_ds_retorno );
--
   if p_fg_retorno                                            = 'S' then
      p_vt_mc_disciplina(ind).id_mc_disciplina                := l_rec_mc_disciplina.id_mc_disciplina;
   end if;
--   
   if p_vt_mc_disciplina_modalidade.count          > 0 then
      p_mc_disciplina_modalidade_incluir( p_vt_mc_disciplina_modalidade
                                        , l_rec_mc_disciplina.id_mc_disciplina
                                        , l_rec_mc_disciplina.cd_disciplina       
                                        , p_fg_retorno   
                                        , p_ds_retorno   );
   end if;                                      
                                        
end loop; 
--
p_fg_retorno                                 := 'S'; 
--
end p_mc_disciplina_incluir;
-- 
-- -----------------------------------------------------------------------------
/*
PROCEDURE: p_mc_modalidade_regra_incluir
DESENVOLVEDOR: Helane, Haroldo, Lucas e José Leitão 
OBJETIVO: persistir as tabelas ca.fat_mc_modalidade_regra e ca.fat_mc_disciplina_regra 
PARÂMETROS:
    1 - p_array_disciplina
    2 - p_id_mc_aluno 
    3 - p_fg_retorno
    4 - p_ds_retorno
*/
-- -----------------------------------------------------------------------------
--
procedure p_mc_modalidade_regra_incluir
( p_id_mc_aluno             in     ca.fat_mc_aluno.id_mc_aluno%type
, p_rec_financeiro          in     ca.pk_fat_mc_plt.rec_financeiro 
, p_fg_retorno              out    varchar 
, p_ds_retorno              out    varchar2 ) is
--
l_rec_fat_mc_modalidade_regra                 ca.fat_mc_modalidade_regra%rowtype;
l_rec_fat_mc_disciplina_regra                 ca.fat_mc_disciplina_regra%rowtype;
--
begin 
--
for ind_mod       in nvl( p_rec_financeiro.modalidade.first, 1 )               .. nvl( p_rec_financeiro.modalidade.last, 0)  loop
    for ind_regra in nvl( p_rec_financeiro.modalidade(ind_mod).regra.first, 1) .. nvl( p_rec_financeiro.modalidade(ind_mod).regra.last, 0) loop
        l_rec_fat_mc_modalidade_regra.id_mc_modalidade_regra :=  null;
        l_rec_fat_mc_modalidade_regra.id_mc_aluno            :=  p_id_mc_aluno;
        l_rec_fat_mc_modalidade_regra.id_modalidade          :=  p_rec_financeiro.modalidade(ind_mod).id_modalidade;
        l_rec_fat_mc_modalidade_regra.tp_objeto_regra        :=  p_rec_financeiro.modalidade(ind_mod).regra(ind_regra).tp_objeto_regra;
        l_rec_fat_mc_modalidade_regra.cd_externo_regra       :=  p_rec_financeiro.modalidade(ind_mod).regra(ind_regra).cd_externo_regra;
        l_rec_fat_mc_modalidade_regra.nm_regra               :=  p_rec_financeiro.modalidade(ind_mod).regra(ind_regra).nm_regra;
--
--  !!* Aqui - Atualização de dados
        pk_fat_mc_dml.p_add_fat_mc_modalidade_regra( l_rec_fat_mc_modalidade_regra
                                                 , p_fg_retorno 
                                                 , p_ds_retorno );
        if p_fg_retorno                 =  'N' then
           raise ex_erro_memoria_calculo;
        end if; 
--
    end loop;
end loop;
--
p_fg_retorno                                 := 'S';

           /*  -- !!* Aqui - 
           if g_vt_mc_modalidade_regra_gr(ind_mod).disciplinas.count          >   0 then
              for ind_disc in g_vt_mc_modalidade_regra_gr(ind_mod).disciplinas.first  .. g_vt_mc_modalidade_regra_gr(ind_mod).disciplinas.last loop
                  l_rec_fat_mc_disciplina_regra.id_mc_disciplina_regra :=  null;
                  l_rec_fat_mc_disciplina_regra.id_mc_modalidade_regra :=  l_rec_fat_mc_modalidade_regra.id_mc_modalidade_regra;
                  
                  if p_vt_mc_disciplina.count                          >   0  then
                     l_ind_disciplina                                  :=  g_vt_mc_disciplina.first;
                     while g_vt_mc_disciplina is not null  loop
                           if g_vt_mc_modalidade_regra_gr(ind_mod).disciplinas(ind_disc).cd_disciplina 
                                                                       =   g_vt_mc_disciplina(l_ind_disciplina).cd_disciplina then
                              l_rec_fat_mc_disciplina_regra.id_mc_disciplina      
                                                                       :=  g_vt_mc_disciplina(l_ind_disciplina).id_mc_disciplina;
                              exit;
                           end if;
                           
                           l_ind_disciplina                            :=  g_vt_mc_disciplina.next(l_ind_disciplina) ;
                     end loop;
                  end if;
                  l_rec_fat_mc_disciplina_regra.cd_ocorrencia_regra    :=  g_vt_mc_modalidade_regra_gr(ind_mod).disciplinas(ind_disc).cd_ocorrencia_regra;
                  pk_fat_mc_dml.p_add_fat_mc_disciplina_regra( l_rec_fat_mc_disciplina_regra
                                                             , p_fg_retorno 
                                                             , p_ds_retorno );
                  if p_fg_retorno                                             =  'N' then
                     raise ex_erro_memoria_calculo;
                  end if;

              end loop;
           end if; 
           
       exception when others then null;
       end;                                                    
  end loop;
end loop;
p_fg_retorno                                 := 'S';*/
--
exception
when ex_erro_memoria_calculo then 
    p_fg_retorno := 'N'; 
end p_mc_modalidade_regra_incluir;

-- 
-- -----------------------------------------------------------------------------
/*
PROCEDURE: p_mc_disciplina_modalidade_incluir
DESENVOLVEDOR: Helane, Haroldo, Lucas e José Leitão 
OBJETIVO: persistir tabela ca.fat_mc_disciplina_modalidade_modalidade
PARÂMETROS:
   1 - p_id_mc_disciplina
   2 - p_cd_disciplina 
   3 - p_fg_retorno
   4 - p_ds_retorno
*/
-- -----------------------------------------------------------------------------
procedure p_mc_disciplina_modalidade_incluir
( p_vt_mc_disciplina_modalidade  in  out pk_fat_mc_plt.ar_mc_disciplina_modalidade
, p_id_mc_disciplina             in      ca.fat_mc_aluno.id_mc_aluno%type
, p_cd_disciplina                in      ca.fat_mc_disciplina.cd_disciplina%type
, p_fg_retorno                   out     varchar2
, p_ds_retorno                   out     varchar2 ) is
--
l_rec_mc_disc_modalidade            ca.fat_mc_disciplina_modalidade%rowtype;
--
begin 
--
for ind in p_vt_mc_disciplina_modalidade.first  .. p_vt_mc_disciplina_modalidade.last loop
    if p_vt_mc_disciplina_modalidade(ind).cd_disciplina  =  p_cd_disciplina  
       then 
       l_rec_mc_disc_modalidade.id_mc_disciplina_modalidade         := null;
       l_rec_mc_disc_modalidade.id_mc_disciplina                    := p_id_mc_disciplina;
       l_rec_mc_disc_modalidade.id_modalidade                       := p_vt_mc_disciplina_modalidade(ind).id_modalidade;
       l_rec_mc_disc_modalidade.vl_desconto_incondicional           := p_vt_mc_disciplina_modalidade(ind).vl_desconto_incondicional;
       l_rec_mc_disc_modalidade.un_desconto_incondicional           := p_vt_mc_disciplina_modalidade(ind).un_desconto_incondicional;
--   
-- !!* Aqui - Atualização de dados
       pk_fat_mc_dml.p_add_fat_mc_disciplina_modalidade( l_rec_mc_disc_modalidade
                                                       , p_fg_retorno 
                                                       , p_ds_retorno );
   if p_fg_retorno                                              = 'S' then
      p_vt_mc_disciplina_modalidade(ind).id_mc_disciplina_modalidade   
                                                                := l_rec_mc_disc_modalidade.id_mc_disciplina_modalidade;
   end if;
end if;
end loop;
p_fg_retorno                                 := 'S';
end p_mc_disciplina_modalidade_incluir;

-----------------------------------------------------------------------------
/*
PROCEDURE: p_validar_dados
DESENVOLVEDOR: Lucas 
OBJETIVO:  
PARÂMETROS:
    1 - p_rec_mc_aluno
    2 - p_vt_mc_disciplina 
    3 - p_fg_retorno
    4 - p_ds_retorno
*/
-- -----------------------------------------------------------------------------
procedure p_validar_dados( p_rec_mc_aluno     in out nocopy ca.pk_fat_mc_plt.rec_mc_aluno 
                         , p_vt_mc_disciplina in out nocopy ca.pk_fat_mc_plt.ar_mc_disciplina 
                         , p_fg_retorno       out     varchar2
                         , p_ds_retorno       out     varchar2 )is
--
l_index number(5);
--
begin
--
p_ds_retorno   := null;
-- Validação das informações do aluno
--
l_index := 1; --g_vt_mc_aluno.first();  ???
if l_index is null then
    p_ds_retorno := 'Sem informações a serem processadas.';
    raise ex_finalizar_memoria_calculo;
end if;
--
IF p_rec_mc_aluno.nr_matricula IS NULL then
    p_ds_retorno := 'Matrícula do aluno não foi informada.' || p_rec_mc_aluno.id_financeiro || '#' || p_rec_mc_aluno.id_pessoa_aluno ;
    raise ex_finalizar_memoria_calculo;
end if;
--
if p_rec_mc_aluno.tp_arquivo is null then
    p_ds_retorno := 'Tipo de aluno não foi informado.';
    raise ex_finalizar_memoria_calculo;
end if;
--
if p_rec_mc_aluno.tp_periodo is null then
    p_ds_retorno := 'Tipo de período acadêmico não foi informado.';
    raise ex_finalizar_memoria_calculo;
end if;
--
if  p_rec_mc_aluno.cd_periodo is null 
and p_rec_mc_aluno.cd_periodo_especial is null then
    p_ds_retorno := 'Código do período regular acadêmico da matrícula não foi informado.';
    raise ex_finalizar_memoria_calculo;
end if; 
--
if p_rec_mc_aluno.cd_curso is null then
    p_ds_retorno := 'Código do curso do aluno não foi informado.';
    raise ex_finalizar_memoria_calculo;
end if;
--
if p_rec_mc_aluno.cd_habilitacao is null then
    p_ds_retorno := 'Código da habilitação do aluno não foi informado.';
    raise ex_finalizar_memoria_calculo;
end if; 
--
if  p_rec_mc_aluno.cd_dominio_categoria_aluno is null then
    p_ds_retorno := 'Código do domínio da categoria do aluno não foi informado.';
    raise ex_finalizar_memoria_calculo;
end if;
--
if  p_rec_mc_aluno.cd_faixa_categoria_aluno is null then
    p_ds_retorno := 'Código do faixa da categoria do aluno não foi informado.';
    raise ex_finalizar_memoria_calculo;
end if;
--
if  p_rec_mc_aluno.nr_semestre_referencia is null then
    p_ds_retorno := 'O semestre de referência do aluno não foi informado.';
    raise ex_finalizar_memoria_calculo;
end if;
--
if p_rec_mc_aluno.nr_hora_optativa_habilitacao is null then
    p_rec_mc_aluno.nr_hora_optativa_habilitacao := 0;
end if; 
--
if p_rec_mc_aluno.nr_hora_optativa_utilizada is null then
   p_rec_mc_aluno.nr_hora_optativa_utilizada := 0;
end if;
--
if p_rec_mc_aluno.cd_est_operador is null then
    p_ds_retorno := 'Estabelecimento da matrícula da pessoa para registro não foi informado.';
    raise ex_finalizar_memoria_calculo;
end if;
--
if p_rec_mc_aluno.nr_mat_operador is null then
    p_ds_retorno := 'Número da matrícula da pessoa para registro não foi informado.';
    raise ex_finalizar_memoria_calculo;
end if;
--
-- Inicializar os campos que serão retornados
--
p_rec_mc_aluno.cd_dominio_tipo_calculo                := null;
p_rec_mc_aluno.cd_faixa_tipo_calculo                  := null;
p_rec_mc_aluno.tp_indice                              := null;
p_rec_mc_aluno.vl_indice                              := null;
p_rec_mc_aluno.cd_dominio_tipo_calculo_habilitacao    := null;
p_rec_mc_aluno.cd_faixa_tipo_calculo_habilitacao      := null;
p_rec_mc_aluno.tp_indice_habilitacao                  := null;
p_rec_mc_aluno.vl_indice_habilitacao                  := null;
p_rec_mc_aluno.vl_hora_habilitacao                    := null;
p_rec_mc_aluno.ds_mensagem_01                         := null;
p_rec_mc_aluno.ds_mensagem_02                         := null;
p_rec_mc_aluno.ds_mensagem_03                         := null;
p_rec_mc_aluno.nr_hora_optativa_sem_onus              := 0;
p_rec_mc_aluno.vl_financeiro                          := 0;
p_rec_mc_aluno.un_financeiro                          := 0;
p_rec_mc_aluno.id_academico                           := null;
--
-- Validação das informções das disciplinas
l_index := p_vt_mc_disciplina.first();
--
if nvl(l_index, 0) < 1 then
    p_ds_retorno := 'Sem disciplinas para processamento.';
end if;
--
while(l_index is not null)loop
--
    if  p_vt_mc_disciplina(l_index).cd_disciplina is null then
        p_ds_retorno := 'Código da disciplina não foi informado.';
        raise ex_finalizar_memoria_calculo;
    end if;
--
    if  p_vt_mc_disciplina(l_index).cd_turma is null then
        p_ds_retorno := p_vt_mc_disciplina(l_index).cd_disciplina
                        || ' - Código da turma não foi informado.';
        raise ex_finalizar_memoria_calculo;
    end if;
--
    if  p_vt_mc_disciplina(l_index).cd_curso is null then
        p_ds_retorno := p_vt_mc_disciplina(l_index).cd_disciplina
                        || ' - Código do curso da oferta não foi informado.';
        raise ex_finalizar_memoria_calculo;
    end if;
--
    if  p_vt_mc_disciplina(l_index).cd_habilitacao is null then
        p_ds_retorno := p_vt_mc_disciplina(l_index).cd_disciplina
                        || ' - Código da habilitação da oferta não foi informado.';
        raise ex_finalizar_memoria_calculo;
    end if;
--
    if  p_vt_mc_disciplina(l_index).nr_creditos_teoricos is null then
        p_ds_retorno := p_vt_mc_disciplina(l_index).cd_disciplina
                        || ' - Quantidade de créditos teóricos não foi informado.';
        raise ex_finalizar_memoria_calculo;
    end if;
--
    if p_vt_mc_disciplina(l_index).nr_creditos_praticos is null then
        p_ds_retorno := p_vt_mc_disciplina(l_index).cd_disciplina
                        || ' - Quantidade de créditos práticos não foi informado.';
        raise ex_finalizar_memoria_calculo;
    end if;
--
    if p_vt_mc_disciplina(l_index).nr_carga_horaria is null then
        p_vt_mc_disciplina(l_index).nr_carga_horaria := 0;
    end if;
--
    if p_vt_mc_disciplina(l_index).nr_carga_horaria_sem_onus is null then
        p_vt_mc_disciplina(l_index).nr_carga_horaria_sem_onus := 0;
    end if;
--
    if p_vt_mc_disciplina(l_index).nr_carga_horaria_sem_onus > p_vt_mc_disciplina(l_index).nr_carga_horaria then
        p_ds_retorno := p_vt_mc_disciplina(l_index).cd_disciplina
                        || ' - Quantidade de carga horária sem ônus não é válida.';
        raise ex_finalizar_memoria_calculo;
    end if;
--
    if p_vt_mc_disciplina(l_index).cd_dominio_situacao_disciplina is null then
        p_ds_retorno :=  p_vt_mc_disciplina(l_index).cd_disciplina
                         || ' - Código do domínio da situação da disciplina não foi informado.';
        raise ex_finalizar_memoria_calculo;
    end if;
--
    if p_vt_mc_disciplina(l_index).cd_faixa_situacao_disciplina is null then
        p_ds_retorno := p_vt_mc_disciplina(l_index).cd_disciplina
                        || ' - Código da faixa da situação da disciplina não foi informado.';
        raise ex_finalizar_memoria_calculo;
    end if;
--
    if p_vt_mc_disciplina(l_index).cd_dominio_tipo_cobranca is null then
        p_ds_retorno := p_vt_mc_disciplina(l_index).cd_disciplina
                        || ' - Código do domínio do tipo de cobrança da disciplina não foi informado.';
        raise ex_finalizar_memoria_calculo;
    end if;
--
    if p_vt_mc_disciplina(l_index).cd_faixa_tipo_cobranca IS NULL then
        p_ds_retorno :=  p_vt_mc_disciplina(l_index).cd_disciplina
                         || ' - Código da faixa do tipo de cobrança da disciplina não foi informado.';
        raise ex_finalizar_memoria_calculo;
    end if;
--    
    -- Inicialização dos campos retornardos
    p_vt_mc_disciplina(l_index).id_grupo_disciplina       := null;
    p_vt_mc_disciplina(l_index).tp_indice_hab_disciplina  := null;
    p_vt_mc_disciplina(l_index).vl_indice_hab_disciplina  := null;
    p_vt_mc_disciplina(l_index).vl_hora_hab_disciplina    := null;
    p_vt_mc_disciplina(l_index).nr_conversao_acad_finan   := null;
    p_vt_mc_disciplina(l_index).nr_unidade_financeira     := null;
    p_vt_mc_disciplina(l_index).vl_indice_disciplina      := null;
    p_vt_mc_disciplina(l_index).vl_disciplina             := null;
    p_vt_mc_disciplina(l_index).ds_disciplina_equivalente := null;
    p_vt_mc_disciplina(l_index).ds_situacao_disciplina    := null;
    p_vt_mc_disciplina(l_index).ds_complemento_situacao   := null;
    p_vt_mc_disciplina(l_index).ds_valor_cobranca         := null;
    p_vt_mc_disciplina(l_index).ds_cobranca               := null;
    p_vt_mc_disciplina(l_index).ds_referencia_academica   := null;
--
    l_index := p_vt_mc_disciplina.next(l_index);
--
end loop;
--
p_fg_retorno     :=   'S'; 
--
exception 
  when ex_finalizar_memoria_calculo  then
       p_fg_retorno    := 'N';
END p_validar_dados;
    -- 
    -----------------------------------------------------------------------------
/*
PROCEDURE: p_buscar_informacoes
DESENVOLVEDOR: Lucas
OBJETIVO:  
PARÂMETROS:
   1 - p_rec_mc_aluno
   2 - p_vt_mc_disciplina
   3 - p_dt_processamento
   4 - p_fg_retorno
   5 - p_ds_retorno
*/
    -- -----------------------------------------------------------------------------
procedure p_buscar_informacoes( p_rec_mc_aluno     in out nocopy pk_fat_mc_plt.rec_mc_aluno
                              , p_vt_mc_disciplina in out nocopy pk_fat_mc_plt.ar_mc_disciplina                                   
                              , p_dt_processamento in     date  
                              , p_fg_retorno       out    varchar2
                              , p_ds_retorno       out    varchar2 )is
    
--
-- Consulta para obter o ID_ACADEMICO do período regular da Graduação ----------
--
cursor cr_id_academico( p_id_academico    in  ca.fat_academico.id_academico%type ) is
select a.cd_dominio_regime
     , a.cd_faixa_regime 
     , tr.ds_tp_aluno  || ' - ' ||  tr.ds_apresentacao ds_regime
  from ca.v_fat_tipo_regime tr
     , ca.fat_academico a
 where a.id_academico   =  p_id_academico
   and a.fg_ativo       =  'S'
   and tr.cd_dominio    =  a.cd_dominio_regime
   and tr.cd_faixa      =  a.cd_faixa_regime
   and tr.st_dominio    =  'A';
--
-- Consulta para identificar o ID_FINANCEIRO e o TP_INDICE
cursor cr_financeiro( p_nr_matricula   number 
                    , p_id_pessoa      number 
                    , p_id_academico   number )IS
select f.id_financeiro 
     , f.tp_indice 
     , ti.cd_dominio_tipo_calculo 
     , ti.cd_faixa_tipo_calculo 
     , a.st_academica
  from ca.v_fat_tipo_indice    ti
     , ca.aluno                a
     , ca.fat_nome_parametro   np
     , ca.fat_financeiro       f
 where f.id_academico                  =   p_id_academico
   and f.cd_dominio_motivo_inativacao  is  null
   and f.nr_matricula                  =   p_nr_matricula
   and np.id_nome_parametro            =   f.id_nome_parametro
   and np.id_pessoa_aluno              =   p_id_pessoa
   and np.fg_ativo                     =   'S'
   and a.nr_matricula                  =   np.nr_matricula 
   and ti.tp_indice                    =   f.tp_indice
   and ti.fg_ativo                     =   'S';
--
-- Consulta para as informações da habilitação 
cursor cr_info_habilitacao( p_cd_curso         number
                          , p_cd_habilitacao   number ) is
select b.cd_curso 
     , b.cd_habilitacao 
     , c.cd_dominio_tipo_calculo   cd_dominio_tipo_calculo_habilitacao 
     , c.cd_faixa_tipo_calculo     cd_faixa_tipo_calculo_habilitacao 
     , b.tp_indice                 tp_indice_habilitacao 
     , b.vl_hora                   vl_hora_habilitacao 
     , b.tp_calculo                tp_calculo_habilitacao
  from ca.v_fat_tipo_indice   c
     , ca.habilitacao         b
 where b.cd_curso       = p_cd_curso
   and b.cd_habilitacao = p_cd_habilitacao
   and c.tp_indice      = b.tp_indice
   and c.fg_ativo       = 'S';
--
-- c6_financeiro do pacote ca.fi_memorial_calculo_clc *** CURSOR MODIFICADO
cursor cr_financeiro_aluno(p_id_financeiro number) is 
select a1.nr_matricula
     , a1.id_financeiro
     , a1.id_modalidade
     , a1.un_financeiro
     , a1.vl_financeiro
     , a1.tp_indice
     , a1.st_academica
     , a1.dt_base
     , case
       when a1.dt_base is not null then
            null
       when a1.dt_base is not null then
            'Sem autorização para efetuar a matricula.'
       else
            to_char(null)
       end ds_msg_autorizacao_matricula
     , case
       when a1.dt_base is not null then
            null
       when a1.dt_base is not null then
            'Sem autorização para efetuar alteração na matricula.'
       else
            to_char( null )
       end ds_msg_autoriz_alter_matric 
     , case
       when a1.tp_ocorrencia        is not null
        and a1.ds_msg_valor_limite  is not null then
            a1.ds_msg_valor_limite
       when a1.tp_ocorrencia is not null
        and a1.ds_msg_valor_limite is null then
            'Sem o registro do límite de valor do semestre.'
       else
            to_char(null)
       end ds_msg_valor_limite 
     , a1.tp_ocorrencia 
from ( select a.nr_matricula
            , f.id_financeiro
            , f.vl_financeiro
            , f.un_financeiro
            , f.tp_indice
            , nvl(a.st_academica,'A') st_academica
            , d.cd_dominio_autoriz_matricula
            , d.cd_faixa_autoriz_matricula 
            , d.cd_dominio_valor_limite
            , d.cd_faixa_valor_limite
            , d.ds_msg_valor_limite
            , d.tp_ocorrencia
            , e.dt_base
            , case
              when d.tp_ocorrencia is null then
                   to_char('1')   -- Sem validação do tipo de ocorrência
              else
                   nvl(( select to_char('3')   -- ocorrência com registro válido
                           from ca.ocorrencia e
                          where e.cd_estabelecimento =       0
                            and e.nr_matricula       =       a.nr_matricula
                            and e.tp_ocorrencia      =       d.tp_ocorrencia
                            and e.st_ocorrencia      =       1
                            and e.dt_ocorrencia      between g.dt_mes_ano_inicio_competencia 
                            and                              g.dt_mes_ano_termino_competencia
                            and rownum               <=      1
                       ),to_char('2')  -- Ocorrência ativa não encontrada
                      )
              end st_ocorrencia_valor_limite
           , d.id_modalidade
         from ca.aluno                      a
            , ca.fat_nome_parametro         b
            , ca.fat_nome_modalidade        c
            , ca.fat_modalidade             d
            , ca.fat_academico_modalidade   e
            , ca.fat_financeiro             f
            , ca.fat_academico              g
        where f.id_financeiro               =       p_id_financeiro
          and f.cd_faixa_motivo_inativacao  is      null
          and a.nr_matricula                =       f.nr_matricula
          and a.nr_matricula                =       b.nr_matricula
          and b.fg_ativo                    =       'S'
          and b.id_nome_parametro           =       c.id_nome_parametro
      
          and c.id_modalidade               =       d.id_modalidade
          and d.id_modalidade_tipo          =       7
          and d.cd_faixa_autoriz_matricula  is      not null 
     --                            or d.cd_faixa_autoriz_alte_matric is not null)
          and e.id_academico(+)             =      f.id_academico
          and e.id_modalidade(+)            =      c.id_modalidade
          and e.fg_ativo(+)                 =      'S'
          and g.id_academico                =       f.id_academico
          and g.fg_ativo                    =       'S'
) a1;

    --
    -- Consulta para validação da cobrança da disciplina 
    cursor cr_valida_cobranca( p_cd_faixa_categoria_aluno      number 
                             , p_cd_faixa_situacao_disciplina  number 
                             , p_cd_tipo_cobranca              number 
                             , p_cd_tipo_calculo               number ) is
       select a.cd_faixa_categoria_aluno
            , a.ds_categoria_aluno
            , b.cd_faixa_situacao_disciplina
            , b.ds_situacao_disciplina
            , c.cd_faixa_tipo_cobranca
            , c.ds_tipo_cobranca
         from ca.d_ca_categoria_semestre         a
            , ca.d_ca_situacao_disciplina        b
            , ca.d_fi_tipo_cobranca_disciplina   c
            , ca.v_fat_tipo_calculo              d -- > fi.d_tp_calculo d
        where a.cd_faixa_categoria_aluno     = p_cd_faixa_categoria_aluno
          and b.cd_faixa_situacao_disciplina = p_cd_faixa_situacao_disciplina
          and b.st_situacao_disciplina       = 'A'
          and c.cd_faixa_tipo_cobranca       = p_cd_tipo_cobranca
          and c.st_tipo_cobranca             = 'A'
          and d.cd_faixa                     = p_cd_tipo_calculo
          and d.st_dominio                   = 'A'
          and ( case
                    when d.cd_faixa = 1 then
                        case
                            when a.cd_faixa_categoria_aluno in(1, 2, 3 )then
                                case
                                    when b.cd_faixa_situacao_disciplina  =  4 
                                     and c.cd_faixa_tipo_cobranca        in ( 4, 5 ) then 
                                         1
                                    when b.cd_faixa_situacao_disciplina  =  5 
                                     and c.cd_faixa_tipo_cobranca        in ( 4, 5 ) then 
                                         1
                                    when b.cd_faixa_situacao_disciplina  =  6 
                                     and c.cd_faixa_tipo_cobranca        in ( 4, 5 ) then 
                                         1
                                    else 
                                         0
                                end
                            else
                              0
                        end
                    when d.cd_faixa                                     =   2 then
                        case
                            when a.cd_faixa_categoria_aluno             =   1 then
                                case
                                    when b.cd_faixa_situacao_disciplina =   1 
                                     and c.cd_faixa_tipo_cobranca       in  ( 1, 2, 5 ) then 
                                         1
                                    when b.cd_faixa_situacao_disciplina =   4 
                                     and c.cd_faixa_tipo_cobranca       in  ( 2, 5 ) then 
                                         1
                                    when b.cd_faixa_situacao_disciplina =   5
                                     and c.cd_faixa_tipo_cobranca       in  ( 3, 5 )then 
                                         1
                                    else 
                                         0
                                end
                            when a.cd_faixa_categoria_aluno             =    2 then
                                case
                                    when b.cd_faixa_situacao_disciplina =   1 
                                     and c.cd_faixa_tipo_cobranca       in  ( 1, 2, 5 ) then
                                         1
                                    when b.cd_faixa_situacao_disciplina =   3 
                                     and c.cd_faixa_tipo_cobranca       in  ( 2, 5 ) then 
                                         1
                                    when b.cd_faixa_situacao_disciplina =   4 
                                     and c.cd_faixa_tipo_cobranca       in  ( 2, 5 ) then 
                                         1
                                    when b.cd_faixa_situacao_disciplina =   5 
                                     and c.cd_faixa_tipo_cobranca       in( 3, 5 ) then 
                                         1
                                    else 
                                         0
                                end
                            when a.cd_faixa_categoria_aluno = 3 then
                                case
                                    when b.cd_faixa_situacao_disciplina =   2
                                     and c.cd_faixa_tipo_cobranca       in  ( 2, 5 ) then 
                                         1
                                    when b.cd_faixa_situacao_disciplina =   3 
                                     and c.cd_faixa_tipo_cobranca       in  ( 2, 5 ) then 
                                         1
                                    when b.cd_faixa_situacao_disciplina =   4 
                                     and c.cd_faixa_tipo_cobranca       in  ( 2, 5 ) then 
                                         1
                                    when b.cd_faixa_situacao_disciplina =   5 
                                     and c.cd_faixa_tipo_cobranca       in  ( 3, 5 ) then 
                                         1
                                    else 0
                                end
                            else 0
                        end
                    else 0
                end)                                                    =   1;
 --   
    cursor cr_mensagens_disciplinas( p_cd_faixa_tipo_calculo             number 
                                   , p_cd_dominio_situacao_disciplina    number
                                   , p_cd_faixa_situacao_disciplina      number
                                   , p_nr_carga_horaria                  number
                                   , p_nr_carga_horaria_sem_onus         number
                                   , p_cd_disciplina_equivalente         varchar2 ) is
        select a.nm_situacao_disciplina || '.' ds_situacao_disciplina 
             , case
               when a.cd_faixa_situacao_disciplina           =      4
                  and p_cd_faixa_tipo_calculo                =      2 then
                      case
                      when p_nr_carga_horaria                =      p_nr_carga_horaria_sem_onus then
                           'Dentro do limite de carga horária estabelecido para a habilitação.'
                      when p_nr_carga_horaria                <>     p_nr_carga_horaria_sem_onus
                       and p_nr_carga_horaria_sem_onus       >      0 then
                           'Ultrapassou em ' || to_char(p_nr_carga_horaria - p_nr_carga_horaria_sem_onus ) || 
                           ' o limite de carga horária estabelecido para a habilitação.'
                      when p_nr_carga_horaria_sem_onus       =      0 then
                           'Ultrapassou o limite de carga horária estabelecido para a habilitação.'
                      end
               else
                 to_char(null)
               end ds_complemento_situacao 
             , case
               when p_cd_disciplina_equivalente is not null then
                    ( select 'Equivalente a ' || b.cd_disciplina || ' ' || b.nm_disciplina || '.'
                        from ca.disciplina b
                       where b.cd_disciplina  =  p_cd_disciplina_equivalente
                    )
                else
                    to_char(null)
               end ds_disciplina_equivalente
          from ca.d_ca_situacao_disciplina a
         where a.cd_dominio_situacao_disciplina = p_cd_dominio_situacao_disciplina
           and a.cd_faixa_situacao_disciplina   = p_cd_faixa_situacao_disciplina
           and a.st_situacao_disciplina         = 'A';
--
type rec_indice is record ( tp_indice        ca.fat_valor_indice.tp_indice%type
                          , vl_indice        ca.fat_valor_indice.tp_indice%type );
--                     
l_rec_valor_indice_habilitacao              rec_indice;
l_rec_valor_indice_habilitacao_disciplina   rec_indice;
l_rec_info_habilitacao                      cr_info_habilitacao%rowtype;
l_rec_info_habilitacao_disciplina           cr_info_habilitacao%rowtype;
l_rec_valida_cobranca                       cr_valida_cobranca%rowtype; 
l_dummy2                                    number;
l_dummy3                                    number;  
windex                                      number;
--
begin
--
p_ds_retorno       := null;
--
if p_rec_mc_aluno.id_pessoa_aluno  is null then
   p_ds_retorno    := 'Não foi encontrada informações no cadastro de pessoa para a matrícula informada . ' ||
                      p_rec_mc_aluno.cd_estabelecimento || p_rec_mc_aluno.nr_matricula;
   raise ex_finalizar_memoria_calculo;
end if;
--
-- Buscar dados acadêmico do periodo em curso
p_rec_mc_aluno.id_academico := f_obter_id_academico ( p_rec_mc_aluno.tp_arquivo         
                                                    , p_rec_mc_aluno.tp_periodo       
                                                    , p_rec_mc_aluno.cd_periodo      
                                                    , p_rec_mc_aluno.cd_periodo_especial );
--
if p_rec_mc_aluno.id_academico  is null  then
   p_ds_retorno  :=  'Acadêmico não foi encontrado. ' || p_rec_mc_aluno.tp_arquivo || '#' || 
                      p_rec_mc_aluno.tp_periodo || '#' || p_rec_mc_aluno.cd_periodo || '#' ||
                      p_rec_mc_aluno.cd_periodo_especial;
   raise ex_finalizar_memoria_calculo;
end if;            

-- Buscar regime 
open cr_id_academico( p_rec_mc_aluno.id_academico ); 
fetch cr_id_academico into p_rec_mc_aluno.cd_dominio_regime
                         , p_rec_mc_aluno.cd_faixa_regime 
                         , p_rec_mc_aluno.ds_regime;
           
if cr_id_academico%notfound then
   p_ds_retorno  :=  'O período acadêmico informado não foi encontrado. #' || 
                      p_rec_mc_aluno.id_academico;
   raise ex_finalizar_memoria_calculo;
end if;            
close cr_id_academico;

-- Buscar dados financeiro do aluno ( id_financeiro, indice, tipo de calculo e situacao acadêmica )
open cr_financeiro( p_rec_mc_aluno.nr_matricula 
                  , p_rec_mc_aluno.id_pessoa_aluno 
                  , p_rec_mc_aluno.id_academico );
fetch cr_financeiro into p_rec_mc_aluno.id_financeiro        
                       , p_rec_mc_aluno.tp_indice   
                       , p_rec_mc_aluno.cd_dominio_tipo_calculo 
                       , p_rec_mc_aluno.cd_faixa_tipo_calculo  
                       , p_rec_mc_aluno.st_academica;
if cr_financeiro%notfound then 
   p_ds_retorno  := 'Não foram encontradas informações financeiras para a matrícula informada. ' || 
                     p_rec_mc_aluno.nr_matricula || '#' || p_rec_mc_aluno.id_pessoa_aluno || '#' || 
                     p_rec_mc_aluno.id_academico;
   raise ex_finalizar_memoria_calculo;
end if;
close cr_financeiro;
 
-- dbms_output.put_Line( '>>> Indice -  p_rec_mc_aluno.tp_indice:' || p_rec_mc_aluno.tp_indice ||' dt processamento:' || p_dt_processamento  ) ; 
--
-- Buscar dados Indice aplicado ( valor, ids )  
p_indice_financeiro( p_rec_mc_aluno.id_academico      
                   , p_rec_mc_aluno.tp_indice     
                   , p_dt_processamento          
                   , p_rec_mc_aluno.vl_indice          -- out           
                   , p_rec_mc_aluno.id_valor_indice    -- out               
                   , p_rec_mc_aluno.id_academico_tabela_preco  );  -- out           
 
if p_rec_mc_aluno.vl_indice     is null then 
   p_ds_retorno  := 'Valor do indice não encontrado. #' || p_rec_mc_aluno.id_academico || '#' ||
                    p_rec_mc_aluno.tp_indice || ' Data de Processamento: '||p_dt_processamento;
   raise ex_finalizar_memoria_calculo;
elsif p_rec_mc_aluno.vl_indice  = 0  then
   p_ds_retorno  := 'Valor do indice igual a zero. #' || p_rec_mc_aluno.id_academico || '#' ||
                    p_rec_mc_aluno.tp_indice;
   raise ex_finalizar_memoria_calculo;
end if;
-- dbms_output.put_Line( '>>> Indice -  vl_indice:' || p_rec_mc_aluno.vl_indice ||' id_valor_indice:' || p_rec_mc_aluno.id_valor_indice  || ' id_academico_tabela_preco:' || p_rec_mc_aluno.id_academico_tabela_preco  );  
   
--
-- Buscar informações da habilitação do aluno ( PK_FAT_MC_CLC - c5_habilitacao_aluno, c6_habilitacao )
-- Considerar que o curso/habilitação informados são os do aluno - não utilizar o cursor c5_habilitacao_aluno
open cr_info_habilitacao( p_cd_curso         =>  p_rec_mc_aluno.cd_curso 
                        , p_cd_habilitacao   =>  p_rec_mc_aluno.cd_habilitacao );
fetch cr_info_habilitacao into l_rec_info_habilitacao;
if cr_info_habilitacao%notfound then 
    p_ds_retorno  := 'Não foram encontradas informações relativas a habilitação do aluno informada. ' ||
                      p_rec_mc_aluno.cd_curso || '#' || p_rec_mc_aluno.cd_habilitacao || '#' ||
                      p_rec_mc_aluno.cd_habilitacao;
    raise ex_finalizar_memoria_calculo;
end if;
close cr_info_habilitacao; 
    
-- Obter o valor do índice da habilitação 
-- Obter valor do Indice    
p_indice_financeiro( p_rec_mc_aluno.id_academico 
                   , l_rec_info_habilitacao.tp_indice_habilitacao        
                   , p_dt_processamento               
                   , l_rec_valor_indice_habilitacao.vl_indice   -- out            
                   , l_dummy2                                   -- out
                   , l_dummy3  );                               -- out
--
l_rec_valor_indice_habilitacao.tp_indice     :=  l_rec_info_habilitacao.tp_indice_habilitacao  ;                                                              
if l_rec_valor_indice_habilitacao.tp_indice      is null then 
   p_ds_retorno  := 'Valor do indice( habilitação do aluno ) não encontrado. #' || p_rec_mc_aluno.id_academico|| '#' ||
                    l_rec_info_habilitacao.tp_indice_habilitacao  ; 
   raise ex_finalizar_memoria_calculo;
elsif l_rec_valor_indice_habilitacao.tp_indice   = 0  then
   p_ds_retorno  := 'Valor do indice( habilitação do aluno )  igual a zero. #' || p_rec_mc_aluno.id_academico|| '#' ||
                    l_rec_info_habilitacao.tp_indice_habilitacao ; 
   raise ex_finalizar_memoria_calculo;
end if; 
--    
-- Validar com as variáveis dos cursores 
if l_rec_info_habilitacao.cd_faixa_tipo_calculo_habilitacao   is   null 
or l_rec_info_habilitacao.cd_faixa_tipo_calculo_habilitacao   =    0     then
   p_ds_retorno  := 'Tipo de cálculo da habilitação informada não está cadastrado.#'|| 
                    p_rec_mc_aluno.id_academico || '#' || 
                    l_rec_info_habilitacao.tp_indice_habilitacao;
   raise ex_finalizar_memoria_calculo;
end if;
--
if l_rec_info_habilitacao.tp_indice_habilitacao               is   null
or l_rec_info_habilitacao.tp_indice_habilitacao               =    0     then
    p_ds_retorno  := 'Tipo de índice da habilitação informada não está cadastrado.';
    raise ex_finalizar_memoria_calculo;
end if;
--
if l_rec_info_habilitacao.vl_hora_habilitacao                 is   null
or l_rec_info_habilitacao.vl_hora_habilitacao                 =    0     then
    p_ds_retorno  :=  'Valor hora da habilitação informada não está cadastrado.#'|| 
                    p_rec_mc_aluno.id_academico || '#' || 
                    l_rec_info_habilitacao.tp_indice_habilitacao;
    raise ex_finalizar_memoria_calculo;
end if;
--
if l_rec_valor_indice_habilitacao.vl_indice                   is   null  
or l_rec_valor_indice_habilitacao.vl_indice                   =    0     then
    p_ds_retorno  := 'Valor do índice da habilitação informada não está cadastrado.#'|| 
                    p_rec_mc_aluno.id_academico || '#' || 
                    l_rec_info_habilitacao.tp_indice_habilitacao;
    raise ex_finalizar_memoria_calculo;
end if;
--
p_rec_mc_aluno.cd_dominio_tipo_calculo_habilitacao    := l_rec_info_habilitacao.cd_dominio_tipo_calculo_habilitacao;
p_rec_mc_aluno.cd_faixa_tipo_calculo_habilitacao      := l_rec_info_habilitacao.cd_faixa_tipo_calculo_habilitacao;
p_rec_mc_aluno.tp_indice_habilitacao                  := l_rec_info_habilitacao.tp_indice_habilitacao;
p_rec_mc_aluno.vl_hora_habilitacao                    := l_rec_info_habilitacao.vl_hora_habilitacao;
p_rec_mc_aluno.vl_indice_habilitacao                  := l_rec_valor_indice_habilitacao.vl_indice;
--
-- Os cálculos serão feitos com os parâmetros dos campos financeiros
-- Obter informações das disciplinas
windex := p_vt_mc_disciplina.first();
while windex is not null loop
-- Validar regras de utilização dos parâmetros
-- cd_faixa_categoria_aluno, cd_faixa_situacao_disciplina e cd_faixa_tipo_cobranca
      begin
      open cr_valida_cobranca( p_cd_faixa_categoria_aluno      =>  p_rec_mc_aluno.cd_faixa_categoria_aluno 
                             , p_cd_faixa_situacao_disciplina  =>  p_vt_mc_disciplina(windex).cd_faixa_situacao_disciplina 
                             , p_cd_tipo_cobranca              =>  p_vt_mc_disciplina(windex).cd_faixa_tipo_cobranca 
                             , p_cd_tipo_calculo               =>  p_rec_mc_aluno.cd_faixa_tipo_calculo );
       fetch cr_valida_cobranca into l_rec_valida_cobranca;
          IF cr_valida_cobranca%NOTFOUND then 
             p_ds_retorno  :=  p_vt_mc_disciplina(windex).cd_disciplina || 
                               ' - Existe incompatibilidade entre modalidade de cálculo financeiro, categoria do aluno, situação da disciplina e tipo de cobrança.';
             raise ex_finalizar_memoria_calculo;
          end if;
        close cr_valida_cobranca;
      exception when others then 
            p_ds_retorno  :=  'Não foi possível acessar as informações sobre a validação da cobrança da disciplina informada.' ||
                              p_vt_mc_disciplina(windex).cd_disciplina || '>' || p_rec_mc_aluno.cd_faixa_categoria_aluno ||  
                              '#' ||  p_vt_mc_disciplina(windex).cd_faixa_situacao_disciplina ||
                              '#' ||  p_vt_mc_disciplina(windex).cd_faixa_tipo_cobranca ||
                              '#' ||  p_rec_mc_aluno.cd_faixa_tipo_calculo;
            raise ex_finalizar_memoria_calculo; 
      end;
--        
-- Atualizar informações financeiras quando a habilitação da disciplina for diferente da habilitação do aluno
      if p_rec_mc_aluno.cd_curso|| '.'|| p_rec_mc_aluno.cd_habilitacao     <> 
         p_vt_mc_disciplina(windex).cd_curso || '.' || p_vt_mc_disciplina(windex).cd_habilitacao  then
            -- Verificar se os parâmetros financeiros da habilitação que ofertou a disciplina estão cadastrados
            -- Informações da habilitação da turma que ofertou a disciplina ( PK_FAT_MC_CLC - c6_habilitacao )
           begin
                open cr_info_habilitacao( p_vt_mc_disciplina(windex).cd_curso 
                                        , p_vt_mc_disciplina(windex).cd_habilitacao );
                fetch cr_info_habilitacao into l_rec_info_habilitacao_disciplina;
                if cr_info_habilitacao%notfound then 
                    p_ds_retorno  := 'Não foram encontradas informações relativas a habilitação da disciplina informada. ' || 
                                     p_vt_mc_disciplina(windex).cd_disciplina || '#' || p_vt_mc_disciplina(windex).cd_curso || '#' || 
                                     p_vt_mc_disciplina(windex).cd_habilitacao;
                    raise ex_finalizar_memoria_calculo;
                end if;
                close cr_info_habilitacao;
            
           exception when others then 
                p_ds_retorno  := 'Não foi possível acessar as informações relativas a habilitação da disciplina informada. ' ||
                                 p_vt_mc_disciplina(windex).cd_disciplina || '#' || p_vt_mc_disciplina(windex).cd_curso || '#' || 
                                 p_vt_mc_disciplina(windex).cd_habilitacao;
                raise ex_finalizar_memoria_calculo;
           end;

           --> Obter tipo de índice da habilitação da turma que ofertou a disciplina - valor do índice  
           l_rec_valor_indice_habilitacao_disciplina.tp_indice  :=  l_rec_info_habilitacao_disciplina.tp_indice_habilitacao;
           p_indice_financeiro( p_rec_mc_aluno.id_academico 
                              , l_rec_valor_indice_habilitacao_disciplina.tp_indice   
                              , p_dt_processamento            
                              , l_rec_valor_indice_habilitacao_disciplina.vl_indice   -- out             
                              , l_dummy2                                              -- out 
                              , l_dummy3  )  ;   
           
           if l_rec_valor_indice_habilitacao_disciplina.tp_indice      is null then 
              p_ds_retorno  := 'Tipo de indice( habilitação da turma que ofertou a disciplina ) não encontrado. #' || 
                               p_rec_mc_aluno.id_academico|| '#' ||
                               l_rec_info_habilitacao_disciplina.tp_indice_habilitacao;
              raise ex_finalizar_memoria_calculo;
           elsif l_rec_valor_indice_habilitacao_disciplina.tp_indice   = 0  then
              p_ds_retorno  := 'Tipo de indice( habilitação da turma que ofertou a disciplina ) igual a zero. #' || 
                               p_rec_mc_aluno.id_academico|| '#' ||
                               l_rec_info_habilitacao_disciplina.tp_indice_habilitacao;
              raise ex_finalizar_memoria_calculo;
           elsif nvl( l_rec_valor_indice_habilitacao_disciplina.vl_indice, 0 )   = 0  then
              p_ds_retorno  := 'Valor do indice( habilitação da turma que ofertou a disciplina ) igual a zero. #' || 
                               p_rec_mc_aluno.id_academico|| '#' ||
                               l_rec_info_habilitacao_disciplina.tp_indice_habilitacao;
              raise ex_finalizar_memoria_calculo;
           end if;



           if l_rec_info_habilitacao_disciplina.cd_faixa_tipo_calculo_habilitacao  is    null 
           or l_rec_info_habilitacao_disciplina.cd_faixa_tipo_calculo_habilitacao  =     0     then
                p_ds_retorno  := 'Tipo de cálculo da habilitação da disciplina não está cadastrado.';
                raise ex_finalizar_memoria_calculo;
           end if;

           if l_rec_info_habilitacao_disciplina.tp_indice_habilitacao        is    null 
           or l_rec_info_habilitacao_disciplina.tp_indice_habilitacao        =     0    then
              p_ds_retorno  := 'Tipo de índice da habilitação da disciplina não está cadastrado.';
              raise ex_finalizar_memoria_calculo;
           end if;

           if l_rec_info_habilitacao_disciplina.vl_hora_habilitacao          is    null 
           or l_rec_info_habilitacao_disciplina.vl_hora_habilitacao          =     0    then
              p_ds_retorno  :=  'Valor hora da habilitação da disciplina não está cadastrada.';
              raise ex_finalizar_memoria_calculo;
           end if;

           if l_rec_valor_indice_habilitacao_disciplina.vl_indice            is     null 
           or l_rec_valor_indice_habilitacao_disciplina.vl_indice            =      0    then
              p_ds_retorno  := 'Valor do índice da habilitação da disciplina não está cadastrado.';
              raise ex_finalizar_memoria_calculo;
           end if;
            
           p_vt_mc_disciplina(windex).cd_dominio_tipo_calculo_hab_disciplina   :=  l_rec_info_habilitacao_disciplina.cd_dominio_tipo_calculo_habilitacao;
           p_vt_mc_disciplina(windex).cd_faixa_tipo_calculo_hab_disciplina     :=  l_rec_info_habilitacao_disciplina.cd_faixa_tipo_calculo_habilitacao;
           p_vt_mc_disciplina(windex).tp_indice_hab_disciplina                 :=  l_rec_info_habilitacao_disciplina.tp_indice_habilitacao;
           p_vt_mc_disciplina(windex).vl_hora_hab_disciplina                   :=  l_rec_info_habilitacao_disciplina.vl_hora_habilitacao;
           p_vt_mc_disciplina(windex).vl_indice_hab_disciplina                 :=  l_rec_valor_indice_habilitacao_disciplina.vl_indice;
        else
           p_vt_mc_disciplina(windex).cd_dominio_tipo_calculo_hab_disciplina   :=  p_rec_mc_aluno.cd_dominio_tipo_calculo;
           p_vt_mc_disciplina(windex).cd_faixa_tipo_calculo_hab_disciplina     :=  p_rec_mc_aluno.cd_faixa_tipo_calculo;
           p_vt_mc_disciplina(windex).tp_indice_hab_disciplina                 :=  p_rec_mc_aluno.tp_indice_habilitacao;
           p_vt_mc_disciplina(windex).vl_hora_hab_disciplina                   :=  p_rec_mc_aluno.vl_hora_habilitacao;
           p_vt_mc_disciplina(windex).vl_indice_hab_disciplina                 :=  p_rec_mc_aluno.vl_indice_habilitacao;
        end if;
       
        -- Formatação das mensagens para a disciplina
        open cr_mensagens_disciplinas( p_rec_mc_aluno.cd_faixa_tipo_calculo 
                                     , p_vt_mc_disciplina(windex).cd_dominio_situacao_disciplina 
                                     , p_vt_mc_disciplina(windex).cd_faixa_situacao_disciplina 
                                     , p_vt_mc_disciplina(windex).nr_carga_horaria 
                                     , p_vt_mc_disciplina(windex).nr_carga_horaria_sem_onus 
                                     , p_vt_mc_disciplina(windex).cd_disciplina_equivalente );
        fetch cr_mensagens_disciplinas into p_vt_mc_disciplina(windex).ds_situacao_disciplina 
                                          , p_vt_mc_disciplina(windex).ds_complemento_situacao
                                          , p_vt_mc_disciplina(windex).ds_disciplina_equivalente ;
        close cr_mensagens_disciplinas;
        --
        /* *** IMPLEMENTAÇÃO PENDENTE 
        -- Verificar se existe ocorrência de validação de regra para alguma das disciplinas
        -- e se foi informada ocorrência para o aluno
        */
        windex := p_vt_mc_disciplina.NEXT(windex);
    end loop;
    
    p_fg_retorno   := 'S';
exception 
   when ex_finalizar_memoria_calculo  then
        p_fg_retorno    := 'N';
END p_buscar_informacoes;
    -- 
    -----------------------------------------------------------------------------
/*
PROCEDURE: P_CALCULO_CREDITOS
DESENVOLVEDOR: Lucas 
OBJETIVO: Cálculo do valor das disciplinas considerando o código da
          situação financeira.

          Modalidade créditos - converter as quantidades de créditos acadêmicos práticos
          e téoricos para créditos financeiros.

          Modalidade mensalista - o valor da disciplina não será apresentado individualmente
          será mostrado o valor total da semestralidade.

PARÂMETROS:
    1 - p_fg_exibir
    2 - p_array_aluno
    3 - p_array_disciplina 
*/
-- -----------------------------------------------------------------------------
procedure p_calculo_creditos( p_rec_mc_aluno           in out nocopy ca.pk_fat_mc_plt.rec_mc_aluno 
                            , p_vt_mc_disciplina       in out nocopy ca.pk_fat_mc_plt.ar_mc_disciplina 
                            , p_fg_exibir              in varchar2   
                            , p_fg_retorno             out    varchar2
                            , p_ds_retorno             out    varchar2 )is
--
cursor cursor_descricao_cobranca( p_cd_faixa_tipo_cobranca    number 
                                , p_nr_creditos_teoricos      number 
                                , p_nr_creditos_praticos      number 
                                , p_pc_csa_clb                number 
                                , p_vl_indice_aluno           number ) is
-- CI 36812/20 >>>
select case
       when p_cd_faixa_tipo_cobranca = 5 then
            'Disciplina a ser cursada sem ônus.'
       else
            case
            when p_nr_creditos_teoricos > 0
             and p_nr_creditos_praticos > 0 then
                'Cobrada por quantidade de créditos práticos e teóricos da disciplina:'
                || ' (( Créditos teóricos + ( '
                || trim(to_char(p_pc_csa_clb,'90D99MI','NLS_NUMERIC_CHARACTERS = '',.'' '))
                || ' * Créditos práticos )) * Índice financeiro do aluno ) = '
                || '(( '
                || p_nr_creditos_teoricos
                || ' + '
                || '( '
                || trim(to_char(p_pc_csa_clb,'90D99MI','NLS_NUMERIC_CHARACTERS = '',.'' '))
                || ' * '
                || p_nr_creditos_praticos
                || ' )) * '
                || trim(to_char(p_vl_indice_aluno,'L999G999G990D99MI','NLS_NUMERIC_CHARACTERS = '',.'' NLS_CURRENCY = ''R$'' '
                ))
                || ' ).'
            when p_nr_creditos_teoricos > 0
             and p_nr_creditos_praticos = 0 then
                'Cobrada por quantidade de créditos práticos e teóricos da disciplina:'
                || ' (( Créditos teóricos + ( '
                || trim(to_char(p_pc_csa_clb,'90D99MI','NLS_NUMERIC_CHARACTERS = '',.'' '))
                || ' * Créditos práticos )) * Índice financeiro do aluno ) = '
                || '(( '
                || p_nr_creditos_teoricos
                || ' + '
                || '( '
                || trim(to_char(p_pc_csa_clb,'90D99MI','NLS_NUMERIC_CHARACTERS = '',.'' '))
                || ' * '
                || p_nr_creditos_praticos
                || ' )) * '
                || trim(to_char(p_vl_indice_aluno,'L999G999G990D99MI','NLS_NUMERIC_CHARACTERS = '',.'' NLS_CURRENCY = ''R$ '' '
                ))
                || ' ).'
            when p_nr_creditos_teoricos = 0
             and p_nr_creditos_praticos > 0 then
                'Cobrada por quantidade de créditos práticos e teóricos da disciplina:'
                || ' (( Créditos teóricos + ( '
                || trim(to_char(p_pc_csa_clb,'90D99MI','NLS_NUMERIC_CHARACTERS = '',.'' '))
                || ' * Créditos práticos )) * Índice financeiro do aluno ) = '
                || '(( '
                || p_nr_creditos_teoricos
                || ' + '
                || '( '
                || trim(to_char(p_pc_csa_clb,'90D99MI','NLS_NUMERIC_CHARACTERS = '',.'' '))
                || ' * '
                || p_nr_creditos_praticos
                || ' )) * '
                || trim(to_char(p_vl_indice_aluno,'L999G999G990D99MI','NLS_NUMERIC_CHARACTERS = '',.'' NLS_CURRENCY = ''R$ '' '
                ))
                || ' ).'
            end
     end descricao_cobranca
from dual;
--
wcursor_descricao_cobranca  cursor_descricao_cobranca%ROWTYPE;
--
windex                       number;
wvl_indice_aluno             number;
vl_id_grupo_disciplina       number;
wvl_sem_onus                 number;
--    
begin
--
    vl_id_grupo_disciplina := 0;
    wvl_sem_onus := 0;

    wvl_indice_aluno := p_rec_mc_aluno.vl_indice;
    if p_rec_mc_aluno.cd_faixa_tipo_calculo = 1 then
    -- Cálculo por crédito
        windex := p_vt_mc_disciplina.first();
        while(windex is not null)loop

            p_vt_mc_disciplina(windex).ds_referencia_academica    :=  p_vt_mc_disciplina(windex).nr_creditos_teoricos || '.' ||
                                                                      p_vt_mc_disciplina(windex).nr_creditos_praticos; 

            p_vt_mc_disciplina(windex).nr_conversao_acad_finan    :=  (p_vt_mc_disciplina(windex).nr_creditos_teoricos +
                                                                      (gc_pc_csa_clb * p_vt_mc_disciplina(windex).nr_creditos_praticos));
            
            IF p_vt_mc_disciplina(windex).cd_faixa_tipo_cobranca  =   5 then
            -- Disciplina sem Onus  -- CD_Dominio = 610 
                -- CI 36812/20 >>>
                -- Algumas informações de custo da disciplina deverão se preservadas  
                p_vt_mc_disciplina(windex).nr_unidade_financeira  :=  (p_vt_mc_disciplina(windex).nr_creditos_teoricos +
                                                                      (gc_pc_csa_clb * p_vt_mc_disciplina(windex).nr_creditos_praticos));

                p_vt_mc_disciplina(windex).vl_indice_disciplina   :=  wvl_indice_aluno;
                p_vt_mc_disciplina(windex).vl_disciplina          :=  TRUNC((p_vt_mc_disciplina(windex).nr_unidade_financeira * wvl_indice_aluno),2);

                p_rec_mc_aluno.vl_financeiro                      :=  p_rec_mc_aluno.vl_financeiro  
                                                                  +   p_vt_mc_disciplina(windex).vl_disciplina;
                p_rec_mc_aluno.un_financeiro                      :=  p_rec_mc_aluno.un_financeiro 
                                                                  +   p_vt_mc_disciplina(windex).nr_unidade_financeira;
                -- Incluir o registro da modalidade de desconto da disciplina - c8_disciplina_sem_onus
                p_vt_mc_disciplina(windex).ds_valor_cobranca      :=  TRIM(TO_CHAR(wvl_sem_onus,'L999G999G990D99MI','NLS_NUMERIC_CHARACTERS = '',.'' NLS_CURRENCY = ''R$ '' '));
                --
                -- ** as unidades financeiras da disciplina sem ônus será desconsiderada no cálculo da parcela
            else          
                p_vt_mc_disciplina(windex).nr_unidade_financeira  :=  p_vt_mc_disciplina(windex).nr_creditos_teoricos +
                                                                      (gc_pc_csa_clb * p_vt_mc_disciplina(windex).nr_creditos_praticos);

                p_vt_mc_disciplina(windex).vl_indice_disciplina   :=  wvl_indice_aluno;
                
                p_vt_mc_disciplina(windex).vl_disciplina          :=  trunc((p_vt_mc_disciplina(windex).nr_unidade_financeira * wvl_indice_aluno),2);

                p_rec_mc_aluno.vl_financeiro                      :=  p_rec_mc_aluno.vl_financeiro 
                                                                  +   p_vt_mc_disciplina(windex).vl_disciplina;
                p_rec_mc_aluno.un_financeiro                      :=  p_rec_mc_aluno.un_financeiro 
                                                                  +   p_vt_mc_disciplina(windex).nr_unidade_financeira; 

                p_vt_mc_disciplina(windex).ds_valor_cobranca      :=  trim(to_char(p_vt_mc_disciplina(windex).vl_disciplina,'L999G999G990D99MI','NLS_NUMERIC_CHARACTERS = '',.'' NLS_CURRENCY = ''R$ '' '));

            end if;

            begin
                open cursor_descricao_cobranca( p_cd_faixa_tipo_cobranca    =>  p_vt_mc_disciplina(windex).cd_faixa_tipo_cobranca 
                                              , p_nr_creditos_teoricos      =>  p_vt_mc_disciplina(windex).nr_creditos_teoricos 
                                              , p_nr_creditos_praticos      =>  p_vt_mc_disciplina(windex).nr_creditos_praticos 
                                              , p_pc_csa_clb                =>  gc_pc_csa_clb 
                                              , p_vl_indice_aluno           =>  wvl_indice_aluno );
                fetch cursor_descricao_cobranca INTO wcursor_descricao_cobranca;
                close cursor_descricao_cobranca;
                
                p_vt_mc_disciplina(windex).ds_cobranca            := wcursor_descricao_cobranca.descricao_cobranca; 
                
                if p_fg_exibir                                    =  'S' then
                   g_rec_fat_mc_log1.ds_log1 := '------------' || chr(10) || 
                                                'Disciplina: '                || p_vt_mc_disciplina(windex).cd_disciplina  || chr(10) || 
                                                'Turma da disciplina:'        || p_vt_mc_disciplina(windex).cd_turma       || chr(10) ||
                                                'Curso da disciplina: '       || p_vt_mc_disciplina(windex).cd_curso       || chr(10) ||
                                                'Habilitação da disciplina: ' || p_vt_mc_disciplina(windex).cd_habilitacao || chr(10) ||
                                                'Descrição da cobrança: '     || p_vt_mc_disciplina(windex).ds_cobranca;
                   dbms_output.put_line(g_rec_fat_mc_log1.ds_log1);                     
                   g_rec_fat_mc_log1.id_log1                  :=  null;
                   g_rec_fat_mc_log1.id_financeiro            :=  p_rec_mc_aluno.id_financeiro;
                   g_rec_fat_mc_log1.nr_matricula             :=  p_rec_mc_aluno.nr_matricula;
                   g_rec_fat_mc_log1.id_mc_aluno              :=  p_rec_mc_aluno.id_mc_aluno; 
                   pk_fat_mc_dml.p_add_fat_mc_log1( g_rec_fat_mc_log1    
                                                  , g_fg_retorno_log    
                                                  , g_ds_retorno_log  )  ;  

                end if;
            exception when others then
                if cursor_descricao_cobranca%isopen then
                    close cursor_descricao_cobranca;
                end if;
                p_ds_retorno := 'P_calculo_creditos: Não foi possível obter as informações sobre a descrição de cobrança.';
                raise ex_erro_memoria_calculo;
            end;
        
            vl_id_grupo_disciplina                                := vl_id_grupo_disciplina + 1;
            p_vt_mc_disciplina(windex).id_grupo_disciplina        := vl_id_grupo_disciplina;

            windex := p_vt_mc_disciplina.next(windex);
        end loop;

    else
        p_ds_retorno := 'P_calculo_creditos: Modalidade de cálculo não prevista.';
        raise ex_erro_memoria_calculo;
    end if;
    
    p_fg_retorno := 'S';    
exception 
  when ex_erro_memoria_calculo then
       p_fg_retorno := 'N';
end p_calculo_creditos;

-- 
-- -----------------------------------------------------------------------------
/*
PROCEDURE: P_CALCULO_CREDITOS
DESENVOLVEDOR: Lucas 
OBJETIVO: Cálculo do valor da disciplina cobrada pelo valor da hora da
          habilitação do aluno.

PARÂMETROS:
    1 - p_rec_mc_aluno
    2 - p_vt_mc_disciplina
    3 - p_fg_exibir 
    4 - p_index
    5 - p_fg_retorno 
    6 - p_ds_retorno
*/
-- -----------------------------------------------------------------------------
procedure p_valor_habilitacao_aluno( p_rec_mc_aluno      in  out nocopy ca.pk_fat_mc_plt.rec_mc_aluno 
                                   , p_vt_mc_disciplina  in  out nocopy ca.pk_fat_mc_plt.ar_mc_disciplina 
                                   , p_fg_exibir         in  varchar2 
                                   , p_index             in  number 
                                   , p_fg_retorno        out varchar2
                                   , p_ds_retorno        out varchar2) is
--
wnr_unidades              NUMBER;
wnr_unidades_dif          NUMBER;
wnr_unidades_disciplina   NUMBER;
--
wvl_indice_aluno            ca.fat_valor_indice.vl_indice%TYPE;
wvl_hora_aluno              ca.habilitacao.vl_hora%TYPE;
--
BEGIN
--
    wnr_unidades_dif := 0;

    wvl_indice_aluno := p_rec_mc_aluno.vl_indice;
    wvl_hora_aluno := p_rec_mc_aluno.vl_hora_habilitacao;

    -- o cálculo considera que a cobrança será sempre pela carga horária da disciplina
    -- sem a conversão dos créditos praticos, independente do tipo de cálculo da oferta
    p_vt_mc_disciplina(p_index).ds_referencia_academica := p_vt_mc_disciplina(p_index).nr_carga_horaria;
    
    if p_vt_mc_disciplina(p_index).cd_faixa_tipo_calculo_hab_disciplina = 1 then
        p_vt_mc_disciplina(p_index).nr_conversao_acad_finan := p_vt_mc_disciplina(p_index).nr_carga_horaria;
        wnr_unidades := TRUNC((wvl_hora_aluno * (p_vt_mc_disciplina(p_index).nr_conversao_acad_finan)) / wvl_indice_aluno, 4);
    elsif p_vt_mc_disciplina(p_index).cd_faixa_tipo_calculo_hab_disciplina = 2 then
        p_vt_mc_disciplina(p_index).nr_conversao_acad_finan := p_vt_mc_disciplina(p_index).nr_carga_horaria;
        wnr_unidades := TRUNC((wvl_hora_aluno * (p_vt_mc_disciplina(p_index).nr_conversao_acad_finan)) / wvl_indice_aluno,4);
    else
        p_ds_retorno  := 'p_valor_habilitacao_aluno: ' || 
                          p_vt_mc_disciplina(p_index).cd_faixa_tipo_calculo_hab_disciplina ||
                          ' - Tipo de cálculo da habilitação da oferta não previsto.';
        raise ex_erro_memoria_calculo;
    end if;

    p_vt_mc_disciplina(p_index).nr_unidade_financeira := wnr_unidades;
    p_vt_mc_disciplina(p_index).vl_indice_disciplina  := wvl_indice_aluno;
    p_vt_mc_disciplina(p_index).vl_disciplina         := trunc((wnr_unidades * wvl_indice_aluno),2);

    p_rec_mc_aluno.vl_financeiro                    := p_rec_mc_aluno.vl_financeiro 
                                                      +  p_vt_mc_disciplina(p_index).vl_disciplina;
    p_rec_mc_aluno.un_financeiro                    := p_rec_mc_aluno.un_financeiro 
                                                      +  p_vt_mc_disciplina(p_index).nr_unidade_financeira;

    IF p_vt_mc_disciplina(p_index).nr_unidade_financeira = 0 then
        p_vt_mc_disciplina(p_index).ds_valor_cobranca := '-';
        p_vt_mc_disciplina(p_index).ds_cobranca       := 'Disciplina com carga horária sem ônus.';
    else
        p_vt_mc_disciplina(p_index).ds_valor_cobranca := trim(to_char(p_vt_mc_disciplina(p_index).vl_disciplina,'L999G999G990D99MI','NLS_NUMERIC_CHARACTERS = '',.'' NLS_CURRENCY = ''R$ '' '));
        if p_vt_mc_disciplina(p_index).nr_carga_horaria_sem_onus > 0 then
            p_vt_mc_disciplina(p_index).ds_cobranca := 'Cobrada por quantidade de carga horária com o valor da hora da habilitação do aluno:'
                                                         || ' ( Carga horária excedente * Valor da hora ) = ( '
                                                         || to_char(p_vt_mc_disciplina(p_index).nr_conversao_acad_finan - nvl
                                                         (p_vt_mc_disciplina(p_index).nr_carga_horaria_sem_onus,0))
                                                         || ' * '
                                                         || trim(to_char(wvl_hora_aluno,'L999G999G990D99MI','NLS_NUMERIC_CHARACTERS = '',.'' NLS_CURRENCY = ''R$'' '
                                                         ))
                                                         || ' ).';

        else
            p_vt_mc_disciplina(p_index).ds_cobranca := 'Cobrada por quantidade de carga horária com o valor da hora da habilitação do aluno:'
                                                         || ' ( Carga horária * Valor da hora ) = ( '
                                                         || p_vt_mc_disciplina(p_index).nr_conversao_acad_finan
                                                         || ' * '
                                                         || trim(to_char(wvl_hora_aluno,'L999G999G990D99MI','NLS_NUMERIC_CHARACTERS = '',.'' NLS_CURRENCY = ''R$'' '
                                                         ))
                                                         || ' ).';
        end if;
    end if;
    
    if p_fg_exibir   =  'S' then
       g_rec_fat_mc_log1.ds_log1 := 'Disciplina: ' || p_vt_mc_disciplina(p_index).cd_disciplina || chr(10) || 
                                    'Turma da disciplina:' || p_vt_mc_disciplina(p_index).cd_turma || chr(10) ||
                                    'Curso da disciplina: ' || p_vt_mc_disciplina(p_index).cd_curso || chr(10) ||
                                    'Habilitação da disciplina: ' || p_vt_mc_disciplina(p_index).cd_habilitacao || chr(10) ||
                                    'Descrição da cobrança: ' || p_vt_mc_disciplina(p_index).ds_cobranca;
       dbms_output.put_line(g_rec_fat_mc_log1.ds_log1);
       g_rec_fat_mc_log1.id_log1                  :=  null;
       g_rec_fat_mc_log1.id_financeiro            :=  p_rec_mc_aluno.id_financeiro;
       g_rec_fat_mc_log1.nr_matricula             :=  p_rec_mc_aluno.nr_matricula;
       g_rec_fat_mc_log1.id_mc_aluno              :=  p_rec_mc_aluno.id_mc_aluno; 
       pk_fat_mc_dml.p_add_fat_mc_log1( g_rec_fat_mc_log1    
                                      , g_fg_retorno_log    
                                      , g_ds_retorno_log  )  ; 
    end if;
    
    p_fg_retorno := 'S';    
exception 
  when ex_erro_memoria_calculo then
       p_fg_retorno := 'N';
END p_valor_habilitacao_aluno;

-- 
-----------------------------------------------------------------------------
/*
PROCEDURE: P_VALOR_HABILITACAO_OFERTA
DESENVOLVEDOR: Lucas 
OBJETIVO: Cálculo do valor da disciplina cobrada pelo valor da hora da
          habilitação do curso que ofertou. 
PARÂMETROS:
    1 - p_rec_mc_aluno
    2 - p_vt_mc_disciplina
    3 - p_fg_exibir 
    4 - p_index
    5 - p_fg_retorno 
    6 - p_ds_retorno
*/
-- -----------------------------------------------------------------------------
procedure p_valor_habilitacao_oferta( p_rec_mc_aluno            in out nocopy ca.pk_fat_mc_plt.rec_mc_aluno 
                                    , p_vt_mc_disciplina        in out nocopy ca.pk_fat_mc_plt.ar_mc_disciplina 
                                    , p_fg_exibir               in     varchar2  
                                    , p_index                   in     number 
                                    , p_fg_retorno              out    varchar2
                                    , p_ds_retorno              out    varchar2) is
--
cursor cursor_descricao_cobranca(   p_cd_curso                  NUMBER,
                                    p_cd_habilitacao            NUMBER,
                                    p_nr_creditos_teoricos      NUMBER,
                                    p_nr_creditos_praticos      NUMBER,
                                    p_vl_hora_hab_disciplina    NUMBER,
                                    p_pc_csa_clb                NUMBER,
                                    p_carga_horaria_teorica     NUMBER,
                                    p_carga_horaria_pratica     NUMBER) IS 
select 'Cobrada por quantidade de carga horária com o valor da hora da habilitação da oferta (' || 
       trim(to_char(p_cd_curso,'0000'))     ||  '.' || 
       trim(to_char(p_cd_habilitacao,'00')) ||  '):'|| 
       case
            when p_nr_creditos_teoricos         >    0
             and p_nr_creditos_praticos         =    0 then
                 ' ( Carga horária teórica * Valor da hora ) = ( '|| 
                 to_char(p_carga_horaria_teorica) || ' * ' || 
                 trim(to_char(p_vl_hora_hab_disciplina,'L999G999G990D99MI' ,'NLS_NUMERIC_CHARACTERS = '',.'' NLS_CURRENCY = ''R$'' ')) || ' ).'
            when p_nr_creditos_teoricos         =    0
             and p_nr_creditos_praticos         >    0 then
                 ' ( Carga horária prática * Valor da hora * '
                 || TRIM(to_char(p_pc_csa_clb,'90D99MI','NLS_NUMERIC_CHARACTERS = '',.'' '))
                 || ' ) = ( '
                 || to_char(p_carga_horaria_pratica)
                 || ' * '
                 || TRIM(to_char(p_vl_hora_hab_disciplina,'L999G999G990D99MI','NLS_NUMERIC_CHARACTERS = '',.'' NLS_CURRENCY = ''R$'' '))
                 || ' * '
                 || TRIM(to_char(p_pc_csa_clb,'90D99MI','NLS_NUMERIC_CHARACTERS = '',.'' '))
                 || ' ).'
            when p_nr_creditos_teoricos         >   0
             and p_nr_creditos_praticos         >   0 then
                 ' (( Carga horária teórica * Valor da hora ) + ( Carga horária prática * Valor da hora * '
                 || TRIM(to_char(p_pc_csa_clb,'90D99MI','NLS_NUMERIC_CHARACTERS = '',.'' '))
                 || ' )) = (( '
                 || to_char(p_carga_horaria_teorica)
                 || ' * '
                 || TRIM(to_char(p_vl_hora_hab_disciplina,'L999G999G990D99MI' ,'NLS_NUMERIC_CHARACTERS = '',.'' NLS_CURRENCY = ''R$'' '))
                 || ' ) + ( '
                 || to_char(p_carga_horaria_pratica)
                 || ' * '
                 || TRIM(to_char(p_vl_hora_hab_disciplina,'L999G999G990D99MI', 'NLS_NUMERIC_CHARACTERS = '',.'' NLS_CURRENCY = ''R$'' '))
                 || ' * '
                 || TRIM(to_char(p_pc_csa_clb,'90D99MI','NLS_NUMERIC_CHARACTERS = '',.'' '))
                 || ' )).'
            else
                 ' '
        end descricao_cobranca
from dual;
--
wcursor_descricao_cobranca  cursor_descricao_cobranca%ROWTYPE;
--
wnr_unidades            number;
wvl_indice_aluno        ca.fat_valor_indice.vl_indice%type;
wcarga_horaria_teorica  number;
wcarga_horaria_pratica  number;
--
begin
--
--dbms_output.put_line( '>>>>>  p_valor_habilitacao_oferta' );
wvl_indice_aluno := p_rec_mc_aluno.vl_indice;
p_vt_mc_disciplina(p_index).ds_referencia_academica := p_vt_mc_disciplina(p_index).nr_carga_horaria;
--
-- Ver tipo de cálculo da habilitação que ofertou - se for crédito o cálculo deverá ser feito pela proporção de csa+(1.25*clb)
if p_vt_mc_disciplina(p_index).cd_faixa_tipo_calculo_hab_disciplina = 1 then
    wcarga_horaria_teorica :=   (p_vt_mc_disciplina(p_index).nr_carga_horaria * p_vt_mc_disciplina(p_index).nr_creditos_teoricos)/
                                (p_vt_mc_disciplina(p_index).nr_creditos_teoricos + p_vt_mc_disciplina(p_index).nr_creditos_praticos);

    wcarga_horaria_pratica :=   (p_vt_mc_disciplina(p_index).nr_carga_horaria - wcarga_horaria_teorica);
    p_vt_mc_disciplina(p_index).nr_conversao_acad_finan :=  (wcarga_horaria_teorica +(gc_pc_csa_clb * wcarga_horaria_pratica));
    wnr_unidades := trunc(((p_vt_mc_disciplina(p_index).vl_hora_hab_disciplina *
                            (p_vt_mc_disciplina(p_index).nr_conversao_acad_finan)) / wvl_indice_aluno),4);
elsif p_vt_mc_disciplina(p_index).cd_faixa_tipo_calculo_hab_disciplina = 2 then
    p_vt_mc_disciplina(p_index).nr_conversao_acad_finan := p_vt_mc_disciplina(p_index).nr_carga_horaria;
    
    wnr_unidades := TRUNC((p_vt_mc_disciplina(p_index).vl_hora_hab_disciplina *
                            (p_vt_mc_disciplina(p_index).nr_conversao_acad_finan)) / wvl_indice_aluno,4);
else
   p_ds_retorno  := 'p_valor_habilitacao_oferta: ' ||
                     p_vt_mc_disciplina(p_index).cd_disciplina ||
                     ' - Tipo de cálculo da habilitação da oferta não previsto.';
   raise ex_erro_memoria_calculo;
end if;

p_vt_mc_disciplina(p_index).nr_unidade_financeira := wnr_unidades;
p_vt_mc_disciplina(p_index).vl_indice_disciplina  := wvl_indice_aluno;
p_vt_mc_disciplina(p_index).vl_disciplina         := trunc((p_vt_mc_disciplina(p_index).nr_unidade_financeira 
                                                  *  wvl_indice_aluno),2);

p_rec_mc_aluno.vl_financeiro                    := p_rec_mc_aluno.vl_financeiro 
                                                  +  p_vt_mc_disciplina(p_index).vl_disciplina;
p_rec_mc_aluno.un_financeiro                    := p_rec_mc_aluno.un_financeiro 
                                                  +  p_vt_mc_disciplina(p_index).nr_unidade_financeira;


--dbms_output.put_line( '  1 vl_financeiro:' || p_rec_mc_aluno.vl_financeiro );
if  p_vt_mc_disciplina(p_index).nr_unidade_financeira = 0 then
    p_vt_mc_disciplina(p_index).ds_valor_cobranca    := '-';
    p_vt_mc_disciplina(p_index).ds_cobranca          := 'Desciplina com carga horária sem ônus.';
else
    if p_vt_mc_disciplina(p_index).vl_disciplina      > 0 then
        p_vt_mc_disciplina(p_index).ds_valor_cobranca := trim(to_char(p_vt_mc_disciplina(p_index).vl_disciplina,'L999G999G990D99MI','NLS_NUMERIC_CHARACTERS = '',.'' NLS_CURRENCY = ''R$ '' '));

        if p_vt_mc_disciplina(p_index).nr_carga_horaria_sem_onus > 0 then
            p_vt_mc_disciplina(p_index).ds_cobranca := 'Cobrada por quantidade de carga horária com o valor da hora da habilitação da oferta:'
                                                         || ' ( Carga horária excedente * Valor da hora ) = ( '
                                                         || to_char(p_vt_mc_disciplina(p_index).nr_conversao_acad_finan
                                                         )
                                                         || ' * '
                                                         || trim(to_char(p_vt_mc_disciplina(p_index).vl_hora_hab_disciplina
                                                         ,'L999G999G990D99MI','NLS_NUMERIC_CHARACTERS = '',.'' NLS_CURRENCY = ''R$'' '
                                                         ))
                                                         || ' ).';

        else
            if p_vt_mc_disciplina(p_index).cd_faixa_tipo_calculo_hab_disciplina = 1 then
                if p_vt_mc_disciplina(p_index).nr_conversao_acad_finan <> p_vt_mc_disciplina(p_index).nr_carga_horaria then
                    begin
                        open cursor_descricao_cobranca( p_cd_curso                  =>  p_vt_mc_disciplina(p_index).cd_curso,
                                                        p_cd_habilitacao            =>  p_vt_mc_disciplina(p_index).cd_habilitacao,
                                                        p_nr_creditos_teoricos      =>  p_vt_mc_disciplina(p_index).nr_creditos_teoricos,
                                                        p_nr_creditos_praticos      =>  p_vt_mc_disciplina(p_index).nr_creditos_praticos,
                                                        p_vl_hora_hab_disciplina    =>  p_vt_mc_disciplina(p_index).vl_hora_hab_disciplina,
                                                        p_pc_csa_clb                =>  gc_pc_csa_clb,
                                                        p_carga_horaria_teorica     =>  wcarga_horaria_teorica,
                                                        p_carga_horaria_pratica     =>  wcarga_horaria_pratica);
                        fetch cursor_descricao_cobranca into wcursor_descricao_cobranca;
                        close cursor_descricao_cobranca;
                        
                        p_vt_mc_disciplina(p_index).ds_cobranca :=  wcursor_descricao_cobranca.descricao_cobranca;
                    exception when others then
                        if cursor_descricao_cobranca%isopen then
                            close cursor_descricao_cobranca;
                        end if;
                    end;
                else
                    -- Disciplina só téorica
                    p_vt_mc_disciplina(p_index).ds_cobranca := 'Cobrada por carga horária com o valor da hora da habilitação da oferta ('
                                                                 || trim(to_char(p_vt_mc_disciplina(p_index).cd_curso,'0000'
                                                                 ))
                                                                 || '.'
                                                                 || trim(to_char(p_vt_mc_disciplina(p_index).cd_habilitacao
                                                                 ,'00'))
                                                                 || '):'
                                                                 || ' ( Carga horária teórica * Valor da hora ) = ( '
                                                                 || to_char(wcarga_horaria_teorica)
                                                                 || ' * '
                                                                 || trim(to_char(p_vt_mc_disciplina(p_index).vl_hora_hab_disciplina
                                                                 ,'L999G999G990D99MI','NLS_NUMERIC_CHARACTERS = '',.'' NLS_CURRENCY = ''R$'' '
                                                                 ))
                                                                 || ' ).';
                end if;

            else
                p_vt_mc_disciplina(p_index).ds_cobranca := 'Cobrada por carga horária com o valor da hora da habilitação da oferta ('
                                                             || trim(to_char(p_vt_mc_disciplina(p_index).cd_curso,'0000'
                                                             ))
                                                             || '.'
                                                             || trim(to_char(p_vt_mc_disciplina(p_index).cd_habilitacao
                                                             ,'00'))
                                                             || '):'
                                                             || ' ( Carga horária * Valor da hora ) = ( '
                                                             || p_vt_mc_disciplina(p_index).nr_conversao_acad_finan
                                                             || ' * '
                                                             || trim(to_char(p_vt_mc_disciplina(p_index).vl_hora_hab_disciplina
                                                             ,'L999G999G990D99MI','NLS_NUMERIC_CHARACTERS = '',.'' NLS_CURRENCY = ''R$'' '
                                                             ))
                                                             || ' ).';
            end if;
        end if;
    end if;
end if;

if p_fg_exibir   =  'S' then
   g_rec_fat_mc_log1.ds_log1 := 'Disciplina: '                || p_vt_mc_disciplina(p_index).cd_disciplina  || chr(10) || 
                                'Turma da disciplina:'        || p_vt_mc_disciplina(p_index).cd_turma       || chr(10) ||
                                'Curso da disciplina: '       || p_vt_mc_disciplina(p_index).cd_curso       || chr(10) ||
                                'Habilitação da disciplina: ' || p_vt_mc_disciplina(p_index).cd_habilitacao || chr(10) ||
                                'Descrição da cobrança: '     || p_vt_mc_disciplina(p_index).ds_cobranca;
   dbms_output.put_line(g_rec_fat_mc_log1.ds_log1);
   g_rec_fat_mc_log1.id_log1                  :=  null;
   g_rec_fat_mc_log1.id_financeiro            :=  p_rec_mc_aluno.id_financeiro;
   g_rec_fat_mc_log1.nr_matricula             :=  p_rec_mc_aluno.nr_matricula;
   g_rec_fat_mc_log1.id_mc_aluno              :=  p_rec_mc_aluno.id_mc_aluno; 
   pk_fat_mc_dml.p_add_fat_mc_log1( g_rec_fat_mc_log1    
                                  , g_fg_retorno_log    
                                  , g_ds_retorno_log  )  ;  
end if;
--
p_fg_retorno := 'S';    
--
exception 
  when ex_erro_memoria_calculo then
       p_fg_retorno := 'N';
                      
end p_valor_habilitacao_oferta;
 
    -- 
    -----------------------------------------------------------------------------
/*
PROCEDURE: P_VALOR_MENSALIDADE
DESENVOLVEDOR: Lucas 
OBJETIVO: Cálculo do valor da disciplina do semestre de referência para alunos das
          categorias 'Padrão' e 'Padrão com dependência'.

          As disciplinas do semestre de referência serão agrupadas e o valor apresentado
          para o conjunto.
PARÂMETROS:
    1 - p_rec_mc_aluno
    2 - p_vt_mc_disciplina
    3 - p_fg_exibir 
    4 - p_index
    5 - p_nr_carga_horaria_total
    6 - p_index_ultima_disciplina_padrao
    7 - p_nr_acumulado_unidades
    8 - p_fg_retorno
    9 - p_ds_retorno
*/
    -- -----------------------------------------------------------------------------
procedure p_valor_mensalidade( p_rec_mc_aluno                      in out nocopy ca.pk_fat_mc_plt.rec_mc_aluno 
                             , p_vt_mc_disciplina                  in out nocopy ca.pk_fat_mc_plt.ar_mc_disciplina 
                             , p_fg_exibir                         in     varchar2   
                             , p_index                             in     number
                             , p_nr_carga_horaria_total            in     number
                             , p_index_ultima_disciplina_padrao    in     number
                             , p_nr_acumulado_unidades             in     out nocopy number
                             , p_fg_retorno                        out    varchar2
                             , p_ds_retorno                        out    varchar2 ) is 
--
wnr_unidades_disciplina           number;
--
begin 
--
wnr_unidades_disciplina := 0;
p_vt_mc_disciplina(p_index).ds_referencia_academica :=  p_vt_mc_disciplina(p_index).nr_carga_horaria;
p_vt_mc_disciplina(p_index).nr_conversao_acad_finan :=  p_vt_mc_disciplina(p_index).nr_carga_horaria;
--
wnr_unidades_disciplina :=  trunc(((g_nr_unidades_semestre / p_nr_carga_horaria_total) 
                             *   p_vt_mc_disciplina(p_index).nr_carga_horaria),4);
p_nr_acumulado_unidades :=  p_nr_acumulado_unidades 
                             +   wnr_unidades_disciplina;

-- Acrescentar a diferença na última disciplina
if  p_index_ultima_disciplina_padrao = p_index then
  wnr_unidades_disciplina :=  wnr_unidades_disciplina 
                               +   (g_nr_unidades_semestre - p_nr_acumulado_unidades); 
end if;

p_vt_mc_disciplina(p_index).nr_unidade_financeira   :=  wnr_unidades_disciplina;

-- O valor de custo da disciplina será cálculado pelo índice do financeiro
-- e não pelo da disciplina p_array_disciplina(windex).vl_indice_hab_disciplina
p_vt_mc_disciplina(p_index).vl_disciplina           :=  trunc((p_rec_mc_aluno.vl_indice 
                                                  *   p_vt_mc_disciplina(p_index).nr_unidade_financeira),2);

-- dbms_output.put_line( 'vl_indice:'|| p_rec_mc_aluno.vl_indice || chr(10) ||
--                      '**nr_unidade_financeira:'|| p_vt_mc_disciplina(p_index).nr_unidade_financeira);
p_vt_mc_disciplina(p_index).ds_valor_cobranca       :=  trim(to_char((g_nr_unidades_semestre 
                                                  *   p_rec_mc_aluno.vl_indice),'L999G999G990D99MI','NLS_NUMERIC_CHARACTERS = '',.'' NLS_CURRENCY = ''R$ '' '));
  
p_vt_mc_disciplina(p_index).ds_cobranca             := 'Incluído no valor das mensalidades do semestre: ' || g_nr_unidades_semestre    ||
                                                     ' vezes ' || 
                                                     trim(to_char(p_rec_mc_aluno.vl_indice,'L999G999G990D99MI' ,'NLS_NUMERIC_CHARACTERS = '',.'' NLS_CURRENCY = ''R$ '' '))
                                                     || '.';
--                        
-- dbms_output.put_line( '---p_valor_mensalidade' );
p_fg_retorno   :=   'S';
--
end p_valor_mensalidade; 
 
    -- 
/*
-- -----------------------------------------------------------------------------
PROCEDURE: P_VALOR_MENSALISTA_SEM_ONUS
DESENVOLVEDOR: Lucas 
OBJETIVO: Atualizar informações no registro da disciplina quando ela for 
          cursada em ônus
PARÂMETROS:
    1 - p_rec_mc_aluno
    2 - p_vt_mc_disciplina
    3 - p_fg_exibir 
    4 - p_fg_exibir
    5 - p_fg_retorno
    6 - p_ds_retorno
-- -----------------------------------------------------------------------------
*/

procedure p_valor_mensalista_sem_onus( p_rec_mc_aluno            in out nocopy ca.pk_fat_mc_plt.rec_mc_aluno 
                                     , p_vt_mc_disciplina        in out nocopy ca.pk_fat_mc_plt.ar_mc_disciplina 
                                     , p_fg_exibir               in  varchar2  
                                     , p_index                   in number
                                     , p_fg_retorno              out    varchar2
                                     , p_ds_retorno              out    varchar2 ) is
--
wnr_unidades        number;
wvl_indice_aluno    ca.fat_valor_indice.vl_indice%type;
wvl_hora_aluno      ca.habilitacao.vl_hora%type;
wvl_sem_onus        number;
--
begin
--
--dbms_output.put_line( '>>>>> p_valor_mensalista_sem_onus' );
wvl_sem_onus := 0;
wvl_indice_aluno := p_rec_mc_aluno.vl_indice;
wvl_hora_aluno   := p_rec_mc_aluno.vl_hora_habilitacao;
--   
-- o cálculo considera que a cobrança será sempre pela carga horária da disciplina
-- sem a conversão dos créditos praticos, independente do tipo de cálculo da oferta
--
p_vt_mc_disciplina(p_index).ds_referencia_academica := p_vt_mc_disciplina(p_index).nr_carga_horaria;
if  p_vt_mc_disciplina(p_index).cd_faixa_tipo_calculo_hab_disciplina = 1 then
    p_vt_mc_disciplina(p_index).nr_conversao_acad_finan := p_vt_mc_disciplina(p_index).nr_carga_horaria;
    wnr_unidades := TRUNC((wvl_hora_aluno * p_vt_mc_disciplina(p_index).nr_conversao_acad_finan) / wvl_indice_aluno,4);
elsif p_vt_mc_disciplina(p_index).cd_faixa_tipo_calculo_hab_disciplina = 2 then
    p_vt_mc_disciplina(p_index).nr_conversao_acad_finan := p_vt_mc_disciplina(p_index).nr_carga_horaria;
    wnr_unidades := TRUNC((wvl_hora_aluno * p_vt_mc_disciplina(p_index).nr_conversao_acad_finan )/ wvl_indice_aluno,4);

else
    p_ds_retorno  := 'P_valor_mensalidade_sem_onus: ' || 
                     p_vt_mc_disciplina(p_index).cd_faixa_tipo_calculo_hab_disciplina || 
                     ' - Tipo de cálculo da habilitação da oferta não previsto.';
    raise ex_erro_memoria_calculo;
end if;
--
p_vt_mc_disciplina(p_index).nr_unidade_financeira := wnr_unidades;
p_vt_mc_disciplina(p_index).vl_indice_disciplina  := wvl_indice_aluno;
p_vt_mc_disciplina(p_index).vl_disciplina         := TRUNC((wnr_unidades * wvl_indice_aluno),2);
--
p_rec_mc_aluno.vl_financeiro                    := p_rec_mc_aluno.vl_financeiro
                                                  +  p_vt_mc_disciplina(p_index).vl_disciplina;
--    
p_rec_mc_aluno.un_financeiro                    := p_rec_mc_aluno.un_financeiro 
                                                  +  p_vt_mc_disciplina(p_index).vl_disciplina;
--
p_vt_mc_disciplina(p_index).ds_valor_cobranca := '-';
p_vt_mc_disciplina(p_index).ds_cobranca       := 'Disciplina a ser cursada sem ônus.';
--
-- Incluir o registro da modalidade de desconto da disciplina - c9_carga_horaria_sem_onus
-- Converter carga-horária em unidades funanceiras 
/*
wnr_unidades_sem_onus = TRUNC((wvl_hora_aluno *
                      (NVL(p_array_disciplina(p_index).nr_carga_horaria_sem_onus,0)))/ 
                      wvl_indice_aluno,4)

*/
--
p_fg_retorno := 'S';    
--
exception 
  when ex_erro_memoria_calculo then
       p_fg_retorno := 'N';
END p_valor_mensalista_sem_onus;

    -- 
/*
-- -----------------------------------------------------------------------------
PROCEDURE: P_CALCULO_MENSALISTA
DESENVOLVEDOR: Lucas 
OBJETIVO: Para aluno da modalidade mensalista
          Cálculo do valor a ser cobrado pelas disciplinas do semestre de referência considerando
          a categoria do aluno. Alunos 'Não Padrão' o valor da disciplina será cobrado por hora-aula,
          para os demais o valor será apresentado para conjunto de disciplinas e as
          optativas e dependência serão calculadas por hora-aula.

          Para aluno da modalidade créditos
          Os créditos acadêmicos convertidos em financeiros

          A definição do procedimento de cálculo será dada pelos parâmetros financeiros.

PARÂMETROS:
    1 - p_rec_mc_aluno
    2 - p_vt_mc_disciplina
    3 - p_fg_exibir 
    4 - p_fg_retorno
    5 - p_ds_retorno
*/
-- -----------------------------------------------------------------------------
procedure p_calculo_mensalista( p_rec_mc_aluno       in out nocopy ca.pk_fat_mc_plt.rec_mc_aluno 
                              , p_vt_mc_disciplina   in out nocopy ca.pk_fat_mc_plt.ar_mc_disciplina 
                              , p_fg_exibir          in     varchar2 
                              , p_fg_retorno         out    varchar2
                              , p_ds_retorno         out    varchar2) as
--
windex                          number;
wnr_carga_horaria_total         number;
wid_grupo_disciplina            number;
--
windex_ultima_disciplina_padrao number;
wnr_acumulado_unidades          number; 
l_eh_mensalista                 varchar2(1) := 'N';
--                  
begin
--
--dbms_output.put_line( '>>> p_calculo_mensalista -------------' );
wnr_carga_horaria_total :=  0;
wnr_acumulado_unidades  :=  0;
--
-- dbms_output.put_line ('1 p_rec_mc_aluno.vl_financeiro: '|| p_rec_mc_aluno.vl_financeiro );
-- dbms_output.put_line ('1 p_rec_mc_aluno.un_financeiro: '|| p_rec_mc_aluno.un_financeiro );
--
windex := p_vt_mc_disciplina.FIRST();
while(windex is not null)loop
    if p_vt_mc_disciplina(windex).cd_faixa_tipo_cobranca = 1 then
       wnr_carga_horaria_total         := wnr_carga_horaria_total + p_vt_mc_disciplina(windex).nr_carga_horaria;
       windex_ultima_disciplina_padrao :=  windex;
    end if;
    windex := p_vt_mc_disciplina.next(windex);
end loop;
--    
windex := p_vt_mc_disciplina.first();
while(windex is not null)loop
    if p_vt_mc_disciplina(windex).cd_faixa_tipo_cobranca = 1 then -- Mensalidade
       -- dbms_output.put_line( 'p_valor_mensalidade: - ' || p_rec_mc_aluno.tp_indice  || ' R$ ' || p_rec_mc_aluno.vl_indice );
       p_valor_mensalidade( p_rec_mc_aluno        
                          , p_vt_mc_disciplina  
                          , p_fg_exibir 
                          , windex
                          , wnr_carga_horaria_total
                          , windex_ultima_disciplina_padrao
                          , wnr_acumulado_unidades
                          , p_fg_retorno
                          , p_ds_retorno );
       if p_fg_retorno = 'N' then
           raise ex_erro_memoria_calculo;
       end if;
       l_eh_mensalista   := 'S';
    
    elsif p_vt_mc_disciplina(windex).cd_faixa_tipo_cobranca = 2 then -- Valor da hora da habilitação do curso do aluno
        -- dbms_output.put_line( 'p_valor_habilitacao_aluno' );
        p_valor_habilitacao_aluno( p_rec_mc_aluno    
                                 , p_vt_mc_disciplina  
                                 , p_fg_exibir
                                 , windex
                                 , p_fg_retorno
                                 , p_ds_retorno );
       if p_fg_retorno = 'N' then
           raise ex_erro_memoria_calculo;
       end if;
        
    elsif p_vt_mc_disciplina(windex).cd_faixa_tipo_cobranca = 3 then -- Valor da hora da habilitação do curso que ofertou
        --dbms_output.put_line( 'p_valor_habilitacao_aluno' );
        p_valor_habilitacao_oferta( p_rec_mc_aluno         
                                  , p_vt_mc_disciplina   
                                  , p_fg_exibir
                                  , windex
                                 , p_fg_retorno
                                 , p_ds_retorno );
       if p_fg_retorno = 'N' then
           raise ex_erro_memoria_calculo;
       end if;
        
    elsif p_vt_mc_disciplina(windex).cd_faixa_tipo_cobranca = 5 then -- Disciplina a ser cursada sem ônus
        -- Disciplina a ser cursada sem ônus
        -- Espera-se que alunos com trancamento em 2020-1 sejam cobrados por carga horária 
        -- CI 36812/20 - DAF - Trancamento de Disciplinas 20.1
        --dbms_output.put_line( 'p_valor_mensalista_sem_onus' );
        p_valor_mensalista_sem_onus( p_rec_mc_aluno        
                                   , p_vt_mc_disciplina   
                                   , p_fg_exibir
                                   , windex
                                   , p_fg_retorno
                                   , p_ds_retorno );
       if p_fg_retorno = 'N' then
           raise ex_erro_memoria_calculo;
       end if;

    else
        -- não é o valor esperado
        null;
    end if;
    --
    -- Definição dos grupos de apresentação - id_grupo_disciplina
    /*
    As informações de situação acadêmica e valor das disciplinas do
    semestre de referência para aluno padrão e padrão com dependência
    serão mostradas agrupadas
    */

    if p_vt_mc_disciplina(windex).cd_faixa_situacao_disciplina <> 1 then
        wid_grupo_disciplina                       := wid_grupo_disciplina + 1;
    end if;

    p_vt_mc_disciplina(windex).id_grupo_disciplina := wid_grupo_disciplina;
    p_rec_mc_aluno.nr_hora_optativa_sem_onus       := p_rec_mc_aluno.nr_hora_optativa_sem_onus 
                                                   +  p_vt_mc_disciplina(windex).nr_carga_horaria_sem_onus;
    windex := p_vt_mc_disciplina.next(windex);
end loop; 

if l_eh_mensalista                                 =  'S' then
--   dbms_output.put_line( 'é mensalista' );
   p_rec_mc_aluno.vl_financeiro                    := p_rec_mc_aluno.vl_financeiro 
                                                   +  (g_nr_unidades_semestre * p_vt_mc_disciplina(1).vl_disciplina );
   p_rec_mc_aluno.un_financeiro                    := g_nr_unidades_semestre;

end if; 
--dbms_output.put_line ('2 p_rec_mc_aluno.vl_financeiro: '|| p_rec_mc_aluno.vl_financeiro );
--dbms_output.put_line ('2 p_rec_mc_aluno.un_financeiro: '|| p_rec_mc_aluno.un_financeiro );
p_fg_retorno := 'S';    
exception 
  when ex_erro_memoria_calculo then
       p_fg_retorno := 'N';             
END p_calculo_mensalista;

    --
/*
-----------------------------------------------------------------------------
PROCEDURE: P_CALCULO_SEMESTRALIDADE
DESENVOLVEDOR: Lucas 
OBJETIVO: - Para aluno da modalidade mensalista
          Cálculo do valor a ser cobrado pelas disciplinas do semestre de referência considerando
          a categoria do aluno. Alunos 'Não Padrão' o valor da disciplina será cobrado por hora-aula,
          para os demais o valor será apresentado para conjunto de disciplinas e as
          optativas e dependência serão calculadas por hora-aula.

          - Para aluno da modalidade créditos
          Os créditos acadêmicos convertidos em financeiros
A definição do procedimento de cálculo será dada pelos parâmetros financeiros.
PARÂMETROS:
    1 - p_rec_mc_aluno
    2 - p_vt_mc_disciplina
    3 - p_fg_exibir 
    4 - p_fg_retorno
    5 - p_ds_retorno
*/
    -- -----------------------------------------------------------------------------
procedure p_calculo_semestralidade( p_rec_mc_aluno      in out nocopy ca.pk_fat_mc_plt.rec_mc_aluno 
                                  , p_vt_mc_disciplina  in out nocopy ca.pk_fat_mc_plt.ar_mc_disciplina 
                                  , p_fg_exibir         in     varchar2  
                                  , p_fg_retorno        out    varchar2
                                  , p_ds_retorno        out    varchar2 ) is
--
begin
--
if p_fg_exibir   =  'S' then
   g_rec_fat_mc_log1.ds_log1 := '-----------------------------------' || chr(10) || 
                                'Matrícula do aluno(a): '        || p_rec_mc_aluno.nr_matricula   || chr(10) || 
                                'Curso do aluno(a): '            || p_rec_mc_aluno.cd_curso       || chr(10) ||
                                'Habilitação do aluno(a): '      || p_rec_mc_aluno.cd_habilitacao || chr(10) ||
                                'Tipo de aluno: '                || p_rec_mc_aluno.tp_arquivo     || chr(10) ||
                                'Período acadêmico: '            || p_rec_mc_aluno.cd_periodo     || chr(10) ||
                                'Tipo de período acadêmico: '    || p_rec_mc_aluno.tp_periodo     || chr(10) ||
                                'Período acadêmico-financeiro: ' || p_rec_mc_aluno.id_academico   || chr(10) ||
                                'cd_faixa_tipo_calculo: ' || p_rec_mc_aluno.cd_faixa_tipo_calculo  || chr(10) ||
                                '-----------------------------------';
   dbms_output.put_line(g_rec_fat_mc_log1.ds_log1);                     
   g_rec_fat_mc_log1.id_log1                  :=  null;
   g_rec_fat_mc_log1.id_financeiro            :=  p_rec_mc_aluno.id_financeiro;
   g_rec_fat_mc_log1.nr_matricula             :=  p_rec_mc_aluno.nr_matricula;
   g_rec_fat_mc_log1.id_mc_aluno              :=  p_rec_mc_aluno.id_mc_aluno; 
   pk_fat_mc_dml.p_add_fat_mc_log1( g_rec_fat_mc_log1    
                                  , g_fg_retorno_log    
                                  , g_ds_retorno_log  )  ;          
end if;
--     
--dbms_output.put_line(  'cd_faixa_tipo_calculo:' || p_rec_mc_aluno.cd_faixa_tipo_calculo  );
if p_rec_mc_aluno.cd_faixa_tipo_calculo    = 1 then 
-- Aluno com financeiro da modalidade de cálculo créditos
   p_calculo_creditos( p_rec_mc_aluno     
                     , p_vt_mc_disciplina  
                     , p_fg_exibir    
                     , p_fg_retorno    
                     , p_ds_retorno  ); 
    
elsif p_rec_mc_aluno.cd_faixa_tipo_calculo = 2 then 
-- Aluno com financeiro da modalidade de cálculo mensalista
   p_calculo_mensalista( p_rec_mc_aluno          
                       , p_vt_mc_disciplina 
                       , p_fg_exibir    
                       , p_fg_retorno    
                       , p_ds_retorno  );
else
    -- Modalidade não prevista 
   p_ds_retorno  := 'P_calculo_semestralidade: Modalidade de cálculo de parcela não prevista.';
   raise ex_erro_memoria_calculo;             
end if;
--
-- Ordenar disciplinas para apresentação
--
p_ordenar_apresentacao_disciplinas(p_vt_mc_disciplina ) ;
--
exception 
  when ex_erro_memoria_calculo then
       p_fg_retorno     := 'N';
end p_calculo_semestralidade;    
-- 
/*
-- -----------------------------------------------------------------------------
PROCEDURE: P_ORDENAR_APRESENTACAO_DISCIPLINAS
DESENVOLVEDOR: Lucas 
OBJETIVO: Ordenar disciplinas para apresentação
PARÂMETROS:
    1 - p_vt_mc_disciplina
-- -----------------------------------------------------------------------------
--
*/
procedure p_ordenar_apresentacao_disciplinas( p_vt_mc_disciplina        in out nocopy ca.pk_fat_mc_plt.ar_mc_disciplina ) is
--
type t_refc1                    is ref cursor;
refc1                           t_refc1;
--
wid_grupo_disciplina            number := 0;
wds_sql_disc                    varchar(32000);
windex                          number := 0;
wrf_consulta                    varchar2(32000);
wrf_nr_index                    number;
wrf_nr_ordem_apresentacao       number;
wrf_cd_faixa_tipo_cobranca      number;
wrf_nr_carga_horaria_sem_onus   number;
wrf_cd_disciplina               varchar2(4);
--
begin
--
wrf_consulta := null;
windex       := p_vt_mc_disciplina.first();
while(windex is not null)loop
    select 'select ' || windex ||
           ' nr_index, ' ||
           case
           when(a.cd_faixa_situacao_disciplina                    in ( 1,2 )
            and p_vt_mc_disciplina(windex).cd_faixa_tipo_cobranca <> 1)then
                    '2 nr_ordem_apresentacao, '
           else
                    a.nr_ordem_apresentacao || ' nr_ordem_apresentacao, '
           end || 
           p_vt_mc_disciplina(windex).cd_faixa_tipo_cobranca    ||  ' cd_faixa_tipo_cobranca, ' ||
           p_vt_mc_disciplina(windex).nr_carga_horaria_sem_onus ||  ' nr_carga_horaria_sem_onus, ' ||
           '''' ||  p_vt_mc_disciplina(windex).cd_disciplina    ||  '''' || ' cd_disciplina ' ||
           ' from dual '
        into wds_sql_disc
        from ca.d_ca_situacao_disciplina a
       where a.cd_dominio_situacao_disciplina = p_vt_mc_disciplina(windex).cd_dominio_situacao_disciplina
         and a.cd_faixa_situacao_disciplina   = p_vt_mc_disciplina(windex).cd_faixa_situacao_disciplina;
--
    windex := p_vt_mc_disciplina.next(windex);
--
    if windex is not null then
        wds_sql_disc := wds_sql_disc || ' union ';
    end if;
--
    wrf_consulta := wrf_consulta || wds_sql_disc;
--
end loop;


if wrf_consulta is not null then
    wrf_consulta := wrf_consulta || ' order by nr_ordem_apresentacao, cd_faixa_tipo_cobranca, nr_carga_horaria_sem_onus asc, cd_disciplina';
    wid_grupo_disciplina := 1;
    open refc1 for wrf_consulta;
    loop
        fetch refc1 into wrf_nr_index 
                       , wrf_nr_ordem_apresentacao 
                       , wrf_cd_faixa_tipo_cobranca 
                       , wrf_nr_carga_horaria_sem_onus 
                       , wrf_cd_disciplina;
        exit when refc1%notfound;
        if wrf_nr_ordem_apresentacao = 1 then
            null;
        else
            wid_grupo_disciplina := wid_grupo_disciplina + 1;
        end if;
        p_vt_mc_disciplina(wrf_nr_index).id_grupo_disciplina := wid_grupo_disciplina;

    end loop;

    close refc1;
end if;
--
end p_ordenar_apresentacao_disciplinas;

    --
/* 
-- -----------------------------------------------------------------------------
PROCEDURE: P_GERAR_DISCIPLINA_MODALIDADE
DESENVOLVEDOR: Lucas 
OBJETIVO: -  
PARÂMETROS:
    1 - p_rec_mc_aluno
    2 - p_vt_mc_disciplina
    3 - p_vt_mc_disciplina_modalidade 
    4 - p_fg_exibir
    4 - p_fg_retorno
    4 - p_ds_retorno
-- -----------------------------------------------------------------------------
*/
procedure p_gerar_disciplina_modalidade( p_rec_mc_aluno                 in     ca.pk_fat_mc_plt.rec_mc_aluno 
                                       , p_vt_mc_disciplina             in out ca.pk_fat_mc_plt.ar_mc_disciplina 
                                       , p_vt_mc_disciplina_modalidade  in out pk_fat_mc_plt.ar_mc_disciplina_modalidade
                                       , p_fg_exibir                    in     varchar2   
                                       , p_fg_retorno                   out    varchar2
                                       , p_ds_retorno                   out    varchar2  ) is
--
--
-- Consulta para identificar a modalidade de desconto para uma disciplina 
-- a ser cursada sem ônus
--
cursor cursor_disciplina_sem_onus is
select a.id_modalidade
  from fat_modalidade a
 where a.cd_modalidade_externo = 'DISCIPLINA_SEM_ONUS'
   and a.fg_ativo              = 'S';
--
--
-- Consulta para identificar a modalidade de desconto para uma disciplina 
-- a ser cursada com carga horária sem ônus
--
cursor cursor_carga_horaria_sem_onus is
select a.id_modalidade
  from fat_modalidade a
 where a.cd_modalidade_externo = 'CARGA_HORARIA_SEM_ONUS'
   and a.fg_ativo              = 'S';
--
wcursor_disciplina_sem_onus     cursor_disciplina_sem_onus%ROWTYPE;
wcursor_carga_horaria_sem_onus  cursor_carga_horaria_sem_onus%ROWTYPE;
--
windex      number;
windex_dm   number  :=  0;
--
begin
--
begin
    open cursor_disciplina_sem_onus;
    fetch cursor_disciplina_sem_onus into wcursor_disciplina_sem_onus;
    close cursor_disciplina_sem_onus;
end;
--
begin
    open cursor_carga_horaria_sem_onus;
    fetch cursor_carga_horaria_sem_onus into wcursor_carga_horaria_sem_onus;
    close cursor_carga_horaria_sem_onus;
end;
--
windex := p_vt_mc_disciplina.first();
while (windex is not null) loop
    if      p_rec_mc_aluno.cd_faixa_tipo_calculo                         = 2
        and nvl(p_vt_mc_disciplina(windex).nr_carga_horaria_sem_onus, 0) > 0 
        and p_vt_mc_disciplina(windex).cd_faixa_situacao_disciplina      = 4 
        and p_vt_mc_disciplina(windex).cd_faixa_tipo_cobranca            = 2 then
--
-- Carga horária sem ônus
--
        windex_dm   :=  windex_dm + 1;
        
        p_vt_mc_disciplina_modalidade(windex_dm).cd_disciplina       :=  p_vt_mc_disciplina(windex).cd_disciplina;  
        p_vt_mc_disciplina_modalidade(windex_dm).id_modalidade       :=  wcursor_carga_horaria_sem_onus.id_modalidade;
        
        p_vt_mc_disciplina_modalidade(windex_dm).vl_desconto_incondicional  :=  trunc(( nvl( p_vt_mc_disciplina(windex_dm).nr_carga_horaria_sem_onus, 0)
                                                                            /   p_vt_mc_disciplina(windex_dm).nr_carga_horaria) 
                                                                            *   p_vt_mc_disciplina(windex_dm).vl_disciplina, 2);


        p_vt_mc_disciplina_modalidade(windex_dm).un_desconto_incondicional  :=  trunc((nvl( p_vt_mc_disciplina(windex_dm).nr_carga_horaria_sem_onus,0)
                                                                            /   p_vt_mc_disciplina(windex_dm).nr_carga_horaria) 
                                                                            *   p_vt_mc_disciplina(windex_dm).nr_unidade_financeira, 4);
        
    elsif p_vt_mc_disciplina(windex).cd_faixa_tipo_cobranca = 5 then
--
-- Cursada sem ônus
--
        windex_dm                                                           :=  windex_dm + 1;
        p_vt_mc_disciplina_modalidade(windex_dm).cd_disciplina              :=  p_vt_mc_disciplina(windex).cd_disciplina;  
        p_vt_mc_disciplina_modalidade(windex_dm).id_modalidade              :=  wcursor_disciplina_sem_onus.id_modalidade;
        p_vt_mc_disciplina_modalidade(windex_dm).vl_desconto_incondicional  :=  p_vt_mc_disciplina(windex_dm).vl_disciplina;
        p_vt_mc_disciplina_modalidade(windex_dm).un_desconto_incondicional  :=  p_vt_mc_disciplina(windex_dm).nr_unidade_financeira;
        
    end if;
    windex  :=  p_vt_mc_disciplina.next(windex);
end loop;
--
p_fg_retorno := 'S';
--
end p_gerar_disciplina_modalidade;

-- 
-----------------------------------------------------------------------------
/*
PROCEDURE: P_PROCESSAR
DESENVOLVEDOR: Lucas 
OBJETIVO: Gerar memória de cálculo
PARÂMETROS:
   1 - p_rec_mc_aluno
   2 - p_vt_mc_disciplina
   3 - p_vt_mc_disciplina_modalidade 
   4 - p_dt_processamento
   5 - p_fg_exibir
   6 - p_fg_retorno
   7 - p_ds_retorno

*/
-- -----------------------------------------------------------------------------
procedure p_processar( p_rec_mc_aluno                in out nocopy ca.pk_fat_mc_plt.rec_mc_aluno 
                     , p_vt_mc_disciplina            in out nocopy ca.pk_fat_mc_plt.ar_mc_disciplina 
                     , p_vt_mc_disciplina_modalidade in out nocopy ca.pk_fat_mc_plt.ar_mc_disciplina_modalidade
                     , p_dt_processamento            in     date
                     , p_fg_exibir                   in     varchar2 
                     , p_fg_retorno                     out varchar2  
                     , p_ds_retorno                     out varchar2 ) is
--
begin
--
-- Validar informações enviadas
p_validar_dados( p_rec_mc_aluno    
               , p_vt_mc_disciplina   
               , p_fg_retorno 
               , p_ds_retorno );
if p_fg_retorno   = 'N' then
   raise ex_finalizar_memoria_calculo;
end if;
--
-- Complementar informações
p_buscar_informacoes( p_rec_mc_aluno          
                    , p_vt_mc_disciplina   
                    , p_dt_processamento
                    , p_fg_retorno 
                    , p_ds_retorno );
if p_fg_retorno   = 'N' then
   raise ex_finalizar_memoria_calculo;
end if;  
--
-- Procedimento de cálculo do valor do semestre
p_calculo_semestralidade( p_rec_mc_aluno       
                        , p_vt_mc_disciplina  
                        , p_fg_exibir     
                        , p_fg_retorno 
                        , p_ds_retorno );
                        
if p_fg_retorno   = 'N' then
   raise ex_finalizar_memoria_calculo;
end if;  
--
-- Procedimento de geração de modalidades de desconto de acordo com as disciplinas
p_gerar_disciplina_modalidade( p_rec_mc_aluno       
                             , p_vt_mc_disciplina  
                             , p_vt_mc_disciplina_modalidade  
                             , p_fg_exibir     
                             , p_fg_retorno 
                             , p_ds_retorno );
if p_fg_retorno   = 'N' then
   raise ex_finalizar_memoria_calculo;
end if;
--                   
-- Chamar procedimento que verifica se existe autorização com limitação de unidades financeiras para a matrícula
-- Não realiza a atualização envia mensagem informando a ocorrência
-- autorizacao_matricula ( p_array_aluno       => p_array_aluno,
--                         p_array_disciplina  => p_array_disciplina,
--                         p_tp_procedimento   => gc_autorizacao_processar);                                
p_fg_retorno        := 'S';

exception 
when ex_finalizar_memoria_calculo then
     p_fg_retorno   :=  'N';
end p_processar;

    --==========================================================================
    -- INÍCIO OBJETOS PARA CÁLCULO                                             
    --==========================================================================
    
/*
-- -----------------------------------------------------------------------------
PROCEDURE: p_calculo
DESENVOLVEDOR: Helane, Haroldo e José Leitão 
OBJETIVO: Gerar títulos de mensalidade de aluno da graduação

Considerar o semestre acadêmico correspondente a data de inicio de vigència 
da modalidade. 
Será considerado o dia de vencimento padrão que está em vigor para o aluno

Conforme regra, os vencimentos do PEX são sequenciais iniciando após o 
término previsto do curso de acordo com o fluxograma (tp_disciplina = 1) 
ou após o último vencimento de títulos PEX para o aluno.

PARÃMETROS:
    1 - p_fg_exibir
        S-Sim   N-Não
    2 - p_fg_retorno
    3 - p_ds_retorno
-- -----------------------------------------------------------------------------
*/
-- !!* Aqui - Incluir parâmetro para indicar que o cálculo destina-se ao título oferta
--
--
procedure p_calculo
( p_rec_mc_aluno                  in out nocopy ca.pk_fat_mc_plt.rec_mc_aluno 
, p_vt_mc_disciplina              in out nocopy ca.pk_fat_mc_plt.ar_mc_disciplina 
, p_vt_mc_disciplina_modalidade   in out nocopy pk_fat_mc_plt.ar_mc_disciplina_modalidade 
, p_rec_financeiro                in out nocopy ca.pk_fat_mc_plt.rec_financeiro
, p_vt_financeiro_modalidade_aux  in out nocopy ca.pk_fat_mc_plt.vt_fin_modalidade_aux
, p_vt_titulos_aux                in out nocopy ca.pk_fat_mc_plt.vt_titulo_aux
, p_vt_titulos_gerados_aux        in out nocopy ca.pk_fat_mc_plt.vt_titulo_aux 
, p_vt_titulos_preservados_aux    in out nocopy ca.pk_fat_mc_plt.vt_titulo_aux
, p_vt_titulos_modalidade_aux     in out nocopy ca.pk_fat_mc_plt.vt_titulo_modalidade 
, p_vt_modalidade_competencia_aux in out nocopy ca.pk_fat_mc_plt.vt_modalidade_competencia 
, p_qt_titulos_por_competencia_modalidade 
                                  in out        number  
, p_vt_mensalidade_pg             in            ca.pk_fat_mc_plt.ar_mensalidade_pg     
, p_vt_regra_academica            in            ca.pk_fat_mc_plt.ar_mc_regra_academica 
, p_tp_operacao                   in            varchar2  
, p_fg_exibir                     in            varchar2  
, p_fg_titulo_oferta              in            varchar2 
, p_dt_processamento              in            date
, p_dt_vencimento_titulo_oferta   in            date default null
, p_fg_retorno                    out           varchar2
, p_ds_retorno                    out           varchar2 
) is
--
-- Campos utilizados para visualização de dbms_output 
wid_comp                         number := 0;
wtx_linha                        varchar2(500);
wid_modalidade                   number := 0;     
wnr_competencia                  number := 0;
--    
l_convenio_pagamento_05          varchar2(1) := null;
l_financiamento_publico_07       varchar2(1) := null;
l_financiamento_privado_08       varchar2(1) := null;
l_parcelamento_unifor_11         varchar2(1) := null; 
l_liquido_modalidade_aux         number(12, 2);
l_vl_financeiro_a_cobrar         number(12, 2);
l_id_movimento_financeiro_sda    ca.sda_movimento_financeiro.id_movimento_financeiro%type;
l_vl_diferenca                   ca.ctr_titulo.vl_titulo%type;
l_vl_credito_sda                 ca.ctr_titulo.vl_titulo%type;   
l_nr_sequencia_calc_modalidade   number(4) := 0;
l_ind_mod_comp                   number(4);
l_id_modalidade_ant              ca.fat_modalidade.id_modalidade%type;
--
begin 
--
if p_rec_mc_aluno.tp_arquivo =  1 -- graduacao
   and nvl( p_rec_financeiro.vl_financeiro, 0 ) =  0 then
   p_ds_retorno := 'Valor do semestre do aluno GR não pode ser ZERO';
   raise ex_erro_memoria_calculo; 
end if; 
--
--dbms_output.put_line ('2 p_rec_financeiro.vl_financeiro: '||p_rec_financeiro.vl_financeiro);
--
p_fg_retorno                                 := 'N';
p_rec_financeiro.qt_competencia_preservada   := 0;
--
-- Obter o valor da semestralidade, distribuir o vendido e listar as 
-- modalidades em vigor
l_convenio_pagamento_05                      := 'N';
l_financiamento_publico_07                   := 'N';
l_financiamento_privado_08                   := 'N';
l_parcelamento_unifor_11                     := 'N';
--     
-- Obter os dados do financeiro e configurações da matrícula do aluno
-- a partir da memória de calculo informada  
open  c0_validacao( p_rec_mc_aluno.id_financeiro );
fetch c0_validacao into rc0;
if c0_validacao%notfound then
   close c0_validacao;
   p_ds_retorno := 'Financeiro ' || p_rec_mc_aluno.id_financeiro ||' não encontrado para o processamento.';          
   raise ex_erro_memoria_calculo;
end if;
close c0_validacao;   

--
if p_rec_mc_aluno.tp_periodo = 'N' then
   -- Graduação período de férias
   p_rec_financeiro.nr_dia_vencimento_padrao := to_char( p_dt_processamento, 'dd' ) + rc0.qt_dias_vencimento_boleto_pe;
else
   p_rec_financeiro.nr_dia_vencimento_padrao := f_dia_vencimento_padrao( p_rec_mc_aluno.id_academico  
                                                                       , 1    -- Competência
                                                                       , rc0.cd_identificador_vencimento
                                                                       , 1 ); -- retorna o dia padrão de vecimento
end if;
--
if p_rec_mc_aluno.tp_arquivo = 1 and p_tp_operacao = 'P' then
-- Processar somente para graduação
   -- Identificar e guardar os títulos que devem ser preservados ( não cancelados )
   -- gerados anteriormente 
   -- variavel global "g_qt_competencia_preservada" é atualizada 
   
   p_titulo_preservar_cancelar( p_rec_mc_aluno 
                              , p_rec_financeiro
                              , p_dt_processamento
                              , p_fg_retorno           
                              , p_ds_retorno  )  ;
                           
   if p_fg_retorno     =   'N'  then 
      raise ex_erro_memoria_calculo; 
   end if;
end if;  
--
-- Montar vetor de títulos preservados ( p_vt_titulos_preservados_aux ) a 
-- partir de p_rec_financeiro.titulo
dbms_output.put_line('Tit financ antes montar_vt_titulos_aux : '||p_rec_financeiro.titulo.count);
p_montar_vt_titulos_aux( p_rec_financeiro        
                       , 'S'       -- Títulos preservados
                       , p_dt_vencimento_titulo_oferta
                       , p_vt_titulos_preservados_aux );
                       
dbms_output.put_line('Tit financ depois montar_vt_titulos_aux : '||p_rec_financeiro.titulo.count);
--dbms_output.put_line( '==>P_CALCULO - g_qt_competencia_preservada:' || g_qt_competencia_preservada  ); 
if nvl( p_rec_financeiro.qt_competencia_preservada,0) = 0 then 
   -- Verifica a quantidade de competências/shift quando não houver titulo(s) preservado(s)
   if (first_day( p_dt_processamento ) - 1) < rc0.dt_mes_ano_inicio_competencia then 
       p_rec_financeiro.qt_competencia_shift  := 0;
   else
       p_competencia_shift( rc0.dt_mes_ano_inicio_competencia
                          , first_day( p_dt_processamento ) - 1   
                          , p_rec_financeiro.qt_competencia_shift   );
   end if;
/*
   dbms_output.put_line( 'P_CALCULO - SHIFT( A )'  || 
                         ' dt_mes_ano_inicio_competencia:' || to_char( rc0.dt_mes_ano_inicio_competencia ,'dd/mm/yyyy' ) ||
                         ' p_dt_processamento: '||to_char(p_dt_processamento,'dd/mm/yyyy')||
                         ' first_day( p_dt_processamento ) - 1:' || to_char( first_day( p_dt_processamento ) - 1,'dd/mm/yyyy' ) ||
                         ' qt_competencia_shift:' || p_rec_financeiro.qt_competencia_shift );
*/
else
   -- Verifica a quantidade de competências/shift quando houver titulo(s) preservado(s)
   p_rec_financeiro.qt_competencia_shift   := p_vt_titulos_preservados_aux(1).nr_competencia - 1; 
/*
   dbms_output.put_line( 'P_CALCULO - SHIFT( B )'   || 
                         ' p_vt_titulos_preservados_aux(1).nr_competencia:' || p_vt_titulos_preservados_aux(1).nr_competencia ||
                         ' qt_competencia_shift:' || p_rec_financeiro.qt_competencia_shift );
*/
end if;
--
-- Quantidades de competências já realizadas na data referencia do processamento
rc0.qt_parcelas         := rc0.qt_parcelas  
                           - p_rec_financeiro.qt_competencia_shift;  
-- 
-- Inicializar os períodos de competências
if p_rec_mc_aluno.tp_periodo      = 'N' then
   -- Graduação período de férias
   p_rec_financeiro.nr_competencia_inicio   := 1;
   p_rec_financeiro.nr_competencia_fim      := rc0.qt_parcelas;
--
elsif p_rec_mc_aluno.tp_periodo    in ( 'R', 'I' ) then
   -- Graduação
   p_rec_financeiro.nr_competencia_inicio   := 1;
   -- !!* Aqui - alterar a quantidade de títulos quando for para gerar título oferta da graduação
   if p_fg_titulo_oferta = 'S' then
      p_rec_financeiro.nr_competencia_fim   := ca.pk_fat_financeiro_qry.f_qt_parcela_cad_matricula(pv_id_financeiro => p_rec_financeiro.id_financeiro);
   else
      p_rec_financeiro.nr_competencia_fim   := rc0.qt_parcelas;
   end if;
--
elsif p_rec_mc_aluno.tp_periodo    = 'P' then
   -- Pós Graduação 
   p_rec_financeiro.nr_competencia_inicio   := p_vt_mensalidade_pg.first;
   p_rec_financeiro.nr_competencia_fim      := p_vt_mensalidade_pg.last;
end if;
--                          
if p_rec_mc_aluno.tp_arquivo = 1 then
   p_rec_financeiro.qt_competencia   := p_rec_financeiro.nr_competencia_fim 
                                        - p_rec_financeiro.nr_competencia_inicio + 1; 
                                             
   l_vl_credito_sda                  := abs( p_rec_financeiro.vl_financeiro_preservado 
                                             - p_rec_financeiro.vl_financeiro );
--   
   if p_rec_financeiro.vl_financeiro_preservado > p_rec_financeiro.vl_financeiro     then
   -- creditar diferença no SDA
      -- Alterar Status do aluno para débito automátioco no SDA
      ca.pk_sda_saldo_aluno_clc.p_alterar_fg_debito_autorizado( p_rec_mc_aluno.nr_matricula
                                                              , 'S'  -- p_fg_debito_autorizado = 
                                                              , p_fg_retorno 
                                                              , p_ds_retorno);
      -- Creditar diferença no SDA - Evento contábil 410 
      ca.pk_sda_saldo_aluno_clc.p_creditar_no_saldo( p_rec_mc_aluno.id_pessoa_aluno             -- id pessoa
                                                   , p_rec_mc_aluno.nr_matricula   -- matrícula
                                                   , 'Crédito decorrente de recebimento de títulos a maior - Recálculo'  
                                                   , 410                           -- Código do evento contabil
                                                   , l_vl_credito_sda              -- Valor de crédito
                                                   , p_fg_retorno 
                                                   , p_ds_retorno 
                                                   , l_id_movimento_financeiro_sda ); --movimento financeiro gerado
--
      p_ds_retorno := 'Valor R$ ' || to_char( abs( l_vl_financeiro_a_cobrar ), '999G999G990D00' ) || 
                     ' creditado no SDP para o aluno'; 
      -- Alterar Status do aluno para débito manualo no SDA
      ca.pk_sda_saldo_aluno_clc.p_alterar_fg_debito_autorizado( p_rec_mc_aluno.nr_matricula
                                                              , 'N'  -- p_fg_debito_autorizado = 
                                                              , p_fg_retorno 
                                                              , p_ds_retorno);
      /* ratear proporcionalmente aos títulos já pagos? como fica o status do titulo? 
          
           -- Associar ao movimento do título o evento contábil 275 ( devolução de título )
           ca.pk_ctr_titulo_clc.p_titulo_devolucao( st_titulo.id_titulo   
                                                  , p_fg_retorno 
                                                  , p_ds_retorno );
      */
      raise ex_finalizar_memoria_calculo; 
   end if;
   
   --dbms_output.put_line( '>>>>>>c5_padrao:' || p_rec_mc_aluno.id_financeiro || '#' ||
   --                       p_rec_mc_aluno.tp_indice|| '#' ||
   --                       p_rec_mc_aluno.id_valor_indice || '#' || 
   --                       p_rec_mc_aluno.vl_indice );
-- !!* Aqui - Não se aplica para o período especial tp_periodo = 'N'
-- !!* Aqui - Se a consulta não retornar valores não tem sentido definir o valor para qt_unidade_titulo_01 e qt_unidade_titulo_02
   if p_rec_mc_aluno.tp_periodo = 'N' then
--
      rc5.qt_unidade_titulo_01 := trunc(p_rec_mc_aluno.un_financeiro / p_rec_financeiro.qt_competencia,4);
      rc5.qt_unidade_titulo_02 := 0;
-- 
      rc5.vl_titulo_01         := trunc(p_rec_mc_aluno.vl_financeiro / p_rec_financeiro.qt_competencia,2);
      rc5.vl_titulo_02         := 0;
--
   else

      open  c5_padrao ( p_rec_mc_aluno.id_financeiro
                      , p_rec_mc_aluno.tp_indice
                      , p_rec_mc_aluno.vl_indice );
      fetch c5_padrao into rc5;
      if c5_padrao%notfound then
         close c5_padrao;
         p_ds_retorno := 'Padrão de cálculo do financeiro do aluno não encontrado.';
         raise ex_erro_memoria_calculo;
      end if;
      close c5_padrao;
   
   end if;
--
   p_rec_financeiro.vl_competencia1 := rc5.vl_titulo_01;
   p_rec_financeiro.vl_competencia2 := rc5.vl_titulo_02;
--
/*
   if c5_padrao%found then
      if p_rec_mc_aluno.tp_periodo      =     'N' then
      -- Graduação período de férias
         -- !!* Aqui -  Verificar rc5.qt_unidade_titulo_01 e rc5.qt_unidade_titulo_02
         rc5.qt_unidade_titulo_01         := 1;
         rc5.qt_unidade_titulo_02         := 1;
         rc5.vl_titulo_01                 := nvl( p_rec_financeiro.vl_financeiro, 0 ) 
                                              /   p_rec_financeiro.qt_competencia;
         rc5.vl_titulo_02                 := nvl( p_rec_financeiro.vl_financeiro, 0 ) 
                                              /   p_rec_financeiro.qt_competencia; 
      end if; 
   else
      if p_rec_mc_aluno.tp_periodo      =     'N' then
      -- Graduação período de férias
         rc5.qt_unidade_titulo_01         := 1;
         rc5.qt_unidade_titulo_02         := 1;
         rc5.vl_titulo_01                 := nvl( p_rec_financeiro.vl_financeiro, 0 ) 
                                              /   p_rec_financeiro.qt_competencia;
         rc5.vl_titulo_02                 := nvl( p_rec_financeiro.vl_financeiro, 0 ) 
                                              /   p_rec_financeiro.qt_competencia; 
      else
         close c5_padrao;
         p_ds_retorno := 'Padrão de cálculo do financeiro do aluno não encontrado.';
         raise ex_erro_memoria_calculo;
      end if;
   end if;    
   close c5_padrao;
*/

end if;

if p_fg_exibir = 'S' then
   g_rec_fat_mc_log1.ds_log1 := '  ' || chr(10) || 
                                '===============================================================' || chr(10) || 
                                'Modalidades:  '  ;
   dbms_output.put_line(g_rec_fat_mc_log1.ds_log1);                     
   g_rec_fat_mc_log1.id_log1                  :=  null;
   g_rec_fat_mc_log1.id_financeiro            :=  p_rec_mc_aluno.id_financeiro;
   g_rec_fat_mc_log1.nr_matricula             :=  p_rec_mc_aluno.nr_matricula;
   g_rec_fat_mc_log1.id_mc_aluno              :=  p_rec_mc_aluno.id_mc_aluno;  
   pk_fat_mc_dml.p_add_fat_mc_log1( g_rec_fat_mc_log1    
                                  , g_fg_retorno_log    
                                  , g_ds_retorno_log  )  ;                      
end if;
  
-- !!* Aqui -  --> tem que popular o vetor de modalidades do financeiro ate aqui.
--   modalidade 169                                     
-- Montar vetor de modalidades "l_vt_financeiro_modalidade_aux" 
-- a partir do record de fincanceiro "p_rec_financeiro"
p_montar_vt_financeiro_modalidade_aux( p_rec_financeiro    
                                     , p_vt_financeiro_modalidade_aux );                                             
--
-- Considerar que o padrão de quantidade de unidades financeira só se aplica 
-- para os títulos da primeira e segunda vigencia do periodo regular e internato da medicina
--
-- Indificar se aluno possui as modalidades:
-- 5 - Convênio de pagamento
-- 7 - Financiamento público
-- 8 - Financiamento Privado
-- 11 - Financiamento Unifor PEX          
for r1m in c1_modalidade( p_vt_financeiro_modalidade_aux , 0 ) loop
     -- Convênio de pagamento
    if r1m.id_modalidade_tipo = 05 then 
       l_convenio_pagamento_05 := 'S'; 
    end if;
     
     -- Financiamento público
    if r1m.id_modalidade_tipo              =   07 then 
       if nvl( r1m.cd_externo_padrao, 'X') =   'NOVO_FIES' then
          p_rec_financeiro.vl_limite       :=  r1m.vl_limite  ;
          rc5.vl_titulo_01                 :=  ( p_rec_financeiro.vl_financeiro 
                                               - p_rec_financeiro.vl_financeiro_preservado 
                                               ) / p_rec_financeiro.qt_competencia;
          rc5.vl_titulo_02                 :=  rc5.vl_titulo_01 ;
       end if; 
       l_financiamento_publico_07         :=  'S'; 
    end if; 

     -- Financiamento Privado
    if r1m.id_modalidade_tipo             =   08 then 
       l_financiamento_privado_08         :=  'S'; 
       --wcd_externo_padrao                 :=  r1m.cd_externo_padrao; 
    end if;
     
    -- Financiamento Unifor PEX
    if r1m.id_modalidade_tipo             =   11 then
       l_parcelamento_unifor_11           :=  'S';
    end if;

     -- Exibir   
    if p_fg_exibir                        =   'S' then
       g_rec_fat_mc_log1.ds_log1          := lpad( r1m.id_modalidade_tipo, 3, ' ' )     || ' - '   || 
                                             rpad( r1m.nm_modalidade_tipo, 40, ' ')     || ' > '   ||
                                             lpad( r1m.id_modalidade, 3, ' ' )          || ' - '   ||
                                             rpad( r1m.nm_modalidade, 40, ' ')          || 
                                             rpad( '[ ' || r1m.cd_externo_padrao || ']', 25, ' ' ) ||       
                                             r1m.ds_situacao_modalidade                 || ' : '   ||
                                             r1m.pc_modalidade                          || '% / $' || 
                                             to_char(r1m.vl_modalidade ,'S9999990.00');
       dbms_output.put_line(g_rec_fat_mc_log1.ds_log1);                     
       g_rec_fat_mc_log1.id_log1                  :=  null;
       g_rec_fat_mc_log1.id_financeiro            :=  p_rec_mc_aluno.id_financeiro;
       g_rec_fat_mc_log1.nr_matricula             :=  p_rec_mc_aluno.nr_matricula;
       g_rec_fat_mc_log1.id_mc_aluno              :=  p_rec_mc_aluno.id_mc_aluno; 
       pk_fat_mc_dml.p_add_fat_mc_log1( g_rec_fat_mc_log1    
                                      , g_fg_retorno_log    
                                      , g_ds_retorno_log )  ;  
    end if;
end loop;

-- exibir
if p_fg_exibir = 'S' then
     
   l_vl_diferenca     :=  p_rec_financeiro.vl_financeiro - p_rec_financeiro.vl_financeiro_preservado;
    
   g_rec_fat_mc_log1.ds_log1 := '------------------------------------------------------' || chr(10) ||
                                 'Aluno: '         || to_char( p_rec_mc_aluno.nr_matricula, '0000000') ||
                                 ' Período:'       || nvl( p_rec_mc_aluno.cd_periodo, p_rec_mc_aluno.cd_periodo_especial ) ||
                                 ' Tipo Calc:'     || p_rec_financeiro.ds_tp_calculo || '  ' || 
                                 ' Processamento:' || to_char( p_dt_processamento, 'dd/mm/yyyy' ) || chr(10) ||                                         
                                 'Vl Semestre: '   || to_char( p_rec_financeiro.vl_financeiro, 'S9999990.00')  ||
                                 ' Vl preservado: '|| trim( to_char( p_rec_financeiro.vl_financeiro_preservado,'S9999990.00' ))   || 
                                 ' Vl diferença: ' || trim( to_char( ( l_vl_diferenca ),'S9999990.00'))  ;
   dbms_output.put_line( g_rec_fat_mc_log1.ds_log1);                     
   g_rec_fat_mc_log1.id_log1                  :=  null;
   g_rec_fat_mc_log1.id_financeiro            :=  p_rec_mc_aluno.id_financeiro;
   g_rec_fat_mc_log1.nr_matricula             :=  p_rec_mc_aluno.nr_matricula;
   g_rec_fat_mc_log1.id_mc_aluno              :=  p_rec_mc_aluno.id_mc_aluno; 
   pk_fat_mc_dml.p_add_fat_mc_log1( g_rec_fat_mc_log1    
                                  , g_fg_retorno_log    
                                  , g_ds_retorno_log  )  ;   

   if p_rec_mc_aluno.tp_arquivo     =   1  then
       -- Processar somente para graduação 
      g_rec_fat_mc_log1.ds_log1 := 'Valor Padrão -> Titulo1: ' ||trim(to_char(rc5.vl_titulo_01,'S9999990.00')) ||
                                   ' Titulo2: '                ||trim(to_char(rc5.vl_titulo_02,'S9999990.00')) ||
                                   ' Vl limite: '              ||trim(to_char(p_rec_financeiro.vl_limite,'S9999990.00')) ;
        
      dbms_output.put_line(g_rec_fat_mc_log1.ds_log1);                     
      g_rec_fat_mc_log1.id_log1                  :=  null;
      g_rec_fat_mc_log1.id_financeiro            :=  p_rec_mc_aluno.id_financeiro;
      g_rec_fat_mc_log1.nr_matricula             :=  p_rec_mc_aluno.nr_matricula;
      g_rec_fat_mc_log1.id_mc_aluno              :=  p_rec_mc_aluno.id_mc_aluno; 
      pk_fat_mc_dml.p_add_fat_mc_log1( g_rec_fat_mc_log1    
                                     , g_fg_retorno_log    
                                     , g_ds_retorno_log  )  ;   

   end if; 
  
   g_rec_fat_mc_log1.ds_log1 := 'Regime: '                 || p_rec_mc_aluno.ds_regime        || '  '    || 
                                ' Financeiro: '            || p_rec_mc_aluno.id_financeiro    || '  '    || 
                                ' Acadêmico: '             || p_rec_mc_aluno.id_academico     || chr(10) ||
                                 
                                'Competências -> Início: ' || p_rec_financeiro.nr_competencia_inicio         || 
                                ' Fim:'                    || p_rec_financeiro.nr_competencia_fim            || '  '    || 
                                ' [ Preservada(s): '       || p_rec_financeiro.qt_competencia_preservada     ||  
                                ' Shift:'                  || p_rec_financeiro.qt_competencia_shift          || ' ]  '  ||
                                ' Qtd:'                    || p_rec_financeiro.qt_competencia                || '  '    || 
                                ' Dia padrao:'             || p_rec_financeiro.nr_dia_vencimento_padrao  || chr(10) ||
                                'Títulos preservados:'     || p_rec_financeiro.qt_titulos_preservados || chr(10) ||
                                '------------------------------------------------------' ; 
   dbms_output.put_line(g_rec_fat_mc_log1.ds_log1);                     
   g_rec_fat_mc_log1.id_log1                  :=  null;
   g_rec_fat_mc_log1.id_financeiro            :=  p_rec_mc_aluno.id_financeiro;
   g_rec_fat_mc_log1.nr_matricula             :=  p_rec_mc_aluno.nr_matricula;
   g_rec_fat_mc_log1.id_mc_aluno              :=  p_rec_mc_aluno.id_mc_aluno; 
   pk_fat_mc_dml.p_add_fat_mc_log1( g_rec_fat_mc_log1    
                                  , g_fg_retorno_log    
                                  , g_ds_retorno_log  )  ;   
 
end if; 
   
-- Distribuição da semestralidade por competência 
------------------------------------------------------------------------ 
p_distribuir_semestre_competencia( p_rec_financeiro
                                 , p_rec_mc_aluno 
                                 , p_vt_titulos_preservados_aux
                                 , p_vt_mensalidade_pg );         -- in
                                              
    -- Exibir distribuição do vendido
if p_fg_exibir = 'S' then
   g_rec_fat_mc_log1.ds_log1 := '--- Distribuição do vendido -------------------------------------------------------------------' ; 
   dbms_output.put_line(g_rec_fat_mc_log1.ds_log1);                     
   g_rec_fat_mc_log1.id_log1                  :=  null;
   g_rec_fat_mc_log1.id_financeiro            :=  p_rec_mc_aluno.id_financeiro;
   g_rec_fat_mc_log1.nr_matricula             :=  p_rec_mc_aluno.nr_matricula;
   g_rec_fat_mc_log1.id_mc_aluno              :=  p_rec_mc_aluno.id_mc_aluno; 
   pk_fat_mc_dml.p_add_fat_mc_log1( g_rec_fat_mc_log1    
                                  , g_fg_retorno_log    
                                  , g_ds_retorno_log  )  ;   

   if p_rec_financeiro.competencia.count > 0 then
      wtx_linha := '-';
      for ind in p_rec_financeiro.competencia.first  .. p_rec_financeiro.competencia.last loop
          wtx_linha  := wtx_linha ||  '    Cmp ' || lpad ( ind, 2, ' ' );      
      end loop;
   end if;
   g_rec_fat_mc_log1.ds_log1 := wtx_linha;
   dbms_output.put_line(g_rec_fat_mc_log1.ds_log1);                     
   g_rec_fat_mc_log1.id_log1                  :=  null;
   g_rec_fat_mc_log1.id_financeiro            :=  p_rec_mc_aluno.id_financeiro;
   g_rec_fat_mc_log1.nr_matricula             :=  p_rec_mc_aluno.nr_matricula;
   g_rec_fat_mc_log1.id_mc_aluno              :=  p_rec_mc_aluno.id_mc_aluno; 
   pk_fat_mc_dml.p_add_fat_mc_log1( g_rec_fat_mc_log1    
                                  , g_fg_retorno_log    
                                  , g_ds_retorno_log  )  ; 
   if p_rec_financeiro.competencia.count > 0 then
      wtx_linha := '-';
      for ind in p_rec_financeiro.competencia.first .. p_rec_financeiro.competencia.last loop
          wtx_linha  := wtx_linha||  to_char( nvl( p_rec_financeiro.competencia(ind).vl_vendido, 0),'999990D00') ;
                 
      end loop;
   end if; 
   g_rec_fat_mc_log1.ds_log1 := wtx_linha || chr(10) ||
                                 '-';
   dbms_output.put_line(g_rec_fat_mc_log1.ds_log1);                     
   g_rec_fat_mc_log1.id_log1                  :=  null;
   g_rec_fat_mc_log1.id_financeiro            :=  p_rec_mc_aluno.id_financeiro;
   g_rec_fat_mc_log1.nr_matricula             :=  p_rec_mc_aluno.nr_matricula;
   g_rec_fat_mc_log1.id_mc_aluno              :=  p_rec_mc_aluno.id_mc_aluno; 
   pk_fat_mc_dml.p_add_fat_mc_log1( g_rec_fat_mc_log1    
                                  , g_fg_retorno_log    
                                  , g_ds_retorno_log  )  ;   
end if;

-- Redefinição dos período de competência, previamente definidos 
if p_rec_mc_aluno.tp_arquivo               = 1 then
   -- Graduação
   p_rec_financeiro.nr_competencia_inicio := 1 +  p_rec_financeiro.qt_competencia_preservada   ;
end if;

--dbms_output.put_line( '**6 COMPETENCIA:' || g_nr_competencia_inicio || 
--                      ' a:'    || g_nr_competencia_fim );

-- Totalizar os DESCONTOS INCONDICIONAIS concedidos  
----------------------------------------------------------------------------
wid_comp                            :=     0;
l_nr_sequencia_calc_modalidade      :=     0;
p_desconto_incondicional( p_vt_financeiro_modalidade_aux
                        , p_rec_financeiro
                        , p_rec_mc_aluno
                        , l_nr_sequencia_calc_modalidade
                        , p_fg_retorno           
                        , p_ds_retorno );

if p_fg_retorno               =   'N' then
   raise ex_erro_memoria_calculo;
end if;
--
-- Totalizar as BOLSAS  
-- -------------------------------------------------------------------------
p_bolsa( p_vt_financeiro_modalidade_aux
       , p_rec_financeiro
       , p_rec_mc_aluno
       , l_nr_sequencia_calc_modalidade ) ;  
--   
-- Totalizar os DESCONTOS CONDICIONAIS  
----------------------------------------------------------------------------
p_desconto_condicional( p_vt_financeiro_modalidade_aux
                      , p_rec_financeiro
                      , p_rec_mc_aluno
                      , l_nr_sequencia_calc_modalidade );         
--
-- Recalcular o percentual do fator de limite
begin
p_percentual_fator_limite( p_rec_mc_aluno
                         , p_rec_financeiro
                         , p_rec_financeiro.vl_limite
                         , p_rec_financeiro.pc_fator_limite);
exception 
when others then
     p_rec_financeiro.vl_limite   := 0;
end;
--   
if p_fg_exibir = 'S' then 
   g_rec_fat_mc_log1.ds_log1 := ' ' || chr(10) ||
                                'Percentual Fator Limite:' || p_rec_financeiro.pc_fator_limite || chr(10) ||
                                ' ';
   dbms_output.put_line(g_rec_fat_mc_log1.ds_log1);                     
   g_rec_fat_mc_log1.id_log1                  :=  null;
   g_rec_fat_mc_log1.id_financeiro            :=  p_rec_mc_aluno.id_financeiro;
   g_rec_fat_mc_log1.nr_matricula             :=  p_rec_mc_aluno.nr_matricula;
   g_rec_fat_mc_log1.id_mc_aluno              :=  p_rec_mc_aluno.id_mc_aluno; 
   pk_fat_mc_dml.p_add_fat_mc_log1( g_rec_fat_mc_log1    
                                  , g_fg_retorno_log   
                                  , g_ds_retorno_log )  ;   
end if;
-- 
-- Atualizar percentual das modalidades FIES no array das modalidades financeira 
if l_financiamento_publico_07         =  'S' and 
   p_rec_financeiro.pc_fator_limite   <= 1   then
   p_atualiza_array_modalidade_competencia_fies( p_rec_financeiro );
end if;    

--
-- Totalizar o modalidades de cobrança
-- -------------------------------------------------------------------------
-- Considerar que o aluno só poderá ter um Convênio de pagamento em vigor
--  5 - Convênio de pagamento
--  7 - Financiamento publico
--  8 - Financiamento privado
-- 11 - Financiamento Unifor - PEX 

if l_convenio_pagamento_05     = 'S' or 
   l_financiamento_publico_07  = 'S' or 
   l_financiamento_privado_08  = 'S' or 
   l_parcelamento_unifor_11    = 'S'  then 
--
   p_distribuir_modalidades_cobranca( p_vt_financeiro_modalidade_aux
                                    , p_rec_financeiro
                                    , p_rec_mc_aluno
                                    , l_nr_sequencia_calc_modalidade );    
--
end if;
--
--  Totalizar a modalidade ALUNO REGULAR
-- -------------------------------------------------------------------------
p_aluno_regular( p_vt_financeiro_modalidade_aux         -- In
               , p_rec_financeiro                       -- In out
               , p_rec_mc_aluno                         -- In 
               , l_nr_sequencia_calc_modalidade   ) ;   -- In out
--          
-- Exibir a distribuição dos valores por competência e modalidade  
if p_fg_exibir         = 'S' then
   
   g_rec_fat_mc_log1.ds_log1 := '--- Valor por modalidade ----------------------------------------------------------------------' || chr(10) || 
                                'Cmp Vendido  Modalidade                                              Pc  PcOrig      Vl Base Vl Modalidade';
   dbms_output.put_line(g_rec_fat_mc_log1.ds_log1);                     
   g_rec_fat_mc_log1.id_log1           :=  null;
   g_rec_fat_mc_log1.id_financeiro     :=  p_rec_mc_aluno.id_financeiro;
   g_rec_fat_mc_log1.nr_matricula      :=  p_rec_mc_aluno.nr_matricula;
   g_rec_fat_mc_log1.id_mc_aluno       :=  p_rec_mc_aluno.id_mc_aluno; 
   pk_fat_mc_dml.p_add_fat_mc_log1( g_rec_fat_mc_log1    
                                  , g_fg_retorno_log    
                                  , g_ds_retorno_log )  ;   
end if;
--dbms_output.put_line( ' ***1 Tam vt_modalidade_competencia:' || vt_modalidade_competencia.count );           
   wid_modalidade     := 0; 
   l_ind_mod_comp      := 1;
   while p_rec_financeiro.mod_comp.last       >=  l_ind_mod_comp loop
--
         l_id_modalidade_ant                   :=  p_rec_financeiro.mod_comp(l_ind_mod_comp).id_modalidade;
         while p_rec_financeiro.mod_comp.last  >=  l_ind_mod_comp and 
               l_id_modalidade_ant              =   p_rec_financeiro.mod_comp(l_ind_mod_comp).id_modalidade loop
--
               g_rec_fat_mc_log1.ds_log1       :=  trim(to_char(p_rec_financeiro.mod_comp(l_ind_mod_comp).nr_competencia,'00'))||
                                                   lpad(trim(to_char(nvl(p_rec_financeiro.mod_comp(l_ind_mod_comp).vl_vendido, 0),'S9999990.00')),9,' ')||'  '||
                                                   rpad(substr(p_rec_financeiro.mod_comp(l_ind_mod_comp).id_modalidade||'-'||
                                                               p_rec_financeiro.mod_comp(l_ind_mod_comp).nm_modalidade  || '[ '||
                                                               p_rec_financeiro.mod_comp(l_ind_mod_comp).nm_modalidade_tipo|| ' ]' ,1,50),50,' ') ||'  '||
                                                  
                                                  lpad(trim(to_char(nvl( p_rec_financeiro.mod_comp(l_ind_mod_comp).pc_modalidade, 0) ,'990.00')),6,' ')||'  '||
                                                  lpad(trim(to_char(nvl( p_rec_financeiro.mod_comp(l_ind_mod_comp).pc_modalidade_original, 0) ,'990.00')),6,' ')||'  '||
                                                  lpad(trim(to_char(nvl( p_rec_financeiro.mod_comp(l_ind_mod_comp).vl_base_calculo,0),'S9999990.00')),11,' ')||'   '||
                                                  lpad(trim(to_char(nvl( p_rec_financeiro.mod_comp(l_ind_mod_comp).vl_modalidade,0),'S9999990.00')),11,' ')
                                                  ||' > '|| p_rec_financeiro.mod_comp(l_ind_mod_comp).tp_apropriacao_titulo
                                                  ||' > '|| p_rec_financeiro.mod_comp(l_ind_mod_comp).st_competencia_modalidade
                                                  ||' >> '||p_rec_financeiro.mod_comp(l_ind_mod_comp).id_modalidade_origem ;
--
              dbms_output.put_line(g_rec_fat_mc_log1.ds_log1);                     
              g_rec_fat_mc_log1.id_log1       :=  null;
              g_rec_fat_mc_log1.id_financeiro :=  p_rec_mc_aluno.id_financeiro;
              g_rec_fat_mc_log1.nr_matricula  :=  p_rec_mc_aluno.nr_matricula;
              g_rec_fat_mc_log1.id_mc_aluno   :=  p_rec_mc_aluno.id_mc_aluno; 
              pk_fat_mc_dml.p_add_fat_mc_log1( g_rec_fat_mc_log1    
                                             , g_fg_retorno_log    
                                             , g_ds_retorno_log  )  ;  
                                              
              l_ind_mod_comp                  := l_ind_mod_comp + 1;
         end loop;
         g_rec_fat_mc_log1.ds_log1             :=  '-' || chr(10) ;
         dbms_output.put_line(g_rec_fat_mc_log1.ds_log1);   
                          
         g_rec_fat_mc_log1.id_log1       :=  null;
         g_rec_fat_mc_log1.id_financeiro :=  p_rec_mc_aluno.id_financeiro;
         g_rec_fat_mc_log1.nr_matricula  :=  p_rec_mc_aluno.nr_matricula;
         g_rec_fat_mc_log1.id_mc_aluno   :=  p_rec_mc_aluno.id_mc_aluno; 
         pk_fat_mc_dml.p_add_fat_mc_log1( g_rec_fat_mc_log1    
                                        , g_fg_retorno_log    
                                        , g_ds_retorno_log  )  ;  
   end loop; 

--    
--dbms_output.put_line( ' ***2 Tam vt_modalidade_competencia:' || vt_modalidade_competencia.count );
-- Exibir a distribuição dos valores por competência  
if p_fg_exibir = 'S' then
   g_rec_fat_mc_log1.ds_log1 :=  '-' || chr(10)||
                                 '--- Valor por competência ---------------------------------------------------------------------'|| chr(10)||
                                 'Cmp      Vendido   Dsc Incond        Bolsa        Saldo     Dsc Cond  Sdo Dsc Cond    Compet'; 
   dbms_output.put_line(g_rec_fat_mc_log1.ds_log1);                     
   g_rec_fat_mc_log1.id_log1                  :=  null;
   g_rec_fat_mc_log1.id_financeiro            :=  p_rec_mc_aluno.id_financeiro;
   g_rec_fat_mc_log1.nr_matricula             :=  p_rec_mc_aluno.nr_matricula;
   g_rec_fat_mc_log1.id_mc_aluno              :=  p_rec_mc_aluno.id_mc_aluno; 
   pk_fat_mc_dml.p_add_fat_mc_log1( g_rec_fat_mc_log1    
                                  , g_fg_retorno_log  
                                  , g_ds_retorno_log );
                                   
   for ind_comp  in p_rec_financeiro.competencia.first .. p_rec_financeiro.competencia.last loop
       g_rec_fat_mc_log1.ds_log1 := trim(to_char( p_rec_financeiro.competencia(ind_comp).nr_competencia,'00'))||'   '||
                                    lpad(trim(to_char(nvl( p_rec_financeiro.competencia(ind_comp).vl_vendido, 0) ,'S9999990.00')),11,' ')||'  '||
                                    lpad(trim(to_char((-1* nvl( p_rec_financeiro.competencia(ind_comp).vl_desconto_incondicional, 0)) ,'S9999990.00')),11,' ')||'  '||
                                    lpad(trim(to_char((-1* nvl( p_rec_financeiro.competencia(ind_comp).vl_bolsa, 0) ),'S9999990.00')),11,' ')||'  '||
                                    lpad(trim(to_char( nvl( p_rec_financeiro.competencia(ind_comp).vl_saldo, 0) ,'S9999990.00')),11,' ')||'  '||
                                    lpad(trim(to_char((-1* nvl( p_rec_financeiro.competencia(ind_comp).vl_desconto_condicional,0) ),'S9999990.00')),11,' ')||'   '||
                                    lpad(trim(to_char( nvl( p_rec_financeiro.competencia(ind_comp).vl_saldo_desc_condicional,0) ,'S9999990.00')),11,' ') ||  '   ' ||
                                    to_char( p_rec_financeiro.competencia(ind_comp).dt_competencia, 'mm/yyyy' ) ||' '
                                    ;  
--
       dbms_output.put_line(g_rec_fat_mc_log1.ds_log1);                     
       g_rec_fat_mc_log1.id_log1                  :=  null;
       g_rec_fat_mc_log1.id_financeiro            :=  p_rec_mc_aluno.id_financeiro;
       g_rec_fat_mc_log1.nr_matricula             :=  p_rec_mc_aluno.nr_matricula;
       g_rec_fat_mc_log1.id_mc_aluno              :=  p_rec_mc_aluno.id_mc_aluno; 
       pk_fat_mc_dml.p_add_fat_mc_log1( g_rec_fat_mc_log1    
                                      , g_fg_retorno_log    
                                      , g_ds_retorno_log  )  ;   
     
   end loop;
end if;
--    
-- Montar vetor de modaldiades "l_vt_financeiro_modalidade_aux" 
-- a partir do record de fincanceiro "p_rec_financeiro"
p_montar_vt_modalidade_competencia_aux( p_rec_financeiro 
                                      , p_vt_modalidade_competencia_aux    );  


-- Gerar array de títulos por competência/modaliade  
-- -------------------------------------------------------------------------
p_array_titulo( p_rec_financeiro
              , p_vt_modalidade_competencia_aux
              , p_qt_titulos_por_competencia_modalidade );    


/*
-- Titulos do Financiamentos(  privado ou pex )   
----------------------------------------------------------------------------
-- Ajustar a distribuição dos títulos gerados por competência de acordo com regra
-- das modalidades de financiamento e parcelamento

if l_financiamento_privado_08                      =  'S' then

   -- Financiamento privado    
   vt_titulo_privado.delete;
   vt_titulo_modalidade_privado.delete;

   p_vt_titulo_gerado_financ_privado( wcd_externo_padrao          -- in     
                                    , wnr_titulo_ultimo           -- in out 
                                    , p_fg_retorno                -- out
                                    , p_ds_retorno )  ;           -- out
   if p_fg_retorno     =   'N'  then 
      raise ex_erro_memoria_calculo; 
   end if;
  
elsif l_parcelamento_unifor_11                                     =   'S' then
   -- Parcelamemto unifor - pex
   p_vt_titulo_gerado_financ_unifor ;    -- in  out  
end if; */

    -- Exibir a composição dos titulos gerados - memória de cálculo
if p_fg_exibir = 'S' then
   g_rec_fat_mc_log1.ds_log1 := '-' || chr(10) || 
                                '--- Títulos --------------------------------------------------------------------------'|| chr(10) || 
                                'Cmp  modalidade             Título        Principal   Dsc Incond        Bolsa     Dsc Cond      Líquido   Pagador'  ; 
   dbms_output.put_line(g_rec_fat_mc_log1.ds_log1);                     
   g_rec_fat_mc_log1.id_log1                  :=  null;
   g_rec_fat_mc_log1.id_financeiro            :=  p_rec_mc_aluno.id_financeiro;
   g_rec_fat_mc_log1.nr_matricula             :=  p_rec_mc_aluno.nr_matricula;
   g_rec_fat_mc_log1.id_mc_aluno              :=  p_rec_mc_aluno.id_mc_aluno; 
   pk_fat_mc_dml.p_add_fat_mc_log1( g_rec_fat_mc_log1    
                                  , g_fg_retorno_log    
                                  , g_ds_retorno_log  )  ;   
end if;                                  
--
   wnr_competencia := 0;
    
   -- Montar array p_vt_titulos_aux com todos os títulos ( preservados + gerados )
   p_montar_vt_titulos_aux( p_rec_financeiro        
                          , '%'       -- Todos os títulos ( preservados + gerados )
                          , p_dt_vencimento_titulo_oferta 
                          , p_vt_titulos_aux );

   --dbms_output.put_line( 'TITULO qtd:' || p_vt_titulos_aux.count );
   for tit in ( select * 
                from table(p_vt_titulos_aux) 
                order by nr_competencia
                       , id_pessoa_cobranca
                       , dt_vencimento  ) loop
                      
       --dbms_output.put_line( 'TITULO - nr_competencia:' ||tit.nr_competencia );
       
       l_liquido_modalidade_aux  :=    nvl(tit.vl_titulo,0) 
                                 -   ( nvl(tit.vl_desconto_incondicional,0) 
                                 +     nvl(tit.vl_bolsa,0)
                                 +     nvl(tit.vl_desconto_condicional,0 )) ;
        if p_fg_exibir = 'S' then                                 
           g_rec_fat_mc_log1.ds_log1 := trim(to_char(tit.nr_competencia,'00'))                                         ||'   '||
                                        rpad( substr( nvl( tit.nm_modalidade, ' ' ),  1,20), 20, ' ' )                                 ||'   '||      
                                        trim(to_char( nvl( tit.id_titulo,0)  ,'000000000'))                              ||'   '||      
                                        lpad(trim(to_char(nvl(tit.vl_titulo,0),'S9999990.00')),11,' ')                 ||'  '||
                                        lpad(trim(to_char(nvl(tit.vl_desconto_incondicional,0),'S9999990.00')),11,' ') ||'  '||
                                        lpad(trim(to_char(nvl(tit.vl_bolsa,0),'S9999990.00')),11,' ')                  ||'  '||
                                        lpad(trim(to_char(nvl(tit.vl_desconto_condicional,0),'S9999990.00')),11,' ')   ||'  '||
                                        lpad(trim(to_char( l_liquido_modalidade_aux,'S9999990.00')),11,' ')            ||'  '||
                                        lpad(trim(to_char( tit.id_pessoa_cobranca ,'99999999')),8,' ')  ; 
           dbms_output.put_line(g_rec_fat_mc_log1.ds_log1);                     
           g_rec_fat_mc_log1.id_log1                  :=  null;
           g_rec_fat_mc_log1.id_financeiro            :=  p_rec_mc_aluno.id_financeiro;
           g_rec_fat_mc_log1.nr_matricula             :=  p_rec_mc_aluno.nr_matricula;
           g_rec_fat_mc_log1.id_mc_aluno              :=  p_rec_mc_aluno.id_mc_aluno; 
           pk_fat_mc_dml.p_add_fat_mc_log1( g_rec_fat_mc_log1    
                                          , g_fg_retorno_log    
                                          , g_ds_retorno_log  )  ;   
        end if;

       -- Montar array p_vt_titulos_aux com todos os títulos ( preservados + gerados )
       p_montar_vt_titulos_modalidade_aux( p_rec_financeiro        
                                         , tit.nr_ind_titulo
                                         , p_vt_titulos_modalidade_aux );
     
       -- Títulos por modalidade 
       -------------------------------------------------------------------------
       -- Apresentar as modalidades a que se destinam os pagamentos primeiro
       for titmod in ( select a.id_modalidade
                            , a.id_modalidade_tipo
                            , a.nm_modalidade
                            , a.id_modalidade_origem
                            , ( a.vl_modalidade * 
                                decode(b.id_modalidade_tipo, 2,-1,3,-1,4,-1,6,-1,+1 ) ) vl_modalidade
                        from table(p_vt_titulos_modalidade_aux) a
                           , ca.fat_modalidade b
                       where a.nr_ind_titulo   =   tit.nr_ind_titulo 
                         and a.id_modalidade   =   b.id_modalidade
                        order by decode(b.id_modalidade_tipo, 2,-1,3,-1,4,-1,6,-1,+1 ) desc
                          , id_modalidade_tipo
                          , id_modalidade
                     )  loop
           
           select '-    '|| 
                  rpad(rpad(titmod.id_modalidade_tipo||'/'||
                            titmod.id_modalidade,11,' ')||
                       substr(titmod.nm_modalidade,1,30)||
                       decode( titmod.id_modalidade_origem, null, ' ',
                               ' Origem ('||   titmod.id_modalidade_origem  ||') ')
                       ,58,' ')||'  '||
                       lpad(trim(to_char(nvl( titmod.vl_modalidade, 0) ,'S9999990.00')),11,' ')

           into   wtx_linha
           from dual;
           if p_fg_exibir = 'S' then         
               g_rec_fat_mc_log1.ds_log1 := wtx_linha ; 
               dbms_output.put_line(g_rec_fat_mc_log1.ds_log1);                     
               g_rec_fat_mc_log1.id_log1                  :=  null;
               g_rec_fat_mc_log1.id_financeiro            :=  p_rec_mc_aluno.id_financeiro;
               g_rec_fat_mc_log1.nr_matricula             :=  p_rec_mc_aluno.nr_matricula;
               g_rec_fat_mc_log1.id_mc_aluno              :=  p_rec_mc_aluno.id_mc_aluno; 
               pk_fat_mc_dml.p_add_fat_mc_log1( g_rec_fat_mc_log1    
                                              , g_fg_retorno_log    
                                              , g_ds_retorno_log  )  ; 
            end if;

       end loop; 
       if p_fg_exibir = 'S' then
           g_rec_fat_mc_log1.ds_log1 := ' '; 
           dbms_output.put_line(g_rec_fat_mc_log1.ds_log1);                     
           g_rec_fat_mc_log1.id_log1                  :=  null;
           g_rec_fat_mc_log1.id_financeiro            :=  p_rec_mc_aluno.id_financeiro;
           g_rec_fat_mc_log1.nr_matricula             :=  p_rec_mc_aluno.nr_matricula;
           g_rec_fat_mc_log1.id_mc_aluno              :=  p_rec_mc_aluno.id_mc_aluno; 
           pk_fat_mc_dml.p_add_fat_mc_log1( g_rec_fat_mc_log1    
                                              , g_fg_retorno_log    
                                              , g_ds_retorno_log  )  ;   
        end if;                                          

   end loop;

--                                                                 
p_fg_retorno   := 'S';
p_ds_retorno   := 'Memória de cáculo efeuada com sucesso.';
--
exception 
when ex_finalizar_memoria_calculo then 
     p_fg_retorno := 'F';
when ex_erro_memoria_calculo then 
     p_fg_retorno := 'N';  
end p_calculo ;
--
-- -----------------------------------------------------------------------------
/*
PROCEDURE: p_percentual_fator_limite
DESENVOLVEDOR: Helane, Haroldo e José Leitão 
OBJETIVO: 
PARÃMETROS:

*/
-- -----------------------------------------------------------------------------
procedure p_percentual_fator_limite
( p_rec_mc_aluno            in out nocopy ca.pk_fat_mc_plt.rec_mc_aluno 
, p_rec_financeiro          in       ca.pk_fat_mc_plt.rec_financeiro  
, p_vl_limite               in out   number
, p_pc_fator_limite         in out   number ) is  
-- 
l_vl_vendido_liquido        number(12, 2);
l_vl_total_desconto         number(12, 2);
--
begin
--
-- Calcular o fator do limite de crédito
l_vl_vendido_liquido     := p_rec_mc_aluno.vl_financeiro ;   
l_vl_total_desconto      := 0;
if p_rec_financeiro.competencia.count > 0 then
   for ind in p_rec_financeiro.competencia.first .. p_rec_financeiro.competencia.last  loop
       l_vl_total_desconto               :=   l_vl_total_desconto
                                         +    abs( p_rec_financeiro.competencia(ind).vl_desconto_incondicional ) 
                                         +    abs( p_rec_financeiro.competencia(ind).vl_bolsa )
                                         +    abs( p_rec_financeiro.competencia(ind).vl_desconto_condicional );

   end loop;
end if;
--
p_vl_limite                             :=  p_vl_limite  / ( 1 - ( l_vl_total_desconto / p_rec_mc_aluno.vl_financeiro ) );
--
-- Quando l_vl_limite igual a Zero, indica que o Financioamento não tem limite 
if nvl( p_vl_limite, 0 ) < l_vl_vendido_liquido  then
   if l_vl_vendido_liquido  =  0 then
      p_pc_fator_limite                 :=   1;
   else
      p_pc_fator_limite                 :=   nvl( p_vl_limite, 0) / l_vl_vendido_liquido; 
--   
      if nvl( p_pc_fator_limite,0) = 0   then
         p_pc_fator_limite              :=   1;
      end if; 
--
   end if;
else
   p_pc_fator_limite                    :=   1;         
end if;
--
end p_percentual_fator_limite;
--   
-- -----------------------------------------------------------------------------
/*
PROCEDURE: p_atualiza_base_calculo_competencia
DESENVOLVEDOR: Helane, Haroldo e José Leitão 
OBJETIVO: Atualizar a base de cálculo do array de competêcia
PARÃMETROS:
    1 - p_rec_financeiro
    2 - p_nr_ind_competencia

*/
-- -----------------------------------------------------------------------------
procedure p_atualiza_base_calculo_competencia
( p_rec_financeiro     in out nocopy ca.pk_fat_mc_plt.rec_financeiro 
, p_nr_ind_competencia in number ) is
--
begin
-- Atualizar base de cálculo  
----------------------------------------------------------------------------
p_rec_financeiro.competencia(p_nr_ind_competencia).vl_saldo                   
                             :=   nvl( p_rec_financeiro.competencia(p_nr_ind_competencia).vl_vendido, 0)
                             -  ( nvl( p_rec_financeiro.competencia(p_nr_ind_competencia).vl_desconto_incondicional,0) 
                             +    nvl( p_rec_financeiro.competencia(p_nr_ind_competencia).vl_bolsa, 0) );
p_rec_financeiro.competencia(p_nr_ind_competencia).vl_saldo_desc_condicional  
                             :=   nvl( p_rec_financeiro.competencia(p_nr_ind_competencia).vl_vendido, 0) 
                             -  ( nvl( p_rec_financeiro.competencia(p_nr_ind_competencia).vl_desconto_incondicional, 0)  
                             +    nvl( p_rec_financeiro.competencia(p_nr_ind_competencia).vl_bolsa, 0) 
                             +    nvl( p_rec_financeiro.competencia(p_nr_ind_competencia).vl_desconto_condicional, 0) );
   
end p_atualiza_base_calculo_competencia;
--
-- -----------------------------------------------------------------------------
/*
PROCEDURE: P_VALIDACAO_MC
DESENVOLVEDOR: Helane, Haroldo e José Leitão 
OBJETIVO: Validação dos dados que serão utilizado na MC
PARÂMETROS:

*/
-- -----------------------------------------------------------------------------
procedure p_validacao_mc
( p_rec_mc_aluno         in out nocopy ca.pk_fat_mc_plt.rec_mc_aluno
, p_vt_mc_disciplina     in out nocopy ca.pk_fat_mc_plt.ar_mc_disciplina 
, p_dt_processamento     in     date
, p_fg_retorno           out    varchar2
, p_ds_retorno           out    varchar2 ) is
--
begin
--
p_validar_dados( p_rec_mc_aluno    
               , p_vt_mc_disciplina      
               , p_fg_retorno    
               , p_ds_retorno );
--
if p_fg_retorno   = 'N' then
   raise ex_erro_memoria_calculo;
end if; 
--
p_buscar_informacoes( p_rec_mc_aluno    
                    , p_vt_mc_disciplina 
                    , p_dt_processamento
                    , p_fg_retorno    
                    , p_ds_retorno );
--
if p_fg_retorno   = 'N' then
   raise ex_erro_memoria_calculo;
end if; 
--
-- 
-- !!* Aqui -
/*
p_autorizacao_matricula( p_rec_mc_aluno       
                       , p_vt_mc_disciplina  
                       , p_array_modalidade
                       , p_dt_processamento
                       , p_fg_retorno    
                       , p_ds_retorno );    
--
if p_fg_retorno   = 'N' then
   raise ex_erro_memoria_calculo;
end if;
*/
--
p_fg_retorno     := 'S';
--
exception
when ex_erro_memoria_calculo then 
     p_fg_retorno := 'N'; 
end p_validacao_mc;
--   
-----------------------------------------------------------------------------
/*
PROCEDURE: p_distribuir_semestre_competencia
DESENVOLVEDOR: Helane, Haroldo e José Leitão 
OBJETIVO: Distribuir os valores vendidos por competência
PARÂMETROS:
   1 - p_rec_financeiro
   2 - p_rec_mc_aluno
   3 - p_vt_titulos_preservados_aux
   4 - p_vt_mensalidade_pg

*/
-- -----------------------------------------------------------------------------
procedure p_distribuir_semestre_competencia    
( p_rec_financeiro              in out nocopy ca.pk_fat_mc_plt.rec_financeiro
, p_rec_mc_aluno                in     ca.pk_fat_mc_plt.rec_mc_aluno 
, p_vt_titulos_preservados_aux  in ca.pk_fat_mc_plt.vt_titulo_aux
, p_vt_mensalidade_pg           in     ca.pk_fat_mc_plt.ar_mensalidade_pg      )   is
--
cursor cr_total_titulo_preservado( pc_nr_competencia  in number ) is
select sum( vl_titulo_mc )
from   ( select distinct id_modalidade 
              , vl_titulo_mc  
           from table( p_vt_titulos_preservados_aux )
           where nr_competencia     = pc_nr_competencia );
--    
cursor cr_titulo_preservado( pc_nr_competencia  in number ) is
select * 
from table( p_vt_titulos_preservados_aux )  ;
--
wvl_apropriado             number := 0;
wvl_resto                  number := 0;
wvl_vendido_cmpt_outra     number;
wvl_vendido_cmpt_3         number; 
l_qt_comp_apos2a           number(2); 
--
begin
-- Distribuição da semestralidade por competência 
----------------------------------------------------------------------------

if  p_rec_mc_aluno.tp_arquivo     =   1  then
   -- Processar somente para graduação
    wvl_apropriado      :=  0;
    wvl_resto           :=  0;
    
    if p_rec_financeiro.qt_competencia_preservada     <=  2 then
       l_qt_comp_apos2a                :=  p_rec_financeiro.qt_competencia  - 2; 
    else
       l_qt_comp_apos2a                :=  p_rec_financeiro.qt_competencia  - 
                                           p_rec_financeiro.qt_competencia_preservada; 
    end if;
    --dbms_output.put_line( '===> P_DISTRIBUIR_SEMESTRE_COMPETENCIA - QT COMP::' || p_rec_financeiro.qt_competencia ||  
    --                      ' comp ini:' || p_rec_financeiro.nr_competencia_inicio || 
    --                      ' Comp fim:' || p_rec_financeiro.nr_competencia_fim  ||
    --                      ' l_qt_comp_apos2a:' || l_qt_comp_apos2a ||  
    --                      ' qt_pres:' || p_rec_financeiro.qt_competencia_preservada  ||
    --                      ' Comp_shif:' || p_rec_financeiro.qt_competencia_shift );
    --dbms_output.put_line( '===> P_DISTRIBUIR_SEMESTRE_COMPETENCIA' );
    
    -- Popular o array "vt_valor_competencia" com os valores vendidos por competência
    for ind in 1 .. p_rec_financeiro.nr_competencia_fim loop
        --dbms_output.put_line( '  * ind:' || ind );  
         
        p_rec_financeiro.competencia(ind).nr_competencia            := ind + p_rec_financeiro.qt_competencia_shift ; 
        p_rec_financeiro.competencia(ind).vl_vendido                := 0;
        p_rec_financeiro.competencia(ind).vl_desconto_incondicional := 0;
        p_rec_financeiro.competencia(ind).vl_bolsa                  := 0;
        p_rec_financeiro.competencia(ind).vl_desconto_condicional   := 0;
        p_rec_financeiro.competencia(ind).vl_saldo                  := 0;
        p_rec_financeiro.competencia(ind).vl_aluno                  := 0;
        p_rec_financeiro.competencia(ind).vl_convenio               := 0;
        p_rec_financeiro.competencia(ind).vl_saldo_desc_condicional := 0; 
        
        if ind                                                      =  1   then
           p_rec_financeiro.competencia(ind).uf_competencia         := rc5.qt_unidade_titulo_01;
        elsif ind                                                   =  2   then
           p_rec_financeiro.competencia(ind).uf_competencia         := rc5.qt_unidade_titulo_02;
        else
           p_rec_financeiro.competencia(ind).uf_competencia         := 0;
        end if;

        p_academico_titulo( p_rec_mc_aluno.id_academico
                          , p_rec_financeiro.competencia(ind).nr_competencia  
                          , p_rec_financeiro.competencia(ind).id_academico_titulo
                          , p_rec_financeiro.competencia(ind).dt_competencia );   
        --dbms_output.put_line( '2 - ind:' || ind ||  
        --                  ' g_nr_competencia_inicio:' || g_nr_competencia_inicio ||  
        --                  ' qt_tit_preservado:' || g_vet_titulos_preservados.count );                   
        if ind            <  ( p_rec_financeiro.nr_competencia_inicio + p_rec_financeiro.qt_competencia_preservada  )   then
            -- Titulos preservados ( não podem ser cancelados )
            if p_rec_financeiro.competencia.count   > 0  then
            
               p_rec_financeiro.competencia(ind).vl_vendido                := 0;
               
               --dbms_output.put_line( ' ** preservados por competencia - intervalo:'|| p_rec_financeiro.competencia.first
               --                   || ' - ' || p_rec_financeiro.competencia.last );

               for indice in p_rec_financeiro.competencia.first .. p_rec_financeiro.competencia.last loop
                   --dbms_output.put_line( '   *Indice:'|| indice || ' - competencia: ' || p_rec_financeiro.competencia( indice ).nr_competencia||
                   --                     ' ind/shift:' || ind || '/' ||p_rec_financeiro.qt_competencia_shift );
                                         
                   if p_rec_financeiro.competencia( indice ).nr_competencia = ind + p_rec_financeiro.qt_competencia_shift then 
                     
                       --dbms_output.put_line( '     >>   competencia: ' || p_rec_financeiro.competencia( indice ).nr_competencia);
                    
                       --for st_tit in cr_titulo_preservado( p_rec_financeiro.competencia( indice ).nr_competencia ) loop
                       --    dbms_output.put_line( '         mod: ' || st_tit.id_modalidade || 
                       --                          ' comp:' || st_tit.nr_competencia||
                       --                          ' vl tit:' || st_tit.vl_titulo||
                       --                          ' vl tit mc:' || st_tit.vl_titulo_mc ||
                       --                          ' Pessoa:' || st_tit.id_pessoa_cobranca  );
                       --end loop;
                   
                   
                      open cr_total_titulo_preservado(  p_rec_financeiro.competencia( indice ).nr_competencia  );   
                      fetch cr_total_titulo_preservado into p_rec_financeiro.competencia(ind).vl_vendido ;
                      close cr_total_titulo_preservado;
                                                     
                      p_rec_financeiro.competencia(ind).nr_competencia       := p_rec_financeiro.competencia( indice ).nr_competencia ;
                   end if;
               end loop; 
               
            end if;
            wvl_apropriado                      := wvl_apropriado  
                                                +  p_rec_financeiro.competencia(ind).vl_vendido;
            wvl_resto                           := p_rec_financeiro.vl_financeiro  
                                                -  wvl_apropriado;
            wvl_vendido_cmpt_outra              := trunc((wvl_resto / l_qt_comp_apos2a ),2);
            --dbms_output.put_line( '       A (PRESERVADO) ind:' || ind || 
            --                      ' vl_vendido:' ||  p_rec_financeiro.competencia(ind).vl_vendido||
            --                      ' Apropriado:' ||  wvl_apropriado || ' wvl_resto:' || wvl_resto ||
            --                      ' wvl_vendido_cmpt_outra:' || wvl_vendido_cmpt_outra ||
            --                      ' l_qt_comp_apos2a:' || l_qt_comp_apos2a );   
        else 
            -- Se valor do semestre maior que somatório apropriado 
            if p_rec_financeiro.vl_financeiro   >  wvl_apropriado then
               --dbms_output.put_line( '       Distribuicao de competencia - Indice: ' || ind ); 
               -- Critério da 1a mensalidade
               if ind                                     =  1 then
                  -- Valor do semestre menor ou igual a Parcela 1
                  --dbms_output.put_line( '    vl_titulo_01: ' || rc5.vl_titulo_01||
                  --                      ' vl_financeiro:' || p_rec_financeiro.vl_financeiro|| 
                  --                      ' vl_financeiro_preservado:'||p_rec_financeiro.vl_financeiro_preservado ); 
                  if p_rec_financeiro.vl_financeiro       <= rc5.vl_titulo_01 then
                     p_rec_financeiro.competencia(ind).vl_vendido := p_rec_financeiro.vl_financeiro; 
                  else
                  -- Valor do semestre maior que a parcela 1
                     p_rec_financeiro.competencia(ind).vl_vendido := rc5.vl_titulo_01;
                  end if;

                  wvl_apropriado                           := p_rec_financeiro.competencia(ind).vl_vendido ; 
                  
                  wvl_resto                                := p_rec_financeiro.vl_financeiro  
                                                           -  wvl_apropriado;
                  --dbms_output.put_line( '  IND1  - vendido:' ||p_rec_financeiro.competencia(ind).vl_vendido ||
                  --                      ' wvl_apropriado: ' || wvl_apropriado||
                  --                      ' wvl_resto:' || wvl_resto ); 
                  -- Critério da 2a mensalidade
               elsif ind = 2 then
                  -- Resto a pagar menor ou igual a parcela 2  
                  if wvl_resto                            <= rc5.vl_titulo_02 then 
                     p_rec_financeiro.competencia(ind).vl_vendido := wvl_resto;
                     --dbms_output.put_line( '   E2 - wvl_resto: ' || wvl_resto || ' rc5.vl_titulo_02:' || rc5.vl_titulo_02  );  
                  else
                  -- Resto a pagar maior que a parcela 2  
                     p_rec_financeiro.competencia(ind).vl_vendido := rc5.vl_titulo_02;
                     
                  
                  end if;
                  wvl_apropriado                          := wvl_apropriado 
                                                          +  p_rec_financeiro.competencia(ind).vl_vendido;

                  wvl_resto                               := wvl_resto 
                                                          -  p_rec_financeiro.competencia(ind).vl_vendido
                                                          ;  
                  --dbms_output.put_line( '  IND2 - vendido:' ||p_rec_financeiro.competencia(ind).vl_vendido ||
                  --                      '  wvl_apropriado: ' || wvl_apropriado||
                  --                      ' wvl_resto:' || wvl_resto ); 

               -- Critério da 3a mensalidade
               elsif ind = 3 then 
                  -- Ajuste de diferencas de calculo ( centavos ) 
                  wvl_vendido_cmpt_outra                  := trunc((wvl_resto / l_qt_comp_apos2a ),2);
                  p_rec_financeiro.competencia(ind).vl_vendido    := wvl_vendido_cmpt_outra 
                                                          + (wvl_resto - (l_qt_comp_apos2a * wvl_vendido_cmpt_outra )); 
                                                                                                                           
                  wvl_apropriado                          := wvl_apropriado 
                                                          +  p_rec_financeiro.competencia(ind).vl_vendido;   
                                                          

               

                  --dbms_output.put_line( '      IND3 - vendido:' ||p_rec_financeiro.competencia(ind).vl_vendido ||
                  --                     ' Vl parcelas:' || wvl_vendido_cmpt_outra ||
                  --                      ' wvl_apropriado: ' || wvl_apropriado||
                  --                      ' wvl_resto:' || wvl_resto ); 
               -- Critério das demais mensalidades  
               else 
                  p_rec_financeiro.competencia(ind).vl_vendido    
                                                          := wvl_vendido_cmpt_outra;
                  wvl_apropriado                          := wvl_apropriado 
                                                          +  p_rec_financeiro.competencia(ind).vl_vendido;     

                  --dbms_output.put_line( '  IND'|| ind || ' - vendido:' ||p_rec_financeiro.competencia(ind).vl_vendido ||
                  --                      ' wvl_apropriado: ' || wvl_apropriado||
                  --                      ' wvl_resto:' || wvl_resto ); 

               end if; 
            else 
               p_rec_financeiro.competencia(ind).vl_vendido       := 0;
                
            end if;
            --dbms_output.put_line( '   ind:' || ind || 
            --                      ' vl_vendido:' || p_rec_financeiro.competencia(ind).vl_vendido ||
            --                      ' Apropriado:' ||  wvl_apropriado || ' wvl_resto:' || wvl_resto ||
            --                      ' wvl_vendido_cmpt_outra:' || wvl_vendido_cmpt_outra ||
            --                      ' l_qt_comp_apos2a:' || l_qt_comp_apos2a  );  
        end if;
        p_atualiza_base_calculo_competencia( p_rec_financeiro   
                                           , ind ) ;
    end loop;
elsif  p_rec_mc_aluno.tp_arquivo     =   3  then
    -- Pos-graduacao
    for ind in p_rec_financeiro.nr_competencia_inicio .. p_rec_financeiro.nr_competencia_fim loop
        p_rec_financeiro.competencia(ind).nr_competencia                := ind;
        p_rec_financeiro.competencia(ind).vl_desconto_incondicional     := 0;
        p_rec_financeiro.competencia(ind).vl_bolsa                      := 0;
        p_rec_financeiro.competencia(ind).vl_desconto_condicional       := 0;
        p_rec_financeiro.competencia(ind).vl_saldo                      := 0;
        p_rec_financeiro.competencia(ind).vl_aluno                      := 0;
        p_rec_financeiro.competencia(ind).vl_convenio                   := 0;
        p_rec_financeiro.competencia(ind).vl_saldo_desc_condicional     := 0; 
        
        
        p_academico_titulo( p_rec_mc_aluno.id_academico
                          , p_rec_financeiro.competencia(ind).nr_competencia  
                          , p_rec_financeiro.competencia(ind).id_academico_titulo
                          , p_rec_financeiro.competencia(ind).dt_competencia ); 
        p_rec_financeiro.competencia(ind).vl_vendido                    := p_vt_mensalidade_pg(ind).vl_mensalidade;

        p_atualiza_base_calculo_competencia( p_rec_financeiro   
                                           , ind ) ;
    end loop;
end if;  
end p_distribuir_semestre_competencia ; 
    
-- -----------------------------------------------------------------------------
/*
PROCEDURE: p_desconto_incondicional 
DESENVOLVEDOR: Helane, Haroldo e José Leitão 
OBJETIVO: Atualizar os arrays de competencia ( vt_valor_competencia ) e competencia
          modalidade ( vt_modalidade_competencia ) com os descontos incondicionais
PARÂMETROS:
   1 - p_vt_modalidade_financeiro_aux
   2 - p_rec_financeiro
   3 - p_rec_mc_aluno
   4 - p_nr_sequencia_calc_modalidade
   5 - p_fg_retorno
   6 - p_ds_retorno

*/
-- -----------------------------------------------------------------------------
procedure p_desconto_incondicional
( p_vt_modalidade_financeiro_aux  in     ca.pk_fat_mc_plt.vt_fin_modalidade_aux
, p_rec_financeiro                in  out nocopy  ca.pk_fat_mc_plt.rec_financeiro
, p_rec_mc_aluno                  in     ca.pk_fat_mc_plt.rec_mc_aluno 
, p_nr_sequencia_calc_modalidade  in  out nocopy   number
, p_fg_retorno                    out    varchar2
, p_ds_retorno                    out    varchar2 ) is
--   
l_vl_diferenca              number; 
st_di                       c1_modalidade%rowtype;
--
begin
--
-- dbms_output.put_line( ' >>>>>>>>>>> p_desconto_incondicional ---' );

-- p_atualiza_base_calculo_competencia( p_rec_financeiro );
open  c1_modalidade( p_vt_modalidade_financeiro_aux, 3 );
fetch c1_modalidade  into st_di;
while c1_modalidade%found loop
     --dbms_output.put_line( '***DI   Modalidade:' || st_di.id_modalidade );
   -- 2 - Desconto incondicional
   -- 3 - Desconto condicional ( convertidos para incondicional )
   -- 4 - Convênio de desconto
   if st_di.id_modalidade_tipo in ( 2, 3, 4 ) then
   
      l_vl_diferenca    := nvl( st_di.vl_modalidade 
                                - trunc( st_di.vl_modalidade / p_rec_financeiro.qt_competencia , 2 ) 
                                  * p_rec_financeiro.qt_competencia, 0);
                        
      --l_ind_mod        := 0;
      for ind_comp in 1 .. p_rec_financeiro.nr_competencia_fim  loop
         --dbms_output.put_line( ' IND:' || ind_comp || '  vendido:' || p_rec_financeiro.competencia(ind_comp).vl_vendido||
         --                      ' comp fim:' || p_rec_financeiro.nr_competencia_fim  ||
         --                      ' Saldo:' || p_rec_financeiro.competencia(ind_comp).vl_saldo );
         if p_rec_financeiro.competencia(ind_comp).vl_vendido       >   0 then
             p_nr_sequencia_calc_modalidade                         :=  p_nr_sequencia_calc_modalidade + 1;
             p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).nr_sequencia_calculo       
                                                                    :=  p_nr_sequencia_calc_modalidade;
             p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).nr_competencia
                                                                    :=  p_rec_financeiro.competencia(ind_comp).nr_competencia; 
             p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).nr_ind_financ_competencia
                                                                    :=  p_rec_financeiro.competencia(ind_comp).nr_competencia;
             p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).nr_ind_financ_modalidade
                                                                    :=  st_di.nr_ind_modalidade;

             --p_academico_titulo( p_rec_mc_aluno.id_academico
             --                  , p_rec_financeiro.competencia(ind).nr_competencia  
             --                  , p_rec_financeiro.competencia(ind).modalidade(l_ind_comp).id_academico_titulo  -- out
             --                  , p_rec_financeiro.competencia(ind).modalidade(l_ind_comp).dt_competencia   );  -- out  

             p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).id_modalidade             
                                                                    :=  st_di.id_modalidade;
             p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).id_modalidade_tipo        
                                                                    :=  st_di.id_modalidade_tipo;
             p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).nm_modalidade_tipo        
                                                                    :=  st_di.nm_modalidade_tipo;

             p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).id_pessoa_cobranca        
                                                                    :=  st_di.id_pessoa_cobranca;
             p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).tp_apropriacao_titulo     
                                                                    :=  'I'; -- Desconto incondicial
             p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).st_competencia_modalidade 
                                                                    :=  'A';
             p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).nm_modalidade         
                                                                    :=  st_di.nm_modalidade;
             
             p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).vl_vendido       
                                                                    :=  p_rec_financeiro.competencia(ind_comp).vl_vendido;  
             p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).vl_base_calculo    
                                                                    :=  p_rec_financeiro.competencia(ind_comp).vl_saldo ;  
             p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).vl_modalidade     
                                                                    :=  0;
             p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).pc_modalidade             
                                                                    :=  0;
             p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).pc_modalidade_original    
                                                                    :=  0;
             p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).id_financeiro_modalidade  
                                                                    :=  f_financeiro_modalidade( p_rec_mc_aluno
                                                                                               , st_di.id_modalidade  ); 
             p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).cd_externo_padrao
                                                                    :=  st_di.cd_externo_padrao;
             if  st_di.id_modalidade_tipo               =   2   
                 and ( st_di.cd_externo_padrao          =   'DESCONTO_DE_VALOR_PRIMEIRA'
                       and ind_comp                     =   1 ) 
                 or ( st_di.cd_externo_padrao           =   'DESCONTO_DE_VALOR' )   then 
                    p_desconto_incondicional_valor( p_rec_financeiro 
                                                  , st_di.cd_modalidade_externo
                                                  , ind_comp
                                                  , p_nr_sequencia_calc_modalidade 
                                                  , st_di.vl_modalidade
                                                  , l_vl_diferenca  );    -- Parcela   
                             
             elsif ( st_di.id_modalidade_tipo           =   2 
                and     nvl(st_di.cd_externo_padrao,'X')  not  in ( 'DESCONTO_DE_VALOR_PRIMEIRA', 'DESCONTO_DE_VALOR')) 
                or    ( st_di.id_modalidade_tipo          in   ( 3, 4 ) 
                and     nvl(st_di.cd_externo_padrao,'X')  =    'DESC_INCONDICIONAL_PRIMEIRA' ) then 
                    p_desconto_incondicional_percentual( p_rec_financeiro
                                                       , p_rec_mc_aluno 
                                                       , st_di.cd_modalidade_externo
                                                       , st_di.cd_externo_padrao
                                                       , ind_comp
                                                       , p_nr_sequencia_calc_modalidade 
                                                       , st_di.id_modalidade
                                                       , st_di.id_modalidade_tipo
                                                       , st_di.pc_modalidade
                                                       , l_vl_diferenca
                                                       , p_ds_retorno 
                                                       , p_fg_retorno );   
                                        
                    if p_fg_retorno                  =   'N'  then 
                       --dbms_output.put_line( '** Erro DI - IND:' || ind_comp || '#' || l_ind_mod || 
                       --                      ' retorno:' || p_ds_retorno ); 
                       raise ex_erro_memoria_calculo; 
                    end if;
                    
             end if;
             p_atualiza_base_calculo_competencia ( p_rec_financeiro, ind_comp);
             
             -- dbms_output.put_line( ' DI - '|| p_nr_sequencia_calc_modalidade|| ' id Mod:' || p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).id_modalidade );
             --                      ' VL DI:'  || p_rec_financeiro.competencia(ind_comp).modalidade(l_ind_mod).vl_modalidade ||
             --                      ' vl vend mod:' || p_rec_financeiro.competencia(ind_comp).modalidade(l_ind_mod).vl_vendido 
             --                   ); 
          end if; 
       
      end loop;
   end if; 

   fetch c1_modalidade  into st_di;
end loop; 
close c1_modalidade;
--
exception 
 when ex_erro_memoria_calculo  then
      p_fg_retorno    := 'N';
end p_desconto_incondicional;     
--
-- -----------------------------------------------------------------------------
/*
PROCEDURE: p_desconto_incondicional_percentual
DESENVOLVEDOR: Helane, Haroldo e José Leitão 
OBJETIVO: Atualizar os arrays de competencia ( vt_valor_competencia ) e competencia
          modalidade ( vt_modalidade_competencia ) com os descontos incondicionais
          em percentual
PARÂMETROS:
   1 - p_tem_modalidade
   2 - p_ind_parcela
   3 - p_fg_retorno
   4 - p_ds_retorno
*/
-- -----------------------------------------------------------------------------
procedure p_desconto_incondicional_percentual
( p_rec_financeiro           in out nocopy ca.pk_fat_mc_plt.rec_financeiro
, p_rec_mc_aluno             in     ca.pk_fat_mc_plt.rec_mc_aluno 
, p_cd_modalidade_externo    in     ca.fat_modalidade.cd_modalidade_externo%type
, p_cd_externo_padrao        in     ca.fat_modalidade.cd_externo_padrao%type 
, p_ind_competencia          in     number
, p_ind_modalidade_comp      in     number  
, p_id_modalidade            in     ca.fat_modalidade.id_modalidade%type 
, p_id_modalidade_tipo       in     ca.fat_modalidade_tipo.id_modalidade_tipo%type 
, p_pc_modalidade            in     number
, p_vl_diferenca             in     number 
, p_fg_retorno               out    varchar2
, p_ds_retorno               out    varchar2 ) is
--
st_desc_inc                       c3_desconto_incondicional%rowtype;
--
begin
--
p_rec_financeiro.mod_comp(p_ind_modalidade_comp).vl_modalidade           := 0;
p_rec_financeiro.mod_comp(p_ind_modalidade_comp).pc_modalidade           := p_pc_modalidade;
p_rec_financeiro.mod_comp(p_ind_modalidade_comp).pc_modalidade_original  := p_pc_modalidade;
--
if p_id_modalidade_tipo = 2
   and 
   nvl(p_cd_modalidade_externo,'X') not in ( 'DESCONTO_DE_VALOR_PRIMEIRA', 'DESCONTO_DE_VALOR') 
   then  
   if nvl( p_cd_externo_padrao, 'X' ) = 'DESCONTO_A_PARTIR_DA_SEGUNDA' 
      then
      -- A parti da 2a mensalidade
      if p_ind_competencia > 1 
          then
          p_rec_financeiro.mod_comp(p_ind_modalidade_comp).vl_modalidade         
                                            :=    trunc(p_rec_financeiro.mod_comp(p_ind_modalidade_comp).vl_base_calculo 
                                            *     (p_rec_financeiro.mod_comp(p_ind_modalidade_comp).pc_modalidade/100),2);
          p_rec_financeiro.competencia(p_ind_competencia).vl_desconto_incondicional  
                                            :=    p_rec_financeiro.competencia(p_ind_competencia).vl_desconto_incondicional  
                                            +     p_rec_financeiro.mod_comp(p_ind_modalidade_comp).vl_modalidade;
         --p_tem_modalidade                   := p_tem_modalidade + 1;
       end if;
   elsif nvl( p_cd_externo_padrao, 'X' ) = 'DESCONTO_A_PARTIR_DA_TERCEIRA' 
      then
      -- A parti da 3a mensalidade
      if p_ind_competencia > 2 
          then
          p_rec_financeiro.mod_comp(p_ind_modalidade_comp).vl_modalidade
                                           :=     trunc(p_rec_financeiro.mod_comp(p_ind_modalidade_comp).vl_base_calculo 
                                           *      (p_rec_financeiro.mod_comp(p_ind_modalidade_comp).pc_modalidade/100),2);
          p_rec_financeiro.competencia(p_ind_competencia).vl_desconto_incondicional
                                           :=     p_rec_financeiro.competencia(p_ind_competencia).vl_desconto_incondicional
                                           +      p_rec_financeiro.mod_comp(p_ind_modalidade_comp).vl_modalidade;
       --   p_tem_modalidade                                              :=  p_tem_modalidade + 1;
       end if;
--
   else
      p_rec_financeiro.mod_comp(p_ind_modalidade_comp).vl_modalidade            
                                           :=    trunc(p_rec_financeiro.mod_comp(p_ind_modalidade_comp).vl_base_calculo  
                                           *     (p_rec_financeiro.mod_comp(p_ind_modalidade_comp).pc_modalidade/100),2);
      if p_ind_competencia = 1
         and 
         p_vl_diferenca <> 0 
         then 
         p_rec_financeiro.mod_comp(p_ind_modalidade_comp).vl_modalidade
                                           :=    p_rec_financeiro.mod_comp(p_ind_modalidade_comp).vl_modalidade 
                                           +     p_vl_diferenca;
      end if;

      p_rec_financeiro.competencia(p_ind_competencia).vl_desconto_incondicional    
                                           :=    nvl( p_rec_financeiro.competencia(p_ind_competencia).vl_desconto_incondicional, 0) 
                                           +     p_rec_financeiro.mod_comp(p_ind_modalidade_comp).vl_modalidade;
      --p_tem_modalidade                     :=  p_tem_modalidade + 1;
   end if;

elsif p_id_modalidade_tipo in ( 3,4 ) 
   and 
   nvl(p_cd_externo_padrao,'X') = 'DESC_INCONDICIONAL_PRIMEIRA'  
   then
   -- 3 - Desconto condicional
   -- 4 - Convênio de desconto

   if nvl( p_cd_externo_padrao, 'X' ) = 'DESC_INCONDICIONAL_PRIMEIRA' 
      and 
      p_ind_competencia = 1 
      then
         --
         -- Converter desconto condicional em incondicional
      open  c3_desconto_incondicional;
      fetch c3_desconto_incondicional into st_desc_inc;
      if c3_desconto_incondicional%notfound then
         close c3_desconto_incondicional; 
         p_ds_retorno := 'Modalidade incondicional 139, de uso exclusivo do sistema, não encontrada.' ;
         raise ex_erro_memoria_calculo;
      end if;
      close c3_desconto_incondicional;
--
      p_rec_financeiro.mod_comp(p_ind_modalidade_comp).id_modalidade_origem    
                                           :=    p_id_modalidade;
      p_rec_financeiro.mod_comp(p_ind_modalidade_comp).id_modalidade_tipo_origem  
                                           :=    p_id_modalidade_tipo;
      p_rec_financeiro.mod_comp(p_ind_modalidade_comp).id_modalidade 
                                           :=    st_desc_inc.id_modalidade;
      p_rec_financeiro.mod_comp(p_ind_modalidade_comp).nm_modalidade           
                                           :=    st_desc_inc.nm_modalidade;
      p_rec_financeiro.mod_comp(p_ind_modalidade_comp).id_modalidade_tipo      
                                           :=    st_desc_inc.id_modalidade_tipo; 
      p_rec_financeiro.mod_comp(p_ind_modalidade_comp).vl_modalidade           
                                           :=    trunc(trunc(p_rec_financeiro.mod_comp(p_ind_modalidade_comp).vl_base_calculo 
                                           *     (p_rec_financeiro.mod_comp(p_ind_modalidade_comp).pc_modalidade/100),2));  
      -- !!* Aqui -  Verifica se diferenca na 1a mensalidade
      if p_ind_competencia = 1
         and 
         p_vl_diferenca <> 0 
         then 
         p_rec_financeiro.mod_comp(p_ind_modalidade_comp).vl_modalidade       
                                           :=    p_rec_financeiro.mod_comp(p_ind_modalidade_comp).vl_modalidade 
                                           +     p_vl_diferenca;
      end if;
--
      p_rec_financeiro.competencia(p_ind_competencia).vl_desconto_incondicional   
                                           :=    p_rec_financeiro.competencia(p_ind_competencia).vl_desconto_incondicional
                                           +     p_rec_financeiro.mod_comp(p_ind_modalidade_comp).vl_modalidade;
       --p_tem_modalidade                                                 := p_tem_modalidade + 1;

   end if;
--
   p_rec_financeiro.mod_comp(p_ind_modalidade_comp).id_financeiro_modalidade    
                                           :=    f_financeiro_modalidade( p_rec_mc_aluno 
                                                                        , p_rec_financeiro.mod_comp(p_ind_modalidade_comp).id_modalidade  ); 
--
end if;
--
exception 
when ex_erro_memoria_calculo  then
     p_fg_retorno    := 'N';
end p_desconto_incondicional_percentual;     
--
-- -----------------------------------------------------------------------------
/*
PROCEDURE: p_desconto_incondicional_valor
DESENVOLVEDOR: Helane, Haroldo e José Leitão 
OBJETIVO: Atualizar os arrays de competencia ( vt_valor_competencia ) e competencia
          modalidade ( vt_valor_competencia_modalidade ) com os descontos incondicionais
          em valor
PARÂMETROS:
    1 - p_rec_financeiro
    2 - p_cd_modalidade_externo
    1 - p_ind_competencia
    2 - p_ind_modalidade_comp
    1 - p_vl_modalidade
    2 - p_vl_diferenca

*/
-- -----------------------------------------------------------------------------
procedure p_desconto_incondicional_valor( p_rec_financeiro          in out nocopy ca.pk_fat_mc_plt.rec_financeiro
                                        , p_cd_modalidade_externo   in            ca.fat_modalidade.cd_modalidade_externo%type
                                        , p_ind_competencia         in        number
                                        , p_ind_modalidade_comp     in        number   
                                        , p_vl_modalidade           in        number        
                                        , p_vl_diferenca            in        number   )  is
--
begin
--
p_rec_financeiro.mod_comp(p_ind_modalidade_comp).pc_modalidade           :=  0;
p_rec_financeiro.mod_comp(p_ind_modalidade_comp).pc_modalidade_original  :=  0;
p_rec_financeiro.mod_comp(p_ind_modalidade_comp).vl_base_calculo         :=  0;
-- !!* Aqui -  Descto 169 poderá ser tratado aqui
if p_cd_modalidade_externo                                 in  ( 'DISCIPLINA_SEM_ONUS' ,
                                                                'CARGA_HORARIA_SEM_ONUS') then
  p_rec_financeiro.mod_comp(p_ind_modalidade_comp).vl_modalidade :=  p_vl_modalidade/ p_rec_financeiro.qt_competencia;
  if  p_ind_competencia                                              =   1
  and p_vl_diferenca                                      <>  0 then 
      p_rec_financeiro.mod_comp(p_ind_modalidade_comp).vl_modalidade   
                                                          :=  p_rec_financeiro.mod_comp(p_ind_modalidade_comp).vl_modalidade 
                                                          +   p_vl_diferenca;
  end if;
else
  p_rec_financeiro.mod_comp(p_ind_modalidade_comp).vl_modalidade        
                                                          :=  p_vl_modalidade;
end if;   
--
end p_desconto_incondicional_valor;     
--
-- -----------------------------------------------------------------------------
/*
PROCEDURE: p_desconto_condicional
DESENVOLVEDOR: Helane, Haroldo e José Leitão 
OBJETIVO: Atualizar os arrays de competencia ( vt_valor_competencia ) e competencia
          modalidade ( vt_modalidade_competencia ) com os descontos condicionais

*/
-- -----------------------------------------------------------------------------
procedure p_desconto_condicional
( p_vt_modalidade_financeiro_aux  in     ca.pk_fat_mc_plt.vt_fin_modalidade_aux
, p_rec_financeiro                in out nocopy ca.pk_fat_mc_plt.rec_financeiro
, p_rec_mc_aluno                  in     ca.pk_fat_mc_plt.rec_mc_aluno 
, p_nr_sequencia_calc_modalidade  in  out nocopy   number  ) is
--
l_vl_diferenca              number;
l_vl_total_modalidade       number := 0;
st_dc                       c1_modalidade%rowtype;
--
begin
--
--for  ind in 1 .. p_vt_modalidade_financeiro_aux.count loop
--    dbms_output.put_Line( '**** modalidade:' ||  p_vt_modalidade_financeiro_aux(ind).id_modalidade || '- ' ||
--                                                 p_vt_modalidade_financeiro_aux(ind).nm_modalidade || 
--                          ' tipo:' || p_vt_modalidade_financeiro_aux(ind).id_modalidade_tipo || '-' || 
--                                      p_vt_modalidade_financeiro_aux(ind).nm_modalidade_tipo);
--end loop; 
--
-- Popular o array "vt_modalidade_competencia" com dados das modalidades e por competência
open  c1_modalidade( p_vt_modalidade_financeiro_aux, 5 );
fetch c1_modalidade  into st_dc;
while c1_modalidade%found loop
    --dbms_output.put_Line( '>>>> st_dc.id_modalidade:' ||  st_dc.id_modalidade || '-' || 
    --                                                      st_dc.nm_modalidade || 
    --                           ' tipo:' || st_dc.nm_modalidade_tipo);

-- !!* Aqui - atenção as regras de condicional ser alterado para incondicional na primeira vale só para a graduação
-- 
    if st_dc.id_modalidade_tipo in ( 3, 4 ) 
       then  
    -- 3 - Desconto condicional 
    -- 4 - Convênio de desconto
       l_vl_diferenca          :=  nvl( st_dc.vl_modalidade  -  trunc( st_dc.vl_modalidade / p_rec_financeiro.qt_competencia , 2 ) 
                               *   p_rec_financeiro.qt_competencia , 0)   ;           
       l_vl_total_modalidade   :=  0;
--
       --dbms_output.put_Line( '**** p_rec_financeiro.nr_competencia_fim:' ||  p_rec_financeiro.nr_competencia_fim  );
       for ind_comp in 1 .. p_rec_financeiro.nr_competencia_fim loop
         -- dbms_output.put_Line( '****  vendido:' ||p_rec_financeiro.competencia(ind_comp).vl_vendido );
--           if p_rec_financeiro.competencia(ind_comp).vl_vendido > 0   -- 
         -- !!* Aqui - identificar se o desconto incondicional já foi concedido para o condicional
           if p_rec_financeiro.competencia(ind_comp).vl_vendido > 0 
              then
              p_nr_sequencia_calc_modalidade                         :=    p_nr_sequencia_calc_modalidade + 1;
              p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).nr_competencia
                                                                   :=   p_rec_financeiro.competencia(ind_comp).nr_competencia; 

              p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).nr_ind_financ_competencia
                                                                   :=   p_rec_financeiro.competencia(ind_comp).nr_competencia;
              p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).nr_ind_financ_modalidade
                                                                   :=   st_dc.nr_ind_modalidade;

              p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).nr_sequencia_calculo      
                                                                   :=   p_nr_sequencia_calc_modalidade;

              p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).id_modalidade             
                                                                   :=   st_dc.id_modalidade;
              p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).id_modalidade_tipo 
                                                                   :=   st_dc.id_modalidade_tipo;

              p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).nm_modalidade_tipo        
                                                                   :=   st_dc.nm_modalidade_tipo;
    
              p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).id_pessoa_cobranca      
                                                                   :=   st_dc.id_pessoa_cobranca;
              p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).tp_apropriacao_titulo    
                                                                   :=   'C';  -- Desconto condicional
              p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).st_competencia_modalidade 
                                                                   :=   'A';  -- Ativo
              p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).nm_modalidade    
                                                                   :=   st_dc.nm_modalidade;
              p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).vl_vendido      
                                                                   :=   p_rec_financeiro.competencia(ind_comp).vl_vendido  ;
              p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).pc_modalidade     
                                                                   :=   st_dc.pc_modalidade;
              p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).pc_modalidade_original 
                                                                   :=   st_dc.pc_modalidade;
              p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).vl_base_calculo   
                                                                   :=   p_rec_financeiro.competencia(ind_comp).vl_saldo  ;
              p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).vl_modalidade    
                                                                   :=   0;
              p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).id_financeiro_modalidade
                                                                   :=   f_financeiro_modalidade( p_rec_mc_aluno
                                                                                                , st_dc.id_modalidade  ); 
            --dbms_output.put_Line( '**** st_dc.cd_externo_padrao:' ||  st_dc.cd_externo_padrao);
    
-- !!* Aqui - incluído aqui o teste de modalidade em que o desconto é dado na primeira competência do aluno

            if st_dc.cd_externo_padrao =    'DESCONTO_A_PARTIR_DA_SEGUNDA' 
                then
                if ind_comp >  1 
                   then
                   p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).vl_modalidade       
                                                                   :=   trunc(p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).vl_base_calculo 
                                                                   *    (p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).pc_modalidade/100),2);
                   p_rec_financeiro.competencia(ind_comp).vl_desconto_condicional     
                                                                   :=   p_rec_financeiro.competencia(ind_comp).vl_desconto_condicional 
                                                                   +    p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).vl_modalidade;
                end if;
             elsif st_dc.cd_externo_padrao = 'DESCONTO_A_PARTIR_DA_TERCEIRA' 
                then
                if ind_comp > 2 
                   then
                   p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).vl_modalidade      
                                                                   :=   trunc(p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).vl_base_calculo 
                                                                   *    (p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).pc_modalidade/100),2);
                   p_rec_financeiro.competencia(ind_comp).vl_desconto_condicional     
                                                                   :=   p_rec_financeiro.competencia(ind_comp).vl_desconto_condicional  
                                                                   +    p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).vl_modalidade;
                end if; 
             else 
                if (st_dc.cd_externo_padrao = 'DESC_INCONDICIONAL_PRIMEIRA' and ind_comp <> 1 ) then
                    p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).vl_modalidade         
                                                                   :=   trunc(p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).vl_base_calculo  
                                                                   *    (p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).pc_modalidade/100),2);
                    p_rec_financeiro.competencia(ind_comp).vl_desconto_condicional 
                                                                   :=   p_rec_financeiro.competencia(ind_comp).vl_desconto_condicional 
                                                                   +    p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).vl_modalidade;
                end if;
             end if;
          end if;    
--
          if ind_comp = 1
             and 
             l_vl_diferenca <> 0 
             then 
              p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).vl_modalidade           
                                                                   :=    p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).vl_modalidade 
                                                                   +    l_vl_diferenca;
              p_rec_financeiro.competencia(ind_comp).vl_desconto_condicional      
                                                                   :=   p_rec_financeiro.competencia(ind_comp).vl_desconto_condicional 
                                                                   +    l_vl_diferenca;
              l_vl_diferenca                                       :=   0  ;           

              p_atualiza_base_calculo_competencia ( p_rec_financeiro, ind_comp);
          end if;   

          l_vl_total_modalidade                                    :=   l_vl_total_modalidade 
                                                                   +    nvl( p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).vl_modalidade,0);
       end loop;
--       
    end if;
    fetch c1_modalidade  into st_dc;
--
end loop;
close c1_modalidade  ;
--
end p_desconto_condicional;
--
-- -----------------------------------------------------------------------------
/*
PROCEDURE: p_bolsa
DESENVOLVEDOR: Helane, Haroldo e José Leitão 
OBJETIVO: Atualizar os arrays de competencia ( vt_valor_competencia ) e competencia
          modalidade ( vt_modalidade_competencia ) com as bolsas

*/
-- -----------------------------------------------------------------------------
procedure p_bolsa
( p_vt_modalidade_financeiro_aux  in     ca.pk_fat_mc_plt.vt_fin_modalidade_aux
, p_rec_financeiro                in out nocopy ca.pk_fat_mc_plt.rec_financeiro
, p_rec_mc_aluno                  in     ca.pk_fat_mc_plt.rec_mc_aluno 
, p_nr_sequencia_calc_modalidade  in  out nocopy   number  )  is
--
st_bolsa                c1_modalidade%rowtype;
--
begin
--
-- Popular o array "vt_modalidade_competencia" com dados das modalidades e por competência
-- dbms_output.put_line( '***P_BOLSA' );
open  c1_modalidade( p_vt_modalidade_financeiro_aux, 4 );
fetch c1_modalidade  into st_bolsa;
while c1_modalidade%found loop
if st_bolsa.id_modalidade_tipo = 6 
   then
-- 6 - Bolsa
   for ind_comp in 1 .. p_rec_financeiro.nr_competencia_fim loop
     --dbms_output.put_line( '***P_BOLSA - IND:' || ind_comp || 
     --                      ' Modalidade:' || st_bolsa.id_modalidade  || 
     --                      ' BC:' || p_rec_financeiro.competencia(ind_comp).vl_saldo  ||
     --                      ' %:' || st_bolsa.pc_modalidade );
     if p_rec_financeiro.competencia(ind_comp).vl_vendido > 0 
        then
        p_nr_sequencia_calc_modalidade                         :=   p_nr_sequencia_calc_modalidade + 1;
        p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).nr_competencia
                                                               :=   p_rec_financeiro.competencia(ind_comp).nr_competencia; 

        p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).nr_ind_financ_competencia
                                                               :=   p_rec_financeiro.competencia(ind_comp).nr_competencia;
        p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).nr_ind_financ_modalidade
                                                               :=   st_bolsa.nr_ind_modalidade;

        p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).nr_sequencia_calculo      
                                                               :=   p_nr_sequencia_calc_modalidade;
        
        --p_academico_titulo( p_rec_mc_aluno.id_academico
        --                  , vt_valor_competencia(ind).nr_competencia  
        --                  , vt_modalidade_competencia(g_ind_comp_mod).id_academico_titulo  -- out
        --                  , vt_modalidade_competencia(g_ind_comp_mod).dt_competencia   );  -- out     
        p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).id_modalidade            
                                                 :=    st_bolsa.id_modalidade;
        p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).id_modalidade_tipo        
                                                 :=    st_bolsa.id_modalidade_tipo;
        p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).nm_modalidade_tipo        
                                                 :=    st_bolsa.nm_modalidade_tipo;
                                                 
        p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).id_pessoa_cobranca  
                                                 :=    st_bolsa.id_pessoa_cobranca;
        p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).tp_apropriacao_titulo    
                                                 :=    'B';   -- Bolsa
        p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).st_competencia_modalidade 
                                                 :=    'A';   -- Ativo 
        p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).nm_modalidade  
                                                 :=    st_bolsa.nm_modalidade;
        p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).pc_modalidade     
                                                 :=    st_bolsa.pc_modalidade;
        p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).pc_modalidade_original  
                                                 :=    st_bolsa.pc_modalidade;
        p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).vl_vendido    
                                                 :=    p_rec_financeiro.competencia(ind_comp).vl_vendido  ;
        p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).vl_base_calculo   
                                                 :=    p_rec_financeiro.competencia(ind_comp).vl_saldo  ;
        p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).vl_modalidade 
                                                 :=    0;
        p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).id_financeiro_modalidade 
                                                 :=    f_financeiro_modalidade( p_rec_mc_aluno
                                                                              , st_bolsa.id_modalidade  ); 
        p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).cd_externo_padrao
                                                                 :=  st_bolsa.cd_externo_padrao;

        if st_bolsa.cd_externo_padrao            =     'BOLSA_A_PARTIR_DA_SEGUNDA' then
           if ind_comp                           >     1 then
              p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).vl_modalidade       
                                                 :=    trunc(p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).vl_base_calculo
                                                 *     (p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).pc_modalidade/100),2);
              p_rec_financeiro.competencia(ind_comp).vl_bolsa
                                                 :=    p_rec_financeiro.competencia(ind_comp).vl_bolsa
                                                 +     p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).vl_modalidade;
           end if;
        elsif st_bolsa.cd_externo_padrao         =     'BOLSA_A_PARTIR_DA_TERCEIRA' then
           if ind_comp                           >     2 then
              p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).vl_modalidade       
                                                 :=    trunc(p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).vl_base_calculo 
                                                 *     (p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).pc_modalidade/100),2);
              p_rec_financeiro.competencia(ind_comp).vl_bolsa 
                                                 :=    p_rec_financeiro.competencia(ind_comp).vl_bolsa
                                                 +     p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).vl_modalidade;
           end if;
        else
           p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).vl_modalidade      
                                                 :=    trunc(p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).vl_base_calculo
                                                 *     (p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).pc_modalidade/100),2);
           --dbms_output.put_line( '   vl_base_calculo:' || vt_modalidade_competencia(g_ind_comp_mod).vl_base_calculo );
           --dbms_output.put_line( '   pc_modalidade:' || vt_modalidade_competencia(g_ind_comp_mod).pc_modalidade );
           --dbms_output.put_line( '   vl_modalidade:' || vt_modalidade_competencia(g_ind_comp_mod).vl_modalidade);
           p_rec_financeiro.competencia(ind_comp).vl_bolsa   
                                                :=     p_rec_financeiro.competencia(ind_comp).vl_bolsa
                                                +      p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).vl_modalidade;
        end if;
        
        p_atualiza_base_calculo_competencia ( p_rec_financeiro, ind_comp);
--
        --dbms_output.put_line( '     Vendido:' || p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).vl_vendido ||
        --   ' COMP:' || p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).nr_competencia ||
        --   ' BC:' ||  p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).vl_base_calculo  );

      end if;
      --dbms_output.put_line( ' BOLSA :' || p_nr_sequencia_calc_modalidade|| '  modalidade:' || p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).id_modalidade );
      --                      ' vl_bolsa' || vt_valor_competencia(ind).vl_bolsa );
   end loop;
end if;
--
fetch c1_modalidade  into st_bolsa;
end loop;
close c1_modalidade;
--
--if l_tem_modalidade > 0 then
--   p_atualiza_base_calculo_competencia ( p_rec_financeiro, g_ind_comp_mod) ;
-- end if;
--
end p_bolsa;
--

-- -----------------------------------------------------------------------------
/*
PROCEDURE: p_distribuir_modalidades_cobranca
DESENVOLVEDOR: Helane, Haroldo e José Leitão 
OBJETIVO: Atualizar os arrays de competencia ( vt_valor_competencia ) e competencia
          modalidade ( vt_modalidade_competencia ) que podem ser cobradas
Tipos de modalidade:
 5 - Convênio de pagamento
 7 - Financiamento publico
 8 - Financiamento privado
11 - Financiamento Unifor - PEX
*/
-- -----------------------------------------------------------------------------
procedure p_distribuir_modalidades_cobranca
( p_vt_modalidade_financeiro_aux  in     ca.pk_fat_mc_plt.vt_fin_modalidade_aux
, p_rec_financeiro                in out nocopy ca.pk_fat_mc_plt.rec_financeiro
, p_rec_mc_aluno                  in     ca.pk_fat_mc_plt.rec_mc_aluno 
, p_nr_sequencia_calc_modalidade  in  out nocopy   number ) is
--
st_mod_cobr                 c1_modalidade%rowtype;
--
begin
-- Popular o array "vt_modalidade_competencia" com dados das modalidades e por competência
open  c1_modalidade( p_vt_modalidade_financeiro_aux, 6 );
fetch c1_modalidade  into st_mod_cobr;
while c1_modalidade%found loop
    --  5 - Convênio de pagamento
    --  7 - Financiamento publico
    --  8 - Financiamento privado
    -- 11 - Financiamento Unifor - PEX
    if st_mod_cobr.id_modalidade_tipo   in (  5, 7, 8, 11 ) then 
--    
       for ind_comp in 1 .. p_rec_financeiro.nr_competencia_fim loop
--             
          --if st_mod_cobr.id_modalidade_tipo  = 8 then
             --dbms_output.put_line( '**P_DISTRIBUIR_MODALIDADES_COBRANCA  Ind:' || ind_comp ||
             --                      ' nr_competencia:' || p_rec_financeiro.competencia(ind_comp).nr_competencia ||
             --                      ' vendido:' || p_rec_financeiro.competencia(ind_comp).vl_vendido  );
          --end if; 
--
           if p_rec_financeiro.competencia(ind_comp).vl_vendido    >   0 
              then
              p_nr_sequencia_calc_modalidade                       :=  p_nr_sequencia_calc_modalidade + 1;
              p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).nr_competencia
                                                                  :=  p_rec_financeiro.competencia(ind_comp).nr_competencia; 

              p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).nr_ind_financ_competencia
                                                                  :=  p_rec_financeiro.competencia(ind_comp).nr_competencia;
              p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).nr_ind_financ_modalidade
                                                                  :=  st_mod_cobr.nr_ind_modalidade;

              p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).nr_sequencia_calculo      
                                                                  :=  p_nr_sequencia_calc_modalidade;
             
              p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).nr_competencia            
                                                                  :=  p_rec_financeiro.competencia(ind_comp).nr_competencia;
              --p_academico_titulo( p_rec_mc_aluno.id_academico
              --                 , vt_valor_competencia(ind).nr_competencia  
              --                 , p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).id_academico_titulo  -- out
              --                  , p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).dt_competencia   );  -- out    
              
              --dbms_output.put_line(  '   g_ind_comp_mod:' || g_ind_comp_mod || ' dt_competencia:' || p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).dt_competencia ); 
              
              p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).id_modalidade             
                                                                  :=  st_mod_cobr.id_modalidade;
              p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).id_modalidade_tipo        
                                                                  :=  st_mod_cobr.id_modalidade_tipo;
              p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).nm_modalidade_tipo        
                                                                  :=    st_mod_cobr.nm_modalidade_tipo;

              p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).id_pessoa_cobranca        
                                                                  :=  st_mod_cobr.id_pessoa_cobranca;
              p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).tp_apropriacao_titulo     
                                                                  :=  'P';  -- principal - Convênio de pagamento
              p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).st_competencia_modalidade 
                                                                  :=  'A';  -- Ativo
              p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).nm_modalidade           
                                                                  :=  st_mod_cobr.nm_modalidade;
              p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).pc_modalidade       
                                                                  :=  st_mod_cobr.pc_modalidade;
              p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).pc_modalidade_original    
                                                                  :=  st_mod_cobr.pc_modalidade_original ;
             
              p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).vl_vendido                
                                                                  :=  trunc(p_rec_financeiro.competencia(ind_comp).vl_vendido   
                                                                  *   (st_mod_cobr.pc_modalidade/100),2);
              p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).vl_base_calculo           
                                                                  :=  p_rec_financeiro.competencia(ind_comp).vl_saldo; 
              p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).vl_modalidade         
                                                                   :=  trunc(p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).vl_base_calculo  
                                                                  *   (p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).pc_modalidade/100),2);
              p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).id_financeiro_modalidade  
                                                                  :=  f_financeiro_modalidade( p_rec_mc_aluno
                                                                                             , st_mod_cobr.id_modalidade  ); 

              p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).cd_externo_padrao  
                                                                  :=  st_mod_cobr.cd_externo_padrao; 

              p_atualiza_base_calculo_competencia ( p_rec_financeiro, ind_comp);

             --if st_mod_cobr.id_modalidade_tipo  = 8 then
             --   dbms_output.put_line( '   Ind:'   || ind_comp ||
             --                         ' MOD:'     || p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).id_modalidade ||
             --                         ' vl mod:'  || p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).vl_vendido ||
             --                         ' vl comp:' || p_rec_financeiro.competencia(ind_comp).vl_vendido ||
             --                         ' %:'       || p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).pc_modalidade 
             --                         );
             -- end if; 
           end if;
       end loop;
    end if;
    fetch c1_modalidade  into st_mod_cobr;
end loop;
close c1_modalidade ;
--
end p_distribuir_modalidades_cobranca;
--
-- -----------------------------------------------------------------------------
/*
PROCEDURE: p_aluno_regular
DESENVOLVEDOR: Helane, Haroldo e José Leitão 
OBJETIVO: Atualizar os arrays de competencia ( vt_valor_competencia ) e competencia
          modalidade ( vt_modalidade_competencia ) para aluno regular

*/
-- -----------------------------------------------------------------------------
procedure p_aluno_regular
( p_vt_modalidade_financeiro_aux  in     ca.pk_fat_mc_plt.vt_fin_modalidade_aux
, p_rec_financeiro                in out nocopy ca.pk_fat_mc_plt.rec_financeiro
, p_rec_mc_aluno                  in     ca.pk_fat_mc_plt.rec_mc_aluno 
, p_nr_sequencia_calc_modalidade  in out nocopy number ) is
--
cursor cr_valor_minimo_titulo is
select crp.vl_minimo_titulo_mensalidade
  from ca.ctr_conta_receber_parametro crp 
 where crp.id_conta_receber_parametro  = 1;
--
wvl_vendido_convenio                 number(12,2) := 0;
wvl_modalidade_convenio              number(12,2) := 0;
wpc_convenio                         number(7,4)  := 0;
l_vl_total_vendido                   number(12,2) := 0;
l_vl_total_modalidade                number(12,2) := 0;
l_vl_total_base_calculo              number(12,2) := 0; 
l_vl_diferenca                       number(12,2) := 0; 
l_vl_minimo_titulo_mensalidade       ca.ctr_conta_receber_parametro.vl_minimo_titulo_mensalidade%type;    
l_qt_parcelas                        number(5);
l_ind_aluno_regular                  number(3);
l_ind_comp_aux                       number(5)    := 0; 
--
begin
-- Obter o Valor mínimo do título
open  cr_valor_minimo_titulo;
fetch cr_valor_minimo_titulo into l_vl_minimo_titulo_mensalidade;
close cr_valor_minimo_titulo;
--
l_ind_aluno_regular := p_nr_sequencia_calc_modalidade;
for st_aluno in c1_modalidade( p_vt_modalidade_financeiro_aux, 7 ) loop
    if st_aluno.id_modalidade_tipo =  1 
       then
    -- 1 - Aluno regular 
       --dbms_output.put_line( '>>p_aluno_regular - Intervalor de competencia: ' || p_rec_financeiro.nr_competencia_inicio || ' a ' || p_rec_financeiro.nr_competencia_fim ); 
       for ind_comp in 1 .. p_rec_financeiro.nr_competencia_fim loop
           if p_rec_financeiro.competencia(ind_comp).vl_vendido    >    0 then
              p_nr_sequencia_calc_modalidade                       :=   p_nr_sequencia_calc_modalidade + 1;
              p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).nr_competencia
                                                                   :=   p_rec_financeiro.competencia(ind_comp).nr_competencia; 

              p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).nr_ind_financ_competencia
                                                                   :=   p_rec_financeiro.competencia(ind_comp).nr_competencia;
              p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).nr_ind_financ_modalidade
                                                                   :=   st_aluno.nr_ind_modalidade;

              p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).nr_sequencia_calculo      
                                                                   :=   p_nr_sequencia_calc_modalidade;
            
              --p_academico_titulo( p_rec_mc_aluno.id_academico
              --                  , vt_valor_competencia(ind).nr_competencia  
              --                  , p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).id_academico_titulo  -- out
              --                  , p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).dt_competencia   );  -- out     
              --
              p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).id_modalidade             
                                                                   :=   st_aluno.id_modalidade;
              p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).id_modalidade_tipo       
                                                                   :=   st_aluno.id_modalidade_tipo;
              p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).nm_modalidade_tipo        
                                                                   :=   st_aluno.nm_modalidade_tipo;

              p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).id_pessoa_cobranca        
                                                                   :=   st_aluno.id_pessoa_cobranca;
          
              p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).tp_apropriacao_titulo     
                                                                   :=   'P';   -- -- principal - Aluno regular  
              p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).st_competencia_modalidade 
                                                                   :=   'A';   -- Ativo 
              p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).nm_modalidade            
                                                                   :=   st_aluno.nm_modalidade;
              p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).pc_modalidade             
                                                                   :=   st_aluno.pc_modalidade;
                                                                   
              --dbms_output.put_line( '    COMP:' || p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).nr_competencia ||
              --                      ' PC:' || p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).pc_modalidade );
              p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).pc_modalidade_original    
                                                                   :=   st_aluno.pc_modalidade;
              p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).vl_base_calculo           
                                                                   :=   p_rec_financeiro.competencia(ind_comp).vl_saldo  ;
              p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).vl_modalidade            
                                                                   :=   p_rec_financeiro.competencia(ind_comp).vl_saldo   ;
              
              p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).id_financeiro_modalidade 
                                                                   :=   f_financeiro_modalidade( p_rec_mc_aluno
                                                                                               , st_aluno.id_modalidade  );
--             
              wvl_vendido_convenio    :=   0;
              wvl_modalidade_convenio :=   0;
              wpc_convenio            :=   0;
              l_ind_comp_aux          :=   p_rec_financeiro.mod_comp.first();
-- 
              while( l_ind_comp_aux is not null ) loop   
--                   
                 if p_rec_financeiro.mod_comp(l_ind_comp_aux).id_modalidade_tipo in (  5, 7, 8, 11 )  
                    and 
                    p_rec_financeiro.mod_comp(l_ind_comp_aux).nr_competencia     
                                                                   =    ind_comp + p_rec_financeiro.qt_competencia_shift 
                    then
                -- 5 - Convenio de pagamento  
                -- 7 - Financiamento público
                -- 8 - Financiamento privado
                -- 11 - Parcelamento Unifor - PEX

                   wvl_vendido_convenio                            :=   wvl_vendido_convenio    
                                                                   +    p_rec_financeiro.mod_comp(l_ind_comp_aux).vl_vendido;
                   wvl_modalidade_convenio                         :=   wvl_modalidade_convenio 
                                                                   +    p_rec_financeiro.mod_comp(l_ind_comp_aux).vl_modalidade;

                   wpc_convenio                                    :=   wpc_convenio            
                                                                   +    p_rec_financeiro.mod_comp(l_ind_comp_aux).pc_modalidade;
                   --dbms_output.put_line( '     ID MOD:' || p_rec_financeiro.mod_comp(l_ind_comp_aux).id_modalidade ||
                   --                 ' wpc_convenio:' ||wpc_convenio ||
                   --                 ' PC:' || p_rec_financeiro.mod_comp(l_ind_comp_aux).pc_modalidade );

                 end if;

                 l_ind_comp_aux := p_rec_financeiro.mod_comp.next(l_ind_comp_aux);
              end loop;
 
              p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).vl_vendido      
                                                                   :=   p_rec_financeiro.competencia(ind_comp).vl_vendido 
                                                                   -    wvl_vendido_convenio;
              p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).vl_modalidade  
                                                                   :=   p_rec_financeiro.competencia(ind_comp).vl_saldo  
                                                                   -    wvl_modalidade_convenio;
              l_vl_total_vendido                                   :=   l_vl_total_vendido
                                                                   +    p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).vl_vendido;
                                                                        
              l_vl_total_modalidade                                :=   l_vl_total_modalidade
                                                                   +    p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).vl_modalidade;

              l_vl_total_base_calculo                              :=   l_vl_total_base_calculo
                                                                   +    p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).vl_base_calculo;

              p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).pc_modalidade   
                                                                   :=   100 - wpc_convenio;


              --dbms_output.put_line( '    ind:' || p_nr_sequencia_calc_modalidade||
              --                      ' COMP:' || p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).nr_competencia ||
              --                      ' TP:' ||  p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).tp_apropriacao_titulo ||
              --                      ' mod:'|| p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).id_modalidade ||
              --                     ' VL:' || p_rec_financeiro.mod_comp(p_nr_sequencia_calc_modalidade).vl_modalidade );

              p_atualiza_base_calculo_competencia ( p_rec_financeiro, ind_comp);

           end if;
       end loop;
    end if;
end loop;
--
l_qt_parcelas := trunc( l_vl_total_modalidade / l_vl_minimo_titulo_mensalidade );
if l_qt_parcelas = 0 then
   l_qt_parcelas := 1;
end if;
--
l_vl_diferenca := l_vl_total_modalidade  
                  - trunc(  l_vl_total_modalidade  / l_qt_parcelas , 2 )
                  * l_qt_parcelas;  
--
-- Verificar a modalidade aluno deve ser gerado menos de parcelas     
if l_qt_parcelas < p_rec_financeiro.qt_competencia      
   then  
   l_ind_aluno_regular := p_rec_financeiro.mod_comp.first();
   while l_ind_aluno_regular is not null loop
       if p_rec_financeiro.mod_comp(l_ind_aluno_regular).id_modalidade =  1 
          then
          if p_rec_financeiro.mod_comp(l_ind_aluno_regular).nr_competencia <= l_qt_parcelas 
             then
             p_rec_financeiro.mod_comp(l_ind_aluno_regular).vl_vendido         :=  trunc( l_vl_total_vendido / l_qt_parcelas, 2) ;
             p_rec_financeiro.mod_comp(l_ind_aluno_regular).vl_modalidade      :=  trunc( l_vl_total_modalidade / l_qt_parcelas, 2) ;  
             p_rec_financeiro.mod_comp(l_ind_aluno_regular).vl_base_calculo    :=  trunc( l_vl_total_base_calculo / l_qt_parcelas, 2) ;                            
             if p_rec_financeiro.mod_comp(l_ind_aluno_regular).nr_competencia  =   1 
                then
                p_rec_financeiro.mod_comp(l_ind_aluno_regular).vl_vendido      :=  p_rec_financeiro.mod_comp(l_ind_aluno_regular).vl_vendido
                                                                                 +   l_vl_diferenca;
                p_rec_financeiro.mod_comp(l_ind_aluno_regular).vl_modalidade   :=  p_rec_financeiro.mod_comp(l_ind_aluno_regular).vl_modalidade
                                                                                 +   l_vl_diferenca;
             end if;
          else
             p_rec_financeiro.mod_comp(l_ind_aluno_regular).vl_vendido         :=  0;
             p_rec_financeiro.mod_comp(l_ind_aluno_regular).vl_modalidade      :=  0;               
             p_rec_financeiro.mod_comp(l_ind_aluno_regular).vl_base_calculo    :=  0;   
          end if;
       end if;
       l_ind_aluno_regular   :=         p_rec_financeiro.mod_comp.next( l_ind_aluno_regular );
   end loop;
end if;
--
end p_aluno_regular;
--
-- -----------------------------------------------------------------------------
/*
PROCEDURE: p_array_titulo
DESENVOLVEDOR: Helane, Haroldo e José Leitão 
OBJETIVO: Montar array de títulos 
PARÂMETROS:
   1 - p_rec_financeiro  
   2 - p_vt_modalidade_competencia_aux
*/
-- -----------------------------------------------------------------------------
procedure p_array_titulo
( p_rec_financeiro                        in out nocopy ca.pk_fat_mc_plt.rec_financeiro
, p_vt_modalidade_competencia_aux         in            ca.pk_fat_mc_plt.vt_modalidade_competencia 
, p_qt_titulos_por_competencia_modalidade in out    number  ) is
--
cursor cr_mod_cobranca
( p_nr_competencia in  ca.ctr_titulo.nr_competencia%type ) is
select *
  from table (p_vt_modalidade_competencia_aux) mc
 where tp_apropriacao_titulo      =   'P'
   and nr_competencia             =   p_nr_competencia
   and vl_vendido                 >   0;   
--
cursor cr_mod_outras
( p_nr_competencia in  ca.ctr_titulo.nr_competencia%type ) is
select *
  from table (p_vt_modalidade_competencia_aux) mc
 where tp_apropriacao_titulo      <>  'P'
   and nr_competencia             =   p_nr_competencia;
--
cursor cr_mod_cobranc_12_titulos_competencia
( p_id_modalidade   in  ca.fat_modalidade.id_modalidade%type
, p_qt_titulo       in  number) is
select sum( vl_vendido ) / p_qt_titulo  vl_vendido
  from table (p_vt_modalidade_competencia_aux) mc
 where tp_apropriacao_titulo      =   'P'
   and id_modalidade              =   p_id_modalidade;   
--
cursor cr_mod_outras_12_titulos_competencia
( p_id_modalidade           in  ca.fat_modalidade.id_modalidade%type
, p_tp_apropriacao_titulo   in  varchar2 
, p_qt_titulo               in  number ) is
select sum( vl_modalidade ) / p_qt_titulo  vl_modalidade
  from table (p_vt_modalidade_competencia_aux) mc
 where tp_apropriacao_titulo      =   p_tp_apropriacao_titulo
   and id_modalidade              =   p_id_modalidade;
--       
l_ind_competencia_inicio         number(5); 
l_ind_tit                        number(5);
ind_mod_comp                     number(5);
--
l_ind_tit_mod                    number(5);
l_vl_desconto_incondicional      number(12,2);
l_vl_desconto_condicional        number(12,2);
l_vl_desconto_bolsa              number(12,2);
l_qt_titulo_12_parcelas          number(3); 
l_vl_vendido_mod_cobranca_aux    number(12,2 );
--
begin 
l_ind_tit :=   p_rec_financeiro.titulo.count;
--dbms_output.put_line( '----------- p_montar_array_titulo ----------');
--dbms_output.put_line( '1 l_ind_competencia_inicio:' ||  l_ind_competencia_inicio  );        
--dbms_output.put_line( '2 comp:' ||  p_rec_financeiro.nr_competencia_inicio ||  ' a ' ||  p_rec_financeiro.nr_competencia_fim );
--dbms_output.put_line( '3 ind_mod_cobr:' ||   p_rec_financeiro.mod_comp.first ||  ' a ' ||  p_rec_financeiro.mod_comp.last );
--dbms_output.put_line( '4 qt_competencia_preservada:' ||  p_rec_financeiro.qt_competencia_preservada );
--dbms_output.put_line( '5 qt_competencia_shift:' ||  p_rec_financeiro.qt_competencia_shift );

l_ind_competencia_inicio :=   p_rec_financeiro.nr_competencia_inicio; 
                                             --      +    p_rec_financeiro.qt_competencia_preservada
                                             --      +    p_rec_financeiro.qt_competencia_shift ;

--dbms_output.put_line( '6 p_rec_financeiro.nr_competencia_inicio:' ||  p_rec_financeiro.nr_competencia_inicio  );
--dbms_output.put_line( '6 p_rec_financeiro.nr_competencia_fim:' ||  p_rec_financeiro.nr_competencia_fim  );
--dbms_output.put_line( '6 p_rec_financeiro.qt_competencia_shift:' ||  p_rec_financeiro.qt_competencia_shift );
--dbms_output.put_line( '---------------------');
--
for ind_comp  in l_ind_competencia_inicio .. p_rec_financeiro.nr_competencia_fim loop
--  
    ind_mod_comp :=  ind_mod_comp + 1;
--    
    for st_mod_cobranca in cr_mod_cobranca( p_rec_financeiro.competencia(ind_comp).nr_competencia ) loop
    -- 1  - Aluno regular
    -- 5  - Convênio de pagamento
    -- 7  - Financiamento público
    -- 8  - Financiamento privado
    -- 11 - Financiamento Unifor - PEX 
--        
        dbms_output.put_line('************* Competencia : '|| ind_comp ||' ; modalidade '|| st_mod_cobranca.id_modalidade);
        l_vl_vendido_mod_cobranca_aux :=  st_mod_cobranca.vl_vendido;            
        if st_mod_cobranca.cd_externo_padrao  =   'DOZE_PARCELAS' then
            p_qt_titulos_por_competencia_modalidade   :=  2;
            open  cr_mod_cobranc_12_titulos_competencia( st_mod_cobranca.id_modalidade
                                                       , p_rec_financeiro.qt_competencia   * p_qt_titulos_por_competencia_modalidade );
            fetch cr_mod_cobranc_12_titulos_competencia into st_mod_cobranca.vl_vendido;
            close cr_mod_cobranc_12_titulos_competencia;
        else
            p_qt_titulos_por_competencia_modalidade    :=  1;
        end if;
--
        --if st_mod_cobranca.id_modalidade = 105 then
        --   dbms_output.put_line( '>>> cd_externo_padrao:' ||st_mod_cobranca.cd_externo_padrao ||
        --   ' qtd:' || l_qt_titulos_gerar_competencia );
        --end if;
--
        for ind_qt_titulo  in 1 .. p_qt_titulos_por_competencia_modalidade loop
            l_ind_tit                                                    :=  l_ind_tit + 1;
            p_rec_financeiro.titulo(l_ind_tit).nr_ind_financ_competencia :=  l_ind_tit;
            
            p_rec_financeiro.titulo(l_ind_tit).nr_ind_financ_modalidade  :=  null;  
            p_rec_financeiro.titulo(l_ind_tit).nr_ind_titulo             :=  l_ind_tit; 
            p_rec_financeiro.titulo(l_ind_tit).id_titulo                 :=  null; 
            p_rec_financeiro.titulo(l_ind_tit).fg_titulo_preservado      :=  'N';
            p_rec_financeiro.titulo(l_ind_tit).id_pessoa_cobranca        :=  st_mod_cobranca.id_pessoa_cobranca;   
            p_rec_financeiro.titulo(l_ind_tit).nr_competencia            :=  st_mod_cobranca.nr_competencia;   
            p_rec_financeiro.titulo(l_ind_tit).id_modalidade_tipo        :=  st_mod_cobranca.id_modalidade_tipo;   
            p_rec_financeiro.titulo(l_ind_tit).id_modalidade             :=  st_mod_cobranca.id_modalidade;   
            p_rec_financeiro.titulo(l_ind_tit).nm_modalidade             :=  st_mod_cobranca.nm_modalidade;   
            p_rec_financeiro.titulo(l_ind_tit).vl_titulo                 :=  st_mod_cobranca.vl_vendido;   
            --   dbms_output.put_line( '   (2) vl_titulo:' ||p_rec_financeiro.mod_comp(ind_mod_comp).vl_vendido||
            --                         ' Mod:' || p_rec_financeiro.mod_comp(ind_mod_comp).id_modalidade||
            --                         ' Ind:' || ind_mod_comp  );
            p_rec_financeiro.titulo(l_ind_tit).vl_desconto_incondicional :=  0; 
            p_rec_financeiro.titulo(l_ind_tit).vl_bolsa                  :=  0;   
            p_rec_financeiro.titulo(l_ind_tit).vl_desconto_condicional   :=  0;   
            p_rec_financeiro.titulo(l_ind_tit).vl_titulo_liquido         :=  0; 
            p_rec_financeiro.titulo(l_ind_tit).id_mc_titulo              :=  null;   
            p_rec_financeiro.titulo(l_ind_tit).dt_vencimento             :=  null;   
            p_rec_financeiro.titulo(l_ind_tit).dt_competencia            :=  null;   
            p_rec_financeiro.titulo(l_ind_tit).id_academico_titulo       :=  null;  
            p_rec_financeiro.titulo(l_ind_tit).vl_titulo_mc              :=  l_vl_vendido_mod_cobranca_aux;   
            p_rec_financeiro.titulo(l_ind_tit).ds_titulo_preservado      :=  'Não';  
            p_rec_financeiro.titulo(l_ind_tit).ds_titulo_faturado        :=  'Não';   
            p_rec_financeiro.titulo(l_ind_tit).ds_titulo_recebido        :=  'Não';   
            p_rec_financeiro.titulo(l_ind_tit).dt_geracao_titulo         :=  null;
            
            --if p_rec_financeiro.titulo(l_ind_tit).nr_competencia = 2  then
            --    dbms_output.put_line( '------------------------------' );
            --    dbms_output.put_line( '  a) MODALIDADE:' || p_rec_financeiro.titulo(l_ind_tit).id_modalidade ||
            --                              ' COMP:' || p_rec_financeiro.titulo(l_ind_tit).nr_competencia ||
            --                              ' VL Tit:' || p_rec_financeiro.titulo(l_ind_tit).vl_titulo  );
            --end if;
--                                      
            l_ind_tit_mod                                                :=  0;
            l_vl_desconto_incondicional                                  :=  0;
            l_vl_desconto_condicional                                    :=  0;
            l_vl_desconto_bolsa                                          :=  0;  
--  
            for st_mod_outras  in     cr_mod_outras( p_rec_financeiro.competencia(ind_comp).nr_competencia ) loop
                --if p_rec_financeiro.titulo(l_ind_tit).nr_competencia = 2  then
                --    dbms_output.put_line( '  B)* nm_modalidade:' ||st_mod_outras.nm_modalidade || 
                --                          ' vl_modalidade:'         || st_mod_outras.vl_modalidade ||
                --                          ' vl_vendido:'            || st_mod_outras.vl_vendido ||
                --                          ' pc_modalidade:'         || st_mod_outras.pc_modalidade ||
                --                          ' TP Aprop:'             || st_mod_outras.tp_apropriacao_titulo || '<' );
                --end if;

                l_ind_tit_mod                                            :=  l_ind_tit_mod + 1; 
                p_rec_financeiro.titulo(l_ind_tit).tit_mod(l_ind_tit_mod).nr_ind_financ_competencia 
                                                                         :=  null; 
                p_rec_financeiro.titulo(l_ind_tit).tit_mod(l_ind_tit_mod).nr_ind_financ_modalidade 
                                                                         :=  p_rec_financeiro.titulo(l_ind_tit).nr_ind_financ_modalidade; 
                p_rec_financeiro.titulo(l_ind_tit).tit_mod(l_ind_tit_mod).nr_ind_titulo               
                                                                         :=  p_rec_financeiro.titulo(l_ind_tit).nr_ind_titulo; 
                p_rec_financeiro.titulo(l_ind_tit).tit_mod(l_ind_tit_mod).id_modalidade               
                                                                         :=  st_mod_outras.id_modalidade; 
                p_rec_financeiro.titulo(l_ind_tit).tit_mod(l_ind_tit_mod).id_pessoa_cobranca          
                                                                         :=  st_mod_cobranca.id_pessoa_cobranca; 
                p_rec_financeiro.titulo(l_ind_tit).tit_mod(l_ind_tit_mod).id_modalidade_tipo          
                                                                         :=  st_mod_outras.id_modalidade_tipo; 
                p_rec_financeiro.titulo(l_ind_tit).tit_mod(l_ind_tit_mod).nm_modalidade               
                                                                         :=  st_mod_outras.nm_modalidade; 
                p_rec_financeiro.titulo(l_ind_tit).tit_mod(l_ind_tit_mod).id_modalidade_origem        
                                                                         :=  st_mod_outras.id_modalidade_origem; 
                p_rec_financeiro.titulo(l_ind_tit).tit_mod(l_ind_tit_mod).id_modalidade_tipo_origem   
                                                                         :=  st_mod_outras.id_modalidade_tipo_origem; 
                p_rec_financeiro.titulo(l_ind_tit).tit_mod(l_ind_tit_mod).pc_modalidade    
                                                                         :=  st_mod_cobranca.pc_modalidade; 

                p_rec_financeiro.titulo(l_ind_tit).tit_mod(l_ind_tit_mod).nr_competencia  
                                                                         :=  st_mod_cobranca.nr_competencia;
--                 
                if st_mod_cobranca.cd_externo_padrao  =   'DOZE_PARCELAS' 
                   and 
                   p_qt_titulos_por_competencia_modalidade              =   2   then
--                    
                    l_qt_titulo_12_parcelas                 :=  p_rec_financeiro.qt_competencia  
                                                            *   p_qt_titulos_por_competencia_modalidade;
                    open  cr_mod_outras_12_titulos_competencia( st_mod_outras.id_modalidade
                                                              , st_mod_outras.tp_apropriacao_titulo
                                                              , l_qt_titulo_12_parcelas ) ;
                    fetch cr_mod_outras_12_titulos_competencia into  st_mod_outras.vl_modalidade;
                    close cr_mod_outras_12_titulos_competencia;    

                    p_rec_financeiro.titulo(l_ind_tit).tit_mod(l_ind_tit_mod).vl_modalidade
                                                                             :=  trunc( ( st_mod_outras.vl_modalidade  ) 
                                                                             *   (st_mod_cobranca.pc_modalidade/100),2);


                    if  ( st_mod_outras.cd_externo_padrao       in ( 'DESCONTO_A_PARTIR_DA_SEGUNDA', 'DESC_INCONDICIONAL_SEGUNDA', 'BOLSA_A_PARTIR_DA_SEGUNDA') 
                          and   
                          p_rec_financeiro.competencia(ind_comp).nr_competencia   = 1 )
                        or  
                        ( st_mod_outras.cd_externo_padrao       in ( 'DESCONTO_A_PARTIR_DA_SEGUNDA', 'DESC_INCONDICIONAL_SEGUNDA', 'BOLSA_A_PARTIR_DA_SEGUNDA')
                          and   
                          (p_rec_financeiro.qt_competencia_shift + 1) >= p_rec_financeiro.competencia(ind_comp).nr_competencia) 
                        then
                       --if p_rec_financeiro.titulo(l_ind_tit).nr_competencia = 2  then
                       --  dbms_output.put_line( '    **(9.1');
                       --end if;
                       p_rec_financeiro.titulo(l_ind_tit).tit_mod(l_ind_tit_mod).vl_modalidade
                                                                 :=  0;

                       if st_mod_outras.tp_apropriacao_titulo    =   'I' then
                       -- Desconto incondicional
                          l_vl_desconto_incondicional            :=  0 ;  
                       elsif st_mod_outras.tp_apropriacao_titulo =   'B' then
                       -- Bolsa
                          l_vl_desconto_bolsa                                   :=  0;  
                       end if;
                    else
                       --if p_rec_financeiro.titulo(l_ind_tit).nr_competencia = 2  then
                       --   dbms_output.put_line( '    **(9.2');
                       --end if;
                       p_rec_financeiro.titulo(l_ind_tit).tit_mod(l_ind_tit_mod).vl_modalidade
                                                                             :=  trunc( ( st_mod_outras.vl_modalidade  ) 
                                                                             *   (st_mod_cobranca.pc_modalidade/100),2);

                       if st_mod_outras.tp_apropriacao_titulo    =   'I' then
                       -- Desconto incondicional
                          l_vl_desconto_incondicional            :=  l_vl_desconto_incondicional 
                                                                 +    p_rec_financeiro.titulo(l_ind_tit).tit_mod(l_ind_tit_mod).vl_modalidade; 
                       elsif st_mod_outras.tp_apropriacao_titulo =   'B' then
                       -- Bolsa
                          l_vl_desconto_bolsa                    :=  l_vl_desconto_bolsa  
                                                                 +    p_rec_financeiro.titulo(l_ind_tit).tit_mod(l_ind_tit_mod).vl_modalidade ; 
                       end if;
                    end if;
                  
                    --if p_rec_financeiro.titulo(l_ind_tit).nr_competencia = 2  then
                    --  dbms_output.put_line( '  D) comp:' || p_rec_financeiro.competencia(ind_comp).nr_competencia ||
                    --                          ' TP:' ||st_mod_outras.tp_apropriacao_titulo     ||
                    --                          ' l_vl_mod:' ||st_mod_outras.vl_modalidade ||  
                    --                          ' l_vl_DI:' ||l_vl_desconto_incondicional ||  
                    --                          ' l_Bols:' ||l_vl_desconto_bolsa ||  
                    --                          ' Vt_vl_mod:' ||p_rec_financeiro.titulo(l_ind_tit).tit_mod(l_ind_tit_mod).vl_modalidade || 
                    --                          ' l_qt12p:' || l_qt_titulo_12_parcelas  
                    --                          );     
                    --end if;
                    
                    if st_mod_outras.tp_apropriacao_titulo       =   'C' then
                    -- Desconto condicional
                       l_vl_desconto_condicional                 :=   l_vl_desconto_condicional 
                                                                 +    ( p_rec_financeiro.titulo(l_ind_tit).tit_mod(l_ind_tit_mod).vl_modalidade); 
                    end if;
                --------------------------------------------------------
                else   
                    p_rec_financeiro.titulo(l_ind_tit).tit_mod(l_ind_tit_mod).vl_modalidade
                                                                             :=  trunc( ( st_mod_outras.vl_modalidade  ) 
                                                                             *   (st_mod_cobranca.pc_modalidade/100),2);

                    if st_mod_outras.tp_apropriacao_titulo       = 'I' then
                    -- Desconto incondicional
                       l_vl_desconto_incondicional                           :=  l_vl_desconto_incondicional 
                                                                             +   ( p_rec_financeiro.titulo(l_ind_tit).tit_mod(l_ind_tit_mod).vl_modalidade ); 
                    elsif st_mod_outras.tp_apropriacao_titulo    = 'B' then
                    -- Bolsa
                       l_vl_desconto_bolsa                                   :=  l_vl_desconto_bolsa 
                                                                             +   ( p_rec_financeiro.titulo(l_ind_tit).tit_mod(l_ind_tit_mod).vl_modalidade); 
                    elsif st_mod_outras.tp_apropriacao_titulo    = 'C' then
                    -- Desconto condicional
                       l_vl_desconto_condicional                            :=   l_vl_desconto_condicional 
                                                                            +    ( p_rec_financeiro.titulo(l_ind_tit).tit_mod(l_ind_tit_mod).vl_modalidade); 
                    end if;
                end if;
            end loop;   
                      
            -- Atualizar no array 'titulo' os acumulados de descontos incondicionais, condicionais e bolsas              
            p_rec_financeiro.titulo(l_ind_tit).vl_desconto_condicional   := p_rec_financeiro.titulo(l_ind_tit).vl_desconto_condicional
                                                                         +  l_vl_desconto_condicional;             
            p_rec_financeiro.titulo(l_ind_tit).vl_desconto_incondicional := p_rec_financeiro.titulo(l_ind_tit).vl_desconto_incondicional
                                                                         +  l_vl_desconto_incondicional;             
            p_rec_financeiro.titulo(l_ind_tit).vl_bolsa                  := p_rec_financeiro.titulo(l_ind_tit).vl_bolsa
                                                                         +  l_vl_desconto_bolsa;
            --if p_rec_financeiro.titulo(l_ind_tit).nr_competencia = 2  then                                                                
            --   dbms_output.put_line( '  E) comp: vt_vl_bolsa:' ||p_rec_financeiro.titulo(l_ind_tit).vl_bolsa || 
            --                      ' vt_vl_DI:' ||p_rec_financeiro.titulo(l_ind_tit).vl_desconto_incondicional||
            --                      ' vt_vl_DC:' ||p_rec_financeiro.titulo(l_ind_tit).vl_desconto_condicional ||
            --                      ' vt_vl_mod:' || p_rec_financeiro.titulo(l_ind_tit).id_modalidade
            --                    );
            --end if;
            -- dbms_output.put_line( '---------------------------------------------' );

            -- Incluir a modalidade de cobrança associada ao título
            l_ind_tit_mod := l_ind_tit_mod + 1;
            p_rec_financeiro.titulo(l_ind_tit).tit_mod(l_ind_tit_mod).nr_ind_financ_competencia 
                                                                      := null; 
            p_rec_financeiro.titulo(l_ind_tit).tit_mod(l_ind_tit_mod).nr_ind_financ_modalidade 
                                                                      := p_rec_financeiro.titulo(l_ind_tit).nr_ind_financ_modalidade; 
            p_rec_financeiro.titulo(l_ind_tit).tit_mod(l_ind_tit_mod).nr_ind_titulo               
                                                                      := p_rec_financeiro.titulo(l_ind_tit).nr_ind_titulo; 
            p_rec_financeiro.titulo(l_ind_tit).tit_mod(l_ind_tit_mod).id_modalidade               
                                                                      := p_rec_financeiro.titulo(l_ind_tit).id_modalidade ; 
            p_rec_financeiro.titulo(l_ind_tit).tit_mod(l_ind_tit_mod).id_pessoa_cobranca          
                                                                      := p_rec_financeiro.titulo(l_ind_tit).id_pessoa_cobranca; 
            p_rec_financeiro.titulo(l_ind_tit).tit_mod(l_ind_tit_mod).id_modalidade_tipo          
                                                                      := p_rec_financeiro.titulo(l_ind_tit).id_modalidade_tipo; 
            p_rec_financeiro.titulo(l_ind_tit).tit_mod(l_ind_tit_mod).nm_modalidade               
                                                                      := st_mod_cobranca.nm_modalidade; 
            p_rec_financeiro.titulo(l_ind_tit).tit_mod(l_ind_tit_mod).id_modalidade_origem        
                                                                      := st_mod_cobranca.id_modalidade_origem; 
            p_rec_financeiro.titulo(l_ind_tit).tit_mod(l_ind_tit_mod).id_modalidade_tipo_origem   
                                                                      := st_mod_cobranca.id_modalidade_tipo_origem; 
            p_rec_financeiro.titulo(l_ind_tit).tit_mod(l_ind_tit_mod).pc_modalidade    
                                                                      := st_mod_cobranca.pc_modalidade; 
            p_rec_financeiro.titulo(l_ind_tit).tit_mod(l_ind_tit_mod).vl_modalidade
                                                                      := p_rec_financeiro.titulo(l_ind_tit).vl_titulo; 
            
            p_rec_financeiro.titulo(l_ind_tit).tit_mod(l_ind_tit_mod).nr_competencia  
                                                                      := p_rec_financeiro.titulo(l_ind_tit).nr_competencia;
         end loop;         
    end loop;
--    
end loop;
--
end p_array_titulo;
-- 
-- -----------------------------------------------------------------------------
/*
PROCEDURE: p_titulo_persistir
DESENVOLVEDOR: Helane, Haroldo e José Leitão 
OBJETIVO: Persistir CA.CTR_TIULO e CA.FAT_MC_TIULO
PARÂMETROS:
   1 - p_rec_rc0
   2 - p_fg_retorno
   3 - p_ds_retorno

*/
-- -----------------------------------------------------------------------------
procedure p_titulo_persistir
( p_tp_operacao                             in      varchar2
, p_rec_mc_aluno                            in      ca.pk_fat_mc_plt.rec_mc_aluno 
, p_vt_titulos_aux                          in out  nocopy ca.pk_fat_mc_plt.vt_titulo_aux 
, p_vt_titulo_modalidade_aux                in out  nocopy ca.pk_fat_mc_plt.vt_titulo_modalidade 
, p_fl_exibir                               in      varchar2
, p_id_pessoa_aluno                         in      ca.cp_pessoa.id_pessoa%type
, p_rec_financeiro                          in out  nocopy ca.pk_fat_mc_plt.rec_financeiro
, p_qt_titulos_por_competencia_modalidade   in      number   
, p_dt_processamento                        in      date     
, p_dt_primeira_mensalidade_pg              in      date            
, p_fg_retorno                                 out  varchar2 
, p_ds_retorno                                 out  varchar2  ) is  
--
cursor cr_titulo is
select t.id_modalidade     
    , t.nr_competencia  
    , t.id_pessoa_cobranca 
    , t.id_titulo 
    , t.dt_competencia
    , t.dt_vencimento
    , t.vl_titulo 
    , t.vl_desconto_incondicional  
    , t.vl_bolsa
    , t.vl_titulo_liquido
    , t.vl_desconto_condicional 
    , decode( t.fg_titulo_preservado, 'N', 'CALCULO', 'TITULO' )   tipo 
    , t.ds_titulo_preservado
    , t.ds_titulo_faturado
    , t.ds_titulo_recebido 
    , t.id_modalidade_tipo
    , t.vl_titulo_mc 
    , t.nr_ind_titulo
    , m.nm_modalidade
 from ca.fat_modalidade m
    , table( p_vt_titulos_aux ) t   
where m.id_modalidade   = t.id_modalidade 
order by t.id_modalidade
    , t.id_pessoa_cobranca  
    , t.nr_competencia
    , t.dt_competencia
    , t.dt_vencimento;
--
l_rec_ctr_titulo                      ca.ctr_titulo%rowtype;
l_id_academico_titulo                 ca.fat_academico_titulo.id_academico_titulo%type;
--
l_id_mc_titulo                        ca.fat_mc_titulo.id_mc_titulo%type;
l_fg_titulo_oferta                    varchar2(1) := 'S';  
l_id_modalidade_ant                   ca.fat_modalidade.id_modalidade%type;  
tit                                   cr_titulo%rowtype; 
l_qt_titulo_modalidade                number(5);
l_nr_competencia_ant                  ca.ctr_titulo.nr_competencia%type;
l_qt_mes_incremento_vencimento        number(2) ;
--
begin
--
p_fg_retorno                      :=  'N'; 
--
if p_fl_exibir  =   'S' then 
--
   if p_tp_operacao               =   'P' then
      g_rec_fat_mc_log1.ds_log1   :=  '   ' || chr(10) || 'Titulo(s) gerado(s):'   || chr(10) ;
   elsif p_tp_operacao            =   'S' then
      g_rec_fat_mc_log1.ds_log1   :=  '   ' || chr(10) || 'Titulo(s) Simulado(s):' || chr(10) ;
   end if;
--
   g_rec_fat_mc_log1.ds_log1 :=  g_rec_fat_mc_log1.ds_log1 || 
                                 '------------------'|| chr(10) ||  
                                 'Preserv '         ||
                                 'Receb '           ||
                                 'Fat '             ||
                                 'Título   '        ||
                                 'Modalidade              '             ||
                                 'Pessoa '          ||
                                 'Seq '             ||
                                 'Compet  '     ||
                                 'Vencimento  '     ||
                                 '  Vl titulo '     ||
                                 'Desc incond '     || 
                                 '    Bolsa '       || 
                                 'Vl Líquido '      || 
                                 'D Condic'         || chr(10) ||                
                                 '------- '         ||
                                 '----- '           ||
                                 '--- '             ||
                                 '-------- '        ||
                                 '----------------------- '   ||
                                 '------ '          ||
                                 '--- '             ||
                                 '------  '          ||
                                 '----------- '     ||
                                 '----------- '     ||
                                 '----------- '     || 
                                 '--------- '       || 
                                 '---------- '      || 
                                 '-------- ' ;               
   dbms_output.put_line(g_rec_fat_mc_log1.ds_log1);
   g_rec_fat_mc_log1.id_log1                  :=  null;
   g_rec_fat_mc_log1.id_financeiro            :=  p_rec_mc_aluno.id_financeiro;
   g_rec_fat_mc_log1.nr_matricula             :=  p_rec_mc_aluno.nr_matricula;
   g_rec_fat_mc_log1.id_mc_aluno              :=  p_rec_mc_aluno.id_mc_aluno; 
   pk_fat_mc_dml.p_add_fat_mc_log1( g_rec_fat_mc_log1    
                                  , g_fg_retorno_log    
                                  , g_ds_retorno_log  );   
end if;
--
p_fg_retorno   := null;        

-- Loop do array de títulos gerados 
open  cr_titulo;
fetch cr_titulo into tit;
while cr_titulo%found loop
   l_id_modalidade_ant                 :=  tit.id_modalidade; 
   l_nr_competencia_ant                :=  tit.nr_competencia;
   l_qt_titulo_modalidade              :=  f_qt_titulo_modalidade( p_vt_titulos_aux
                                                                 , l_id_modalidade_ant
                                                                 , l_nr_competencia_ant );
--
-- dbms_output.put_line ('tit.nr_competencia: <'||tit.nr_competencia||'> tit.dt_competencia: <'||tit.dt_competencia||'> tit.dt_vencimento: <'||tit.dt_vencimento||'>');
--
   if l_qt_titulo_modalidade           =   1 then
      l_qt_mes_incremento_vencimento   :=  0;
   else
      l_qt_mes_incremento_vencimento   :=   ( l_nr_competencia_ant - p_rec_financeiro.qt_competencia_shift ) - l_qt_titulo_modalidade + 1;
   end if;
--  
   --dbms_output.put_line( '    ***1 .tit.id_modalidade :'|| tit.id_modalidade|| 
   --                      ' l_qt_titulo_modalidade:' || l_qt_titulo_modalidade ||
   --                      ' l_qt_mes_incremento_vencimento:' || l_qt_mes_incremento_vencimento 
   --                      );
   while cr_titulo%found 
     and l_id_modalidade_ant  = tit.id_modalidade    
     and l_nr_competencia_ant = tit.nr_competencia loop 
--               
     if  tit.tipo =   'CALCULO'    then  
         -- Popular record para persistir CTR_TITULO 
--       
         l_rec_ctr_titulo.id_financeiro                  := p_rec_mc_aluno.id_financeiro;
         l_rec_ctr_titulo.id_pessoa_cobranca             := tit.id_pessoa_cobranca;
         l_rec_ctr_titulo.id_pessoa_cliente              := p_id_pessoa_aluno;
         l_rec_ctr_titulo.cd_estab_cliente               := 0;
         l_rec_ctr_titulo.nr_matric_cliente              := p_rec_mc_aluno.nr_matricula;
--
         l_rec_ctr_titulo.cd_periodo_processo            := null;
         l_rec_ctr_titulo.nr_processo                    := null;
--       
         l_rec_ctr_titulo.cd_dominio_st_titulo           := s_pl_dominio_codigo( 'CTR_002' );   
         l_rec_ctr_titulo.cd_faixa_st_titulo             := 1;
--    
         l_rec_ctr_titulo.cd_dominio_especie_titulo      := s_pl_dominio_codigo( 'CTR_001' ); 
         l_rec_ctr_titulo.cd_faixa_especie_titulo        := 1;    
--      
         l_rec_ctr_titulo.id_modalidade_cobranca         := tit.id_modalidade;
--       
         -- Quando FIES não pode haver desconto condicional ( desconto associado a data de vencimento )
         if l_rec_ctr_titulo.id_modalidade_cobranca      in ( 145, 107 ) then
            tit.vl_desconto_incondicional                := abs( tit.vl_desconto_incondicional )
                                                         +  abs( tit.vl_desconto_condicional) ;
            tit.vl_desconto_condicional                  := 0;
         end if;        
--
         l_rec_ctr_titulo.vl_titulo                      := tit.vl_titulo;
         l_rec_ctr_titulo.vl_desconto_incondicional      := abs( tit.vl_desconto_incondicional );
         l_rec_ctr_titulo.vl_bolsa                       := abs( tit.vl_bolsa );
--       
         l_rec_ctr_titulo.vl_titulo_liquido              := l_rec_ctr_titulo.vl_titulo
                                                         -  l_rec_ctr_titulo.vl_desconto_incondicional 
                                                         -  l_rec_ctr_titulo.vl_bolsa; 
--
         l_rec_ctr_titulo.vl_desconto_condicional        := abs( tit.vl_desconto_condicional );
--       
         l_rec_ctr_titulo.vl_original                    := l_rec_ctr_titulo.vl_titulo_liquido;
         l_rec_ctr_titulo.nr_competencia                 := tit.nr_competencia;
         l_rec_ctr_titulo.vl_titulo_mc                   := tit.vl_titulo_mc;
         l_rec_ctr_titulo.dt_vencimento                  := null;
--       
         l_rec_ctr_titulo.fg_titulo_oferta               := l_fg_titulo_oferta; 
         l_rec_ctr_titulo.dt_hr_inclusao                 := p_dt_processamento; 
         l_rec_ctr_titulo.id_valor_indice                := p_rec_mc_aluno.id_valor_indice; 
--       
         --dbms_output.put_line( '.nr_competencia:'|| tit.nr_competencia ||
         --                      ' valor:' || tit.vl_titulo ||
         --                      ' Modalidade:' || tit.id_modalidade ||
         --                      ' tam array:' || vt_valor_competencia.count );
         if tit.id_modalidade_tipo = 8 then
         -- 9 - Financiamento próprio
            --l_vl_vendido                                 :=  0;
            --for ind in g_vt_financeiro_modalidade.first  ..  g_vt_financeiro_modalidade.last loop
            --    if g_vt_financeiro_modalidade(ind).id_modalidade = tit.id_modalidade then
            --       l_vl_vendido                          :=  nvl( l_vl_vendido, 0)
            --                                             +   g_vt_financeiro_modalidade(ind).vl_modalidade;
            --    end if;
            --end loop;
           
            --l_rec_ctr_titulo.un_titulo                   :=  ( tit.vl_titulo  * vt_valor_competencia(tit.nr_competencia).uf_competencia )
            --                                             /   l_vl_vendido;
            l_rec_ctr_titulo.un_titulo                   :=  0;
         else
            l_rec_ctr_titulo.un_titulo                   :=  ( tit.vl_titulo  * p_rec_financeiro.competencia(tit.nr_competencia - p_rec_financeiro.qt_competencia_shift ).uf_competencia )
                                                         /   p_rec_financeiro.competencia(tit.nr_competencia - p_rec_financeiro.qt_competencia_shift ).vl_vendido;
         end if;        
--
         l_fg_titulo_oferta                              := 'N'; 
         --dbms_output.put_line( 'p_titulo_persistir - l_nr_competencia_inicio_modalidade:' || l_nr_competencia_inicio_modalidade ||
         --  '  id_modalidade:' || l_id_modalidade_ant     );              
         p_ctr_titulo_incluir( p_tp_operacao
                             , p_rec_mc_aluno.tp_periodo 
                             , p_rec_mc_aluno.tp_arquivo 
                             , p_rec_mc_aluno.id_academico  
                             , l_rec_ctr_titulo 
                             , p_rec_financeiro 
                             , tit.nr_ind_titulo 
                             , l_qt_mes_incremento_vencimento       
                             , p_dt_processamento
                             , p_dt_primeira_mensalidade_pg    
  
                             , p_fg_retorno  
                             , p_ds_retorno  );

         if p_fg_retorno     =  'N' then
            raise ex_erro_memoria_calculo;
         end if;
         p_rec_financeiro.titulo( tit.nr_ind_titulo ).nr_competencia :=  l_rec_ctr_titulo.nr_competencia;
         --tit.nr_competencia                                     :=  l_rec_ctr_titulo.nr_competencia;
     else
         -- Titulo já existente e preservado
         l_rec_ctr_titulo.id_titulo                             :=  tit.id_titulo ;
         l_rec_ctr_titulo.id_modalidade_cobranca                :=  tit.id_modalidade  ; 
         l_rec_ctr_titulo.id_pessoa_cobranca                    :=  tit.id_pessoa_cobranca ; 
         l_rec_ctr_titulo.dt_competencia                        :=  tit.dt_competencia ;    
         l_rec_ctr_titulo.dt_vencimento                         :=  tit.dt_vencimento ; 
         l_rec_ctr_titulo.vl_titulo                             :=  tit.vl_titulo ; 
         l_rec_ctr_titulo.vl_desconto_incondicional             :=  tit.vl_desconto_incondicional ;
         l_rec_ctr_titulo.vl_bolsa                              :=  tit.vl_bolsa ;
         l_rec_ctr_titulo.vl_titulo_liquido                     :=  tit.vl_titulo_liquido ; 
         l_rec_ctr_titulo.vl_desconto_condicional               :=  tit.vl_desconto_condicional ;   
         l_rec_ctr_titulo.vl_titulo_mc                          :=  tit.vl_titulo_mc;
     end if;
--
     --dbms_output.put_line( 'p_fl_exibir:' || p_fg_retorno || 'p_fg_retorno:' || p_fg_retorno);     
     if p_fl_exibir     =   'S'  then 
        g_rec_fat_mc_log1.ds_log1 := rpad( tit.ds_titulo_preservado, 8 , ' ')                  ||
                                     rpad( tit.ds_titulo_recebido, 6 , ' ')                  ||
                                     rpad( tit.ds_titulo_faturado, 4 , ' ')                    ||
                                     rpad( nvl( to_char( l_rec_ctr_titulo.id_titulo), ' ' ), 9 , ' ')                ||
                                     substr( rpad( to_char( l_rec_ctr_titulo.id_modalidade_cobranca) || '-'|| tit.nm_modalidade,30, ' ' ) , 1, 23 )  || ' '  ||
                                     rpad( l_rec_ctr_titulo.id_pessoa_cobranca, 7, ' ' )       ||
                                     rpad( nvl( to_char( tit.nr_competencia ), ' ' ) , 4, ' ' )                        ||
                                     rpad( nvl( to_char( l_rec_ctr_titulo.dt_competencia, 'mm/yyyy' ), ' ' ), 8, ' ' )           ||
                                     rpad( nvl( to_char( l_rec_ctr_titulo.dt_vencimento, 'dd/mm/yyyy' ), ' ' ),12, ' ' )            ||
                                     rpad( nvl( to_char( l_rec_ctr_titulo.vl_titulo, '999G990D00' ), ' ' ), 12, ' ' )   || 
                                     rpad( nvl( to_char( l_rec_ctr_titulo.vl_desconto_incondicional, '999G990D00' ), ' ' ), 11, ' ' )  ||  
                                     rpad( nvl( to_char( l_rec_ctr_titulo.vl_bolsa, '99G990D00' ), ' ' ), 10, ' ' )    ||
                                     rpad( nvl( to_char( l_rec_ctr_titulo.vl_titulo_liquido, '999G990D00' ), ' ' ), 12, ' ' ) || 
                                     rpad( nvl( to_char( l_rec_ctr_titulo.vl_desconto_condicional, '9990D00' ), ' ' ), 8, ' ' );   



        dbms_output.put_line(g_rec_fat_mc_log1.ds_log1);
        g_rec_fat_mc_log1.id_log1                  :=  null;
        g_rec_fat_mc_log1.id_financeiro            :=  p_rec_mc_aluno.id_financeiro;
        g_rec_fat_mc_log1.nr_matricula             :=  p_rec_mc_aluno.nr_matricula;
        g_rec_fat_mc_log1.id_mc_aluno              :=  p_rec_mc_aluno.id_mc_aluno; 
        pk_fat_mc_dml.p_add_fat_mc_log1( g_rec_fat_mc_log1    
                                       , g_fg_retorno_log    
                                       , g_ds_retorno_log  )  ;   
     end if;
--
     if tit.tipo = 'TITULO' then     
        -- !!* Aqui - Incluir a MC TItulo e filhos para os titulos preservados
        -- Incluir record para para titulo preservado na nova MC
        -- criar cursor/select com MC anterior e popular l_rec_ctr_titulo
        -- Alterar as colunas a.id_mc_titulo, a.id_mc_aluno da tabela ca.fat_mc_titulo
        -- Tem que fazer a
        p_mc_titulo_incluir( p_rec_mc_aluno         
                           , l_rec_ctr_titulo                        -- in       
                           , l_id_academico_titulo         -- in
                           , l_id_mc_titulo                -- out
                           , p_fg_retorno                  -- out
                           , p_ds_retorno );               -- out
        -- fazer a mesma coisa com a tabela ca.mc_titulo_modalidade
        p_mc_titulo_modalidade_incluir( p_rec_mc_aluno
                                         , p_vt_titulo_modalidade_aux
                                         , tit.nr_competencia           
                                         , l_id_mc_titulo
                                         , p_fg_retorno         --  out   
                                         , p_ds_retorno );  
        -- Atualizar array dos titulos 
        p_rec_financeiro.titulo(tit.nr_ind_titulo).id_titulo           := l_rec_ctr_titulo.id_titulo;
        p_rec_financeiro.titulo(tit.nr_ind_titulo).id_mc_titulo        := l_id_mc_titulo;
        p_rec_financeiro.titulo(tit.nr_ind_titulo).dt_vencimento       := l_rec_ctr_titulo.dt_vencimento;
        p_rec_financeiro.titulo(tit.nr_ind_titulo).id_academico_titulo := l_id_academico_titulo;

     elsif tit.tipo = 'CALCULO' then     
     -- Novo titulo                         
        if  p_rec_mc_aluno.tp_arquivo =   1  then
            -- Atualizar o id_titulo no vetor pt_titulo  
            p_rec_financeiro.titulo (tit.nr_ind_titulo).id_titulo   
                                     := l_rec_ctr_titulo.id_titulo;
            -- Persistir CA.CTR_MC_TITULO 
            if p_tp_operacao = 'P' then
 --           
               p_mc_titulo_incluir( p_rec_mc_aluno         
                                  , l_rec_ctr_titulo                        -- in       
                                  , l_id_academico_titulo         -- in
                                  , l_id_mc_titulo                -- out
                                  , p_fg_retorno                  -- out
                                  , p_ds_retorno );               -- out
               if p_fg_retorno     =  'N' then
                  raise ex_erro_memoria_calculo;
               end if;
--         
               -- Persistir CA.FAT_MC_TITULO_MODALIDADE
               p_mc_titulo_modalidade_incluir( p_rec_mc_aluno
                                             , p_vt_titulo_modalidade_aux
                                             , tit.nr_competencia           
                                             , l_id_mc_titulo
                                             , p_fg_retorno         --  out   
                                             , p_ds_retorno );  
               if p_fg_retorno     =  'N' then
                  raise ex_erro_memoria_calculo;
               end if;
            end if;
 --
            -- Atualizar array dos titulos 
            p_rec_financeiro.titulo(tit.nr_ind_titulo).id_titulo           := l_rec_ctr_titulo.id_titulo;
            p_rec_financeiro.titulo(tit.nr_ind_titulo).id_mc_titulo        := l_id_mc_titulo;
            p_rec_financeiro.titulo(tit.nr_ind_titulo).dt_vencimento       := l_rec_ctr_titulo.dt_vencimento;
            p_rec_financeiro.titulo(tit.nr_ind_titulo).id_academico_titulo := l_id_academico_titulo;
        end if; 
     end if; 
--
     if l_qt_titulo_modalidade              >   1 then
        l_qt_mes_incremento_vencimento      :=  l_qt_mes_incremento_vencimento + 1;
     end if;
--     
     fetch cr_titulo into tit;
--
   end loop;
end loop;
close cr_titulo;
--
p_fg_retorno  :=  'S'; 
--
exception 
when ex_erro_memoria_calculo then
   p_fg_retorno     := 'N';
end p_titulo_persistir;
--
-- -----------------------------------------------------------------------------
/*
PROCEDURE: p_ctr_titulo_incluir
DESENVOLVEDOR: Helane, Haroldo e José Leitão 
OBJETIVO: Persistir  CA.CTR_TITULO  
PARÂMETROS:
    1 - p_nr_titulo
    2 - p_id_mc_titulo
    3 - p_fg_retorno
    4 - p_ds_retorno           

*/
-- -----------------------------------------------------------------------------
procedure p_ctr_titulo_incluir
( p_tp_operacao                       in     varchar
, p_tp_periodo                        in     varchar2
, p_tp_arquivo                        in     number
, p_id_academico                      in     ca.fat_academico.id_academico%type 
, p_rec_ctr_titulo                    in out nocopy ca.ctr_titulo%rowtype  
, p_rec_financeiro                    in out nocopy ca.pk_fat_mc_plt.rec_financeiro
, p_ind_titulo                        in     number
, p_qt_mes_incremento_vencimento      in     number    
, p_dt_processamento                  in     date      
, p_dt_primeira_mensalidade_pg        in     date      
, p_fg_retorno                        out    varchar2 
, p_ds_retorno                        out    varchar2  ) is
--                  
l_id_academico_titulo       ca.fat_academico_titulo.id_academico_titulo%type;
l_id_modalidade_tipo        ca.fat_modalidade.id_modalidade_tipo%type;
l_dt_vencimento             ca.ctr_titulo.dt_vencimento%type;
--
begin 
-- Popular record para persistir CTR_TITULO
p_rec_ctr_titulo.id_pessoa_cobranca             := nvl( p_rec_ctr_titulo.id_pessoa_cobranca, p_rec_ctr_titulo.id_pessoa_cliente );
p_rec_ctr_titulo.vl_desconto_incondicional      := abs( p_rec_ctr_titulo.vl_desconto_incondicional );
p_rec_ctr_titulo.vl_bolsa                       := abs( p_rec_ctr_titulo.vl_bolsa  );
--
p_rec_ctr_titulo.vl_titulo_liquido              := p_rec_ctr_titulo.vl_titulo
                                       -  p_rec_ctr_titulo.vl_desconto_incondicional 
                                       -  p_rec_ctr_titulo.vl_bolsa; 
--
p_rec_ctr_titulo.vl_desconto_condicional        := abs( p_rec_ctr_titulo.vl_desconto_condicional );
l_dt_vencimento                                 := p_rec_ctr_titulo.dt_vencimento;
--

--if p_rec_ctr_titulo.id_modalidade_cobranca <> 1 then
--   dbms_output.put_line( '>>>>> p_ctr_titulo_incluir - p_nr_ordem_titulo:' || p_rec_ctr_titulo.nr_competencia ||
--                        ' p_qt_titulo_modalidade:' ||p_qt_titulo_modalidade ||
--                        ' p_qt_mes_incremento_vencimento:' || p_qt_mes_incremento_vencimento ); 
--end if;
--          
p_dados_titulo
     ( p_id_financeiro                 => p_rec_ctr_titulo.id_financeiro
     , p_tp_periodo                    => p_tp_periodo  
     , p_tp_arquivo                    => p_tp_arquivo 
     , p_id_academico                  => p_id_academico
     , p_cd_identificador_vencimento   => p_rec_ctr_titulo.nr_competencia  
     , p_nr_dia_vencimento_padrao      => p_rec_financeiro.nr_dia_vencimento_padrao 
     , p_qt_competencia                => p_rec_financeiro.qt_competencia  
     , p_nr_competencia_inicio         => p_rec_financeiro.nr_competencia_inicio    
     , p_id_modalidade_cobranca        => p_rec_ctr_titulo.id_modalidade_cobranca  
     , p_nr_ordem_titulo               => p_rec_ctr_titulo.nr_competencia      
     , p_qt_mes_incremento_vencimento  => p_qt_mes_incremento_vencimento
     , p_dt_processamento              => p_dt_processamento
     , p_dt_primeira_mensalidade_pg    => p_dt_primeira_mensalidade_pg
--     
     , p_id_pessoa_irrf                => p_rec_ctr_titulo.id_pessoa_irrf                 -- out
     , p_dt_competencia                => p_rec_ctr_titulo.dt_competencia                 -- out
     , p_dt_vencimento                 => p_rec_ctr_titulo.dt_vencimento                  -- out
     , p_pc_multa                      => p_rec_ctr_titulo.pc_multa                       -- out
     , p_pc_juros                      => p_rec_ctr_titulo.pc_juros                       -- out
     , p_ds_referencia                 => p_rec_ctr_titulo.ds_referencia                  -- out
     , p_fg_fatura                     => p_rec_ctr_titulo.fg_fatura                      -- out
     , p_fg_contabiliza_rlp            => p_rec_ctr_titulo.fg_contabiliza_rlp             -- out
     , p_cd_agente_cobrador            => p_rec_ctr_titulo.cd_agente_cobrador             -- out
     , p_fg_agrupa_sacado              => p_rec_ctr_titulo.fg_agrupa_sacado               -- out
     , p_fg_titulo_oferta              => p_rec_ctr_titulo.fg_titulo_oferta               -- out
     , p_fg_instrucao_banco            => p_rec_ctr_titulo.fg_instrucao_banco             -- out
     , p_ds_mensagem_01                => p_rec_ctr_titulo.ds_mensagem_01                 -- out
     , p_ds_mensagem_02                => p_rec_ctr_titulo.ds_mensagem_02                 -- out
     , p_ds_mensagem_03                => p_rec_ctr_titulo.ds_mensagem_03                 -- out
     , p_ds_mensagem_04                => p_rec_ctr_titulo.ds_mensagem_04                 -- out
     , p_fg_retorno                    => p_fg_retorno                                    -- out
     , p_ds_retorno                    => p_ds_retorno                                    -- out
     , p_id_academico_titulo           => l_id_academico_titulo                           -- out
     , p_id_modalidade_tipo            => l_id_modalidade_tipo                            -- out
     , p_id_banco_agencia_carteira     => p_rec_ctr_titulo.id_banco_agencia_carteira      -- out
     , p_fg_gerar_boleto               => p_rec_ctr_titulo.fg_gerar_boleto                -- out
     , p_fg_postar_boleto              => p_rec_ctr_titulo.fg_postar_boleto               -- out
     , p_qt_dias_anteced_gerar_boleto  => p_rec_ctr_titulo.qt_dias_anteced_gerar_boleto   -- out 
     ); 
     
if p_fg_retorno = 'N' then
   raise ex_erro_memoria_calculo;
end if;
--
p_rec_financeiro.titulo(p_ind_titulo).dt_competencia       :=   p_rec_ctr_titulo.dt_competencia;         
p_rec_financeiro.titulo(p_ind_titulo).dt_vencimento        :=   p_rec_ctr_titulo.dt_vencimento;         
--
--if p_qt_titulo_modalidade                              >  6 then 
--p_rec_ctr_titulo.nr_competencia                      := round( p_rec_ctr_titulo.nr_competencia / 2);
--end if;    
--dbms_output.put_line( ' ** P_CTR_TITULO_INCLUIR - '||
--                      ' p_qt_titulo_modalidade:' || p_qt_titulo_modalidade||
--                      ' p_rec_ctr_titulo.nr_competencia:' || p_rec_ctr_titulo.nr_competencia||
--                      ' nr_competencia:' || p_rec_ctr_titulo.nr_competencia  );
--
if l_dt_vencimento                                     is not null then
   p_rec_ctr_titulo.dt_vencimento                      := l_dt_vencimento;
end if; 
--
if p_rec_ctr_titulo.id_banco_agencia_carteira          is null then
   p_rec_ctr_titulo.fg_gerar_boleto                    := 'N';
   p_rec_ctr_titulo.fg_postar_boleto                   := 'N';
else
   p_rec_ctr_titulo.fg_gerar_boleto                    := 'S';
   p_rec_ctr_titulo.fg_postar_boleto                   := 'S';
end if;
--
p_rec_ctr_titulo.dt_hr_inclusao                        := nvl( p_rec_ctr_titulo.dt_hr_inclusao, sysdate );
p_rec_ctr_titulo.fg_migracao                           := nvl( p_rec_ctr_titulo.fg_migracao, 'N' );
p_rec_ctr_titulo.vl_ajuste                             := nvl( p_rec_ctr_titulo.vl_ajuste, 0 );
p_rec_ctr_titulo.qt_dias_anteced_gerar_boleto          := 10;
--
-- !!* Aqui - Inclusão do título
if p_tp_operacao                                       =  'P' then
   ca.pk_ctr_titulo_clc.p_titulo_incluir( p_rec_ctr_titulo 
                                        , p_fg_retorno
                                        , p_ds_retorno);
   if p_fg_retorno           = 'N'  then
      raise ex_erro_memoria_calculo;
   end if;
end if;
--
exception 
when ex_erro_memoria_calculo then
     p_fg_retorno     := 'N';
end p_ctr_titulo_incluir; 
--
-- -----------------------------------------------------------------------------
/*
PROCEDURE: p_mc_titulo_modalidade_incluir
DESENVOLVEDOR: Helane, Haroldo e José Leitão 
OBJETIVO: Persistir Títulos por modalidade - CA.FAT_TITULO_MODALIDADE  
PARÂMETROS:
    1 - p_nr_titulo
    2 - p_id_mc_titulo
    3 - p_fg_retorno
    4 - p_ds_retorno 
*/          
-- -----------------------------------------------------------------------------
procedure p_mc_titulo_modalidade_incluir
( p_rec_mc_aluno              in       ca.pk_fat_mc_plt.rec_mc_aluno  
, p_vt_titulo_modalidade_aux  in       ca.pk_fat_mc_plt.vt_titulo_modalidade 
, p_nr_competencia            in       number
, p_id_mc_titulo              in       ca.fat_mc_titulo.id_mc_titulo%type 
, p_fg_retorno                out      varchar2 
, p_ds_retorno                out      varchar2  ) is 
--
rg_tit_mod                  ca.fat_mc_titulo_modalidade%rowtype; 
--
begin
--
p_fg_retorno    := 'N';
--
for titmod in ( select a.id_modalidade
                     , a.id_modalidade_tipo
                     , a.nm_modalidade
                     , a.id_modalidade_origem
                     , ( a.vl_modalidade * 
                         decode(b.id_modalidade_tipo, 2,-1,3,-1,4,-1,6,-1,+1 ) ) vl_modalidade
                     , a.pc_modalidade
                  from table( p_vt_titulo_modalidade_aux) a
                     , ca.fat_modalidade b
                 where a.id_modalidade      =   b.id_modalidade
                   and a.nr_competencia     =   p_nr_competencia 
                 order by decode(b.id_modalidade_tipo, 2,-1,3,-1,4,-1,6,-1,+1 ) desc
                     , id_modalidade_tipo
                     , id_modalidade
              )  loop
--
    rg_tit_mod.id_mc_titulo_modalidade       := null;
    rg_tit_mod.id_mc_aluno                   := p_rec_mc_aluno.id_mc_aluno;
    rg_tit_mod.id_mc_titulo                  := p_id_mc_titulo;
    rg_tit_mod.id_modalidade_cobranca        := titmod.id_modalidade;
    rg_tit_mod.id_modalidade_origem          := titmod.id_modalidade_origem;
    rg_tit_mod.pc_modalidade                 := titmod.pc_modalidade;
    rg_tit_mod.vl_modalidade                 := titmod.vl_modalidade; 
--    
    pk_fat_mc_dml.p_add_fat_mc_titulo_modalidade ( rg_tit_mod, p_fg_retorno, p_ds_retorno);
--     
    if p_fg_retorno     =   'N'  then
       raise ex_erro_memoria_calculo;
    end if;
--
end loop;
--
p_fg_retorno    := 'S';
--
exception 
when ex_erro_memoria_calculo then
     p_fg_retorno     := 'N';
end p_mc_titulo_modalidade_incluir;
--
-- -----------------------------------------------------------------------------
/*
PROCEDURE: p_mc_titulo_incluir
DESENVOLVEDOR: Helane, Haroldo e José Leitão 
OBJETIVO: Persistir Títulos por modalidade - CA.FAT_MC_TITULO 
PARÂMETROS:
    1 - p_reg_ctr_titulo         
    2 - p_id_academico_titulo 
    3 - p_id_mc_titulo      
    4 - p_fg_retorno            
    5 - p_ds_retorno                  
*/
    -- -----------------------------------------------------------------------------
procedure p_mc_titulo_incluir
( p_rec_mc_aluno             in   ca.pk_fat_mc_plt.rec_mc_aluno  
, p_reg_ctr_titulo           in   ca.ctr_titulo%rowtype  
, p_id_academico_titulo      in   number  
, p_id_mc_titulo             out  ca.fat_mc_titulo.id_mc_titulo%type 
, p_fg_retorno               out  varchar2 
, p_ds_retorno               out  varchar2 ) is 
--
rg_mc_tit                    ca.fat_mc_titulo%rowtype;
--
begin
--
p_fg_retorno    := 'N';
--
rg_mc_tit.id_mc_titulo                := null; 
rg_mc_tit.id_mc_aluno                 := p_rec_mc_aluno.id_mc_aluno ;
rg_mc_tit.id_titulo                   := p_reg_ctr_titulo.id_titulo;
rg_mc_tit.id_pessoa_cobranca          := p_reg_ctr_titulo.id_pessoa_cobranca;
rg_mc_tit.id_modalidade_cobranca      := p_reg_ctr_titulo.id_modalidade_cobranca;
rg_mc_tit.dt_competencia              := p_reg_ctr_titulo.dt_competencia;  
rg_mc_tit.dt_vencimento               := p_reg_ctr_titulo.dt_vencimento;
rg_mc_tit.vl_titulo                   := p_reg_ctr_titulo.vl_titulo;
rg_mc_tit.vl_desconto_incondicional   := p_reg_ctr_titulo.vl_desconto_incondicional;
rg_mc_tit.vl_bolsa                    := p_reg_ctr_titulo.vl_bolsa;
rg_mc_tit.vl_desconto_condicional     := p_reg_ctr_titulo.vl_desconto_condicional;
rg_mc_tit.id_academico_titulo         := p_id_academico_titulo;
--
pk_fat_mc_dml.p_add_fat_mc_titulo ( rg_mc_tit, p_fg_retorno, p_ds_retorno);
--    
if p_fg_retorno = 'N'  then
   raise ex_erro_memoria_calculo;
end if;
--
p_id_mc_titulo  := rg_mc_tit.id_mc_titulo;
p_fg_retorno    := 'S';
--
exception 
when ex_erro_memoria_calculo then
      p_fg_retorno     := 'N';
end p_mc_titulo_incluir;
--       
-- -----------------------------------------------------------------------------
/* 
PROCEDURE: p_dados_titulo
DESENVOLVEDOR: Helane, Haroldo e José Leitão 
OBJETIVO: Obter dados do título
PARÂMETROS:


*/
-- -----------------------------------------------------------------------------
--
procedure p_dados_titulo
( p_id_financeiro                    in   ca.fat_financeiro.id_financeiro%type
, p_tp_periodo                       in   varchar2
, p_tp_arquivo                       in   number
, p_id_academico                     in   ca.fat_academico.id_academico%type
, p_cd_identificador_vencimento      in   varchar2
, p_nr_dia_vencimento_padrao         in   number
, p_qt_competencia                   in   number 
, p_nr_competencia_inicio            in   number
, p_id_modalidade_cobranca           in   number
, p_nr_ordem_titulo                  in   number  
, p_qt_mes_incremento_vencimento     in   number  
, p_dt_processamento                 in   date 
, p_dt_primeira_mensalidade_pg       in   date
--
, p_id_pessoa_irrf                   out  number 
, p_dt_competencia                   out  date
, p_dt_vencimento                    out  date
, p_pc_multa                         out  number
, p_pc_juros                         out  number
, p_ds_referencia                    out  varchar2
, p_fg_fatura                        out  varchar2
, p_fg_contabiliza_rlp               out  varchar2
, p_cd_agente_cobrador               out  number
, p_fg_agrupa_sacado                 out  varchar2
, p_fg_titulo_oferta                 out  varchar2
, p_fg_instrucao_banco               out  varchar2
, p_ds_mensagem_01                   out  varchar2
, p_ds_mensagem_02                   out  varchar2
, p_ds_mensagem_03                   out  varchar2
, p_ds_mensagem_04                   out  varchar2
--
, p_fg_retorno                       out  varchar2
, p_ds_retorno                       out  varchar2 
, p_id_academico_titulo              out  number
, p_id_modalidade_tipo               out  number
, p_id_banco_agencia_carteira        out  ca.fat_modalidade.id_banco_agencia_carteira%type
, p_fg_gerar_boleto                  out  ca.ctr_titulo.fg_gerar_boleto%type
, p_fg_postar_boleto                 out  ca.ctr_titulo.fg_gerar_boleto%type
, p_qt_dias_anteced_gerar_boleto     out  ca.ctr_titulo.fg_gerar_boleto%type
) is
--
cursor cr_dados_cobranca( pc_id_financeiro            in  number 
                        , pc_id_modalidade_cobranca   in  number ) is
select f.id_modalidade
, f.id_modalidade_tipo
, nvl(f.fg_agrupa_sacado, 'N') fg_agrupa_sacado  
, f.cd_externo_padrao
from ca.fat_modalidade f
where f.id_modalidade =  pc_id_modalidade_cobranca ;
--    and f.fg_ativo                  =  'S' ; 
--
begin
--
p_fg_retorno := 'N';
p_ds_retorno := null;
--
if p_id_financeiro is null then 
   p_ds_retorno := 'Identificador do financeiro não foi informado.';
   goto saida;
end if;
--
if p_id_modalidade_cobranca is null then 
   p_ds_retorno :=  'Identificador da modalidade de cobrança não foi informado.';
   goto saida;
end if;
--
if p_nr_ordem_titulo is null then
   p_ds_retorno := 'Número de ordem do título não foi informado.';
   goto saida;
end if;
--
--dbms_output.put_line( '***    P_DADOS_TITULO - p_id_financeiro:' ||p_id_financeiro || 
--                      ' p_nr_ordem_titulo:' || p_nr_ordem_titulo ||
--                      ' p_id_modalidade_cobranca :' ||     p_id_modalidade_cobranca ||
--                      ' p_tp_periodo:' || p_tp_periodo || 
--                      ' p_nr_dia_vencimento_padrao:' || p_nr_dia_vencimento_padrao || 
--                      ' p_dt_processamento:' || p_dt_processamento || 
--                      ' p_dt_primeira_mensalidade_pg:' || p_dt_primeira_mensalidade_pg 
--                         );

open c4_fat_financeiro ( p_id_financeiro
                       , p_nr_ordem_titulo 
                       , p_id_modalidade_cobranca 
                       , p_tp_periodo   
                       , p_tp_arquivo 
                       , p_nr_dia_vencimento_padrao
                       , p_dt_processamento
                       , p_dt_primeira_mensalidade_pg );
fetch c4_fat_financeiro into rc4;
--dbms_output.put_line( '    P_DADOS_TITULO - p_qt_titulo_modalidade:' ||p_qt_titulo_modalidade ); -- ||
--                      ' p_nr_ordem_titulo:' || p_nr_ordem_titulo ||
--                     ' rc4.nr_ordem_titulo :' ||      rc4.nr_ordem_titulo ||
--                      ' p_nr_competencia_original:' || p_nr_competencia_original   );

if c4_fat_financeiro%notfound then 
   --dbms_output.put_line( '***    P_DADOS_TITULO - não achou ' );
   g_rc4_ultimo.cd_externo_padrao :=   null;
   rc4   :=   g_rc4_ultimo;
--
   open cr_dados_cobranca( p_id_financeiro 
                         , p_id_modalidade_cobranca  );
   fetch cr_dados_cobranca into rc4.id_modalidade
                              , rc4.id_modalidade_tipo
                              , rc4.fg_agrupa_sacado
                              , rc4.cd_externo_padrao ; 
   close cr_dados_cobranca ;
--
   rc4.id_academico_titulo                           :=   null;
   rc4.nr_ordem_titulo                               :=   rc4.nr_ordem_titulo + 1; 
   rc4.id_acad_tit_vencimento                        :=   null; 
--
   --dbms_output.put_line( ' p_dados_tiulo - comp:' ||      rc4.nr_ordem_titulo ||
   --                      ' l_qt_competencia_modalidade:' || l_qt_competencia_modalidade ||
   --                      ' p_nr_competencia_original:' || p_nr_competencia_original ||
   --                      ' p_nr_competencia_inicio_modalidade:' || p_nr_competencia_inicio_modalidade   );
   if rc4.dt_vencimento is   null  then
      rc4.dt_vencimento :=   trunc( p_dt_processamento + 2 );
      --dbms_output.put_line( ' **1   rc4.dt_mes_ano_competencia:' || rc4.dt_mes_ano_competencia );
   else
      rc4.dt_vencimento :=   add_months( rc4.dt_vencimento, 1) ; 
   end if;
end if; 
close c4_fat_financeiro;
--
------------------------------------------------------------------------
--
rc4.dt_vencimento              :=   add_months( rc4.dt_vencimento, p_qt_mes_incremento_vencimento      ) ;   
--if p_id_modalidade_cobranca   = 105  then
--    dbms_output.put_line( '    P_DADOS_TITULO(1.1) - p_nr_dia_vencimento_padrao:' || p_nr_dia_vencimento_padrao ||
--                          ' dia:'           || to_char(rc4.dt_vencimento,'dd') ||
--                          ' Increm:' || p_qt_mes_incremento_vencimento
--                          );
--    dbms_output.put_line( '    P_DADOS_TITULO(1.2) dt vcto:'           ||  rc4.dt_vencimento ||
--                          '    p_dt_processamento:' || p_dt_processamento 
--                          );
--end if;
--
if p_nr_dia_vencimento_padrao  >  to_char(rc4.dt_vencimento,'dd') then
   rc4.dt_vencimento           := to_date( to_char( p_nr_dia_vencimento_padrao, '00' ) || 
                                           to_char( rc4.dt_vencimento, '/mm/yyyy'), 'dd/mm/yyyy');
   --if p_id_modalidade_cobranca   = 105   then
   --    dbms_output.put_line( '    P_DADOS_TITULO(2) - dt_vencimento 1:' ||  to_char( rc4.dt_vencimento, 'dd/mm/yyyy' )  );        
   --end if;  
elsif rc4.dt_vencimento        <=  p_dt_processamento    then
   rc4.dt_vencimento           :=  to_date( to_char( p_dt_processamento, 'dd' ) || 
                                            to_char( rc4.dt_vencimento, '/mm/yyyy'), 'dd/mm/yyyy') 
                               + g_qt_dias_tolerancia_vencto_titulo; 
   --if p_id_modalidade_cobranca   = 105    then
   --    dbms_output.put_line( '    P_DADOS_TITULO(3) - dt_vencimento 2:' || to_char( rc4.dt_vencimento, 'dd/mm/yyyy' )  ||
   --                          ' g_qt_dias_tolerancia_vencto_titulo:' || g_qt_dias_tolerancia_vencto_titulo );        
   --end if;
end if;    
--    
g_rc4_ultimo.dt_vencimento                           :=   rc4.dt_vencimento  ;                                               
g_rc4_ultimo.dt_mes_ano_competencia                  :=   rc4.dt_mes_ano_competencia  ;                                               
p_dt_competencia                                     :=   rc4.dt_mes_ano_competencia;
p_dt_vencimento                                      :=   rc4.dt_vencimento;
--
p_id_academico_titulo                                :=   rc4.id_academico_titulo;
p_id_pessoa_irrf                                     :=   rc4.id_pessoa_aluno;
--
--if p_nr_ordem_titulo > 6 then
--   dbms_output.put_line( ' POS P_DADOS_TITULO -  SEQ:' || p_nr_ordem_titulo || 
--                         ' Competencia:' ||   g_rc4_ultimo.dt_mes_ano_competencia  ||
--                         ' Vct:'  || g_rc4_ultimo.dt_vencimento   
--                       );        
--end if;
--
if rc4.id_banco_agencia_carteira                     is   not null then
    p_id_banco_agencia_carteira                      :=   rc4.id_banco_agencia_carteira;
    p_cd_agente_cobrador                             :=   rc4.cd_agente_cobrador;
    p_fg_gerar_boleto                                :=   'S';
    p_fg_postar_boleto                               :=   'S';
    p_qt_dias_anteced_gerar_boleto                   :=   10; 
elsif rc4.cd_agente_cobrador                         is   not null then
    p_id_banco_agencia_carteira                      :=   null;
    p_cd_agente_cobrador                             :=   rc4.cd_agente_cobrador;
    p_fg_gerar_boleto                                :=   'N';
    p_fg_postar_boleto                               :=   'N';
    p_qt_dias_anteced_gerar_boleto                   :=   0; 
end if;
--
if rc4.fg_considerar_encargos                        =    'S' then
   p_pc_multa                                        :=   rc4.pc_multa;
   p_pc_juros                                        :=   rc4.pc_juros;
else
   p_pc_multa                                        :=   0;
   p_pc_juros                                        :=   0;
end if;   
--
p_ds_referencia                :=    'Título Mensalidade do aluno '||
                                     trim(to_char(rc4.nr_matricula,'0000000'))||'/'||rc4.dv_matricula||
                                     ' de '||rc4.ds_tp_aluno||' do '||rc4.ds_apresentacao||
                                     rc4.ds_periodo||' para a competência '||
                                     to_char(rc4.dt_mes_ano_competencia,'YYYY/MM');
p_fg_fatura                    :=    'S';
p_fg_contabiliza_rlp           :=    'N';
p_fg_agrupa_sacado             :=    rc4.fg_agrupa_sacado;
--
p_fg_titulo_oferta             := rc4.fg_titulo_oferta;
if rc4.fg_titulo_oferta = 'S' then 
   -- Tratar as mensagens específicas dos títulos para emissão dos boletos das outras modalidades tipo
   p_ds_mensagem_03         := 'A renovação da matrícula está condicionada ao pagamento deste boleto';
   p_ds_mensagem_04         :=    'e a quitação de débitos anteriores - ART. 5 LEI 9870/99.';
else
   p_ds_mensagem_03         := null;
   p_ds_mensagem_04         := null;
end if;
--
if rc4.id_modalidade_tipo      = 1   then
   p_fg_instrucao_banco        :=    'S';
   p_ds_mensagem_01            :=    'Mensalidade do aluno '||
                                     trim(to_char(rc4.nr_matricula,'0000000'))||'/'||rc4.dv_matricula||
                                     ' de '||rc4.ds_tp_aluno||' do '||rc4.ds_apresentacao||' '||
                                     rc4.ds_periodo;
   p_ds_mensagem_02            :=    'para a competência '||to_char(rc4.dt_mes_ano_competencia,'YYYY/MM');
   p_fg_retorno                :=    'S';
--
elsif rc4.id_modalidade_tipo   =     5 then   -- CONVÊNIO DE PAGAMENTO: Destino de cobrança é empresa
   p_fg_instrucao_banco        :=    'S';
   p_ds_mensagem_01            :=    'Mensalidade do aluno '||
                                     trim(to_char(rc4.nr_matricula,'0000000'))||'/'||rc4.dv_matricula||
                                     ' de '||rc4.ds_tp_aluno||' do '||rc4.ds_apresentacao||' '||
                                     rc4.ds_periodo;
   p_ds_mensagem_02            :=    'para a competência '||to_char(rc4.dt_mes_ano_competencia,'YYYY/MM');
--
   p_fg_retorno                :=    'S';
--
elsif rc4.id_modalidade_tipo   =     7 then   
-- FINANCIAMENTO PÚBLICO: Destino de cobrança é empresa
   p_fg_instrucao_banco        :=    'N';
   p_fg_retorno                :=    'S';
   p_ds_mensagem_01            := null;
   p_ds_mensagem_02            := null;
   p_ds_mensagem_03            := null;
   p_ds_mensagem_04            := null;
--
elsif rc4.id_modalidade_tipo   =     8 then   
-- FINANCIAMENTO PRIVADO: Destino de cobrança é empresa
   p_fg_instrucao_banco        :=    'N';
   if rc4.id_modalidade        =     103 then
      p_fg_retorno             :=    'S';
   elsif rc4.id_modalidade     =     105 then
      p_fg_retorno             :=    'S';
   else
      p_ds_retorno             :=    'Modalidade não prevista';
      p_fg_retorno             :=    'S';
   end if;
   p_ds_mensagem_01            := null;
   p_ds_mensagem_02            := null;
   p_ds_mensagem_03            := null;
   p_ds_mensagem_04            := null;
--
elsif rc4.id_modalidade_tipo   =     11 then  
-- PARCELAMENTO UNIFOR: Destino de cobrança é o aluno
-- Não entendi o tratamento da modalidade tipo !!!   
   if rc4.nr_ordem_titulo      =     1 then
      p_fg_instrucao_banco     :=    'S';
      p_ds_mensagem_01         :=    'Mensalidade do aluno '||
                                     trim(to_char(rc4.nr_matricula,'0000000'))||'/'||rc4.dv_matricula||
                                     ' de '||rc4.ds_tp_aluno||' do '||rc4.ds_apresentacao||' '||
                                     rc4.ds_periodo;
      p_ds_mensagem_02         :=    'para a competência '||to_char(rc4.dt_mes_ano_competencia,'YYYY/MM');
--
   elsif rc4.nr_ordem_titulo = 1 and rc4.nr_ordem_titulo <= p_qt_competencia  then

      p_fg_instrucao_banco     :=    'S';
      p_ds_mensagem_01         :=    'Mensalidade do aluno '||
                                     trim(to_char(rc4.nr_matricula,'0000000'))||'/'||rc4.dv_matricula||
                                     ' de '||rc4.ds_tp_aluno||' do '||rc4.ds_apresentacao||' '||
                                     rc4.ds_periodo;
      p_ds_mensagem_02         :=    'para a competência '||to_char(rc4.dt_mes_ano_competencia,'YYYY/MM');
   else
      p_fg_instrucao_banco     :=    'N';
   end if;
   p_fg_retorno                :=    'S';
--
else
   p_fg_retorno                :=    'N';
   p_ds_retorno                :=    'Modalidade ' || p_id_modalidade_cobranca || '/' || 
                                     rc4.id_modalidade_tipo || ' não é de cobrança.';
   goto SAIDA;
--
end if;
p_id_modalidade_tipo           :=    rc4.id_modalidade_tipo;

/*  
if  g_dt_1a_competencia        is    null
and p_nr_competencia_original  =     1   then 
    g_dt_1a_competencia        :=    p_dt_competencia;
end if;
    
if  g_dt_1o_vencimento         is    null
and p_nr_competencia_original  =     1   then 
    g_dt_1o_vencimento         :=    p_dt_vencimento;
end if;  */
--
<<saida>>
null;
--
end p_dados_titulo;
--
-- -----------------------------------------------------------------------------
/*
PROCEDURE: p_mc_valor_competencia_incluir
DESENVOLVEDOR: Helane, Haroldo e José Leitão 
OBJETIVO: Persistir tabela CA.FAT_MC_VALOR_COMPETENCIA
PARÂMETROS:
   1 - vt_valor_competencia     
   2 - p_fg_retorno       
   3 - p_ds_retorno
         
*/
-- -----------------------------------------------------------------------------
procedure p_mc_valor_competencia_incluir
( p_rec_financeiro     in out nocopy ca.pk_fat_mc_plt.rec_financeiro   
, p_rec_mc_aluno       in     ca.pk_fat_mc_plt.rec_mc_aluno   
, p_fg_retorno         out    varchar2 
, p_ds_retorno         out    varchar2 ) is 
--
l_rec_fat_mc_titulo_modalidade      ca.fat_mc_valor_competencia%rowtype;
--
begin
--
p_fg_retorno    := 'N';
--
if p_rec_financeiro.competencia.count  > 0  then 
   for ind_comp in p_rec_financeiro.competencia.first .. p_rec_financeiro.competencia.last loop
        if  p_rec_financeiro.competencia( ind_comp ).vl_vendido               >          0   then
            l_rec_fat_mc_titulo_modalidade.id_mc_valor_competencia    := null;  
                                                                                             
            l_rec_fat_mc_titulo_modalidade.id_mc_aluno                := p_rec_mc_aluno.id_mc_aluno ;
            l_rec_fat_mc_titulo_modalidade.id_academico_titulo        := p_rec_financeiro.competencia( ind_comp ).id_academico_titulo;
            l_rec_fat_mc_titulo_modalidade.vl_vendido                 := p_rec_financeiro.competencia( ind_comp ).vl_vendido;
            l_rec_fat_mc_titulo_modalidade.vl_desconto_incondicional  := p_rec_financeiro.competencia( ind_comp ).vl_desconto_incondicional;
            l_rec_fat_mc_titulo_modalidade.vl_bolsa                   := p_rec_financeiro.competencia( ind_comp ).vl_bolsa;
            l_rec_fat_mc_titulo_modalidade.vl_desconto_condicional    := p_rec_financeiro.competencia( ind_comp ).vl_desconto_condicional; 
            l_rec_fat_mc_titulo_modalidade.nr_competencia             := p_rec_financeiro.competencia( ind_comp ).nr_competencia;
-- !!* Aqui - Atualização de dados
            pk_fat_mc_dml.p_add_fat_mc_valor_competencia( l_rec_fat_mc_titulo_modalidade
                                                        , p_fg_retorno           
                                                        , p_ds_retorno );    
            if p_fg_retorno   = 'N'  then
               raise ex_erro_memoria_calculo;
            end if;             
--            
            -- Salvar no array o Id da tabela ca.fat_mc_valor_competencia
            p_rec_financeiro.competencia( ind_comp ).id_mc_valor_competencia                := l_rec_fat_mc_titulo_modalidade.id_mc_valor_competencia  ;
        end if;
--        
    end loop;
end if;
--
p_fg_retorno    := 'S';
--    
exception 
when ex_erro_memoria_calculo then
     p_fg_retorno     := 'N';
end p_mc_valor_competencia_incluir;                        
--     
-- -----------------------------------------------------------------------------
/*
PROCEDURE: p_persistir_mc_modalidade_competencia
DESENVOLVEDOR: Helane, Haroldo e José Leitão 
OBJETIVO: Persistir tabela CA.FAT_MC_MODALIDADE_COMPETENCIA
PARÂMETROS:
   1 - vt_valor_competencia     
   2 - p_fg_retorno       
   3 - p_ds_retorno          
*/
-- -----------------------------------------------------------------------------
procedure p_persistir_financeiro
( p_rec_mc_aluno             in    ca.pk_fat_mc_plt.rec_mc_aluno  
, p_rec_financeiro           in    ca.pk_fat_mc_plt.rec_financeiro
, p_fg_retorno               out   varchar2 
, p_ds_retorno               out   varchar2 ) is 
--
l_ind_array                      number(5) := 0;
l_rec_fat_financeiro_modalidade  ca.fat_financeiro_modalidade%rowtype; 
--
--  !!* Aqui - Atualização de dados - incluir as outras atualizações no pacote ca.pk_fat_academico_dml
begin
--
p_fg_retorno    := 'N';
--
-- Atualização do financeiro, caso tenha alteracao do valor do financeiro 
update ca.fat_financeiro  
   set vl_financeiro      =   p_rec_mc_aluno.vl_financeiro
     , cd_est_alteracao   =   p_rec_mc_aluno.cd_est_operador
     , nr_mat_alteracao   =   p_rec_mc_aluno.nr_mat_operador
     , id_valor_indice    =   p_rec_mc_aluno.id_valor_indice
     , tp_indice          =   p_rec_mc_aluno.tp_indice
 where id_financeiro      =   p_rec_mc_aluno.id_financeiro
   and vl_financeiro      <>  p_rec_mc_aluno.vl_financeiro;
   
-- Desativar todas as modalidades do financeiro 
update ca.fat_financeiro_modalidade  
   set fg_ativo           =   'N'
 where id_financeiro      =   p_rec_mc_aluno.id_financeiro
   and fg_ativo           =   'S';
--
-- Incluir todas as modalidades do aluno ao financeiro
if p_rec_financeiro.modalidade.count    > 0 then
   for l_ind_array in p_rec_financeiro.modalidade.first .. p_rec_financeiro.modalidade.last loop
--       if p_rec_financeiro.modalidade(l_ind_array).vl_modalidade >  0 then  
       l_rec_fat_financeiro_modalidade.id_financeiro_modalidade :=  null;
       l_rec_fat_financeiro_modalidade.id_financeiro            :=  p_rec_financeiro.id_financeiro;
       l_rec_fat_financeiro_modalidade.id_nome_modalidade       :=  p_rec_financeiro.modalidade(l_ind_array).id_nome_modalidade;
       l_rec_fat_financeiro_modalidade.vl_modalidade            :=  p_rec_financeiro.modalidade(l_ind_array).vl_modalidade;
       l_rec_fat_financeiro_modalidade.vl_limite                :=  p_rec_financeiro.modalidade(l_ind_array).vl_limite ;
       l_rec_fat_financeiro_modalidade.pc_modalidade            :=  p_rec_financeiro.modalidade(l_ind_array).pc_modalidade;
       l_rec_fat_financeiro_modalidade.cd_ocorrencia_regra      :=  p_rec_financeiro.modalidade(l_ind_array).cd_ocorrencia_regra; 
       l_rec_fat_financeiro_modalidade.fg_ativo                 :=  'S';
       l_rec_fat_financeiro_modalidade.id_modalidade            :=  p_rec_financeiro.modalidade(l_ind_array).id_modalidade;
--
       begin
       select a.id_financeiro_modalidade into l_rec_fat_financeiro_modalidade.id_financeiro_modalidade
       from   ca.fat_financeiro_modalidade a
       where  a.id_financeiro      = l_rec_fat_financeiro_modalidade.id_financeiro 
       and    a.id_nome_modalidade = l_rec_fat_financeiro_modalidade.id_nome_modalidade;
       exception
       when no_data_found then
            l_rec_fat_financeiro_modalidade.id_financeiro_modalidade := null;
       end;
--           
           --if l_rec_fat_financeiro_modalidade.vl_modalidade is null then
           -- dbms_output.put_line( '***** id_modalidade:' || l_rec_fat_financeiro_modalidade.id_modalidade  || 
           --                       ' pc_modalidade:' || l_rec_fat_financeiro_modalidade.pc_modalidade );
           --end if;
--          
       if l_rec_fat_financeiro_modalidade.id_financeiro_modalidade is not null then
--
          begin
          update ca.fat_financeiro_modalidade a
          set    a.fg_ativo            = l_rec_fat_financeiro_modalidade.fg_ativo
               , a.vl_modalidade       = l_rec_fat_financeiro_modalidade.vl_modalidade
               , a.cd_ocorrencia_regra = l_rec_fat_financeiro_modalidade.cd_ocorrencia_regra
          where  a.id_financeiro_modalidade = l_rec_fat_financeiro_modalidade.id_financeiro_modalidade;
          end;
--
       else
          pk_fat_academico_dml.p_add_fat_financeiro_modalidade( l_rec_fat_financeiro_modalidade
                                                              , p_fg_retorno    
                                                              , p_ds_retorno   );
          if p_fg_retorno = 'N' then
             p_ds_retorno := 'Exceção em ca.pk_fat_academico_dml.p_add_fat_financeiro_modalidade';
             raise ex_erro_memoria_calculo;
          end if; 
       end if;
--
   end loop;
--
   p_fg_retorno    := 'S';
--
end if;
--
exception 
when ex_erro_memoria_calculo then
     p_fg_retorno     := 'N';
end p_persistir_financeiro;                        
--
-- -----------------------------------------------------------------------------
/*
PROCEDURE: p_mc_modalidade_competencia_incluir
DESENVOLVEDOR: Helane, Haroldo e José Leitão 
OBJETIVO: Persistir tabela CA.FAT_MC_MODALIDADE_COMPETENCIA
PARÂMETROS:
   1 - vt_valor_competencia     
   2 - p_fg_retorno       
   3 - p_ds_retorno          

*/
-- -----------------------------------------------------------------------------
procedure p_mc_modalidade_competencia_incluir
( p_rec_mc_aluno                  in     ca.pk_fat_mc_plt.rec_mc_aluno 
, p_rec_financeiro                in     ca.pk_fat_mc_plt.rec_financeiro
, p_vt_modalidade_competencia_aux in out nocopy ca.pk_fat_mc_plt.vt_modalidade_competencia
, p_fg_retorno                    out    varchar2 
, p_ds_retorno                    out    varchar2 ) is 
--
l_rec_modalidade_competencia              ca.fat_mc_modalidade_competencia%rowtype;
-- l_vt_modalidade_competencia_aux           ca.pk_fat_mc_plt.vt_modalidade_competencia; 
--
begin
--
p_fg_retorno    := 'N';
--
for mc  in ( select id_modalidade    
                  , id_modalidade_origem      
                --  , id_academico_titulo       
                  , pc_modalidade             
                  , pc_modalidade_original             
                  , vl_modalidade               
                  , vl_base_calculo        
                  , tp_apropriacao_titulo    
                  , id_financeiro_modalidade                         
                  , nr_sequencia_calculo     
                  , nr_competencia    
               from table(p_vt_modalidade_competencia_aux) 
              where ( vl_modalidade       >    0 
                 or   ( vl_modalidade     =    0 
                and     id_modalidade     =    1 
                      )
                    )
              order by nr_sequencia_calculo
                  , id_modalidade
                  , nr_competencia 
           )  loop
--                   
    l_rec_modalidade_competencia.id_mc_modalidade_competencia := null;  

    l_rec_modalidade_competencia.id_mc_aluno                  := p_rec_mc_aluno.id_mc_aluno ; 
    l_rec_modalidade_competencia.id_modalidade                := mc.id_modalidade;
    l_rec_modalidade_competencia.id_modalidade_origem         := mc.id_modalidade_origem;
  --l_rec_modalidade_competencia.id_academico_titulo          := mc.id_academico_titulo;
    l_rec_modalidade_competencia.pc_modalidade                := mc.pc_modalidade;
    l_rec_modalidade_competencia.pc_modalidade_original       := mc.pc_modalidade_original;
    l_rec_modalidade_competencia.vl_modalidade                := mc.vl_modalidade;
    l_rec_modalidade_competencia.vl_base                      := nvl( mc.vl_base_calculo, 0);
    l_rec_modalidade_competencia.tp_utilizacao                := mc.tp_apropriacao_titulo;
    l_rec_modalidade_competencia.id_financeiro_modalidade     := mc.id_financeiro_modalidade;  
    l_rec_modalidade_competencia.pc_fator_limite              := p_rec_financeiro.pc_fator_limite;
--   
    pk_fat_mc_dml.p_add_fat_mc_modalidade_competencia( l_rec_modalidade_competencia
                                                   , p_fg_retorno           
                                                   , p_ds_retorno );    
    if p_fg_retorno   = 'N'  then
      -- dbms_output.put_line( 'p_ds_retorno: ' || p_ds_retorno );
       raise ex_erro_memoria_calculo;
    end if;             
end loop;
--
p_fg_retorno    := 'S';
--
exception 
when ex_erro_memoria_calculo then
     p_fg_retorno     := 'N';
end p_mc_modalidade_competencia_incluir;                        

/* 
-- -----------------------------------------------------------------------------
PROCEDURE: P_ARRAY_FINANCEIRO_MODALIDADE
DESENVOLVEDOR: Helane, Haroldo e José Leitão 
OBJETIVO: Montar array com as modalidades necessárias  
PARÂMETROS: 
    1 - p_rec_mc_aluno
    2 - p_vt_regra_academica
    3 - p_rec_financeiro

-- -----------------------------------------------------------------------------
*/
--
-- !!* Aqui - É tratada a situação em que a modalidade não deve ser aplicada no período especial
--
procedure p_array_financeiro_modalidade
( p_rec_mc_aluno                in    ca.pk_fat_mc_plt.rec_mc_aluno  
, p_vt_regra_academica          in    ca.pk_fat_mc_plt.ar_mc_regra_academica 
, p_rec_financeiro            in out nocopy ca.pk_fat_mc_plt.rec_financeiro ) is
--
cursor cr_nome_modalidade is
select nm.id_modalidade 
    , nm.id_nome_modalidade               
    , m.id_modalidade_filha 
    , mt.id_modalidade_tipo
    , mt.nm_modalidade_tipo
    , f.id_financeiro
    , f.id_academico
    , m.nm_modalidade
    , m.ds_modalidade
    , nm.vl_modalidade
    , nm.pc_modalidade
    , nm.pc_modalidade               pc_modalidade_original
    , f.nr_matricula    
    , m.cd_externo_padrao
    , m.cd_modalidade_externo  
    , nm.id_pessoa_nfse
    , nm.id_pessoa_irpf
    , nvl( m.id_pessoa_empresa, f.id_pessoa_aluno ) id_pessoa_cobranca
   
    , decode ( mt.id_modalidade_tipo, 01, 01, -- ALUNO REGULAR  
                                      02, 02, -- DESCONTO INCONDICIONAL
                                      06, 03, -- BOLSA                 
                                      03, 05, -- DESCONTO CONDICIONAL  
                                      04, 06, -- CONVÊNIO DE DESCONTO  
                                      08, 07, -- FINANCIAMENTO PRIVADO 
                                      11, 08, -- PARCELAMENTO UNIFOR   
                                      07, 09, -- FINANCIAMENTO PÚBLICO 
                                      05, 10  -- CONVÊNIO DE PAGAMENTO 
             ) nr_ordem_01
    , decode( nm.pc_modalidade, 100, 1, 0) nr_ordem_02
    , decode( m.cd_externo_padrao, 'DESCONTO_DE_VALOR_PRIMEIRA',0, 'DESCONTO_DE_VALOR', 0, m.id_modalidade) nr_ordem_03
    , nm.vl_limite
    , m.tp_objeto_regra
    , m.cd_externo_regra
    , m.fg_periodo_especial
    , a.cd_faixa_regime
    , ti.tp_calculo
    , ti.ds_tp_calculo
    , p_rec_mc_aluno.vl_financeiro -- f.vl_financeiro 
 from ca.v_fat_tipo_indice ti
    , ca.fat_modalidade_tipo mt
    , ca.fat_modalidade m
    , ca.fat_nome_modalidade nm
    , ca.v_fat_tipo_regime tr  
    , ca.fat_academico a
    , ca.fat_nome_parametro np
    , ca.fat_financeiro f
where f.id_financeiro                    =       p_rec_mc_aluno.id_financeiro
  and f.cd_faixa_motivo_inativacao       is      null
  and np.id_nome_parametro               =       f.id_nome_parametro
  and np.fg_ativo                        =       'S'
  and a.id_academico                     =       f.id_academico
  and a.fg_ativo                         =       'S'
  and nm.id_nome_parametro               =       np.id_nome_parametro
  and m.id_modalidade                    =       nm.id_modalidade
  and m.fg_ativo                         =       'S'
  and ( a.dt_mes_ano_inicio_competencia  between nm.dt_inicio_vigencia  and nm.dt_termino_vigencia                
        or
        a.dt_mes_ano_termino_competencia between nm.dt_inicio_vigencia and nm.dt_termino_vigencia
      ) 
  and mt.id_modalidade_tipo              =       m.id_modalidade_tipo 
  and mt.fg_ativo                        =       'S'
  and ti.tp_indice                       =       f.tp_indice
  and ti.fg_ativo                        =       'S'
  and a.cd_dominio_regime                = tr.cd_dominio
  and a.cd_faixa_regime                  = tr.cd_faixa
  and ( tr.tp_periodo <> 'N' 
        or 
        ( tr.tp_periodo = 'N' and m.fg_periodo_especial = 'S'))
order by f.id_financeiro, m.id_modalidade;
 --
cursor cr_objeto_regra( pc_tp_objeto_regra  in ca.objeto.tp_objeto%type
                  , pc_cd_externo_regra in ca.objeto.cd_externo%type)is
select o.nm_objeto  nm_regra
    , o.tp_objeto  tp_objeto_regra
    , o.cd_externo cd_externo_regra 
 from ca.objeto o
where tp_objeto    = pc_tp_objeto_regra 
  and cd_externo   = pc_cd_externo_regra;
--
cursor cr_modalidade_disc_sem_onus( pc_id_modalidade in number )is
select m.cd_modalidade_externo
    , m.cd_externo_padrao
    , m.nm_modalidade 
    , mt.id_modalidade_tipo
    , mt.nm_modalidade_tipo
 from ca.fat_modalidade_tipo mt
    , ca.fat_modalidade m
where m.id_modalidade                  =   pc_id_modalidade
  and m.fg_ativo                       =   'S'       
  and mt.id_modalidade_tipo            =   m.id_modalidade_tipo
  and mt.fg_ativo                      =   'S'  ;       
--
st_nome_modalidade                        cr_nome_modalidade%rowtype;   
l_ind_array                               number(5) := 0;
l_ind_regra_academica                     number(2) := 0;
l_ind_modalidade_regra_gr                 number(2) := 0;  
l_ind_modalidade                          number(5);
--
l_nr_matricula                            ca.aluno.nr_matricula%type;
st_objeto_regra                           cr_objeto_regra%rowtype;
--    
l_id_modalidade_ant                       ca.fat_modalidade.id_modalidade%type;
--
BEGIN
--
-- Incluir todas as modalidades do aluno ao array
open cr_nome_modalidade;
fetch cr_nome_modalidade into st_nome_modalidade;
while cr_nome_modalidade%found loop
--
   p_rec_financeiro.id_financeiro     :=  st_nome_modalidade.id_financeiro;
   p_rec_financeiro.id_academico      :=  st_nome_modalidade.id_academico;
   p_rec_financeiro.nr_matricula      :=  st_nome_modalidade.nr_matricula;
   p_rec_financeiro.pc_fator_limite   :=  0;
   p_rec_financeiro.vl_limite         :=  0; 
   p_rec_financeiro.tp_calculo        :=  st_nome_modalidade.tp_calculo; 
   p_rec_financeiro.ds_tp_calculo     :=  st_nome_modalidade.ds_tp_calculo; 
   p_rec_financeiro.vl_financeiro     :=  st_nome_modalidade.vl_financeiro; 
--dbms_output.put_line ('1 p_rec_financeiro.vl_financeiro: '||p_rec_financeiro.vl_financeiro);

   l_id_modalidade_ant                :=  st_nome_modalidade.id_modalidade ;
   while cr_nome_modalidade%found 
     and l_id_modalidade_ant          =   st_nome_modalidade.id_modalidade loop
--     
        if  st_nome_modalidade.fg_periodo_especial                         =   'S'
        and st_nome_modalidade.cd_faixa_regime                             =   5 then
        -- Periodo especial de férias - Desconsidar a modalidade
           exit;
        end if; 
        l_ind_array                                                      :=  l_ind_array + 1;
        p_rec_financeiro.modalidade(l_ind_array).id_modalidade           :=  st_nome_modalidade.id_modalidade;
        p_rec_financeiro.modalidade(l_ind_array).id_nome_modalidade      :=  st_nome_modalidade.id_nome_modalidade;
        p_rec_financeiro.modalidade(l_ind_array).id_modalidade_filha     :=  st_nome_modalidade.id_modalidade_filha;
        p_rec_financeiro.modalidade(l_ind_array).id_modalidade_tipo      :=  st_nome_modalidade.id_modalidade_tipo;
        p_rec_financeiro.modalidade(l_ind_array).nm_modalidade_tipo      :=  st_nome_modalidade.nm_modalidade_tipo;
        p_rec_financeiro.modalidade(l_ind_array).nm_modalidade           :=  st_nome_modalidade.nm_modalidade;
        p_rec_financeiro.modalidade(l_ind_array).ds_modalidade           :=  st_nome_modalidade.ds_modalidade;
        p_rec_financeiro.modalidade(l_ind_array).vl_modalidade           :=  st_nome_modalidade.vl_modalidade;
        p_rec_financeiro.modalidade(l_ind_array).pc_modalidade           :=  st_nome_modalidade.pc_modalidade;
        p_rec_financeiro.modalidade(l_ind_array).pc_modalidade_original  :=  st_nome_modalidade.pc_modalidade;
        p_rec_financeiro.modalidade(l_ind_array).cd_externo_padrao       :=  st_nome_modalidade.cd_externo_padrao;
        p_rec_financeiro.modalidade(l_ind_array).cd_modalidade_externo   :=  st_nome_modalidade.cd_modalidade_externo;
        p_rec_financeiro.modalidade(l_ind_array).id_pessoa_irpf          :=  st_nome_modalidade.id_pessoa_irpf;
        p_rec_financeiro.modalidade(l_ind_array).id_pessoa_nfse          :=  st_nome_modalidade.id_pessoa_nfse;
        p_rec_financeiro.modalidade(l_ind_array).id_pessoa_cobranca      :=  st_nome_modalidade.id_pessoa_cobranca;
        p_rec_financeiro.modalidade(l_ind_array).nr_ordem_01             :=  st_nome_modalidade.nr_ordem_01;
        p_rec_financeiro.modalidade(l_ind_array).nr_ordem_02             :=  st_nome_modalidade.nr_ordem_02;
        p_rec_financeiro.modalidade(l_ind_array).nr_ordem_03             :=  st_nome_modalidade.nr_ordem_03;                        
        p_rec_financeiro.modalidade(l_ind_array).vl_limite               :=  st_nome_modalidade.vl_limite ; 
        p_rec_financeiro.vl_limite                                       :=  p_rec_financeiro.vl_limite
                                                                             +   st_nome_modalidade.vl_limite;
--        

        dbms_output.put_line ('Aqui > '||st_nome_modalidade.id_modalidade);

        if p_rec_mc_aluno.tp_arquivo                                     =   3 then
        -- Pós-graduação
            p_rec_financeiro.modalidade(l_ind_array).cd_ocorrencia_regra :=  null;  
        else
        -- Graduação 
           if  st_nome_modalidade.tp_objeto_regra                       is  not null
           and st_nome_modalidade.cd_externo_regra                      is  not null then 

               open cr_objeto_regra( st_nome_modalidade.tp_objeto_regra
                                   , st_nome_modalidade.cd_externo_regra) ;  
               fetch cr_objeto_regra into st_objeto_regra;
               if cr_objeto_regra%found then
                  
                  -- Verifica se a regra da modalidade já esta no array de regras acadêmicas( parãmetro da MC )
                  if p_vt_regra_academica.count                         >   0 then
                     for l_ind_regra in  p_vt_regra_academica.first     ..  p_vt_regra_academica.last  loop 
                         if p_vt_regra_academica(l_ind_regra).nm_regra  =   st_objeto_regra.nm_regra then 
                            p_rec_financeiro.modalidade(l_ind_array).cd_ocorrencia_regra
                                                                        :=  p_vt_regra_academica(l_ind_regra).cd_ocorrencia_regra ;
                            
                            -- Popular o array( g_vt_mc_modalidade_regra_gr ) de regras acadêmicas por ID_modalidade/regras
                            l_ind_modalidade_regra_gr                   :=  l_ind_modalidade_regra_gr + 1; 
                                                                                  
                            p_rec_financeiro.modalidade(l_ind_array).regra(l_ind_modalidade_regra_gr).id_modalidade  
                                                                        :=  st_nome_modalidade.id_modalidade;   
                            p_rec_financeiro.modalidade(l_ind_array).regra(l_ind_modalidade_regra_gr).tp_objeto_regra  
                                                                        :=  st_objeto_regra.tp_objeto_regra;
                            p_rec_financeiro.modalidade(l_ind_array).regra(l_ind_modalidade_regra_gr).cd_externo_regra       
                                                                        :=  st_objeto_regra.tp_objeto_regra  ;  
                            p_rec_financeiro.modalidade(l_ind_array).regra(l_ind_modalidade_regra_gr).nm_regra   
                                                                        :=  st_objeto_regra.nm_regra;
                            p_rec_financeiro.modalidade(l_ind_array).regra(l_ind_modalidade_regra_gr).cd_ocorrencia_regra 
                                                                        :=  p_vt_regra_academica(l_ind_regra).cd_ocorrencia_regra;
                            if p_vt_regra_academica(l_ind_regra).disciplinas.count     >  0 then
                               for ind_disc in p_vt_regra_academica(l_ind_regra).disciplinas.first .. p_vt_regra_academica(l_ind_regra).disciplinas.last loop
                                   p_rec_financeiro.modalidade(l_ind_array).regra(l_ind_modalidade_regra_gr).disciplinas(ind_disc).cd_disciplina
                                                                        :=  p_vt_regra_academica(l_ind_regra).disciplinas(ind_disc).cd_disciplina;
                                   p_rec_financeiro.modalidade(l_ind_array).regra(l_ind_modalidade_regra_gr).disciplinas(ind_disc).cd_ocorrencia_regra
                                                                        :=  p_vt_regra_academica(l_ind_regra).disciplinas(ind_disc).cd_ocorrencia_regra;
                               end loop;
                            end if;
                            exit;
                         end if; 
                     end loop;
                  end if;                      
               end if;
               close cr_objeto_regra;   
           else
               p_rec_financeiro.modalidade(l_ind_array).cd_ocorrencia_regra     :=  null; 
           end if;
       end if;  
       
        l_nr_matricula                                                  :=  st_nome_modalidade.nr_matricula;
     
        -- Criar modalidade 145 - Coparticipação do novo FIES    
        if  nvl( st_nome_modalidade.cd_externo_padrao, 'X' )            =   'NOVO_FIES'
        and st_nome_modalidade.pc_modalidade                            <   100 then
            l_ind_array                                                 :=  l_ind_array + 1;

            p_rec_financeiro.modalidade(l_ind_array).id_modalidade       :=  st_nome_modalidade.id_modalidade_filha; --145
            p_rec_financeiro.modalidade(l_ind_array).id_nome_modalidade  :=  null;
            p_rec_financeiro.modalidade(l_ind_array).id_modalidade_filha :=  null;
            p_rec_financeiro.modalidade(l_ind_array).id_modalidade_tipo  :=  7 ;  
            p_rec_financeiro.modalidade(l_ind_array).nm_modalidade_tipo  :=  'FINANCIAMENTO PÚBLICO';
            p_rec_financeiro.modalidade(l_ind_array).nm_modalidade       :=  'COPARTICIPACAO' ;
            p_rec_financeiro.modalidade(l_ind_array).ds_modalidade       :=  'COPARTICIPACAO FINANCIAMENTO PÚBLICO (NOVO) COM NOVAS REGRAS ESTABELECIDAS EM 2018.1 / DECRETO 14.491 DE 19/09/2017';
            p_rec_financeiro.modalidade(l_ind_array).vl_modalidade       :=  st_nome_modalidade.vl_modalidade;
            p_rec_financeiro.modalidade(l_ind_array).pc_modalidade       :=  ( 100
                                                                        -   st_nome_modalidade.pc_modalidade );
            p_rec_financeiro.modalidade(l_ind_array).pc_modalidade_original :=  ( 100
                                                                        -   st_nome_modalidade.pc_modalidade );
            p_rec_financeiro.modalidade(l_ind_array).cd_externo_padrao   :=  'COPARTICIPACAO';
            p_rec_financeiro.modalidade(l_ind_array).cd_modalidade_externo   :=  'COPARTICIPACAO';
            p_rec_financeiro.modalidade(l_ind_array).id_pessoa_irpf      :=  st_nome_modalidade.id_pessoa_irpf;
            p_rec_financeiro.modalidade(l_ind_array).id_pessoa_nfse      :=  st_nome_modalidade.id_pessoa_nfse;
            p_rec_financeiro.modalidade(l_ind_array).id_pessoa_cobranca  :=  st_nome_modalidade.id_pessoa_cobranca;
            p_rec_financeiro.modalidade(l_ind_array).nr_ordem_01         :=  9;
            p_rec_financeiro.modalidade(l_ind_array).nr_ordem_02         :=  0;
            p_rec_financeiro.modalidade(l_ind_array).nr_ordem_03         :=  st_nome_modalidade.id_modalidade_filha;                        
            p_rec_financeiro.modalidade(l_ind_array).vl_limite           :=  st_nome_modalidade.vl_limite ;            
            p_rec_financeiro.modalidade(l_ind_array).cd_ocorrencia_regra :=  null;    
        end if;
        fetch cr_nome_modalidade into st_nome_modalidade;
   end loop;
end loop;
close cr_nome_modalidade;
--
-- !!* Aqui - >>>>> popular o record/array ( p_rec_financeiro.modalidade(l_ind_array)...... com a modalidade
--  modalidade ( fat_financeiro_modalidade ) de diferença de indice , no momento que for identificado 
-- O record/array fara a persistencia na tabela ( fat_fianceiro_modalidade )
--

/*
-- Incluir as modalidades decorrentes de descontos nas disciplinas
-- ( vetor criar na procedure p_processar )
if p_vt_mc_disciplina_modalidade.count        > 0 then
    for l_indice in p_vt_mc_disciplina_modalidade.first  .. p_vt_mc_disciplina_modalidade.last  loop
        l_ind_array                                                  :=  l_ind_array + 1;
        p_rec_financeiro.modalidade(l_ind_array).id_modalidade       :=  p_rec_financeiro.modalidade( l_indice ).id_modalidade;
        p_rec_financeiro.modalidade(l_ind_array).id_nome_modalidade  :=  null;
        p_rec_financeiro.modalidade(l_ind_array).id_modalidade_filha :=  null;
        open cr_modalidade_disc_sem_onus( g_vt_financeiro_modalidade( l_indice ).id_modalidade );
        fetch cr_modalidade_disc_sem_onus into p_rec_financeiro.modalidade(l_ind_array).cd_modalidade_externo 
                                             , p_rec_financeiro.modalidade(l_ind_array).cd_externo_padrao  
                                             , p_rec_financeiro.modalidade(l_ind_array).nm_modalidade 
                                             , p_rec_financeiro.modalidade(l_ind_array).id_modalidade_tipo
                                             , p_rec_financeiro.modalidade(l_ind_array).nm_modalidade_tipo
                                              ;
        close cr_modalidade_disc_sem_onus;
        
        p_rec_financeiro.modalidade(l_ind_array).vl_modalidade       :=  p_vt_mc_disciplina_modalidade( l_indice ).vl_desconto_incondicional;
        p_rec_financeiro.modalidade(l_ind_array).pc_modalidade       :=  0;
        p_rec_financeiro.modalidade(l_ind_array).pc_modalidade_original  :=  0;
        p_rec_financeiro.modalidade(l_ind_array).id_pessoa_irpf      :=  rc0.id_pessoa_irpf;
        p_rec_financeiro.modalidade(l_ind_array).id_pessoa_nfse      :=  rc0.id_pessoa_nfse;
        p_rec_financeiro.modalidade(l_ind_array).id_pessoa_cobranca  :=  rc0.id_pessoa_cobranca;
        p_rec_financeiro.modalidade(l_ind_array).nr_ordem_01         :=  02;
        p_rec_financeiro.modalidade(l_ind_array).nr_ordem_02         :=  0;
        p_rec_financeiro.modalidade(l_ind_array).nr_ordem_03         :=  0;                        
        p_rec_financeiro.modalidade(l_ind_array).vl_limite           :=  0 ;            
        p_rec_financeiro.modalidade(l_ind_array).cd_ocorrencia_regra :=  null;    
    end loop;
end if; */
end p_array_financeiro_modalidade; 
--                           
-- -----------------------------------------------------------------------------
/*
PROCEDURE: p_atualiza_array_modalidade_competencia_fies
DESENVOLVEDOR: Helane, Haroldo e José Leitão 
OBJETIVO: Atualizar a percentuais da modalidade FIES
PARÃMETROS:
*/
-- -----------------------------------------------------------------------------
procedure p_atualiza_array_modalidade_competencia_fies
( p_rec_financeiro   in out nocopy ca.pk_fat_mc_plt.rec_financeiro ) is   
--
begin
-- Atualizar base de cálculo  
----------------------------------------------------------------------------
if p_rec_financeiro.mod_comp.count > 0 
   then
   for ind in p_rec_financeiro.mod_comp.first  .. p_rec_financeiro.mod_comp.last loop
       if p_rec_financeiro.mod_comp(ind).cd_externo_padrao  
                                                 in   ( 'COPARTICIPACAO', 'NOVO_FIES' ) 
          then
          p_rec_financeiro.mod_comp(ind).pc_modalidade 
                                                 :=   p_rec_financeiro.mod_comp(ind).pc_modalidade_original
                                                 *    p_rec_financeiro.pc_fator_limite;
          p_rec_financeiro.pc_fator_limite       :=   p_rec_financeiro.pc_fator_limite;
       end if;   
   end loop;
end if;
--
end p_atualiza_array_modalidade_competencia_fies;
--
-----------------------------------------------------------------------------
/*
PROCEDURE: p_titulo_preservar_cancelar
DESENVOLVEDOR: Haroldo e José Leitão 
OBJETIVO: Tratamento do titulo associados ao financeiro
PARÃMETROS:
ALTERAÇÃO: Helane - implementada a inclusão e alteração da modalidade que trata da alteração da vigência do índice
           ca.fat_modalidade.cd_modalidade_externo = 'NOVA_VIGENCIA_INDICE'

!!* Aqui - Será necessário obter informações do título no EBS
Quais os status do título no EBS ?

*/
-- -----------------------------------------------------------------------------
procedure p_titulo_preservar_cancelar( p_rec_mc_aluno      in out ca.pk_fat_mc_plt.rec_mc_aluno 
                                     , p_rec_financeiro    in out ca.pk_fat_mc_plt.rec_financeiro
                                     , p_dt_processamento  in     date
                                     , p_fg_retorno        out    varchar2
                                     , p_ds_retorno        out    varchar2 ) is

cursor cr_titulo( pc_id_financeiro              in ca.fat_financeiro.id_financeiro%type
                , pc_nr_dia_vencimento_padrao   in varchar2  ) is
select ca.pk_ctr_util.f_titulo_faturado( t.id_titulo )   fg_faturado  -- !!* Aqui - Analisar informação
     , case 
       when t.cd_faixa_st_titulo in ( 2, 3, 4, 5, 6 ) 
          -- 2   Aberto parcialmente                
          -- 3   Baixado                             
          -- 4   Baixado como despesa                
          -- 5   Baixado por provisão                
          -- 6   Baixado sem recebimento 
     -- Aluno cursando e com Shift de competência maior que zero      
     or   ( s_dados_aluno ( t.nr_matric_cliente, 18  )  = 'C' -- !!* Aqui - Aluno com situação academica cursando - Qual tipo de regime?
     and    f_qt_competencia_preservar( to_date( pc_nr_dia_vencimento_padrao || to_char( t.dt_competencia,'/mm/yyyy'), 'dd/mm/yyyy' )  
                                      , p_dt_processamento 
                                      , t.dt_hr_inclusao ) > 0   
          ) then  
          'S'                   
     else
          'N'  
     end       fg_preservar
   , case 
     when t.cd_faixa_st_titulo in ( 2, 3  )   then
          -- 2   Aberto parcialmente                
          -- 3   Baixado                             
          'S'                   
     else
          'N'  
     end       fg_recebido 
   , t.id_titulo
   , t.cd_faixa_st_titulo
   , trunc( t.dt_vencimento )   dt_vencimento
   , t.dt_competencia      
   , t.vl_desconto_incondicional  
   , t.vl_bolsa               
   , t.vl_titulo_liquido   
   , t.vl_desconto_condicional 
   , t.nr_competencia 
   , t.nr_matric_cliente
   , t.vl_titulo
   , t.id_modalidade_cobranca
   , t.id_pessoa_cliente  
   , case 
     when t.cd_faixa_st_titulo in ( 2, 3  )   then
          -- 2   Aberto parcialmente                
          -- 3   Baixado                             
          'PAGO'                   
     else
          'ABERTO'  
     end        ds_st_titulo
   , case
     when s_dados_aluno ( t.nr_matric_cliente, 18  )  = 'C' then
          'S'
     else
          'N'
     end                                      fg_aluno_cursando
   , m.id_modalidade_tipo   
   , t.dt_hr_inclusao
   , t.vl_titulo_mc
   , m.nm_modalidade
   , t.id_valor_indice
   , f.id_nome_parametro
from ca.fat_modalidade  m 
   , ca.fat_financeiro f 
   , ca.ctr_titulo t 
where t.id_financeiro         =   pc_id_financeiro 
 and t.cd_faixa_st_titulo     <>  7 -- cancelada
 and f.id_financeiro          =   t.id_financeiro
 and m.id_modalidade          =   t.id_modalidade_cobranca
order by t.dt_competencia 
   , 2 desc-- preservar
   , dt_vencimento ;
--            
l_ind                                number(3) := 0;  
st_titulo                            cr_titulo%rowtype;
st_nome_modalidade                   ca.fat_nome_modalidade%rowtype;
l_nr_competencia_inc_fatura          ca.ctr_titulo.nr_competencia%type := 1;  
l_dt_competencia_ant                 ca.ctr_titulo.dt_competencia%type;    
l_ds_competencia                     varchar2(1000) := '';   
l_nr_dia_vencimento_padrao           varchar2(2);
wid_modalidade_ajuste_indice         ca.fat_modalidade.id_modalidade%type := null;
wid_nome_modalidade                  ca.fat_nome_modalidade.id_nome_modalidade%type := null;
wdt_inicio_vigencia                  ca.fat_nome_modalidade.dt_inicio_vigencia%type := null;
wdt_termino_vigencia                 ca.fat_nome_modalidade.dt_termino_vigencia%type := null;
--
begin
--
p_rec_financeiro.qt_titulos_preservados         := 0;
p_rec_financeiro.qt_competencia_preservada      := 0;
p_rec_financeiro.vl_financeiro_preservado       := 0; 
p_rec_financeiro.vl_financeiro_recebido         := 0; 
p_rec_financeiro.vl_financeiro_faturado         := 0; 
p_rec_financeiro.nr_ult_competencia_preservada  := 0;
-- 
l_nr_dia_vencimento_padrao   := lpad( p_rec_financeiro.nr_dia_vencimento_padrao, 2, '0');
--dbms_output.put_line( '>> P_TITULO_PRESERVAR_CANCELAR - PRESERVAR/CANCELAR TITULOS - dia:' || l_nr_dia_vencimento_padrao || '<<<'  );
     
open  cr_titulo( p_rec_mc_aluno.id_financeiro 
              , l_nr_dia_vencimento_padrao );
fetch cr_titulo into st_titulo;
while cr_titulo%found loop
  l_dt_competencia_ant                                            := st_titulo.dt_competencia;
  
  if st_titulo.fg_preservar                                       =  'S'             
  or st_titulo.fg_faturado                                        =  'S'
  or st_titulo.fg_recebido                                        =  'S'  then
     p_rec_financeiro.qt_competencia_preservada                   := p_rec_financeiro.qt_competencia_preservada + 1;
     p_rec_financeiro.nr_ult_competencia_preservada               := st_titulo.nr_competencia;             
--     dbms_output.put_line( '>> P_TITULO_PRESERVAR_CANCELAR - competencia ' || st_titulo.nr_competencia ||  ' será preservada' );
--             
-- Verificar se a modalidade de desconto por nova vigência do índice já existe 
-- acho que não seja o melhor local para tratar a modalidade 169
     if wid_modalidade_ajuste_indice is null then
--
        begin
        select a.id_modalidade into wid_modalidade_ajuste_indice
        from   ca.fat_modalidade a
        where  a.cd_modalidade_externo = 'NOVA_VIGENCIA_INDICE'
        and    a.fg_ativo = 'S'; 
        exception 
        when no_data_found then
             p_fg_retorno := 'N';
             p_ds_retorno := 'Modalidada para tratar alteração de vigência de índice não encontrado.';
             raise ex_erro_memoria_calculo;
        end;
--
        begin
        select a.id_nome_modalidade, a.dt_inicio_vigencia, a.dt_termino_vigencia
        into   wid_nome_modalidade, wdt_inicio_vigencia, wdt_termino_vigencia
        from   ca.fat_nome_modalidade a
        where  a.id_nome_parametro = st_titulo.id_nome_parametro
        and    a.id_modalidade = wid_modalidade_ajuste_indice
        and    a.fg_ativo = 'S';
        exception 
        when no_data_found then
             wid_nome_modalidade := null;
        end;
     end if;
--
     if wid_nome_modalidade is null then
--
        select to_date('01/'||trim(to_char(p_dt_processamento,'mm/yyyy')),'dd/mm/yyyy') 
             , trunc(last_day (p_dt_processamento))  
        into   wdt_inicio_vigencia, wdt_termino_vigencia
        from dual;
--
        st_nome_modalidade.id_nome_modalidade          := null;
        st_nome_modalidade.id_nome_parametro           := st_titulo.id_nome_parametro;
        st_nome_modalidade.nr_matricula                := p_rec_mc_aluno.nr_matricula;
        st_nome_modalidade.id_modalidade               := wid_modalidade_ajuste_indice; -- Desconto nova vigência de índice
--
--                st_nome_modalidade.dt_inicio_vigencia          := trunc( p_dt_processamento );
--                st_nome_modalidade.dt_termino_vigencia         := add_months( trunc( p_dt_processamento ), 1) ;
--
        st_nome_modalidade.dt_inicio_vigencia          := wdt_inicio_vigencia;
        st_nome_modalidade.dt_termino_vigencia         := wdt_termino_vigencia;
--
        st_nome_modalidade.id_pessoa_sacado            := null;  
        st_nome_modalidade.id_pessoa_nfse              := null;
        st_nome_modalidade.id_pessoa_irpf              := null;
        st_nome_modalidade.pc_modalidade               := null;
        st_nome_modalidade.vl_modalidade               := 99; -- como deve ser calculado o valor da modalidade ?  
        st_nome_modalidade.nr_ci                       := null; 
        st_nome_modalidade.id_solicitacao_orcamento    := null;
        st_nome_modalidade.nr_ci_fim_vigencia          := null;
        st_nome_modalidade.vl_limite                   := 0;
        st_nome_modalidade.cd_est_alteracao            := null; 
        st_nome_modalidade.nr_mat_alteracao            := null;
        st_nome_modalidade.fg_ativo                    := 'S';
--
-- Possivelmente quando existir a necessidade de conceder desconto para mais de uma parcela 
-- deve-se alterar a data de termino de vigencia e não incluir nova modalidade
--
        dbms_output.put_line ('IdModalidade: '||st_nome_modalidade.id_modalidade||
                              ' inicio: '||st_nome_modalidade.dt_inicio_vigencia||
                              ' término: '||st_nome_modalidade.dt_termino_vigencia||
                              ' competencia: '||st_titulo.dt_competencia);
--
        -- ca.pk_fat_nome_modalidade_dml.p_incluir_modalidade_aluno(st_nome_modalidade);
        -- !!* Aqui - Alterações Ver Aqui !!
--
        wid_nome_modalidade := st_nome_modalidade.id_nome_modalidade;
--
     else
--              
        if trunc(p_dt_processamento) between wdt_inicio_vigencia and wdt_termino_vigencia then
           null; -- não altera a vigência
        else
--
           if trunc(p_dt_processamento) > wdt_termino_vigencia then
--
              wdt_termino_vigencia := last_day(p_dt_processamento);
--
        -- !!* Aqui - Alterações Ver Aqui !! 
/*
              ca.pk_fat_nome_modalidade_dml.p_alterar_vigencia_mod_aluno
                 ( p_id_nome_modalidade => wid_nome_modalidade
                 , p_dt_inicio_vigencia => wdt_inicio_vigencia
                 , p_dt_termino_vigencia => wdt_termino_vigencia );
*/
           end if;
--
        end if;
     end if;
  end if;
                
  while cr_titulo%found
    and l_dt_competencia_ant                                      =  st_titulo.dt_competencia loop 
      if st_titulo.fg_preservar                                   =  'S'             
      or st_titulo.fg_faturado                                    =  'S'  then
      -- Título em baixado ou faturado
         l_ind                                                    := l_ind + 1;

         p_rec_financeiro.nr_competencia_inicio                   := st_titulo.nr_competencia + 1 ;
         
         if st_titulo.fg_faturado                                 =  'S'  then
            p_rec_financeiro.vl_financeiro_faturado               := p_rec_financeiro.vl_financeiro_faturado
                                                                  +  st_titulo.vl_titulo;
            if st_titulo.nr_competencia                           >  nvl( l_nr_competencia_inc_fatura, 0) 
            and st_titulo.dt_vencimento                           >  trunc( p_dt_processamento )  then
                l_nr_competencia_inc_fatura                       := st_titulo.nr_competencia; 
            end if;
         end if;  
          
         if st_titulo.fg_recebido                                 =  'S'  then
            p_rec_financeiro.vl_financeiro_recebido               := p_rec_financeiro.vl_financeiro_recebido
                                                                  +  st_titulo.vl_titulo;
            p_rec_financeiro.titulo(l_ind).ds_titulo_recebido     := 'Sim'; 
         else
            p_rec_financeiro.titulo(l_ind).ds_titulo_recebido     := 'Não'; 
         end if;
         
         if st_titulo.fg_faturado                                 =  'S' then
            p_rec_financeiro.titulo(l_ind).ds_titulo_faturado     := 'Sim'; 
         else
            p_rec_financeiro.titulo(l_ind).ds_titulo_faturado     := 'Não'; 
         end if;              

         if st_titulo.fg_preservar                                = 'S' then
            p_rec_financeiro.vl_financeiro_preservado             := p_rec_financeiro.vl_financeiro_preservado
                                                                  +  st_titulo.vl_titulo;
                                                               
            p_rec_financeiro.qt_titulos_preservados               := p_rec_financeiro.qt_titulos_preservados
                                                                  +  1;
                                                               
            p_rec_financeiro.titulo(l_ind).ds_titulo_preservado  := 'Sim'; 
         else
            p_rec_financeiro.titulo(l_ind).ds_titulo_preservado  := 'Não'; 
         end if;   
                    
         p_rec_financeiro.titulo(l_ind).nr_ind_financ_competencia := st_titulo.nr_competencia;  
         p_rec_financeiro.titulo(l_ind).nr_ind_financ_modalidade  := null;
         p_rec_financeiro.titulo(l_ind).nr_ind_titulo             := l_ind;
         p_rec_financeiro.titulo(l_ind).id_titulo                 := st_titulo.id_titulo;
         p_rec_financeiro.titulo(l_ind).fg_titulo_preservado      := 'S';
--         p_rec_financeiro.titulo(l_ind).fg_titulo_oferta          := null;
         p_rec_financeiro.titulo(l_ind).id_pessoa_cobranca        := st_titulo.id_pessoa_cliente;  
         p_rec_financeiro.titulo(l_ind).nr_competencia            := st_titulo.nr_competencia;                
         p_rec_financeiro.titulo(l_ind).id_modalidade_tipo        := st_titulo.id_modalidade_tipo;  
         p_rec_financeiro.titulo(l_ind).id_modalidade             := st_titulo.id_modalidade_cobranca;   
         p_rec_financeiro.titulo(l_ind).nm_modalidade             := st_titulo.nm_modalidade;   
         p_rec_financeiro.titulo(l_ind).vl_titulo                 := st_titulo.vl_titulo;    
         p_rec_financeiro.titulo(l_ind).vl_desconto_incondicional 
                                                                  := st_titulo.vl_desconto_incondicional;     
         p_rec_financeiro.titulo(l_ind).vl_bolsa                  := st_titulo.vl_bolsa;  
         p_rec_financeiro.titulo(l_ind).vl_desconto_condicional   := st_titulo.vl_desconto_condicional;     
         p_rec_financeiro.titulo(l_ind).vl_titulo_liquido         := st_titulo.vl_titulo_liquido;  
         p_rec_financeiro.titulo(l_ind).id_mc_titulo              := null;
         p_rec_financeiro.titulo(l_ind).dt_vencimento             := st_titulo.dt_vencimento;    
         p_rec_financeiro.titulo(l_ind).dt_competencia            := st_titulo.dt_competencia;  
         p_rec_financeiro.titulo(l_ind).id_academico_titulo       := null; 
         p_rec_financeiro.titulo(l_ind).vl_titulo_mc              := st_titulo.vl_titulo_mc; 

         p_rec_financeiro.titulo(l_ind).dt_geracao_titulo         := st_titulo.dt_hr_inclusao; 

 
         --dbms_output.put_line( 'Tit '||  st_titulo.id_titulo || ' PRESERVADO');

      else
      -- Título não baixado ou não faturado
          -- Cancelar titulos 
         --dbms_output.put_line( 'Tit '||  st_titulo.id_titulo || ' CANCELADO');
         ca.pk_ctr_titulo_clc.p_titulo_cancelar( st_titulo.id_titulo
                                               , null
                                               , null 
                                               , p_fg_retorno
                                               , p_ds_retorno );
         if p_fg_retorno                  =   'N' then
            raise ex_erro_memoria_calculo;
         end if; 
      end if;        
      fetch cr_titulo into st_titulo;
  end loop;
end loop;
close cr_titulo;
--
if l_ind                                  > 0 and 
   p_rec_financeiro.nr_competencia_inicio > 6 then
   p_rec_financeiro.nr_competencia_inicio :=  l_nr_competencia_inc_fatura ;
end if;
--
p_fg_retorno :=  'S';
--
exception
when ex_erro_memoria_calculo  then
     p_fg_retorno :=  'N';
end p_titulo_preservar_cancelar; 
    
--
-- -----------------------------------------------------------------------------
/*
FUNCTION: f_academico_titulo
DESENVOLVEDOR: Helane, Haroldo e José Leitão 
OBJETIVO: Retornar o ID_ACADEMICO_TITULO do academico e competência informada
PARÂMETROS:
   1 - p_id_academico     
   2 - p_nr_competencia
   1 - p_id_academico_titulo     
   2 - p_dt_mes_ano_competencia
*/   
-- -----------------------------------------------------------------------------
procedure p_academico_titulo( p_id_academico             in  ca.fat_academico_titulo.id_academico%type 
                            , p_nr_competencia           in  ca.fat_academico_titulo.nr_ordem_titulo%type  
                            , p_id_academico_titulo      out ca.fat_academico_titulo.id_academico_titulo%type  
                            , p_dt_mes_ano_competencia   out ca.fat_academico_titulo.dt_mes_ano_competencia%type  ) is
--
cursor cr_academico_titulo is
select id_academico_titulo
     , dt_mes_ano_competencia
 from ca.fat_academico_titulo a
where id_academico      =  p_id_academico
  and nr_ordem_titulo   =  p_nr_competencia; 
--
begin
--
open cr_academico_titulo;
fetch cr_academico_titulo into p_id_academico_titulo
                             , p_dt_mes_ano_competencia;
close cr_academico_titulo;
--
/*
--  
dbms_output.put_line ('p_id_academico: <'||p_id_academico||'> '|| 
'p_nr_competencia: <'||p_nr_competencia||'> '||
'p_id_academico_titulo: <'||p_id_academico_titulo||'> '||
'p_dt_mes_ano_competencia: <'||p_dt_mes_ano_competencia||'> ');
*/
--
end p_academico_titulo;
    
  
-- -----------------------------------------------------------------------------
/*
PROCEDURE: p_criticar_mc
DESENVOLVEDOR: Helane, Haroldo e José Leitão 
OBJETIVO: Validar as informações enviadas pelo acadêmico e 
          retornar quais modalidades possuem regras para validação acadêmica
PARÂMETROS: p_rec_mc_aluno 
            p_vt_mc_disciplina 
            p_array_regra
            p_dt_processamento
            p_fg_retorno 
            p_ds_retorno

*/
-- -----------------------------------------------------------------------------
procedure p_mc_criticar 
( p_rec_mc_aluno      in out nocopy ca.pk_fat_mc_plt.rec_mc_aluno
, p_vt_mc_disciplina  in out nocopy pk_fat_mc_plt.ar_mc_disciplina 
, p_array_regra       in out nocopy ca.pk_fat_mc_plt.ar_mc_modalidade_regra 
, p_dt_processamento  in     date 
, p_fg_retorno        out    varchar2  
, p_ds_retorno        out    varchar2 ) is

windex                  number;

cursor cursor_nome_modalidade ( p_id_financeiro  number ) is
   select nm.id_modalidade
        , m.tp_objeto_regra 
        , m.cd_externo_regra
        , g.nm_objeto nm_regra
       from ca.fat_modalidade m
          , ca.fat_nome_modalidade nm 
          , ca.fat_academico a
          , ca.fat_nome_parametro np
          , ca.fat_financeiro f
          , ca.objeto g
      where f.id_financeiro                   =  p_id_financeiro 
        and f.cd_dominio_motivo_inativacao    is null
        and np.id_nome_parametro              = f.id_nome_parametro
        and nm.id_nome_parametro   = np.id_nome_parametro
        and m.id_modalidade        = nm.id_modalidade
        and f.id_academico         = a.id_academico
        and ( 
              ( m.tp_objeto_regra is not null and m.cd_externo_regra is not null )
              and 
              ( m.tp_objeto_regra = g.tp_objeto and m.cd_externo_regra = g.cd_externo )
              and 
              ( p_dt_processamento between nvl(g.dt_validade_inicio,p_dt_processamento) and nvl(g.dt_validade_fim,p_dt_processamento) )
-- !!* Aqui sysdate tratar parâmetro de data
            )
        and ( a.dt_mes_ano_inicio_competencia  between nm.dt_inicio_vigencia  and nm.dt_termino_vigencia                
         or
              a.dt_mes_ano_termino_competencia between nm.dt_inicio_vigencia and nm.dt_termino_vigencia
            ); 
  wcursor_nome_modalidade    cursor_nome_modalidade%rowtype;

begin
p_ds_retorno    := null;

-- Validar informações enviadas
p_validar_dados( p_rec_mc_aluno     
               , p_vt_mc_disciplina 
               , p_fg_retorno        => p_fg_retorno 
               , p_ds_retorno        => p_ds_retorno );
if p_fg_retorno   = 'N' then
   raise ex_finalizar_memoria_calculo;
end if;

-- Complementar informações
p_buscar_informacoes( p_rec_mc_aluno     
                    , p_vt_mc_disciplina 
                    , p_dt_processamento
                    , p_fg_retorno 
                    , p_ds_retorno );
if p_fg_retorno   = 'N' then
   raise ex_finalizar_memoria_calculo;
end if;  

-- Inclusão das modalidades com regras de validação acadêmicas
 windex := 0;
 begin
    open cursor_nome_modalidade( p_id_financeiro  =>  p_rec_mc_aluno.id_financeiro );
    loop
    fetch cursor_nome_modalidade into wcursor_nome_modalidade;
    exit when cursor_nome_modalidade%notfound;
         windex := windex + 1;
         p_array_regra(windex).id_modalidade         := wcursor_nome_modalidade.id_modalidade;
         p_array_regra(windex).tp_objeto_regra       := wcursor_nome_modalidade.tp_objeto_regra;
         p_array_regra(windex).cd_externo_regra      := wcursor_nome_modalidade.cd_externo_regra;
         p_array_regra(windex).nm_regra              := wcursor_nome_modalidade.nm_regra;
         p_array_regra(windex).cd_ocorrencia_regra   := null;

    end loop;
    close cursor_nome_modalidade;
    
exception when others then
    if cursor_nome_modalidade%isopen then
        close cursor_nome_modalidade;
    end if;
    p_ds_retorno  :=  'Não foi possível recuperar as informações relativas as modalidades com regras acadêmicas. ' ||
                       p_rec_mc_aluno.cd_curso || '#' || p_rec_mc_aluno.cd_habilitacao;
    raise ex_finalizar_memoria_calculo;
end;

p_fg_retorno     :=   'S'; 

exception 
when ex_finalizar_memoria_calculo  then
   p_fg_retorno    := 'N';
end p_mc_criticar;
  

-- -----------------------------------------------------------------------------
/*
-- FUNCTION: f_academico_titulo
-- DESENVOLVEDOR: Helane, Haroldo e José Leitão 
-- OBJETIVO: Retornar o ID_ACADEMICO_TITULO do academico e competência informada
--
-- PARÂMETROS:
--   1 - p_id_mc_aluno     
--   2 - p_id_modalidade      
*/
-- -----------------------------------------------------------------------------
function f_financeiro_modalidade
( p_rec_mc_aluno              in  ca.pk_fat_mc_plt.rec_mc_aluno 
, p_id_modalidade             in  ca.fat_modalidade.id_modalidade%type )
return number is   

cursor cr_financeiro_modalidade is
  select fm.id_financeiro_modalidade 
    from ca.fat_nome_modalidade nm
       , ca.fat_financeiro_modalidade fm
       , ca.fat_mc_aluno  mca
   where mca.id_mc_aluno                   =  p_rec_mc_aluno.id_mc_aluno 
     and fm.id_financeiro                  =  mca.id_financeiro
     and nm.id_nome_modalidade             =  fm.id_nome_modalidade 
     and nm.id_modalidade                  =  p_id_modalidade;

l_retorno               ca.fat_financeiro_modalidade.id_financeiro_modalidade%type;              
begin

open cr_financeiro_modalidade;
fetch cr_financeiro_modalidade into  l_retorno;
close cr_financeiro_modalidade;

return( l_retorno );
end f_financeiro_modalidade;

-- -----------------------------------------------------------------------------
/*
FUNCTION: f_check_modalidade_permitida
DESENVOLVEDOR: José Leitão 
OBJETIVO: Retornar 'S' - Modalidades informada homologada 
                   'N' - Modalidades informada NÂO homologada
PARÂMETROS:
   1 - p_id_nome_parametro     
   2 - p_id_modalidade

-- Não implementada 

*/      
-- -----------------------------------------------------------------------------
function f_check_modalidade_permitida
( p_id_nome_parametro         in  ca.fat_nome_modalidade.id_nome_parametro%type 
, p_id_modalidade             in  ca.fat_modalidade.id_modalidade%type  )
  return varchar2 is   
  l_retorno     varchar2(1)  := 'N';
begin
  l_retorno         :=   'S';
  return ( l_retorno );
end f_check_modalidade_permitida;

-- -----------------------------------------------------------------------------
/*
FUNCTION: f_modalidades_homologadas
DESENVOLVEDOR: José Leitão 
OBJETIVO: 
PARÂMETROS:
   1 - p_id_mc_aluno     
   2 - p_id_modalidade

RETORNO:
    'S' - Modalidades homologadas 
    'N' - Modalidades não homologadas    
*/
-- -----------------------------------------------------------------------------
function f_modalidades_homologadas
( p_id_nome_parametro in ca.fat_nome_modalidade.id_nome_parametro%type 
, p_id_academico      in ca.fat_academico.id_academico%type
, p_tp_arquivo        in number )
return varchar2 is   
--
-- !!* Aqui - Analisar implementação
cursor cr_modalidades_homologadas is
select gmh.id_grupo_modalidade_homologada
     , count( nvl( mh.id_modalidade_cobranca, mh.id_modalidade_tipo_desconto))  qt_mod_homologada 
  from ca.fat_modalidade_homologada mh
       , ( select distinct mh.id_grupo_modalidade_homologada
             from ca.v_fat_modalidade_homologacao mh
            where /*s_as_ativo( null, mh.dt_vigencia_inicio, mh.dt_vigencia_fim, null ) = 'S' 
        and*/ mh.tp_aluno = p_tp_arquivo    
              and exists ( select nm.id_modalidade 
                             from ca.v_fat_nome_modalidade nm
                            where nm.id_nome_parametro  =    p_id_nome_parametro  -- 50433
                              and nm.id_academico       =    p_id_academico
                              and nm.id_modalidade      like nvl( to_char( mh.id_modalidade_cobranca), '%')
                              and nm.id_modalidade_tipo like nvl( to_char(mh.id_modalidade_tipo_desconto ), '%' )
                     --and exists ( select 'x'
                     --               from ca.fat_mc_modalidade_homologada mh
                     --              where mh.id_modalidade_cobranca is not null
                     --                and mh.fg_ativo               =  'S' )
                         )                         
         ) gmh        
 where mh.id_grupo_modalidade_homologada      =   gmh.id_grupo_modalidade_homologada 
   and mh.fg_ativo                            =  'S'                             
 group by gmh.id_grupo_modalidade_homologada; 
--
cursor cr_modalidades_aluno is
select count(*) qt_mod_aluno
  from ca.v_fat_nome_modalidade  a
 where a.id_nome_parametro = p_id_nome_parametro
   and a.id_academico       = p_id_academico;
--
l_retorno               varchar2(1) := 'N';         
l_qt_mod_aluno          number(5);     
--
begin
--
for st_modalidades_homologadas in cr_modalidades_homologadas loop
--
    open  cr_modalidades_aluno;
    fetch cr_modalidades_aluno into  l_qt_mod_aluno;
--    dbms_output.put_line( 'f_modalidades_homologadas - Grupo:' || st_modalidades_homologadas.id_grupo_modalidade_homologada  || 
--                          ' Qts Homolog/Aluno:' ||st_modalidades_homologadas.qt_mod_homologada || '#' || l_qt_mod_aluno );
    if cr_modalidades_aluno%found then
       if st_modalidades_homologadas.qt_mod_homologada  =  l_qt_mod_aluno then
          l_retorno := 'S';
          exit;
       else
          l_retorno := 'N';
       end if;
    end if;
    close cr_modalidades_aluno;
--
end loop; 
--
return( l_retorno );
--
end f_modalidades_homologadas;
        
/*
     function f_modalidades_homologadas( p_id_nome_parametro         in  ca.fat_nome_modalidade.id_nome_parametro%type 
                                      , p_id_academico              in  ca.fat_academico.id_academico%type )
      return varchar2 is   

        cursor cr_modalidades_homologadas is
           select gmh.id_grupo_modalidade_homologada
                , count(mh.id_modalidade_cobranca) qt_mod_homologada 
             from ca.fat_mc_modalidade_homologada mh
                , (select distinct gmh.id_grupo_modalidade_homologada
                     from ca.fat_mc_grupo_modalidade_homologada gmh
                        , ca.fat_mc_modalidade_homologada mh
                    where s_as_ativo( null, gmh.dt_vigencia_inicio, gmh.dt_vigencia_fim, null ) = 'S'   
                      and mh.id_grupo_modalidade_homologada     =   gmh.id_grupo_modalidade_homologada
                      and mh.id_modalidade_cobranca             is  not null
                      and mh.fg_ativo                            =  'S'
                      and exists ( select nm.id_modalidade 
                                     from ca.fat_modalidade_tipo mt
                                        , ca.fat_modalidade m
                                        , ca.fat_nome_modalidade nm 
                                        , ca.fat_academico a 
                                    where a.id_academico                     =       p_id_academico
                                      and a.fg_ativo                         =       'S'
                                      and nm.id_nome_parametro               =       p_id_nome_parametro
                                      and nm.id_modalidade                   =       mh.id_modalidade_cobranca
                                      and ( a.dt_mes_ano_inicio_competencia  between nm.dt_inicio_vigencia and nm.dt_termino_vigencia                
                                       or   a.dt_mes_ano_termino_competencia between nm.dt_inicio_vigencia and nm.dt_termino_vigencia
                                          )  
                                       and m.id_modalidade                    =     nm.id_modalidade 
                                      and mt.id_modalidade_tipo              =     m.id_modalidade_tipo 
                                      and mt.fg_ativo                        =     'S'
                                      and mt.fg_cobranca                     =     'S'
                                      and exists ( select 'x'
                                                     from ca.fat_mc_modalidade_homologada mh
                                                    where mh.id_modalidade_cobranca is not null
                                                      and mh.fg_ativo               =  'S' )
                                 )                         
                  ) gmh        
              where mh.id_grupo_modalidade_homologada     =   gmh.id_grupo_modalidade_homologada
                and mh.id_modalidade_cobranca             is  not null
                and mh.fg_ativo                            =  'S'                             
              group by gmh.id_grupo_modalidade_homologada; 
                         
        cursor cr_modalidades_aluno is
          select count(*) qt_mod_aluno
            from ca.fat_modalidade_tipo mt
               , ca.fat_modalidade m
               , ca.fat_nome_modalidade nm 
               , ca.fat_academico a 
           where a.id_academico                     =     p_id_academico
             and a.fg_ativo                         =     'S'
             and nm.id_nome_parametro               =     p_id_nome_parametro
             and ( a.dt_mes_ano_inicio_competencia  between nm.dt_inicio_vigencia and nm.dt_termino_vigencia                
              or   a.dt_mes_ano_termino_competencia between nm.dt_inicio_vigencia and nm.dt_termino_vigencia
                 )  
             and m.id_modalidade                    =     nm.id_modalidade 
             and mt.id_modalidade_tipo              =     m.id_modalidade_tipo 
             and mt.fg_ativo                        =     'S'
             and mt.fg_cobranca                     =     'S';
                                          
       l_retorno               varchar2(1) := 'N';         
       l_qt_mod_aluno          number(5);     
    begin
       for st_modalidades_homologadas in cr_modalidades_homologadas loop
           open  cr_modalidades_aluno;
           fetch cr_modalidades_aluno       into  l_qt_mod_aluno;
           dbms_output.put_line( 'f_modalidades_homologadas - Grupo:' || st_modalidades_homologadas.id_grupo_modalidade_homologada  || 
                                 ' Qts Homolog/Aluno:' ||st_modalidades_homologadas.qt_mod_homologada || '#' || l_qt_mod_aluno );
           if cr_modalidades_aluno%found then
              if st_modalidades_homologadas.qt_mod_homologada  =  l_qt_mod_aluno then
                 l_retorno                                     := 'S';
                 exit;
              else
                 l_retorno                                     := 'N';
              end if;
           end if;
           close cr_modalidades_aluno;
       end loop; 

       
        return( l_retorno );
    end f_modalidades_homologadas;
  
*/
--
-- -----------------------------------------------------------------------------
/*
FUNCTION: p_competencia_shift
DESENVOLVEDOR: 
OBJETIVO: 
PARÂMETROS:
   1 - p_dt_base_referencia     
   2 - p_dt_processamento
   3 - p_qt_competencia

*/
-- -----------------------------------------------------------------------------
procedure p_competencia_shift
( p_dt_base_referencia  in   date
, p_dt_processamento    in   date
, p_qt_competencia      out  number  )  is
-- 
begin
--
p_qt_competencia   := 0;
--
while add_months( p_dt_base_referencia, p_qt_competencia ) <= p_dt_processamento  loop
      p_qt_competencia  := p_qt_competencia + 1;
--      dbms_output.put_line( '   Período shift - Base:' || to_char( add_months( p_dt_base_referencia, p_qt_competencia ) , 'dd/mm/yyyy' )    );
end loop;
--
/*
dbms_output.put_line( '       Datas - Processamento:' || to_char( p_dt_processamento, 'dd/mm/yyyy' )|| ' - ' ||
                ' Base:'|| to_char( p_dt_base_referencia, 'dd/mm/yyyy' )   || 
                ' - Qt competências:' || p_qt_competencia );
*/
--
end p_competencia_shift;



-----------------------------------------------------------------------------
/*
FUNCTION: f_qt_competencia_preservar
DESENVOLVEDOR: 
OBJETIVO: 
PARÂMETROS:
   1 - p_dt_base_referencia     
   2 - p_dt_processamento
   3 - p_dt_inclusao_titulo

RETORNO:
 
*/
-- -----------------------------------------------------------------------------
function f_qt_competencia_preservar
( p_dt_base_referencia in date
, p_dt_processamento   in date
, p_dt_inclusao_titulo in date  )
return number is
--
l_nr_competencia    number(5);
--
begin
--
--dbms_output.put_line( '   -------------------------' );
l_nr_competencia    := 0; 
--
while true loop
--
   if trunc( p_dt_base_referencia ) > trunc( p_dt_inclusao_titulo ) and 
      add_months( trunc( p_dt_base_referencia ), l_nr_competencia ) > trunc( p_dt_processamento ) then 
        --dbms_output.put_line( 'saida1' );
      exit;
   elsif add_months( trunc( p_dt_base_referencia ), l_nr_competencia ) >  trunc( p_dt_processamento ) then
        --dbms_output.put_line( 'saida2' );
      exit;
   end if;
--    
   l_nr_competencia  := l_nr_competencia + 1;
    --dbms_output.put_line( '   Período shift - Base:' || to_char( add_months( p_dt_base_referencia, l_nr_competencia ) , 'dd/mm/yyyy' )    );
--
end loop;
--dbms_output.put_line( '   competencia Preservar - Dt Proc:' || to_char( p_dt_processamento, 'dd/mm/yyyy' )|| ' - ' ||
--                      ' Dt Base:'|| to_char( p_dt_base_referencia, 'dd/mm/yyyy' )   || 
--                      ' Dt incl:'|| to_char( p_dt_inclusao_titulo, 'dd/mm/yyyy' )   || 
--                      ' - Qt competências:' || l_nr_competencia );
--
return ( l_nr_competencia );
--
end f_qt_competencia_preservar;

-----------------------------------------------------------------------------
/*
FUNCTION: f_dia_vencimento_padrao
DESENVOLVEDOR: Helane, Haroldo e José Leitão 
OBJETIVO: Retornar o ID_ACADEMICO_TITULO do academico e competência informada
PARÂMETROS:
   1 - p_id_academico     
   2 - p_nr_ordem_titulo   
   3 - p_dv_matricula  -- !!* Aqui - Seria oportuno alterar o nome do campo para > cd_identificador_vencimento
   4 - p_tipo_retorno
       1 - retorna o dia padrão de vencimento
       2 - retorna a data de vencimento padrão    
*/
-- -----------------------------------------------------------------------------
function f_dia_vencimento_padrao( p_id_academico     in  ca.fat_academico.id_academico%type 
                                , p_nr_ordem_titulo  in  ca.fat_academico_titulo.nr_ordem_titulo%type 
                                , p_dv_matricula     in  ca.fat_vencimento_padrao.cd_identificador%type 
                                , p_tipo_retorno     in  number )
return varchar2 is   
--
cursor cr_dia_vencimento_padrao is
select case 
       when p_tipo_retorno   = 1 then
            to_char( vp.nr_dia_padrao  )    
       when p_tipo_retorno   = 2 then
            to_char( lpad( vp.nr_dia_padrao ,2, '0' )) ||  to_char( atv.dt_vencimento, '/mm/yyyy' )   
       end   
  from ca.fat_vencimento_padrao  vp
     , ca.fat_acad_titulo_vencimento atv
     , ca.fat_academico_titulo fat
 where fat.id_academico         =  p_id_academico
   and fat.nr_ordem_titulo      =  p_nr_ordem_titulo
   and atv.id_academico_titulo  =  fat.id_academico_titulo 
   and vp.id_vencimento_padrao  =  atv.id_vencimento_padrao
   and vp.cd_identificador      =  p_dv_matricula
   and vp.fg_ativo              =  'S';
--
l_retorno               varchar2(10);              
begin

open cr_dia_vencimento_padrao;
fetch cr_dia_vencimento_padrao into  l_retorno;
close cr_dia_vencimento_padrao;

return( l_retorno );
end f_dia_vencimento_padrao; 
--
-- -----------------------------------------------------------------------------
/*
FUNCTION: f_qt_titulo_modalidade
DESENVOLVEDOR: José Leitão 
OBJETIVO: Retornar a quantidade de títulos a serem gerados/preservados 
          para a modalidade
PARÂMETROS:
   1 - p_vt_titulo     
   2 - p_id_modalidade  
*/
-- -----------------------------------------------------------------------------
function f_qt_titulo_modalidade
( p_vt_titulos_aux               in  ca.pk_fat_mc_plt.vt_titulo_aux 
, p_id_modalidade                in  ca.fat_modalidade.id_modalidade%type
, p_nr_competencia               in  ca.ctr_titulo.nr_competencia%type)
return number is   
--
cursor cr_titulo is
select count(*)   qt_titulo
from   table( p_vt_titulos_aux )  t
where id_modalidade   = p_id_modalidade
and nr_competencia    = p_nr_competencia
and vl_titulo         > 0;
--
l_retorno               number(5) := 0;              
--
begin
--
open cr_titulo ;
fetch cr_titulo into  l_retorno;
close cr_titulo;
--
return( nvl( l_retorno, 0 ));
--
end f_qt_titulo_modalidade;  
--
/*                
-- -----------------------------------------------------------------------------
PROCEDURE: p_indice_financeiro
DESENVOLVEDOR: José Leitão 
OBJETIVO: Retorna dados de indice  
PARÂMETROS:
   1 - p_id_academico
   2 - p_tp_indice
   3 - p_dt_referencia
   4 - p_vl_indice
   5 - p_id_valor_indice
   6 - p_id_academico_tabela_preco

-- -----------------------------------------------------------------------------
*/
procedure p_indice_financeiro( p_id_academico               in  number  
                             , p_tp_indice                  in  number 
                             , p_dt_referencia              in  date  
                             , p_vl_indice                  out number
                             , p_id_valor_indice            out number
                             , p_id_academico_tabela_preco  out number ) IS
--
cursor cr_valor( pc_id_academico     in  number   
               , pc_tp_indice        in  number )is
select vi.vl_indice 
     , vi.id_valor_indice 
     , atp.id_academico_tabela_preco 
  from ca.fat_valor_indice            vi
     , ca.fat_tabela_preco            ftp 
     , ca.fat_academico_tabela_preco  atp 
 where atp.id_academico      =        pc_id_academico 
   --and trunc( p_dt_referencia )      between  atp.dt_inicio_vigencia
   --and                                        atp.dt_termino_vigencia
   and ftp.id_tabela_preco    =       atp.id_tabela_preco
   and ftp.cd_faixa_situacao  =       4  -- liberada para utilizacao

   and vi.id_tabela_preco     =       atp.id_tabela_preco 
   and vi.tp_indice           =       pc_tp_indice
   and vi.fg_ativo            =       'S';
--
begin
--
    open cr_valor(  p_id_academico
                 , p_tp_indice ) ;
    fetch cr_valor into p_vl_indice  
                      , p_id_valor_indice      
                      , p_id_academico_tabela_preco ;
    close cr_valor;
--    
end p_indice_financeiro;
    
--
/*    
-- -----------------------------------------------------------------------------
PROCEDURE: p_indice_financeiro
DESENVOLVEDOR: José Leitão 
OBJETIVO: Retorna dados de indice  
PARÂMETROS: p_id_academico
            p_nr_matricula 
            p_dt_referencia
            p_vl_indice
            p_un_financeiro 
            p_vl_financeiro
            p_tp_indice
            p_id_valor_indice
            p_id_academico_tabela_preco

-- -----------------------------------------------------------------------------
*/
procedure p_indice_financeiro
( p_id_academico                in  number
, p_nr_matricula                in  number  
, p_dt_referencia               in  date 
, p_vl_indice                   out number 
, p_un_financeiro               out number  
, p_vl_financeiro               out number  
, p_tp_indice                   out number  
, p_id_valor_indice             out number  
, p_id_academico_tabela_preco   out number  ) is
--   
cursor cr_valor  is
   select fvi.vl_indice  
        , decode(fti.cd_faixa_tipo_calculo, 1, 3, 2, 1, 1)  un_financeiro   
        , case
          when fti.cd_faixa_tipo_calculo in ( 1 , 2 ) then 
               decode( fti.cd_faixa_tipo_calculo, 1, 3, 2, 1, 1) 
          when fti.cd_faixa_tipo_calculo =   3 then  
               ( select sum(pgm.vl_mensalidade) 
                   from pg.mensalidade pgm
                      , pg.classe pgc 
                  where pgm.nr_curso     = pgc.nr_curso 
                    and pgm.nr_turma     = pgc.nr_turma 
                    and pgc.nr_matricula = p_nr_matricula )
          else
               0
          end  *  fvi.vl_indice                vl_financeiro
        , fnp.tp_indice
        , fvi.id_valor_indice 
        , atp.id_academico_tabela_preco  
     from ca.v_fat_status_financeiro vfsf
        , ca.fat_tipo_indice fti    -- !!* Aqui -  
        , ca.fat_valor_indice fvi 
        , ca.fat_tabela_preco ftp 
        , ca.fat_academico_tabela_preco  atp 
        , ca.aluno al
        , ca.fat_nome_parametro fnp 
        , ca.fat_academico  a
    where a.id_academico         =       p_id_academico
      and a.fg_ativo             =       'S'
      and fnp.nr_matricula       =       p_nr_matricula
      and fnp.fg_ativo           =      'S'
      and al.nr_matricula        =       fnp.nr_matricula

      and atp.id_academico       =       a.id_academico

      and trunc( p_dt_referencia )       between atp.dt_inicio_vigencia  
      and                                        atp.dt_termino_vigencia
 
      and ftp.id_tabela_preco    =       atp.id_tabela_preco
      
      and ftp.cd_faixa_situacao  =       4  -- liberada para utilizacao
      and fvi.id_tabela_preco    =       ftp.id_tabela_preco
      and fvi.tp_indice          =       fnp.tp_indice 
      and fvi.fg_ativo           =       'S'
      and fti.tp_indice           =       fvi.tp_indice 
      and vfsf.cd_faixa          =       1;   -- 1 Credito 
--
begin
--
open cr_valor;
fetch cr_valor into p_vl_indice   
                  , p_un_financeiro     
                  , p_vl_financeiro  
                  , p_tp_indice     
                  , p_id_valor_indice    
                  , p_id_academico_tabela_preco  ;
close cr_valor; 
end p_indice_financeiro;  
--
/*
-- -----------------------------------------------------------------------------
-- FUNCTION: f_obter_id_academico
-- DESENVOLVEDOR: José Leitão 
-- OBJETIVO: Retornar o ID_ACADEMICO do periodo 
--
-- PARÂMETROS:
--   1 - p_tp_arquivo 
--         1   Graduação    
--         2   Pós-Graduação   
--   2 - p_tp_periodo  
--         R - Período Regular     
--         I - Internato Medicina  
--         P - Pós graduação       
--         N - Férias              
--         E - EAD                 
--   3 - p_cd_periodo 
--   4 - p_cd_periodo_especial 
-- -----------------------------------------------------------------------------
*/
function f_obter_id_academico ( p_tp_arquivo          in number  
                              , p_tp_periodo          in varchar2 
                              , p_cd_periodo          in number
                              , p_cd_periodo_especial in number  )
return ca.fat_academico.id_academico%type is   
--


cursor cr_academico  is
select a.id_academico 
  from ca.v_fat_tipo_regime tr
     , ca.fat_academico a
 where tr.tp_arquivo       =  p_tp_arquivo
   and tr.tp_periodo       =  p_tp_periodo
   and a.cd_dominio_regime =  tr.cd_dominio
   and a.cd_faixa_regime   =  tr.cd_faixa
   and p_cd_periodo        = case when tr.tp_periodo = 'R' then a.cd_periodo_regular 
                                  else a.cd_periodo_especial end
   and a.fg_ativo          =  'S' ;
--
l_retorno               varchar2(10);              
--
begin
--
-- !!* Aqui - Melhorar a consulta validando outros campos
open cr_academico;
fetch cr_academico into  l_retorno;
close cr_academico;
--
return( l_retorno );
--
end f_obter_id_academico;
    
/* 
-- -----------------------------------------------------------------------------
FUNCTION: f_obter_id_financeiro
DESENVOLVEDOR: José Leitão 
OBJETIVO: Retornar o ID_FINACEIRO do aluno/period
PARÂMETROS:
   1 - p_nr_matricula
   2 - p_tp_arquivo 
         1   Graduação    
         2   Pós-Graduação   
   3 - p_tp_periodo  
         R - Período Regular     
         I - Internato Medicina  
         P - Pós graduação       
         N - Férias              
         E - EAD                 
   4 - p_cd_periodo 
   5 - p_cd_periodo_especial 
-- -----------------------------------------------------------------------------
*/
function f_obter_id_financeiro
( p_nr_matricula        in number
, p_tp_arquivo          in number
, p_tp_periodo          in varchar2 
, p_cd_periodo          in number
, p_cd_periodo_especial in number  )
return ca.fat_financeiro.id_financeiro%type is   
--
cursor cr_financeiro( pc_nr_matricula        in number
                    , pc_id_academico        in number )   is
    select f.id_financeiro 
      from ca.fat_financeiro f 
     where f.nr_matricula                =   pc_nr_matricula
       and f.id_academico                =   pc_id_academico
       and f.cd_faixa_motivo_inativacao  is  null;
       
l_id_academico          ca.fat_academico.id_academico%type;
l_retorno               varchar2(10);              
begin
l_id_academico   := f_obter_id_academico( p_tp_arquivo  
                                        , p_tp_periodo        
                                        , p_cd_periodo       
                                        , p_cd_periodo_especial );
open cr_financeiro( p_nr_matricula 
                 , l_id_academico );
fetch cr_financeiro into  l_retorno;
close cr_financeiro;

return( l_retorno );
end f_obter_id_financeiro;
--
/*
-- -----------------------------------------------------------------------------
FUNCTION: f_obter_id_financeiro
DESENVOLVEDOR: José Leitão 
OBJETIVO: Retornar o ID_FINACEIRO do aluno/period
PARÂMETROS:
   1 - p_nr_matricula
   2 - p_id_academico 
-- -----------------------------------------------------------------------------
*/
function f_obter_id_financeiro
( p_nr_matricula        in number
, p_id_academico        in number  )
return ca.fat_financeiro.id_financeiro%type is   
--
cursor cr_financeiro( pc_nr_matricula        in number
                    , pc_id_academico        in number )   is
    select f.id_financeiro 
      from ca.fat_financeiro f 
     where f.id_academico                =   pc_id_academico
       and f.nr_matricula                =   pc_nr_matricula
       and f.cd_faixa_motivo_inativacao  is  null;
       
l_retorno               varchar2(10);              
begin
 
open cr_financeiro( p_nr_matricula 
                 , p_id_academico );
fetch cr_financeiro into  l_retorno;
close cr_financeiro;

return( l_retorno );
end f_obter_id_financeiro;
--
-- -----------------------------------------------------------------------------
/*
FUNCTION: f_diferenca_segundos
DESENVOLVEDOR: Helane, Haroldo e José Leitão 
OBJETIVO: Retornar a diferenca de 2 data/hora em segundos
PARÂMETROS:
   1 - p_dt_hr_inicio     
   2 - p_dt_hr_fim   
*/
-- -----------------------------------------------------------------------------
function f_diferenca_segundos
( p_dt_hr_inicio     in timestamp 
, p_dt_hr_fim        in timestamp  ) 
return number is   
--
cursor cr_diferenca is
select extract( second from diff ) seconds
 from (select p_dt_hr_fim - p_dt_hr_inicio  diff
         from dual );
--   
l_retorno               number;              
--
begin
--
open cr_diferenca;
fetch cr_diferenca into  l_retorno;
close cr_diferenca;
--    
return( l_retorno );
--
end f_diferenca_segundos;
--
-- -----------------------------------------------------------------------------
/*
PROCEDURE: P_FAT_FINANCEIRO_INCLUIR
DESENVOLVEDOR: Haroldo e José Leitão 
OBJETIVO: Gerar linha na tabela ca.fat_financeiro
PARÂMETROS: 
   1 - p_rec_mc_aluno
   2 - p_fg_retorno       
   3 - p_ds_retorno   
*/
-- -----------------------------------------------------------------------------
PROCEDURE p_fat_financeiro_incluir
( p_rec_mc_aluno   in out nocopy ca.pk_fat_mc_plt.rec_mc_aluno 
, p_fg_retorno        out  varchar2
, p_ds_retorno        out  varchar2  ) is
--                              
cursor cr_academico( pc_id_academico  in number ) is
select ac.id_academico
     , ac.cd_dominio_regime 
     , ac.cd_faixa_regime  
  from ca.fat_academico        ac
     , ca.v_fat_tipo_regime    tr
 where ac.id_academico         = pc_id_academico
   and ac.cd_dominio_regime    = tr.cd_dominio
   and ac.cd_faixa_regime      = tr.cd_faixa
   and ac.fg_ativo             = 'S' ;
--
-- !!* Aqui - Alterar implementação para obter da tabela de parâmetros as 
-- quantidades de unidades financeiras
-- Para o período especial será incluído um financeiro de matricula com valor 0 zero
cursor cr_indice( pc_nr_matricula     number 
                , pc_id_academico     ca.fat_academico.id_academico%type ) is
select fnp.id_nome_parametro  
     , fnp.tp_indice 
     , fnp.id_pessoa_aluno                   id_pessoa_aluno  
     , vfsf.cd_dominio                       cd_dominio_st_financeiro 
     , vfsf.cd_faixa                         cd_faixa_st_financeiro 
     , fvi.vl_indice  
     , decode(fti.cd_faixa_tipo_calculo, 1, 3, 2, 1, 1) un_financeiro 
     , case 
       when ( fti.cd_faixa_tipo_calculo = 1 
              or 
              fti.cd_faixa_tipo_calculo = 2 ) then 
             decode(fti.cd_faixa_tipo_calculo, 1, 3, 2, 1, 1) -- <== !!* Aqui
        when fti.cd_faixa_tipo_calculo = 3 then  
             ( select sum(pgm.vl_mensalidade) 
                 from pg.mensalidade pgm, pg.aluno pgc
                where pgm.nr_curso = pgc.nr_curso 
                  and pgm.nr_turma = pgc.nr_turma 
                  and pgc.nr_matricula = pc_nr_matricula )
        else
             0
        end   *  fvi.vl_indice       vl_financeiro 
  from  ca.v_fat_status_financeiro vfsf  
      , ca.fat_tipo_indice fti -- !!* Aqui - 
      , ca.fat_valor_indice fvi 
      , ca.fat_tabela_preco ftp 
      , ca.fat_academico_tabela_preco  atp
      , ca.fat_nome_parametro fnp 
      , ca.fat_academico  a 
  where a.id_academico      = pc_id_academico
    and a.fg_ativo          = 'S'
    and fnp.nr_matricula    = pc_nr_matricula
    and fnp.fg_ativo        = 'S'
    and atp.id_academico    = a.id_academico
    and ftp.id_tabela_preco = atp.id_tabela_preco
    and fvi.id_tabela_preco = ftp.id_tabela_preco
    and fvi.tp_indice       = fnp.tp_indice 
    and fti.tp_indice       = fvi.tp_indice 
    and vfsf.cd_faixa       = 1;   -- 1 Financeiro de matricula
--    
st_academico            cr_academico%rowtype;
st_indice               cr_indice%rowtype;  
l_rec_fat_financeiro    ca.fat_financeiro%rowtype;
--  
begin
--
open  cr_academico( p_rec_mc_aluno.id_academico );
fetch cr_academico into st_academico; 
if cr_academico%notfound  then
   p_ds_retorno := 'ID Acadêmico não encontado para o aluno/tipo de período. ';
   raise ex_erro_memoria_calculo;
else
 -- Obter dados do indice do acadêmico do aluno
   open cr_indice( p_rec_mc_aluno.nr_matricula
                 , p_rec_mc_aluno.id_academico  );
   fetch cr_indice into st_indice;
   if cr_indice%notfound then
      p_ds_retorno :=  'Dados Financeiro/índice do aluno não foram encontrados ';  
      raise ex_erro_memoria_calculo;
   end if;
   close cr_indice;
--
   l_rec_fat_financeiro.id_financeiro                  :=  null; 
   l_rec_fat_financeiro.id_nome_parametro              :=  st_indice.id_nome_parametro;
   l_rec_fat_financeiro.id_academico                   :=  st_academico.id_academico;
   l_rec_fat_financeiro.nr_matricula                   :=  p_rec_mc_aluno.nr_matricula;
   l_rec_fat_financeiro.tp_indice                      :=  st_indice.tp_indice;
   l_rec_fat_financeiro.id_pessoa_aluno                :=  p_rec_mc_aluno.id_pessoa_aluno;
   l_rec_fat_financeiro.id_pessoa_resp_financeiro      :=  p_rec_mc_aluno.id_pessoa_aluno;
   l_rec_fat_financeiro.cd_dominio_st_financeiro       :=  st_indice.cd_dominio_st_financeiro;
   l_rec_fat_financeiro.cd_faixa_st_financeiro         :=  st_indice.cd_faixa_st_financeiro;
   l_rec_fat_financeiro.cd_dominio_motivo_inativacao   :=  null; 
   l_rec_fat_financeiro.cd_faixa_motivo_inativacao     :=  null;
   l_rec_fat_financeiro.fg_debito_cobranca             :=  'S';
   l_rec_fat_financeiro.un_financeiro                  :=  st_indice.un_financeiro;
   l_rec_fat_financeiro.vl_financeiro                  :=  st_indice.vl_financeiro;
   l_rec_fat_financeiro.cd_est_alteracao               :=  null;
   l_rec_fat_financeiro.nr_mat_alteracao               :=  null; 
   ca.pk_fat_financeiro_dml.inserir_financeiro( l_rec_fat_financeiro 
                                              , p_fg_retorno
                                              , p_ds_retorno); 
--
   if p_fg_retorno   = 'N'  then
      raise ex_erro_memoria_calculo;
   else
      p_rec_mc_aluno.id_academico              := st_academico.id_academico;
      p_rec_mc_aluno.cd_dominio_regime         := st_academico.cd_dominio_regime;
      p_rec_mc_aluno.cd_faixa_regime           := st_academico.cd_faixa_regime;
      p_rec_mc_aluno.id_financeiro             := l_rec_fat_financeiro.id_financeiro; 
      p_rec_mc_aluno.tp_indice                 := st_indice.tp_indice; 
      p_rec_mc_aluno.vl_financeiro             := l_rec_fat_financeiro.vl_financeiro;
   end if;
-- 
end if;
close  cr_academico;  
--
p_fg_retorno      := 'S';
--
exception
  when ex_erro_memoria_calculo then 
       p_fg_retorno := 'N';
end p_fat_financeiro_incluir;
--
-- -----------------------------------------------------------------------------
/*
PROCEDURE: p_montar_vt_titulos_aux
DESENVOLVEDOR:   José Leitão 
OBJETIVO: Montar vetor p_montar_vt_modalidade_competencia_aux  utilizado em selects
          na rotina de calculo ( p_calculo )
PARÂMETROS:
    1 - p_rec_financeiro
    2 - p_fg_titulo_preservado
    3 - p_vt_titulos_aux
*/
-- -----------------------------------------------------------------------------
procedure p_montar_vt_titulos_aux
( p_rec_financeiro       in   ca.pk_fat_mc_plt.rec_financeiro
, p_fg_titulo_preservado in   varchar2
, p_dt_vencimento_titulo_oferta in date default null
, p_vt_titulos_aux       out  ca.pk_fat_mc_plt.vt_titulo_aux  ) is
--
l_ind_preserv              number(5) := 0;
--
begin
--
p_vt_titulos_aux.delete;
dbms_output.put_line('Titulos do financeiro :'||p_rec_financeiro.titulo.count);
if p_rec_financeiro.titulo.count    >   0 then
   for ind in p_rec_financeiro.titulo.first .. p_rec_financeiro.titulo.last loop 
      
       --dbms_output.put_line( 'IND:' || l_ind_preserv || ' MOD:'||p_rec_financeiro.titulo(ind).id_modalidade||
       --       ' Preserv:' || p_rec_financeiro.titulo(ind).fg_titulo_preservado );
       if p_rec_financeiro.titulo(ind).fg_titulo_preservado            =     p_fg_titulo_preservado 
          or 
          p_fg_titulo_preservado                                    =    '%' 
          then 
          l_ind_preserv                                             :=  l_ind_preserv + 1;
          p_vt_titulos_aux(l_ind_preserv).nr_ind_financ_competencia :=  p_rec_financeiro.titulo(ind).nr_ind_financ_competencia;
          p_vt_titulos_aux(l_ind_preserv).nr_ind_financ_modalidade  :=  p_rec_financeiro.titulo(ind).nr_ind_financ_modalidade;
          p_vt_titulos_aux(l_ind_preserv).nr_ind_titulo             :=  p_rec_financeiro.titulo(ind).nr_ind_titulo; 
          p_vt_titulos_aux(l_ind_preserv).id_titulo                 :=  p_rec_financeiro.titulo(ind).id_titulo;
          p_vt_titulos_aux(l_ind_preserv).fg_titulo_preservado      :=  p_rec_financeiro.titulo(ind).fg_titulo_preservado;
--          p_vt_titulos_aux(l_ind_preserv).fg_titulo_oferta          :=  p_rec_financeiro.titulo(ind).fg_titulo_oferta;
          p_vt_titulos_aux(l_ind_preserv).id_pessoa_cobranca        :=  p_rec_financeiro.titulo(ind).id_pessoa_cobranca;
          p_vt_titulos_aux(l_ind_preserv).nr_competencia            :=  p_rec_financeiro.titulo(ind).nr_competencia;
          p_vt_titulos_aux(l_ind_preserv).id_modalidade_tipo        :=  p_rec_financeiro.titulo(ind).id_modalidade_tipo;
          p_vt_titulos_aux(l_ind_preserv).id_modalidade             :=  p_rec_financeiro.titulo(ind).id_modalidade;
          p_vt_titulos_aux(l_ind_preserv).nm_modalidade             :=  p_rec_financeiro.titulo(ind).nm_modalidade;
          p_vt_titulos_aux(l_ind_preserv).vl_titulo                 :=  p_rec_financeiro.titulo(ind).vl_titulo;
          p_vt_titulos_aux(l_ind_preserv).vl_desconto_incondicional :=  p_rec_financeiro.titulo(ind).vl_desconto_incondicional;
          p_vt_titulos_aux(l_ind_preserv).vl_bolsa                  :=  p_rec_financeiro.titulo(ind).vl_bolsa;
          p_vt_titulos_aux(l_ind_preserv).vl_desconto_condicional   :=  p_rec_financeiro.titulo(ind).vl_desconto_condicional;
          p_vt_titulos_aux(l_ind_preserv).vl_titulo_liquido         :=  p_rec_financeiro.titulo(ind).vl_titulo_liquido;
          p_vt_titulos_aux(l_ind_preserv).id_mc_titulo              :=  p_rec_financeiro.titulo(ind).id_mc_titulo;
          p_vt_titulos_aux(l_ind_preserv).dt_vencimento             :=  p_rec_financeiro.titulo(ind).dt_vencimento;
          p_vt_titulos_aux(l_ind_preserv).dt_competencia            :=  p_rec_financeiro.titulo(ind).dt_competencia; 

          p_vt_titulos_aux(l_ind_preserv).id_academico_titulo       :=  p_rec_financeiro.titulo(ind).id_academico_titulo;
          p_vt_titulos_aux(l_ind_preserv).vl_titulo_mc              :=  p_rec_financeiro.titulo(ind).vl_titulo_mc;
          p_vt_titulos_aux(l_ind_preserv).ds_titulo_preservado      :=  p_rec_financeiro.titulo(ind).ds_titulo_preservado;
          p_vt_titulos_aux(l_ind_preserv).ds_titulo_faturado        :=  p_rec_financeiro.titulo(ind).ds_titulo_faturado;
          p_vt_titulos_aux(l_ind_preserv).ds_titulo_recebido        :=  p_rec_financeiro.titulo(ind).ds_titulo_recebido;
          p_vt_titulos_aux(l_ind_preserv).dt_geracao_titulo         :=  p_rec_financeiro.titulo(ind).dt_geracao_titulo; 
          
          if p_dt_vencimento_titulo_oferta is not null then
            p_vt_titulos_aux(l_ind_preserv).dt_vencimento  :=  p_dt_vencimento_titulo_oferta;
          end if;
                    
          --dbms_output.put_line( ' p_montar_vt_titulos_aux  - '||
          --                      ' IND TIT:' ||p_rec_financeiro.titulo(l_ind_preserv).nr_ind_titulo ||
          --                      ' COMP:' || p_vt_titulos_aux(l_ind_preserv).nr_competencia  ||
          --                      ' MOD:' || p_vt_titulos_aux(l_ind_preserv).id_modalidade  ||
          --                      '  Vl tit:' || p_vt_titulos_aux(l_ind_preserv).vl_titulo   
          --                       );
                                
           
       end if;
   end loop;
--   
end if;
--
end p_montar_vt_titulos_aux;
--
-- -----------------------------------------------------------------------------
/*
PROCEDURE: p_montar_vt_titulos_modalidade_aux
DESENVOLVEDOR:   José Leitão 
OBJETIVO: Montar vetor p_montar_vt_modalidade_competencia_aux  utilizado em selects
          na rotina de calculo ( p_calculo )
PARÂMETROS:
    1 - p_rec_financeiro
    2 - p_ano_mes_competencia
*/
-- -----------------------------------------------------------------------------
procedure p_montar_vt_titulos_modalidade_aux
( p_rec_financeiro             in   ca.pk_fat_mc_plt.rec_financeiro
, p_ind_titulo                 in   number
, p_vt_titulos_modalidade_aux  in out nocopy  ca.pk_fat_mc_plt.vt_titulo_modalidade ) is
--
l_ind_tit_mod              number(5) := 0;
--
begin
--
--p_vt_titulos_modalidade_aux.delete;
--dbms_output.put_line( '>>P_IND_TITULO:' || p_ind_titulo );
--
l_ind_tit_mod := p_vt_titulos_modalidade_aux.count;
if p_rec_financeiro.titulo(p_ind_titulo).tit_mod.count    >   0 then
   for ind in p_rec_financeiro.titulo(p_ind_titulo).tit_mod.first .. p_rec_financeiro.titulo(p_ind_titulo).tit_mod.last loop 
--   
       l_ind_tit_mod                                             :=  l_ind_tit_mod + 1;
--  
       p_vt_titulos_modalidade_aux(l_ind_tit_mod).nr_ind_financ_competencia := p_rec_financeiro.titulo(p_ind_titulo).tit_mod(ind).nr_ind_financ_competencia ;    
       p_vt_titulos_modalidade_aux(l_ind_tit_mod).nr_ind_financ_modalidade  := p_rec_financeiro.titulo(p_ind_titulo).tit_mod(ind).nr_ind_financ_modalidade;   
       p_vt_titulos_modalidade_aux(l_ind_tit_mod).nr_ind_titulo             := p_rec_financeiro.titulo(p_ind_titulo).tit_mod(ind).nr_ind_titulo;               
       p_vt_titulos_modalidade_aux(l_ind_tit_mod).id_modalidade             := p_rec_financeiro.titulo(p_ind_titulo).tit_mod(ind).id_modalidade;              
       p_vt_titulos_modalidade_aux(l_ind_tit_mod).id_pessoa_cobranca        := p_rec_financeiro.titulo(p_ind_titulo).tit_mod(ind).id_pessoa_cobranca;          
       p_vt_titulos_modalidade_aux(l_ind_tit_mod).id_modalidade_tipo        := p_rec_financeiro.titulo(p_ind_titulo).tit_mod(ind).id_modalidade_tipo;          
       p_vt_titulos_modalidade_aux(l_ind_tit_mod).nm_modalidade             := p_rec_financeiro.titulo(p_ind_titulo).tit_mod(ind).nm_modalidade;               
       p_vt_titulos_modalidade_aux(l_ind_tit_mod).id_modalidade_origem      := p_rec_financeiro.titulo(p_ind_titulo).tit_mod(ind).id_modalidade_origem;        
       p_vt_titulos_modalidade_aux(l_ind_tit_mod).id_modalidade_tipo_origem := p_rec_financeiro.titulo(p_ind_titulo).tit_mod(ind).id_modalidade_tipo_origem;   
       p_vt_titulos_modalidade_aux(l_ind_tit_mod).pc_modalidade             := p_rec_financeiro.titulo(p_ind_titulo).tit_mod(ind).pc_modalidade;               
       p_vt_titulos_modalidade_aux(l_ind_tit_mod).vl_modalidade             := p_rec_financeiro.titulo(p_ind_titulo).tit_mod(ind).vl_modalidade;               
       p_vt_titulos_modalidade_aux(l_ind_tit_mod).nr_competencia            := p_rec_financeiro.titulo(p_ind_titulo).tit_mod(ind).nr_competencia;              
   end loop;
--   
end if;
--
end p_montar_vt_titulos_modalidade_aux;

-- -----------------------------------------------------------------------------
/*
PROCEDURE: p_montar_vt_modalidade_competencia_aux
DESENVOLVEDOR: José Leitão 
OBJETIVO: Montar vetor p_montar_vt_modalidade_competencia_aux  utilizado em selects
          na rotina de calculo ( p_calculo )
PARÂMETROS:
--    1 - p_rec_financeiro
--    2 - p_vt_modalidade_competencia_aux
*/
-- -----------------------------------------------------------------------------
procedure p_montar_vt_modalidade_competencia_aux
( p_rec_financeiro                  in   ca.pk_fat_mc_plt.rec_financeiro
, p_vt_modalidade_competencia_aux   out  ca.pk_fat_mc_plt.vt_modalidade_competencia ) is
--
begin
--
p_vt_modalidade_competencia_aux.delete;
--
if p_rec_financeiro.modalidade.count    >   0 then
   for ind in p_rec_financeiro.mod_comp.first .. p_rec_financeiro.mod_comp.last loop 
       p_vt_modalidade_competencia_aux(ind).id_nome_modalidade         := p_rec_financeiro.mod_comp(ind).id_nome_modalidade;   
       p_vt_modalidade_competencia_aux(ind).nr_ind_financ_competencia  := p_rec_financeiro.mod_comp(ind).nr_ind_financ_competencia;
       p_vt_modalidade_competencia_aux(ind).nr_ind_financ_modalidade   := p_rec_financeiro.mod_comp(ind).nr_ind_financ_modalidade;
       p_vt_modalidade_competencia_aux(ind).id_modalidade              := p_rec_financeiro.mod_comp(ind).id_modalidade;
       p_vt_modalidade_competencia_aux(ind).nr_competencia             := p_rec_financeiro.mod_comp(ind).nr_competencia;
       p_vt_modalidade_competencia_aux(ind).tp_apropriacao_titulo      := p_rec_financeiro.mod_comp(ind).tp_apropriacao_titulo;
       p_vt_modalidade_competencia_aux(ind).id_modalidade_origem       := p_rec_financeiro.mod_comp(ind).id_modalidade_origem;
       p_vt_modalidade_competencia_aux(ind).pc_modalidade              := p_rec_financeiro.mod_comp(ind).pc_modalidade;
       p_vt_modalidade_competencia_aux(ind).pc_modalidade_original     := p_rec_financeiro.mod_comp(ind).pc_modalidade_original;
       p_vt_modalidade_competencia_aux(ind).vl_modalidade              := p_rec_financeiro.mod_comp(ind).vl_modalidade;  
       p_vt_modalidade_competencia_aux(ind).pc_modalidade              := p_rec_financeiro.mod_comp(ind).pc_modalidade;  
       p_vt_modalidade_competencia_aux(ind).vl_base_calculo            := p_rec_financeiro.mod_comp(ind).vl_base_calculo;
       p_vt_modalidade_competencia_aux(ind).id_financeiro_modalidade   := p_rec_financeiro.mod_comp(ind).id_financeiro_modalidade;
       p_vt_modalidade_competencia_aux(ind).nr_sequencia_calculo       := p_rec_financeiro.mod_comp(ind).nr_sequencia_calculo;
       p_vt_modalidade_competencia_aux(ind).id_modalidade_tipo         := p_rec_financeiro.mod_comp(ind).id_modalidade_tipo;
       p_vt_modalidade_competencia_aux(ind).id_pessoa_cobranca         := p_rec_financeiro.mod_comp(ind).id_pessoa_cobranca;
       p_vt_modalidade_competencia_aux(ind).nm_modalidade              := p_rec_financeiro.mod_comp(ind).nm_modalidade;
       p_vt_modalidade_competencia_aux(ind).nm_modalidade_tipo         := p_rec_financeiro.mod_comp(ind).nm_modalidade_tipo;
       p_vt_modalidade_competencia_aux(ind).vl_vendido                 := p_rec_financeiro.mod_comp(ind).vl_vendido;
       p_vt_modalidade_competencia_aux(ind).st_competencia_modalidade  := p_rec_financeiro.mod_comp(ind).st_competencia_modalidade;
       p_vt_modalidade_competencia_aux(ind).id_modalidade_tipo_origem  := p_rec_financeiro.mod_comp(ind).id_modalidade_tipo_origem;
       p_vt_modalidade_competencia_aux(ind).id_nome_modalidade         := p_rec_financeiro.mod_comp(ind).id_nome_modalidade;
       p_vt_modalidade_competencia_aux(ind).cd_externo_padrao          := p_rec_financeiro.mod_comp(ind).cd_externo_padrao; 
   end loop;
--   
end if;
--
end p_montar_vt_modalidade_competencia_aux;

-- -----------------------------------------------------------------------------
/*
PROCEDURE: p_montar_vt_financeiro_modalidade_aux
DESENVOLVEDOR: José Leitão 
OBJETIVO: Montar vetor vt_financeiro_modalidade_aux utilizado em selects
          na rotina de calculo ( p_calculo )
PARÂMETROS:
    1 - p_rec_financeiro
    2 - p_vt_financeiro_modalidade_aux

*/
-- -----------------------------------------------------------------------------
procedure p_montar_vt_financeiro_modalidade_aux
( p_rec_financeiro               in  ca.pk_fat_mc_plt.rec_financeiro
, p_vt_financeiro_modalidade_aux out ca.pk_fat_mc_plt.vt_fin_modalidade_aux ) is
--
begin
--
p_vt_financeiro_modalidade_aux.delete;
--
if p_rec_financeiro.modalidade.count    >   0 then
   for ind in p_rec_financeiro.modalidade.first .. p_rec_financeiro.modalidade.last loop 
       p_vt_financeiro_modalidade_aux(ind).id_nome_modalidade     := p_rec_financeiro.modalidade(ind).id_nome_modalidade;   
       p_vt_financeiro_modalidade_aux(ind).id_modalidade          := p_rec_financeiro.modalidade(ind).id_modalidade;      
       p_vt_financeiro_modalidade_aux(ind).id_modalidade_filha    := p_rec_financeiro.modalidade(ind).id_modalidade_filha;       
       p_vt_financeiro_modalidade_aux(ind).id_modalidade_tipo     := p_rec_financeiro.modalidade(ind).id_modalidade_tipo;       
       p_vt_financeiro_modalidade_aux(ind).nm_modalidade_tipo     := p_rec_financeiro.modalidade(ind).nm_modalidade_tipo;      
       p_vt_financeiro_modalidade_aux(ind).nm_modalidade          := p_rec_financeiro.modalidade(ind).nm_modalidade;       
       p_vt_financeiro_modalidade_aux(ind).ds_modalidade          := p_rec_financeiro.modalidade(ind).ds_modalidade;     
       p_vt_financeiro_modalidade_aux(ind).vl_modalidade          := p_rec_financeiro.modalidade(ind).vl_modalidade;     
       p_vt_financeiro_modalidade_aux(ind).pc_modalidade          := p_rec_financeiro.modalidade(ind).pc_modalidade;     
       p_vt_financeiro_modalidade_aux(ind).pc_modalidade_original := p_rec_financeiro.modalidade(ind).pc_modalidade_original;      
       p_vt_financeiro_modalidade_aux(ind).cd_externo_padrao      := p_rec_financeiro.modalidade(ind).cd_externo_padrao;      
       p_vt_financeiro_modalidade_aux(ind).cd_modalidade_externo  := p_rec_financeiro.modalidade(ind).cd_modalidade_externo;      
       p_vt_financeiro_modalidade_aux(ind).id_pessoa_nfse         := p_rec_financeiro.modalidade(ind).id_pessoa_nfse;     
       p_vt_financeiro_modalidade_aux(ind).id_pessoa_irpf         := p_rec_financeiro.modalidade(ind).id_pessoa_irpf;       
       p_vt_financeiro_modalidade_aux(ind).id_pessoa_cobranca     := p_rec_financeiro.modalidade(ind).id_pessoa_cobranca;      
       p_vt_financeiro_modalidade_aux(ind).vl_limite              := p_rec_financeiro.modalidade(ind).vl_limite;      
       p_vt_financeiro_modalidade_aux(ind).cd_ocorrencia_regra    := p_rec_financeiro.modalidade(ind).cd_ocorrencia_regra;       
       p_vt_financeiro_modalidade_aux(ind).nr_ordem_01            := p_rec_financeiro.modalidade(ind).nr_ordem_01;        
       p_vt_financeiro_modalidade_aux(ind).nr_ordem_02            := p_rec_financeiro.modalidade(ind).nr_ordem_02;       
       p_vt_financeiro_modalidade_aux(ind).nr_ordem_03            := p_rec_financeiro.modalidade(ind).nr_ordem_03;    
       --dbms_output.put_line( '***** id_modalidade:' ||  p_rec_financeiro.modalidade(ind).id_modalidade );
   end loop;
   
end if;
end p_montar_vt_financeiro_modalidade_aux;
--    
-- -----------------------------------------------------------------------------
/*
PROCEDURE: p_desconto_retroativo_sda
DESENVOLVEDOR:   Haroldo  e José Leitão 
OBJETIVO: Gerar desconto retroativo  no SDA
PARÂMETROS:
    1 - p_tp_aluno
        1 - Graduação
        2 - Pós-graduação 
    2 - p_ano_mes_competencia
    3 - p_pc_desconto
    4 - p_ds_mensagem_sda
        Mensagem do complemento do histórico do aluno
    5 - p_fg_retorno
    6 - p_ds_retorno
*/
--
-- -----------------------------------------------------------------------------
procedure p_desconto_retroativo_sda
( p_tp_aluno             in   number
, p_ano_mes_competencia  in   date
, p_pc_desconto          in   number
, p_ds_mensagem_sda      in   varchar2
, p_fg_retorno           out  varchar2 
, p_ds_retorno           out  varchar2) as
--                  
cursor cr_titulo( pc_ano_mes_competencia in  date 
                , pc_pc_desconto         in  number  ) is
select t.vl_titulo_liquido *  ( pc_pc_desconto / 100 )  vl_desconto
     , t.nr_matric_cliente 
     , t.id_pessoa_cliente
from   ca.ctr_titulo t  
where  t.dt_competencia between 
                        to_date( '01/' || to_char( p_ano_mes_competencia, 'mm/yyyy' ), 'dd/mm/yyyy' )
                        and
                        last_day( p_ano_mes_competencia)
and t.cd_faixa_especie_titulo   =       1
and t.cd_faixa_st_titulo        <>      7;  --  7 - Cancelado; 
--
l_id_movimento_financeiro_sda    ca.sda_movimento_financeiro.id_movimento_financeiro%type;
--
begin 
p_fg_retorno  := 'N';

-- Creditar desconto concedido no SDA
for st_titulo  in cr_titulo( p_ano_mes_competencia 
                          , p_pc_desconto ) loop
   if p_tp_aluno                 =   s_dados_aluno( st_titulo.nr_matric_cliente, 34 ) then 
      -- Alterar Status do aluno para débito automátioco no SDA
      ca.pk_sda_saldo_aluno_clc.p_alterar_fg_debito_autorizado( st_titulo.nr_matric_cliente
                                                              , 'S'  -- p_fg_debito_autorizado = 
                                                              , p_fg_retorno 
                                                              , p_ds_retorno);
      -- Creditar diferença no SDA - Evento contábil 402
      ca.pk_sda_saldo_aluno_clc.p_creditar_no_saldo( st_titulo.id_pessoa_cliente            -- id pessoa
                                                   , st_titulo.nr_matric_cliente            -- matrícula
                                                   , p_ds_mensagem_sda
                                                   , 402                                    -- Código do evento contabil
                                                   , st_titulo.vl_desconto                   -- Valor de crédito
                                                   , p_fg_retorno 
                                                   , p_ds_retorno 
                                                   , l_id_movimento_financeiro_sda );       --movimento financeiro gerado 
   end if;

end loop;
p_fg_retorno  := 'S';
exception
when ex_erro_memoria_calculo then
    p_fg_retorno  := 'N';
when others then
    p_fg_retorno  := 'N';
    p_ds_retorno  := g_nm_pacote || '.P_DESCONTO_RETROATIVO_SDA - Erro: ' || dbms_utility.format_error_backtrace || ' error - '||dbms_utility.format_error_stack;
end p_desconto_retroativo_sda;
--
-- -----------------------------------------------------------------------------
/*
FUNCTION: f_hora_optativa_utilizada
DESENVOLVEDOR:   Haroldo  e José Leitão 
OBJETIVO: Recuperar o identificador do último registro de memorial de cálculo do aluno
          para o período
PARÂMETROS: p_cd_estabelecimento
            p_nr_matricula
            p_cd_periodo
            p_tp_arquivo
            p_tp_periodo

*/
-- -----------------------------------------------------------------------------
function f_hora_optativa_utilizada( p_cd_estabelecimento number
                                  , p_nr_matricula       number
                                  , p_cd_periodo         number
                                  , p_tp_arquivo         number
                                  , p_tp_periodo         varchar2  )
return number is
--
cursor cursor_horas_optativas_utilizadas( p_nr_matricula number
                                        , p_cd_periodo   number ) is
select nvl( fmca1.nr_hora_optativa_utilizada, 0) +
       nvl( fmca1.nr_hora_optativa_sem_onus, 0)  nr_horas_optativas_utilizadas
  from ca.fat_mc_aluno fmca1
 where fmca1.id_mc_aluno = ( select nvl( max( fmca2.id_mc_aluno ), 0 )
                               from ca.fat_mc_aluno fmca2
                              where fmca2.nr_matricula          = p_nr_matricula
                                and fmca2.cd_periodo_regular    < p_cd_periodo );
--
wcursor_horas_optativas_utilizadas  cursor_horas_optativas_utilizadas%ROWTYPE;
--
begin
--
--ADEQUAÇÃO A NOVA ESTRUTURA
begin
open cursor_horas_optativas_utilizadas(p_nr_matricula, p_cd_periodo);
fetch cursor_horas_optativas_utilizadas into wcursor_horas_optativas_utilizadas;
if cursor_horas_optativas_utilizadas%notfound then
    close cursor_horas_optativas_utilizadas;
    return 0;
end if;
close cursor_horas_optativas_utilizadas;
exception 
when others then
    if cursor_horas_optativas_utilizadas%isopen then
        close cursor_horas_optativas_utilizadas;
    end if;
end;
--
return wcursor_horas_optativas_utilizadas.nr_horas_optativas_utilizadas;
--
end f_hora_optativa_utilizada;
--
--
-- -----------------------------------------------------------------------------
/*
FUNCTION: first_day
DESENVOLVEDOR:   Haroldo  e José Leitão 
OBJETIVO: Retorna o primeiro dia do mês passado no parâmetro
PARÂMETROS:

*/
-- -----------------------------------------------------------------------------
function first_day (pdata in date default sysdate) 
return date is
--
begin
-- Retorna o primeiro dia do mês passado no parâmetro
return last_day(add_months(pdata,-1))+1;
--
end first_day;

/*
-----------------------------------------------------------------------------
-- PROCEDURE: p_teste
-- DESENVOLVEDOR:  José Leitão 
-- OBJETIVO: Teste de cálculo da graduação
--
-- PARÂMETROS:

--    1 - p_fg_retorno
--    2 - p_ds_retorno
--    3 - p_nr_matricula  
--    4 - p_tp_aluno
--          1-GR   2-PG
--    5 - p_cd_periodo
--          Período acadêmico regular da graduação 
--    6 - p_cd_periodo_especial
--          Período acadêmico especial da graduação 
--    7 - p_dt_processamento 
--          Data de processamento( simulação ) que MC será gerada
--          Data deve está no intervado (inicio/fim) do período acadêmico
--          ou período especial informado ( param 5 ou 6 )
-- -----------------------------------------------------------------------------
procedure p_teste( p_fg_retorno           out        varchar2
                 , p_ds_retorno           out        varchar2
                 , p_nr_matricula         in  number default 1913153
                 , p_tp_aluno             in  number default 1 
                 , p_cd_periodo           in  number default 201
                 , p_cd_periodo_especial  in  number default null 
                 , p_dt_processamento     in  date   default to_date( '01/07/2020', 'dd/mm/yyyy' )
                 ) is 
   cursor cr_aluno is
    select distinct   f.id_pessoa_aluno
         , f.nr_matricula
         , a.cd_periodo_regular
         , a.cd_periodo_especial
         , f.id_financeiro
      from ca.fat_financeiro f
         , ca.fat_academico a
     where a.id_academico = 5 
      and a.fg_ativo        = 'S'
      and f.id_academico    = a.id_academico
      and f.nr_matricula    =  p_nr_matricula --1913153(L)  1023542(H)
      and f.id_pessoa_aluno is not null
      and f.cd_faixa_motivo_inativacao is null; 
   
   --p_tp_aluno                    number(1)    :=  1;         -- 1 - graduacao  2-pg
   --p_cd_periodo                  number       :=  201; 
   --p_cd_periodo_especial         number       :=  null;   
  
   p_rec_aluno                   ca.pk_fat_mc_plt.rec_mc_aluno;
   
   p_array_disciplina            ca.pk_fat_mc_plt.ar_mc_disciplina;                 
   p_array_titulo                ca.pk_fat_mc_plt.ar_mc_titulo;
   p_array_mensalidade_pg        ca.pk_fat_mc_plt.ar_mensalidade_pg;  
   p_array_regra_modalidade      ca.pk_fat_mc_plt.ar_mc_regra_academica ;   
   
   p_tp_operacao                 varchar2(1) :=   'V' ; -- V-Validar  S-Simular P-Persitir
   p_fg_exibir                   varchar2(1) :=   'S';
 
   st_aluno                      cr_aluno%rowtype; 
begin
   if  p_tp_aluno     =   1 then
   --  Graduação
       open cr_aluno;
       fetch cr_aluno into st_aluno;
       if cr_aluno%found then
          if nvl( ca.pk_pessoa.f_consulta_pessoa( lpad(p_nr_matricula,10,'0'), '1', 1 ), 0 )
                           <>  st_aluno.id_pessoa_aluno then
             raise_application_error( -20000, 'Matricula ' || p_nr_matricula || ' sem id_pessoa ');
          else
               ca.p_mock_memorial_calculo_new( p_nr_matricula      
                                             , p_cd_periodo  
                                             , p_cd_periodo_especial   
                                             , p_rec_aluno      
                                             , p_array_disciplina  );
                                         
               p_rec_aluno.cd_periodo           := st_aluno.cd_periodo_regular;    
               p_rec_aluno.cd_periodo_regular   := st_aluno.cd_periodo_regular;
               p_rec_aluno.cd_periodo_especial  := st_aluno.cd_periodo_especial;
              
               p_array_regra_modalidade(1).nm_regra                                :=  'Desconto_ingressante_20%';    
               p_array_regra_modalidade(1).cd_ocorrencia_regra                     :=  2;
                               
               p_array_regra_modalidade(1).disciplinas(1).cd_disciplina            :=  'N420';    
               p_array_regra_modalidade(1).disciplinas(1).cd_ocorrencia_regra      :=  3;    
               p_array_regra_modalidade(1).disciplinas(2).cd_disciplina            :=  'N424';    
               p_array_regra_modalidade(1).disciplinas(2).cd_ocorrencia_regra      :=  4;    
              
          
               p_tp_operacao                    := 'V';  -- verificação  
               
               
               if p_rec_aluno.nr_matricula   is null  then 
                  p_ds_retorno := ' Matricula null apos mock ';
                  raise ex_erro_memoria_calculo;
               end if;

                             
          
               dbms_output.put_line( ' '     ); 
               dbms_output.put_line( '--- MC DE VALIDAÇÃO ------'     );
               dbms_output.put_line( ' '     ); 
               ca.pk_fat_mc_clc.p_memoria_calculo_gr( p_tp_operacao        
                                                       , p_fg_exibir  
                                                       , p_rec_aluno       
                                                       , p_array_disciplina  
                                                       , p_array_regra_modalidade
                                                       , p_array_titulo             
                                                       , p_fg_retorno         
                                                       , p_ds_retorno  
                                                       , p_dt_processamento      
                                                       ) ;
                
               if p_fg_retorno = 'N' then 
                  raise ex_erro_memoria_calculo;
               end if;  
          
               p_tp_operacao             := 'P'; -- Persitir

               dbms_output.put_line( ' '     ); 
               dbms_output.put_line( '--- MC DE PERSISTENCIA ------'     );
               dbms_output.put_line( ' '     ); 
               ca.pk_fat_mc_clc.p_memoria_calculo_gr( p_tp_operacao        
                                                 , p_fg_exibir  
                                                 , p_rec_aluno       
                                                 , p_array_disciplina  
                                                 , p_array_regra_modalidade
                                                 , p_array_titulo             
                                                 , p_fg_retorno         
                                                 , p_ds_retorno       
                                                 , p_dt_processamento 
                                                 ) ;  
               dbms_output.put_line( 'Retorno:' || p_fg_retorno|| '-' || p_ds_retorno );
               
               
           end if;
       end if;
       close cr_aluno;
       
   end if;
   
exception   
   when ex_erro_memoria_calculo then
        p_fg_retorno   := 'N';
        dbms_output.put_line( 'ERRO V - Retorno:' || p_fg_retorno || '-' || p_ds_retorno);
                   
end p_teste;  */

-- ===========================================================================================================
-- PLSQL utilizados em rotina extra memória de cálculo
-- ===========================================================================================================

-- -----------------------------------------------------------------------------
/*
FUNCTION: f_vl_indice_financeiro
DESENVOLVEDOR: José Leitão 
OBJETIVO: Retorna dados de indice ou falor financeiro
PARÂMETROS:
   1 - p_tipo_retorno  
       1- valor do indice
       2- unidade financeiro
       3- Valor do financeiro
       4- Tipo de índice
       5 - id_valor_indice
       6 - id_academico_tabela_preco
       7 - Valor Hora da habilitação
   2 - p_id_academico   
   3 - p_nr_matricula
*/
-- -----------------------------------------------------------------------------
function f_indice_financeiro
( p_tipo_retorno         in  number 
, p_id_academico         in  number
, p_nr_matricula         in  number   )
return number is   
--
cursor cr_valor  is
select case
      when p_tipo_retorno   =   1  then
      -- valor do indice
           fvi.vl_indice  
      when p_tipo_retorno   =   2  then
      -- unidade financeiro
           decode(fti.cd_faixa_tipo_calculo, 1, 3, 2, 1, 1)   
      when p_tipo_retorno   =   3  then
      -- Valor do financeiro
           case
           when fti.cd_faixa_tipo_calculo in ( 1 , 2 ) then 
                decode( fti.cd_faixa_tipo_calculo, 1, 3, 2, 1, 1) 
           when fti.cd_faixa_tipo_calculo =   3 then  
                ( select sum(pgm.vl_mensalidade) 
                    from pg.mensalidade pgm
                       , pg.classe pgc 
                   where pgm.nr_curso     = pgc.nr_curso 
                     and pgm.nr_turma     = pgc.nr_turma 
                     and pgc.nr_matricula = p_nr_matricula )
           else
                 0
           end   *  fvi.vl_indice     
      when p_tipo_retorno   =   4  then
      -- Tipo de índice
         h.tp_indice 
      when p_tipo_retorno  =    5 then
           fvi.id_valor_indice 
      when p_tipo_retorno  =    6 then
           atp.id_academico_tabela_preco 
      when p_tipo_retorno   =   7  then
      -- Valor do hora habilitação
           fvi.vl_hora
      end   
 from ca.v_fat_status_financeiro vfsf  
    , ca.fat_tipo_indice fti -- !!* Aqui - 
    , ca.fat_valor_indice fvi 
    , ca.fat_tabela_preco ftp 
    , ca.fat_academico_tabela_preco  atp 
    , ca.habilitacao h
    , ca.aluno al
    , ca.fat_nome_parametro fnp 
    , ca.fat_academico  a
where a.id_academico         =       p_id_academico
  and a.fg_ativo             =       'S'
  and fnp.nr_matricula       =       p_nr_matricula
  and fnp.fg_ativo           =      'S'
  and al.nr_matricula        =       fnp.nr_matricula 
  and h.cd_habilitacao       =       al.cd_habilitacao

  and atp.id_academico       =       a.id_academico
  -- !!* Aqui -  ( retirar comentario abaixo )
  --and trunc( sysdate )       between atp.dt_inicio_competencia  
  --and                                atp.dt_termino_competencia
  
  and ftp.id_tabela_preco    =       atp.id_tabela_preco
  -- !!* Aqui - ( retirar comentario abaixo )
  --and trunc(sysdate)         between ftp.dt_inicio_vigencia_preco 
  --and                                ftp.dt_termino_vigencia_preco     
  and ftp.cd_faixa_situacao  =       4  -- liberada para utilizacao
  
  and fvi.id_tabela_preco    =       ftp.id_tabela_preco
  and fvi.tp_indice          =       fnp.tp_indice 
  and fvi.fg_ativo           =       'S'
  and fti.tp_indice          =       fvi.tp_indice  
  and vfsf.cd_faixa          =       1;   -- 1   Matrícula
--
l_retorno               varchar2(10);              
--
begin
--
open cr_valor;
fetch cr_valor into  l_retorno;
close cr_valor;
--
return( l_retorno );
--
end f_indice_financeiro;
--    
-- -----------------------------------------------------------------------------
/*
FUNCTION: f_indice_financeiro
DESENVOLVEDOR: José Leitão 
OBJETIVO: Retorna dados de indice ou falor financeiro
PARÂMETROS:
   1 - p_tipo_retorno  
       1- valor do indice
       2- unidade financeiro
       3- Valor do financeiro 
       5 - id_valor_indice
       6 - id_academico_tabela_preco
   2 - p_id_academico   
   3 - p_nr_matricula

!!!!! Verificar se afunção está duplicada ou se assinatura é diferente

*/
-- -----------------------------------------------------------------------------
function f_indice_financeiro
( p_id_academico         in  number
, p_nr_matricula         in  number
, p_tp_retorno           in  varchar2   )
return number is   
--
cursor cr_valor  is
select case
when p_tp_retorno   =   1  then
-- valor do indice
   fvi.vl_indice  
when p_tp_retorno   =   2  then
-- unidade financeiro
   decode(fti.cd_faixa_tipo_calculo, 1, 3, 2, 1, 1)   
when p_tp_retorno   =   3  then
-- Valor do financeiro
   case
   when fti.cd_faixa_tipo_calculo in ( 1 , 2 ) then 
        decode( fti.cd_faixa_tipo_calculo, 1, 3, 2, 1, 1) 
   when fti.cd_faixa_tipo_calculo =   3 then  
        ( select sum(pgm.vl_mensalidade) 
            from pg.mensalidade pgm
               , pg.classe pgc 
           where pgm.nr_curso     = pgc.nr_curso 
             and pgm.nr_turma     = pgc.nr_turma 
             and pgc.nr_matricula = p_nr_matricula )
   else
         0
   end   *  fvi.vl_indice 
when p_tp_retorno  =    5 then
   fvi.id_valor_indice 
when p_tp_retorno  =    6 then
   atp.id_academico_tabela_preco 
end   
from ca.v_fat_status_financeiro vfsf  
, ca.fat_tipo_indice fti -- !!* Aqui - 
, ca.fat_valor_indice fvi 
, ca.fat_tabela_preco ftp 
, ca.fat_academico_tabela_preco  atp 
, ca.fat_nome_parametro fnp 
, ca.fat_academico  a
where a.id_academico         =       p_id_academico
and a.fg_ativo             =       'S'
and fnp.nr_matricula       =       p_nr_matricula
and fnp.fg_ativo           =       'S' 

and atp.id_academico       =       a.id_academico
-- !!* Aqui -  ( retirar comentario abaixo )
--and trunc( sysdate )       between atp.dt_inicio_competencia  
--and                                atp.dt_termino_competencia

and ftp.id_tabela_preco    =       atp.id_tabela_preco
-- !!* Aqui -  ( retirar comentario abaixo )
--and trunc(sysdate)         between ftp.dt_inicio_vigencia_preco 
--and                                ftp.dt_termino_vigencia_preco     
and ftp.cd_faixa_situacao  =       4  -- liberada para utilizacao

and fvi.id_tabela_preco    =       ftp.id_tabela_preco
and fvi.tp_indice          =       fnp.tp_indice 
and fvi.fg_ativo           =       'S'
and fti.tp_indice          =       fvi.tp_indice  
and vfsf.cd_faixa          =       1;   -- 1 Credito
--
l_retorno               varchar2(10);              
--
begin
--
open cr_valor;
fetch cr_valor into  l_retorno;
close cr_valor;
--
return( l_retorno );
--
end f_indice_financeiro;
--
-- -----------------------------------------------------------------------------
/*
FUNCTION: f_vl_indice_financeiro
DESENVOLVEDOR: José Leitão 
OBJETIVO: Retorna dados de indice ou falor financeiro
PARÂMETROS:
   1 - p_tipo_retorno  
          1 - valor do indice 
          2 - id_valor_indice
          3 - id_academico_tabela_preco
   2 - p_id_academico
  
*/
-- -----------------------------------------------------------------------------
function f_indice_financeiro1
( p_tipo_retorno         in  number 
, p_id_academico         in  number  
, p_tp_indice            in  number )
return number is   
--
cursor cr_valor( pc_tipo_retorno     in  number 
               , pc_id_academico     in  number   
               , pc_tp_indice        in  number )is
select 
case
  when pc_tipo_retorno  =    1 then
       vi.vl_indice 
  when pc_tipo_retorno  =    2 then
       vi.id_valor_indice 
  when pc_tipo_retorno  =    3 then
       atp.id_academico_tabela_preco 
  end 
from ca.fat_valor_indice            vi
   , ca.fat_academico_tabela_preco  atp 
where atp.id_academico      =        pc_id_academico 
-- !!* Aqui -  ( retirar comentario abaixo )
--  and trunc( sysdate )      between  atp.dt_inicio_competencia 
--  and                                atp.dt_termino_competencia
and vi.id_tabela_preco     =       atp.id_tabela_preco 
and vi.tp_indice           =       pc_tp_indice
and vi.fg_ativo            =       'S'  ;
--
l_retorno               varchar2(10);              
--
begin
--
open cr_valor( p_tipo_retorno
             , p_id_academico
             , p_tp_indice ) ;
fetch cr_valor into  l_retorno;
close cr_valor;
--
return( l_retorno );
--
end f_indice_financeiro1;
--
-- -----------------------------------------------------------------------------
/*
PROCEDURE: p_autorizacao_matricula
DESENVOLVEDOR: Helane, José Leitão 
OBJETIVO: Executa procedimentos que verifica se existe autorização financeiras para a matrícula
PARÂMETROS:

*/
-- -----------------------------------------------------------------------------
procedure p_autorizacao_matricula
( p_array_aluno      in out nocopy ca.pk_fat_mc_plt.ar_mc_aluno 
, p_array_disciplina in out nocopy ca.pk_fat_mc_plt.ar_mc_disciplina 
, p_array_modalidade in out nocopy ca.pk_fat_mc_plt.ar_mc_disciplina_modalidade
, p_dt_processamento in date
, p_fg_retorno       out    varchar2
, p_ds_retorno       out    varchar2 
) is 
--
wnr_matricula           pg.nome.nr_matricula%type;
wun_financeiro          number;
wvl_financeiro          number;
wun_financeiro_desc     number;
wvl_financeiro_desc     number;
wst_autorizacao         varchar2(1) := null;
wds_retorno             varchar2(4000) := null;
wnr_unidade_liberada    number := 999.9999; 
vl_index_a         number;
vl_index_d         number;
vl_index_m         number; 
--
-- Consulta para validação das autorizações de matrícula para as modalidades
-- do tipo de modalidade  id_modalidade_tipo = 7 Financiamento Público
-- c6_financeiro do pacote ca.fi_memorial_calculo_clc
cursor cursor_financeiro_aluno (p_id_financeiro number) is 
select a1.nr_matricula 
    , a1.id_financeiro
    , a1.id_modalidade
    , a1.un_financeiro
    , a1.vl_financeiro
    , a1.tp_indice
    , a1.st_academica
    , a1.dt_base
    , a1.cd_dominio_autoriz_matricula
    , a1.cd_faixa_autoriz_matricula
    , case
      when a1.cd_faixa_autoriz_matricula is not null then
         ( select b.ds_opcao_autorizacao||' - '||
                  decode( a1.ds_msg_autoriz_matricula, null, 
                          'Sem autorização para efetuar a matricula.',
                          a1.ds_msg_autoriz_matricula) 
             from ca.v_fat_autorizacao_matricula b
            where b.cd_dominio_opcao_autorizacao = a1.cd_dominio_autoriz_matricula
              and b.cd_faixa_opcao_autorizacao = a1.cd_faixa_autoriz_matricula )
      ELSE
          to_char(null)
      END ds_msg_autorizacao_matricula
    , a1.cd_dominio_autoriz_alt_matric
    , a1.cd_faixa_autoriz_alt_matric
    , case
      when a1.cd_faixa_autoriz_alt_matric is not null then
         ( select b.ds_opcao_autorizacao||' - '||
                  decode( a1.ds_msg_autoriz_alt_matric, null, 
                          'Sem autorização para efetuar alteração na matricula.',
                          a1.ds_msg_autoriz_alt_matric) 
             from ca.v_fat_autorizacao_matricula b
            where b.cd_dominio_opcao_autorizacao = a1.cd_dominio_autoriz_alt_matric
              and b.cd_faixa_opcao_autorizacao = a1.cd_faixa_autoriz_alt_matric )
      else
          to_char(null)
      end ds_msg_autoriz_alt_matric
    , a1.cd_faixa_valor_limite
    , a1.cd_dominio_valor_limite
    , case
      when a1.cd_faixa_valor_limite is not null then
         ( select b.ds_opcao_autorizacao||' - '||
                  decode( a1.ds_msg_valor_limite, null, 
                          'Sem o registro do límite de valor do semestre.',
                          a1.ds_msg_valor_limite) 
             from ca.v_fat_autorizacao_matricula b
            where b.cd_dominio_opcao_autorizacao = a1.cd_dominio_valor_limite
              and b.cd_faixa_opcao_autorizacao = a1.cd_faixa_valor_limite )
      else
        to_char(null)
      end ds_msg_valor_limite
    , a1.tp_ocorrencia
    --
    -- A data base será utilizada para controlar a validação de modalidades que 
    -- utilizam cd_faixa_autoriz_matricula e cd_faixa_autoriz_alte_matric
    -- As modalidades que utilizam cd_faixa_valor_limite não tem controle de data base
    -- e será necessário que o aluno tenha uma ocorrência ativa com data de ocorrência 
    -- menor ou igual a data de término da vigência da modalidade
   , case
     when a1.cd_faixa_autoriz_matricula is not null then
        case 
        when a1.st_academica not in ('C','T') then 
            case 
            when a1.dt_base is not null then
                 case 
                 when trunc(sysdate) > a1.dt_base then       -- !!* Aqui sysdate tratar parâmstro de data
                      'S' -- validar, atingiu a data base
                 else
                      'N' -- não será validada, ainda não atingiu a data base
                 end 
            else
                 'S' -- sem data base informada, sempre fará a validação
            end
        else
            'N' -- Aluno já está matriculado
        end
     else 
        'N'      
     end st_validacao_matric
   , case
     when a1.cd_dominio_autoriz_alt_matric is not null then
          case 
          when a1.st_academica in ('C','T') then 
               case
               when a1.dt_base is not null then
                    case 
                    when trunc(sysdate) > a1.dt_base then   -- !!* Aqui sysdate tratar parâmetro de data
                         'S' -- validar, atingiu a data base
                    else
                         'N' -- não será validada, ainda não atingiu a data base
                    end 
               else
                   'S' -- sem data base informada, sempre fará a validação
                end
          else
              'N' -- Aluno já está matriculado
          end
     else 
         'N'      
     end st_validacao_alt_matric
    --
   , case
       when a1.cd_faixa_valor_limite is not null
        and a1.tp_ocorrencia is not null 
        and a1.st_ocorrencia_valor_limite = '3' then
            'S'
     else
       'N'      
     end st_validacao_valor_limite
  --
from ( select a.nr_matricula
            , f.id_financeiro
            , f.vl_financeiro
            , f.un_financeiro
            , f.tp_indice
            , nvl(a.st_academica,'A') st_academica 
            , d.cd_dominio_autoriz_matricula 
            , d.cd_faixa_autoriz_matricula 
            , d.ds_msg_autoriz_matricula 
            , d.cd_dominio_autoriz_alt_matric 
            , d.cd_faixa_autoriz_alt_matric 
            , d.ds_msg_autoriz_alt_matric 
            , d.cd_dominio_valor_limite 
            , d.cd_faixa_valor_limite 
            , d.ds_msg_valor_limite 
            , d.tp_ocorrencia 
            , e.dt_base 
            ,( case
               when d.tp_ocorrencia is null then
                    to_char('1')   -- Sem validação do tipo de ocorrência
               else
                    nvl(( select to_char('3')   -- Ocorrência com registro válido
                            from ca.ocorrencia e
                           where e.cd_estabelecimento = 0
                             and e.nr_matricula = a.nr_matricula
                             and e.tp_ocorrencia = d.tp_ocorrencia
                             and e.st_ocorrencia = 1
                             and e.dt_ocorrencia <= g.dt_mes_ano_termino_competencia
                             and rownum <= 1
                         ),to_char('2')  -- Ocorrência ativa não encontrada
                      )
              end) st_ocorrencia_valor_limite
          , d.id_modalidade
       from ca.aluno                      a
          , ca.fat_nome_parametro         b
          , ca.fat_nome_modalidade        c
          , ca.fat_modalidade             d
          , ca.fat_academico_modalidade   e
          , ca.fat_financeiro             f
          , ca.fat_academico              g
      where f.id_financeiro               =  p_id_financeiro
        and a.nr_matricula                =  f.nr_matricula
        and a.nr_matricula                =  b.nr_matricula
        and b.fg_ativo                    =  'S'
        and b.id_nome_parametro           =  c.id_nome_parametro
-- !!* Aqui sysdate - tratar parâmetro de data
        and trunc(sysdate)                between c.dt_inicio_vigencia and c.dt_termino_vigencia
        and c.id_modalidade               =  d.id_modalidade
        and d.id_modalidade_tipo          =  7
        and(d.cd_faixa_autoriz_matricula  is not null
         or d.cd_faixa_autoriz_alt_matric is not null 
         or d.cd_faixa_valor_limite       is not null )
        and e.id_academico(+)             =  f.id_academico
        and e.id_modalidade(+)            =  c.id_modalidade
        and e.fg_ativo(+)                 =  'S'
        and g.id_academico                =  f.id_academico
        ) a1;
wcursor_financeiro_aluno  cursor_financeiro_aluno%rowtype;
--
--
-- Registro de autorização de matricula
--
cursor autorizacao_matricula ( p_id_financeiro  in number
                         , p_id_modalidade  in number
                         , p_nr_matricula   in number
                         , p_tp_indice      in number
                         , p_cd_dominio_opcao_autorizacao in number 
                         , p_cd_faixa_opcao_autorizacao in number )  is
select a.dt_autorizacao, a.cd_faixa_opcao_autorizacao
     , b.ds_opcao_autorizacao
     , a.un_autorizacao
     , a.vl_autorizacao
     --, a.tp_indice
     , case
       when ( a.id_financeiro  <> p_id_financeiro ) then
            'Financeiro da autorização é diferente do financeiro atual.'
       --when ( a.tp_indice <> p_tp_indice ) then
       --     'Tipo de índice da autorização é diferente do financeiro atual.'
       else
            to_char(null)
       end ds_ocorrencia_cadastro
/*
     , case
       when ( a.id_modalidade <> p_id_modalidade ) then
            'Modalidade da autorização é diferente do financeiro atual.'
       --when ( a.tp_indice <> p_tp_indice ) then
       --     'Tipo de índice da autorização é diferente do financeiro atual.'
       else
            to_char(null)
       end ds_ocorrencia_cadastro
*/
from   ca.fat_autorizacao_matricula a
     , ca.v_fat_autorizacao_matricula b
where  a.id_financeiro = p_id_financeiro
and    a.nr_matricula = p_nr_matricula
and    a.cd_dominio_opcao_autorizacao = p_cd_dominio_opcao_autorizacao
and    a.cd_faixa_opcao_autorizacao = p_cd_faixa_opcao_autorizacao
and    a.cd_dominio_opcao_autorizacao = b.cd_dominio_opcao_autorizacao
and    a.cd_faixa_opcao_autorizacao = b.cd_faixa_opcao_autorizacao
and    a.fg_ativo  = 'A'
order by a.dt_autorizacao desc;
--
wautorizacao_matricula    autorizacao_matricula%rowtype;
--
/* Será necessário registrar no memorial que para a matrícula foi validado o limite de valor */
--
begin
--
vl_index_a := 1;
wds_retorno := null; 
--
p_array_aluno(vl_index_a).ds_mensagem_01 := null; 

open cursor_financeiro_aluno ( p_array_aluno(vl_index_a).id_financeiro );
fetch cursor_financeiro_aluno into wcursor_financeiro_aluno;
if cursor_financeiro_aluno%notfound then
   close cursor_financeiro_aluno;
   p_ds_retorno := 'p_autorizacao_matricula: Sem cadastro financeiro para o período '||
                    p_array_aluno(vl_index_a).cd_periodo||'.' ;
   raise ex_erro_memoria_calculo;
end if;
close cursor_financeiro_aluno;
--
-- Identificar o tipo de autorização a ser verificada
--
if  wcursor_financeiro_aluno.st_validacao_matric       = 'N'
and wcursor_financeiro_aluno.st_validacao_alt_matric   = 'N'  
and wcursor_financeiro_aluno.st_validacao_valor_limite = 'N'  then
   goto saida;
end if;
-- 
-- Obter a quantidade de unidades financeiras e o valor das parcelas calculadas 
-- com base nas disciplinas que o aluno escolheu
--
wun_financeiro := 0;
wvl_financeiro := 0;
wun_financeiro_desc := 0;
wvl_financeiro_desc := 0;
vl_index_d := p_array_disciplina.first();
while ( vl_index_d is not null ) loop
--
  wun_financeiro := wun_financeiro + p_array_disciplina(vl_index_d).nr_unidade_financeira;
  wvl_financeiro := wvl_financeiro + p_array_disciplina(vl_index_d).vl_disciplina;
  vl_index_d := p_array_disciplina.next(vl_index_d);
--
  vl_index_m := p_array_modalidade.first();
  while ( vl_index_m is not null ) loop 
    if p_array_disciplina(vl_index_d).cd_disciplina = p_array_modalidade(vl_index_m).cd_disciplina then
       wun_financeiro_desc := wun_financeiro_desc - p_array_modalidade(vl_index_m).un_desconto_incondicional;
       wvl_financeiro_desc := wvl_financeiro_desc - p_array_modalidade(vl_index_m).vl_desconto_incondicional;
    end if;
    vl_index_m := p_array_modalidade.next(vl_index_m);
 
  end loop; 
end loop;

-- Validação das autorizações para matricula 
if wcursor_financeiro_aluno.st_validacao_matric = 'S' then 
   open autorizacao_matricula ( wcursor_financeiro_aluno.id_financeiro
                              , wcursor_financeiro_aluno.id_modalidade
                              , wcursor_financeiro_aluno.nr_matricula
                              , wcursor_financeiro_aluno.tp_indice
                              , wcursor_financeiro_aluno.cd_dominio_autoriz_matricula 
                              , wcursor_financeiro_aluno.cd_faixa_autoriz_matricula );
   fetch autorizacao_matricula into wautorizacao_matricula;
   if autorizacao_matricula%notfound then
      wds_retorno := wcursor_financeiro_aluno.ds_msg_autorizacao_matricula||
                     ' Quantidade de unidades financeiras das disciplinas selecionadas: '||
                     trim(to_char(wun_financeiro,'990D9999MI','NLS_NUMERIC_CHARACTERS = '',.'' '))||'. '||
                     'Valor do semestre: '||
                     trim(to_char(wvl_financeiro,'L999G999G990D99MI','NLS_NUMERIC_CHARACTERS = '',.'' NLS_CURRENCY = ''R$'' '));
   else
      if wautorizacao_matricula.ds_ocorrencia_cadastro is not null then
         wds_retorno := wautorizacao_matricula.ds_ocorrencia_cadastro;
      else
         if wcursor_financeiro_aluno.dt_base is null then -- não valida data da autorização
            null;
         elsif wcursor_financeiro_aluno.dt_base is not null then -- valida a data da autorização
-- !!* Aqui sysdate - tratar parâmetro de data
            if trunc(sysdate) > trunc(wautorizacao_matricula.dt_autorizacao) then
                wds_retorno := wcursor_financeiro_aluno.ds_msg_autorizacao_matricula||
                               ' Data da autorização ( '||to_char(wautorizacao_matricula.dt_autorizacao,'dd/mm/yyyy')||' ) expirada. '||
                               'Quantidade de unidades financeiras das disciplinas selecionadas: '||
                               trim(to_char(wun_financeiro,'990D9999MI','NLS_NUMERIC_CHARACTERS = '',.'' '));
            end if;
         end if;
      end if;
   end if;
   close autorizacao_matricula;
end if;
if wds_retorno is not null then
   goto saida;
end if; 

-- Validação das autorizações para alterar a matricula 
if wcursor_financeiro_aluno.st_validacao_alt_matric = 'S' then 
   if wcursor_financeiro_aluno.un_financeiro = wun_financeiro then
      goto saida;
   end if; 
   open autorizacao_matricula ( wcursor_financeiro_aluno.id_financeiro
                              , wcursor_financeiro_aluno.id_modalidade
                              , wcursor_financeiro_aluno.nr_matricula
                              , wcursor_financeiro_aluno.tp_indice
                              , wcursor_financeiro_aluno.cd_dominio_autoriz_alt_matric
                              , wcursor_financeiro_aluno.cd_faixa_autoriz_alt_matric );
   fetch autorizacao_matricula into wautorizacao_matricula;
   if autorizacao_matricula%notfound then
      wds_retorno := wcursor_financeiro_aluno.ds_msg_autoriz_alt_matric||
                     ' Quantidade de unidades financeiras das disciplinas selecionadas: '||
                     trim(to_char(wun_financeiro,'990D9999MI','NLS_NUMERIC_CHARACTERS = '',.'' '))||'. '||
                     'Valor do semestre: '||
                     trim(to_char(wvl_financeiro,'L999G999G990D99MI','NLS_NUMERIC_CHARACTERS = '',.'' NLS_CURRENCY = ''R$'' '));
   else
      if wautorizacao_matricula.ds_ocorrencia_cadastro is not null then
         wds_retorno := wautorizacao_matricula.ds_ocorrencia_cadastro;
      else
         if wcursor_financeiro_aluno.dt_base is null then -- não valida data da autorização
            if wun_financeiro <> wautorizacao_matricula.un_autorizacao then
               wds_retorno := wcursor_financeiro_aluno.ds_msg_autoriz_alt_matric||
                      ' Quantidade de unidades financeiras autorizadas ('||
                      trim(to_char(wautorizacao_matricula.un_autorizacao,'990D9999MI','NLS_NUMERIC_CHARACTERS = '',.'' '))||
                      ') diverge da quantidade correspondente as disciplinas selecionadas ('||
                      trim(to_char(wun_financeiro,'990D9999MI','NLS_NUMERIC_CHARACTERS = '',.'' '))||'). ';
            end if;
         elsif wcursor_financeiro_aluno.dt_base is not null then -- valida a data da autorização
-- !!* Aqui sysdate - tratat parametro de data
            if trunc(sysdate) > trunc(wcursor_financeiro_aluno.dt_base) then
                wds_retorno := wcursor_financeiro_aluno.ds_msg_autoriz_alt_matric||
                               ' Data da autorização ( '||to_char(wautorizacao_matricula.dt_autorizacao,'dd/mm/yyyy')||' ) expirada. '||
                               'Quantidade de unidades financeiras das disciplinas selecionadas: '||
                               trim(to_char(wun_financeiro,'990D9999MI','NLS_NUMERIC_CHARACTERS = '',.'' '))||'. '||
                               'Valor do semestre: '||
                               trim(to_char(wvl_financeiro,'L999G999G990D99MI','NLS_NUMERIC_CHARACTERS = '',.'' NLS_CURRENCY = ''R$'' '));
            else
               if wun_financeiro <> wautorizacao_matricula.un_autorizacao then
                  wds_retorno := wcursor_financeiro_aluno.ds_msg_autoriz_alt_matric||
                      ' Quantidade de unidades financeiras autorizadas ('||
                      trim(to_char(wautorizacao_matricula.un_autorizacao,'990D9999MI','NLS_NUMERIC_CHARACTERS = '',.'' '))||
                      ') diverge da quantidade correspondente as disciplinas selecionadas ('||
                      trim(to_char(wun_financeiro,'990D9999MI','NLS_NUMERIC_CHARACTERS = '',.'' '))||'). ';
               end if;
            end if;
         end if;
      end if;
   end if;
   close autorizacao_matricula;
end if;
if wds_retorno is not null then
   goto saida;
end if; 

-- Validação do limite de valor 
if wcursor_financeiro_aluno.st_validacao_valor_limite = 'S' then 
   open autorizacao_matricula ( wcursor_financeiro_aluno.id_financeiro
                              , wcursor_financeiro_aluno.id_modalidade
                              , wcursor_financeiro_aluno.nr_matricula
                              , wcursor_financeiro_aluno.tp_indice
                              , wcursor_financeiro_aluno.cd_dominio_valor_limite 
                              , wcursor_financeiro_aluno.cd_faixa_valor_limite );
   fetch autorizacao_matricula into wautorizacao_matricula;
   if autorizacao_matricula%notfound then
      wds_retorno := wcursor_financeiro_aluno.ds_msg_valor_limite||
                     ' - Quantidade de unidades financeiras das disciplinas selecionadas: '||
                     trim(to_char(wun_financeiro,'990D9999MI','NLS_NUMERIC_CHARACTERS = '',.'' '))||'. '||
                     'Valor do semestre: '||
                     trim(to_char(wvl_financeiro,'L999G999G990D99MI','NLS_NUMERIC_CHARACTERS = '',.'' NLS_CURRENCY = ''R$'' '));
   else
      if wautorizacao_matricula.ds_ocorrencia_cadastro is not null then
         wds_retorno := wautorizacao_matricula.ds_ocorrencia_cadastro;
      else
         if wcursor_financeiro_aluno.dt_base is null then -- não valida data da autorização
            if wvl_financeiro_desc > wautorizacao_matricula.vl_autorizacao then
               wds_retorno := wcursor_financeiro_aluno.ds_msg_valor_limite||
                            ' - Valor límite do semestre autorizados ('||
                   trim(to_char(wautorizacao_matricula.vl_autorizacao,'L999G999G990D99MI','NLS_NUMERIC_CHARACTERS = '',.'' NLS_CURRENCY = ''R$'' '))||
                   ') diverge do valor correspondente as disciplinas selecionadas ('||
                   trim(to_char(wvl_financeiro_desc,'L999G999G990D99MI','NLS_NUMERIC_CHARACTERS = '',.'' NLS_CURRENCY = ''R$'' '))||'). ';
            end if;
         elsif wcursor_financeiro_aluno.dt_base is not null then -- valida a data da autorização
-- !!* Aqui sysdate - tratar parametro de data
            if trunc(sysdate) > trunc(wautorizacao_matricula.dt_autorizacao) then
                wds_retorno := wcursor_financeiro_aluno.ds_msg_valor_limite||
                               ' - Data da autorização ( '||to_char(wautorizacao_matricula.dt_autorizacao,'dd/mm/yyyy')||' ) expirada. '||
                               'Quantidade de unidades financeiras das disciplinas selecionadas: '||
                               trim(to_char(wun_financeiro_desc,'990D9999MI','NLS_NUMERIC_CHARACTERS = '',.'' '))||'. '||
                               'Valor do semestre: '||
                               trim(to_char(wvl_financeiro_desc,'L999G999G990D99MI','NLS_NUMERIC_CHARACTERS = '',.'' NLS_CURRENCY = ''R$'' '));
            else
               if wvl_financeiro_desc > wautorizacao_matricula.vl_autorizacao then
                  wds_retorno := wcursor_financeiro_aluno.ds_msg_valor_limite||
                               ' - Valor límite do semestre autorizados ('||
                      trim(to_char(wautorizacao_matricula.vl_autorizacao,'L999G999G990D99MI','NLS_NUMERIC_CHARACTERS = '',.'' NLS_CURRENCY = ''R$'' '))||
                      ') diverge do valor correspondente as disciplinas selecionadas ('||
                      trim(to_char(wvl_financeiro_desc,'L999G999G990D99MI','NLS_NUMERIC_CHARACTERS = '',.'' NLS_CURRENCY = ''R$'' '))||'). ';
               end if;
            end if;
         end if;
      end if;
   end if;
   close autorizacao_matricula;
end if;
--
if wds_retorno is not null then
   goto saida;
end if;
--
<<SAIDA>>
if wds_retorno is not null then
   p_ds_retorno := 'p_autorizacao_matricula: '||wds_retorno;
   raise ex_erro_memoria_calculo; 
end if;
--
p_fg_retorno := 'S';    
--
exception 
  when ex_erro_memoria_calculo then
       p_fg_retorno := 'N';        
end p_autorizacao_matricula;
-- 
-- -----------------------------------------------------------------------------
/*
PROCEDURE: p_desmatricular
DESENVOLVEDOR: Helane, Haroldo, Lucas e José Leitão 
OBJETIVO:  
PARÂMETROS: 
   1 - p_tp_operacao
       1 - Desmatricular por desistência
       2 - Desmatricular por aproveitamento de disciplina
       3 - Desmatricular por mudança de matriz curricular
       4 - Desmatricular matrícula instituional
   1 - p_nr_matricula
   2 - p_tp_periodo
       R - Período Regular   
       I - Internato Medicina
       P - Pós graduação     
       N - Férias            
       E - EAD                    
   3 - p_cd_periodo_regular
   4 - p_cd_periodo_especial
   5 - p_cd_est_operador
   6 - p_nr_mat_operador
   7 - p_fg_retorno
   8 - p_ds_retorno
*/
-- -----------------------------------------------------------------------------
procedure p_desmatricular
( p_tp_operacao                 in  number
, p_nr_matricula                in  ca.aluno.nr_matricula%type
, p_tp_periodo                  in  varchar2
, p_cd_periodo_regular          in  ca.periodo.cd_periodo%type
, p_cd_periodo_especial         in  ca.periodo_especial.cd_periodo%type
, p_cd_est_operador             in  ca.usuario.cd_estabelecimento%type
, p_nr_mat_operador             in  ca.usuario.nr_matricula%type  
, p_id_movimento_financeiro_sda out ca.sda_movimento_financeiro.id_movimento_financeiro%type                                    
, p_fg_retorno                  out varchar2
, p_ds_retorno                  out varchar2 ) is
--
cursor cr_aluno( pc_nr_matricula    in  ca.aluno.nr_matricula%type
               , pc_id_pessoa_aluno in  ca.fat_nome_parametro.id_pessoa_aluno%type  ) is
select st_academica
   , ( select id_nome_parametro  
         from ca.fat_nome_parametro np
        where np.nr_matricula    = pc_nr_matricula
          and np.id_pessoa_aluno = pc_id_pessoa_aluno
          and np.fg_ativo        = 'S' )   id_nome_parametro
from  ca.aluno a
where a.nr_matricula  = pc_nr_matricula;
--
cursor cr_titulo ( pc_id_financeiro    in   ca.fat_financeiro.id_financeiro%type ) is
select pk_ctr_util.f_titulo_faturado( t.id_titulo )   fg_faturado      
   , case
     when t.cd_faixa_st_titulo in ( 2, 3  )   then
          -- 2   Aberto parcialmente                
          -- 3   Baixado
          'S'                   
     else
          'N'  
     end       fg_recebido
   , t.id_titulo 
   , t.vl_titulo
from ca.ctr_titulo t 
where t.id_financeiro             =   pc_id_financeiro 
 and t.cd_faixa_st_titulo        <>  7 -- cancelada
--  and t.id_modalidade_cobranca  =   1    -- Aluno Graduação  
order by t.nr_competencia;
--
st_aluno                  cr_aluno%rowtype;
l_id_financeiro           ca.fat_financeiro.id_financeiro%type;
l_id_academico            ca.fat_financeiro.id_academico%type;
l_id_pessoa_aluno         ca.cp_pessoa.id_pessoa%type;
l_rec_mc_aluno            ca.pk_fat_mc_plt.rec_mc_aluno;
l_ds_mensagem             ca.fat_mc_aluno.ds_mensagem_01%type;
l_vl_financeiro           ca.fat_financeiro.vl_financeiro%type;
l_vl_indice               ca.fat_valor_indice.vl_indice%type;
l_un_financeiro           ca.fat_financeiro.un_financeiro%type;
l_tp_indice               ca.fat_financeiro.tp_indice%type;
l_vl_credito_sda          ca.fat_financeiro.vl_financeiro%type;
l_id_titulo_movimento     ca.ctr_titulo_movimento.id_titulo_movimento%type; 
l_tp_arquivo              number(1) := 1;
--
l_dummmy1                 number;
l_dummmy2                 number;
l_dummmy3                 number;
l_dummmy4                 number;
l_dummmy5                 number;
--
p_modalidade_aluno        ca.fat_nome_modalidade%rowtype;  --Inserido por Luiz
--
begin
--
p_fg_retorno   := 'N';
--
l_id_pessoa_aluno   := ca.pk_pessoa.f_consulta_pessoa( lpad( p_nr_matricula, 10, '0'), 1, 1); 
--
l_id_financeiro     := f_obter_id_financeiro( p_nr_matricula   
                                           , l_tp_arquivo    
                                           , p_tp_periodo      
                                           , p_cd_periodo_regular   
                                           , p_cd_periodo_especial   );
l_id_academico      := f_obter_id_academico( l_tp_arquivo    
                                           , p_tp_periodo      
                                           , p_cd_periodo_regular   
                                           , p_cd_periodo_especial   );
--
-- Consulta aluno
open cr_aluno( p_nr_matricula
            , l_id_pessoa_aluno );
fetch cr_aluno into st_aluno ;
if cr_aluno%notfound then
   p_ds_retorno  := 'Aluno informado não encontrado.';
   raise ex_erro_memoria_calculo;
else
   if p_tp_operacao       =  1  then
  -- 1 - Desmatricular por desistência
      if nvl( st_aluno.st_academica, 'A' )  <> 'T' then
         p_ds_retorno  := 'Situação acadêmica( '|| st_aluno.st_academica ||  
                         ' ) do Aluno não permite dematricular por matrícula institucional.';
         raise ex_erro_memoria_calculo;
      end if;
   elsif p_tp_operacao    =  4  then
  -- 4 - Desmatricular matrícula instituional
      if nvl( st_aluno.st_academica, 'A' )  <> 'T' then
         p_ds_retorno  := 'Situação acadêmica( '|| st_aluno.st_academica ||  
                         ' ) do Aluno não permite dematricular por matrícula institucional.';
         raise ex_erro_memoria_calculo;
      end if;
   end if;
end if;
close cr_aluno;
--
if p_tp_operacao                      =   1 then
-- 1 - Desmatricular por desistência
   l_ds_mensagem := 'Desistência de matrícula';

  -- Desabilitar CA.FAT_NOME_PARAMETRO
   ca.pk_fat_nome_parametro_dml.atualizar_desistencia( p_nr_matricula   
                                                    , l_id_pessoa_aluno       
                                                    , p_fg_retorno    
                                                    , p_ds_retorno );
   if p_fg_retorno     =   'N' then
      raise ex_erro_memoria_calculo;
   end if;
  
  -- Desativar as modalidades ativas do aluno ( CA.FAT_NOME_MODALIDADE )       
  --                              p_encerrar_vigencia_mod_aluno(p_modalidade_aluno  in out nocopy ca.fat_nome_modalidade%rowtype) as
  
  -- Alterado por Luiz 
  -- criado parametro p_modalidade_aluno          
  -- ca.pk_fat_nome_modalidade_dml.p_encerrar_vigencia_mod_aluno( st_aluno.id_nome_parametro );          
   ca.pk_fat_nome_modalidade_dml.p_encerrar_vigencia_mod_aluno( p_modalidade_aluno);

  -- Inativar Financeiro
   ca.pk_fat_financeiro_dml.inativar_financeiro( l_id_financeiro     
                                           , s_pl_dominio_codigo( 'FAT_013' )        -- p_cd_dominio_motivo_inativacao 
                                           , 1                              -- p_cd_faixa_motivo_inativacao  ( 1-desistencia )
                                           , 'Desmatrícula por desistência' -- p_ds_motivo_inativacao 
                                           , p_cd_est_operador  
                                           , p_nr_mat_operador  
                                           , p_fg_retorno      
                                           , p_ds_retorno  );               
   if p_fg_retorno     =   'N' then
      raise ex_erro_memoria_calculo;
   end if;
--
elsif p_tp_operacao                   =   2  then
-- 2 - Desmatricular por aproveitamento de disciplina
   l_ds_mensagem     := 'Aproveitamento de disciplina';
elsif p_tp_operacao                   in  (  3, 4) then
-- 3 - Desmatricular por mudança de matriz curricular
-- 4 - Desmatricular matrícula instituional
   if p_tp_operacao     =  3  then
      l_ds_mensagem     := 'Mudança de matriz curricular';
   elsif p_tp_operacao  =  4  then
      l_ds_mensagem     := 'Matrícula institucional';    
   end if;
--
-- Inicializar valores financeiro CA.FAT_FINANCEIRO
-- ------------------------------------------------
   p_indice_financeiro( l_id_academico     
                     , p_nr_matricula
                     , sysdate  -- data base de processamento para claculo do indice -- !!* Aqui sysdate - tratat parametro de data
                     , l_dummmy1                  
                     , l_un_financeiro             
                     , l_vl_financeiro            
                     , l_tp_indice              
                     , l_dummmy2       
                     , l_dummmy3   );
                               
   ca.pk_fat_financeiro_dml.p_reiniciar_financeiro( l_id_financeiro 
                                                 , l_vl_financeiro
                                                 , l_un_financeiro
                                                 , l_tp_indice );

   if p_tp_operacao                   in  (  3 ) then
  -- 3 - Desmatricular por mudança de matriz curricular                                                         
      -- Atualizar tipo índice de CA.FAT_NOME_PARAMETRO a partir da habiltacao do aluno
      ca.pk_fat_nome_parametro_dml.p_atualiza_indice( st_aluno.id_nome_parametro 
                                                    , l_tp_indice );
   end if;
end if;
--
-- Cancelar os títulos  
l_vl_credito_sda    :=   0;
for st_titulo  in cr_titulo( l_id_financeiro ) loop
    if st_titulo.fg_recebido               =  'S'    
    or st_titulo.fg_faturado               =  'S'   then
       -- Título recebido
       if st_titulo.fg_recebido           =  'S'   then    
          -- Associar ao movimento do título o evento contábil 275 ( devolução de título )
          ca.pk_ctr_titulo_clc.p_titulo_devolucao( st_titulo.id_titulo   
                                                  , l_id_titulo_movimento
                                                  , p_fg_retorno 
                                                  , p_ds_retorno );
                               
          if p_fg_retorno                  =   'N' then
             raise ex_erro_memoria_calculo;
          end if;  
          l_vl_credito_sda                 :=  l_vl_credito_sda 
                                           +   st_titulo.vl_titulo;
       end if;

       -- Título faturado
       if st_titulo.fg_faturado          =  'S'  then
           -- Associar ao movimento do título o evento contábil 402 ( anulação de venda )
          ca.pk_ctr_titulo_clc.p_titulo_anulacao_venda_nfse( st_titulo.id_titulo 
                                                            , l_id_titulo_movimento  
                                                            , p_fg_retorno 
                                                            , p_ds_retorno );
          if p_fg_retorno                  =   'N' then
             raise ex_erro_memoria_calculo;
          end if;  
       end if;
           
       -- Cancelar o título Recebido ou faturado ( sem evento contábil )
       ca.pk_ctr_titulo_clc.p_titulo_cancelar( st_titulo.id_titulo   
                                             , l_id_titulo_movimento
                                             , p_fg_retorno  
                                             , p_ds_retorno );

   else 
       -- Associar ao movimento do título o evento contábil 910 ( cancelamento de título ) 
       ca.pk_ctr_titulo_clc.p_titulo_cancelar( st_titulo.id_titulo
                                             , null
                                             , null 
                                             , p_fg_retorno
                                             , p_ds_retorno );
       if p_fg_retorno                  =   'N' then
          raise ex_erro_memoria_calculo;
       end if;  
   end if;         
end loop;

-- Creditar no SDA valore a devolver ao aluno           
if l_vl_credito_sda   > 0 then 
  -- Alterar Status do aluno para débito automátioco no SDA
   ca.pk_sda_saldo_aluno_clc.p_alterar_fg_debito_autorizado( p_nr_matricula
                                                          , 'S'  -- p_fg_debito_autorizado = 
                                                          , p_fg_retorno 
                                                          , p_ds_retorno);
  -- Creditar no SDA - Evento contábil 400 ( sem lancamento contábil ) 
  ca.pk_sda_saldo_aluno_clc.p_creditar_no_saldo( l_id_pessoa_aluno             -- id pessoa
                                               , p_nr_matricula                -- matrícula
                                               , 'Crédito decorrente de devolução de pagamentos'  
                                               , 400                           -- Código do evento contabil
                                               , l_vl_credito_sda              -- Valor de crédito
                                               , p_fg_retorno 
                                               , p_ds_retorno 
                                               , p_id_movimento_financeiro_sda ); --movimento financeiro gerado
end if;

-- Incluir ocorrencia de desmatrícula em CA.FAT_MC_ALUNO 
l_rec_mc_aluno.id_financeiro              :=  l_id_financeiro;
l_rec_mc_aluno.cd_est_operador            :=  p_cd_est_operador;
l_rec_mc_aluno.nr_mat_operador            :=  p_nr_mat_operador;
l_rec_mc_aluno.cd_estabelecimento         :=  0;
l_rec_mc_aluno.nr_matricula               :=  p_nr_matricula;
l_rec_mc_aluno.cd_periodo                 :=  p_cd_periodo_regular; 
l_rec_mc_aluno.tp_arquivo                 :=  l_tp_arquivo;
l_rec_mc_aluno.tp_periodo                 :=  p_tp_periodo;
l_rec_mc_aluno.id_academico               :=  l_id_academico;  
l_rec_mc_aluno.cd_periodo_regular         :=  p_cd_periodo_regular; 
l_rec_mc_aluno.cd_periodo_especial        :=  p_cd_periodo_especial;   
l_rec_mc_aluno.id_financeiro              :=  l_id_financeiro;
l_rec_mc_aluno.ds_mensagem_01             :=  l_ds_mensagem;   
l_rec_mc_aluno.id_pessoa_aluno            :=  l_id_pessoa_aluno;
l_rec_mc_aluno.dt_registro                :=  sysdate;   
l_rec_mc_aluno.st_academica               :=  st_aluno.st_academica;
l_rec_mc_aluno.fg_mc_aluno                :=  'S';
l_rec_mc_aluno.id_mc_versao               :=  1;
p_mc_aluno_incluir( 0
                 , l_rec_mc_aluno 
                 , p_fg_retorno        
                 , p_ds_retorno   );
if p_fg_retorno     =   'N' then
  raise ex_erro_memoria_calculo;
end if;
        
p_ds_retorno   := 'Rotina executada com sucesso.';
p_fg_retorno   := 'N';
exception 
   when ex_erro_memoria_calculo then
        p_fg_retorno   := 'N';  
   when ex_finalizar_memoria_calculo then
        p_fg_retorno   := 'S';  
end p_desmatricular;
--    
-- -----------------------------------------------------------------------------
-- Objetos para migrar para o pacote ca.pk_fat_financeiro_clc
/*
FUNCTION: f_parametro_financeiro
DESENVOLVEDOR: Helane 
OBJETIVO: Verificar se matrícula possuí os registros de parâmetros necessários
          para gerar um cadastro financeiro.
          Validação para alunos de Graduação e de Pós-graduação
PARÂMETROS:  p_nr_matricula
       
RETORNO:
S<id_nome_parametro>  - possui informações necessárias
N<descrição da ocorrência> - não possuí informações necessárias
*/

function f_parametro_financeiro 
( p_nr_matricula     number )
return varchar2 is
--
cursor c_validar ( pc_nr_matricula   number ) is
select a.id_nome_parametro
     , a.nr_matricula
     , a.id_pessoa_aluno
     , ca.pk_pessoa.f_consulta_pessoa('000'||lpad(a.nr_matricula,7,'0'),'1',1) id_pessoa_aluno_cad 
from   ca.fat_nome_parametro a, pg.nome b
where  a.nr_matricula = pc_nr_matricula
and    a.nr_matricula = b.nr_matricula
and    a.fg_ativo = 'S';
rc_validar        c_validar%rowtype;
--
wds_retorno      varchar2(4000);
-- 
begin
--
if p_nr_matricula is null then
   wds_retorno := 'NMatrícula não informada.';
else
--
   open c_validar ( pc_nr_matricula => p_nr_matricula );
   fetch c_validar into rc_validar;
   if c_validar%NOTFOUND then
      wds_retorno := 'NMatrícula sem cadastro de parâmetros financeiros.';
   else
      if rc_validar.id_pessoa_aluno <> rc_validar.id_pessoa_aluno_cad then
         wds_retorno := 'NIdentificador da pessoa divergente do registrado no parâmsgtro financeiro.';
      else
         wds_retorno := 'S'||trim(to_char(rc_validar.id_nome_parametro));
      end if;
   end if;
   close c_validar;
-- 
end if;
-- 
<<SAIDA>>
--
return (wds_retorno);
--
end f_parametro_financeiro;
-- -----------------------------------------------------------------------------
-- 
/*
FUNCTION: f_financeiro_matricula
DESENVOLVEDOR: Helane 
OBJETIVO: Verificar se o aluno possuí o cadastro financeiro para o período acadêmico.
          Verificar se é permitodo gerar o cadastro
          Validação para alunos de Graduação e períodos acadêmicos dos regimes
          Regular e internato da medicina.
PARÂMETROS:  p_id_academico
             p_id_nome_parametro
RETORNO:
S<id_financeiro>           - Tem cadastro gerado, informa o id_financeiro
S                          - Não tem cadastro gerado, permite gerar
N<descrição da ocorrência> - Cadastro de matrícula não pode ser gerado
*/

function f_financeiro_matricula 
( p_id_academico       number 
, p_id_nome_parametro  number )
return varchar2 is
--
cursor c_validar ( pc_id_academico      number
                 , pc_id_nome_parametro number ) is
select a.id_nome_parametro
     , a.nr_matricula
     , a.id_pessoa_aluno
     , (select e.id_financeiro 
        from   ca.fat_financeiro e 
        where  e.id_nome_parametro = a.id_nome_parametro
        and    e.id_academico = b.id_academico
        and    e.cd_faixa_motivo_inativacao is null ) id_financeiro
     , d.ds_apresentacao ds_regime
     , d.tp_periodo
     , b.dt_inicio_utilizacao
     , b.dt_termino_utilizacao
     , case 
       when d.tp_periodo = 'I' then
            ca.pk_gvs_academico.validar_aluno(0, NULL, NULL, a.nr_matricula) 
-- !!! Atenção com o pacote s_periodo_especial
       else
            'N'
       end  fg_internato_medidcina
--
from   ca.fat_nome_parametro a
     , ca.fat_academico b
     , ca.aluno c
     , ca.v_fat_tipo_regime d
where  a.id_nome_parametro = pc_id_nome_parametro
and    b.id_academico = pc_id_academico
and    a.nr_matricula = c.nr_matricula
and    a.fg_ativo = 'S'
and    b.fg_ativo = 'S'
and    b.cd_dominio_regime = d.cd_dominio
and    b.cd_faixa_regime = d.cd_faixa
;
rc_validar        c_validar%rowtype;
--
wds_retorno      varchar2(4000);
-- 
begin
--
if p_id_academico is null then
   wds_retorno := 'NIdentificador do período acadêmico não informado.';
--
elsif p_id_nome_parametro is null then
   wds_retorno := 'NIdentificador do aluno no cadastro de parâmetros financeiros não informado.';
--
else
--
   open c_validar ( pc_id_academico => p_id_academico 
                  , pc_id_nome_parametro => p_id_nome_parametro );
   fetch c_validar into rc_validar;
   if c_validar%NOTFOUND then
      wds_retorno := 'NIdentificador do período acadêmico e do aluno não são válidos para gerar cadastro financeiro de matrícula.';
   else
      if rc_validar.tp_periodo not in ('R','I') then
         wds_retorno := 'NPeríodo acadêmico de regime '||rc_validar.ds_regime||' não permite gerar cadastro de matrícula.';
      elsif sysdate not between rc_validar.dt_inicio_utilizacao and rc_validar.dt_termino_utilizacao then
         wds_retorno := 'NNão permite gerar cadastro financeiro, fora do prazo permitido para o período acadêmico.';
      elsif rc_validar.id_financeiro is not null then
         wds_retorno := 'S'||trim(to_char(rc_validar.id_financeiro));
      else
         if rc_validar.tp_periodo = 'I' then
            if rc_validar.fg_internato_medidcina = 'S' then
               wds_retorno := 'S'; 
            else
               wds_retorno := 'NAluno não é do '||rc_validar.ds_regime||'.'; 
            end if;
         else
            if rc_validar.fg_internato_medidcina = 'S' then
               wds_retorno := 'NAluno é do Internato, não permite gerar cadastro para '||rc_validar.ds_regime||'.'; 
            else
               wds_retorno := 'S'; 
            end if;
         end if;
      end if;
   end if;
   close c_validar;
-- 
end if;
-- 
<<SAIDA>>
--
return (wds_retorno);
--
end f_financeiro_matricula;
-- -----------------------------------------------------------------------------
-- 

procedure p_complementar_dados 
( p_rec_mc_aluno in out nocopy ca.pk_fat_mc_plt.rec_mc_aluno ) is
--
cursor cursor_complemento ( pc_cd_periodo number
                          , pc_tp_periodo varchar2 
                          , pc_tp_arquivo number ) is
select a.id_academico
     , a.cd_dominio_regime, a.cd_faixa_regime, b.ds_apresentacao ds_regime
     , a.cd_periodo_regular, a.cd_periodo_especial
from   ca.fat_academico a, ca.v_fat_tipo_regime b
where  b.tp_periodo = pc_tp_periodo
and    b.tp_arquivo = pc_tp_arquivo
and    pc_cd_periodo = case when b.tp_periodo = 'R' then a.cd_periodo_regular else a.cd_periodo_especial end
and    a.cd_dominio_regime = b.cd_dominio
and    a.cd_faixa_regime   = b.cd_faixa;
rc_complemento   cursor_complemento%rowtype;
--
begin
--
open cursor_complemento ( pc_cd_periodo => p_rec_mc_aluno.cd_periodo 
                        , pc_tp_periodo => p_rec_mc_aluno.tp_periodo
                        , pc_tp_arquivo => p_rec_mc_aluno.tp_arquivo );
fetch cursor_complemento into rc_complemento;
if cursor_complemento%found then
   p_rec_mc_aluno.id_academico        := rc_complemento.id_academico;
   p_rec_mc_aluno.cd_dominio_regime   := rc_complemento.cd_dominio_regime;
   p_rec_mc_aluno.cd_faixa_regime     := rc_complemento.cd_faixa_regime;
   p_rec_mc_aluno.ds_regime           := rc_complemento.ds_regime;
   p_rec_mc_aluno.cd_periodo_regular  := rc_complemento.cd_periodo_regular;     
   p_rec_mc_aluno.cd_periodo_especial := rc_complemento.cd_periodo_especial;
else
   p_rec_mc_aluno.id_academico        := null;
   p_rec_mc_aluno.cd_dominio_regime   := null;
   p_rec_mc_aluno.cd_faixa_regime     := null;
   p_rec_mc_aluno.ds_regime           := null;
   p_rec_mc_aluno.cd_periodo_regular  := null;
   p_rec_mc_aluno.cd_periodo_especial := null;
end if;
close cursor_complemento;
--
end p_complementar_dados;
-- 
end pk_fat_mc_clc;