create or replace PACKAGE      "PK_FAT_MC_CLC" is
--
-- !!* Aqui -
--
-- Cópia do pacote ca.pk_fat_mc_clc
--
g_nm_pacote                           constant varchar2(100)  := 'PK_FAT_MC_CLC';

ex_erro_memoria_calculo               exception;
ex_finalizar_memoria_calculo          exception;

g_qt_dias_tolerancia_vencto_titulo    constant      number(2) := 1; 

g_rec_fat_mc_log1                     ca.fat_mc_log1%rowtype;
g_fg_retorno_log                      varchar2(1);
g_ds_retorno_log                      varchar2(4000);

g_nr_unidades_semestre                number(2)               := 6;
gc_pc_csa_clb                         constant number         := 1.25; 

-- Obter os dados do financeiro e configurações da matrícula do aluno
-- a partir da memória de calculo informada  
cursor c0_validacao 
( pc_id_financeiro in  number 
) is 
select ti.ds_tp_calculo
    , b.id_pessoa_aluno
    , c.cd_identificador_vencimento
    , b.id_pessoa_aluno  id_pessoa_irpf
    , b.id_pessoa_aluno  id_pessoa_nfse
    , b.id_pessoa_aluno  id_pessoa_cobranca
    , a.qt_dias_vencimento_boleto_pe
    , a.dt_mes_ano_inicio_competencia
    , a.qt_parcelas      
 from ca.v_fat_tipo_indice ti
    , ca.fat_nome_parametro c
    , ca.fat_academico a
    , ca.fat_financeiro b
where b.id_financeiro                =   pc_id_financeiro   
  and b.cd_faixa_motivo_inativacao   is  null    
  and a.id_academico                 =   b.id_academico   
  and a.fg_ativo                     =   'S' 
  and c.id_nome_parametro            =   b.id_nome_parametro
  and c.id_pessoa_aluno              =   b.id_pessoa_aluno
  and c.nr_matricula                 =   b.nr_matricula
  and c.tp_indice                    =   b.tp_indice   
  and c.fg_ativo                     =   'S'
  and ti.tp_indice                   =   b.tp_indice 
  and ti.fg_ativo                    =   'S';
rc0                         c0_validacao%rowtype;        
--
--
-- Obter as modalidades do financeiro do aluno
-- Opções ( p1_tp_selecao ): 
--    0 - Listar todas as modalidades em vigor
--    1 - Obter o valor da semestralidade e distribuir o vendido 
--    2 - Totalizar os descontos incondicionais concedidos em valor
--    3 - Totalizar os descontos incondicionais e condicionais convertidos para incondicionais
--    4 - Totalizar as bolsas
--    5 -  Totalizar os descontos condicionais
--    6 - Totalizar os CONVÊNIOS DE PAGAMENTO
--    7 - Computar valores sob responsabilidade do aluno
--    8 - Computar valores para o financiamento privado
--    9 - Computar valores para o financiamento Unifor ( PEX ) 
cursor c1_modalidade 
( pc_modalidade_financeiro      in  ca.pk_fat_mc_plt.vt_fin_modalidade_aux
, p1_tp_selecao                 in  number  
) is 
select id_modalidade           
     , id_nome_modalidade      
     , id_modalidade_filha    
     , id_modalidade_tipo   
     , nm_modalidade_tipo  
     , nm_modalidade           
     , ds_modalidade            
     , vl_modalidade         
     , pc_modalidade            
     , pc_modalidade_original     
     , cd_externo_padrao           
     , cd_modalidade_externo  
     , id_pessoa_irpf            
     , id_pessoa_nfse             
     , id_pessoa_cobranca  
     , nr_ordem_01               
     , nr_ordem_02               
     , nr_ordem_03                                   
     , vl_limite 
     , cd_ocorrencia_regra
     , case
       when cd_ocorrencia_regra  is not null then
            '( REGRA ACADÊMICA: ' || cd_ocorrencia_regra || ' )'
       end    ds_situacao_modalidade 
     , rownum   nr_ind_modalidade

from table (  pc_modalidade_financeiro ) 
where case 
   -- Modaliade: Todas
      when p1_tp_selecao                     =      0 then 
        'S'
   -- Modalidade: Desconto incondicional
      when p1_tp_selecao                     =      3 
           and cd_ocorrencia_regra               is     null          
           and ( ( id_modalidade_tipo            in     ( 2) 
           and     nvl(cd_externo_padrao,'X')    in     ( 'DESCONTO_DE_VALOR_PRIMEIRA', 'DESCONTO_DE_VALOR')
                 )
               or   ( id_modalidade_tipo            in     ( 2 ) 
           and     nvl(cd_externo_padrao,'X')    not in ( 'DESCONTO_DE_VALOR_PRIMEIRA', 'DESCONTO_DE_VALOR')
               ) 
               or   ( id_modalidade_tipo            in     ( 3,4 ) 
           and     nvl(cd_externo_padrao,'X')    =      'DESC_INCONDICIONAL_PRIMEIRA'
               )
              )  then 
       'S'
   -- Modalidade: Bolsas
      when p1_tp_selecao                     =      4
           and id_modalidade_tipo                in     ( 6 ) then 
       'S'
   -- Modalidade: Desconto condicional
      when p1_tp_selecao                     =      5
           and id_modalidade_tipo                in     ( 3,4 )  
           and cd_ocorrencia_regra               is     null          then  
       'S'
   -- Modalidades: De Cobrança
   --  5 - Convênio de pagamento
   --  7 - Financiamento publico
   --  8 - Financiamento privado
   -- 11 - Financiamento Unifor - PEX               
      when p1_tp_selecao                     =      6 
           and id_modalidade_tipo                in     ( 5, 7, 8, 11 ) then 
       'S'
   -- Modalidades: Aluno
      when p1_tp_selecao                     =      7 
           and id_modalidade_tipo                in     ( 1 ) then 
       'S'
      else
       'N'
      end  = 'S' 

/*
-- Obter o valor da semestralidade e distribuir o vendido 
when p1_tp_selecao                     =      1 
and id_modalidade_tipo                in     ( 1) then 
    'S'

-- Computar valores para o financiamento privado
--when p1_tp_selecao = 8 and fm.id_modalidade_tipo in ( 8 ) then 
--     'S'
-- Computar valores para o financiamento Unifor ( PEX )
when p1_tp_selecao                     =      9 
and id_modalidade_tipo                in     ( 11 ) then 
    'S'   */
order by nr_ordem_01
       , nr_ordem_02
       , nr_ordem_03;                                                                                                                                                                                                             
--  r1m   c1_modalidade%rowtype;
r2m   c1_modalidade%rowtype;
-- 
cursor c3_desconto_incondicional is
select a.id_modalidade_tipo
     , b.id_modalidade
     , b.nm_modalidade
from ca.fat_modalidade_tipo a
   , ca.fat_modalidade b
where b.cd_modalidade_externo       = 'CONVERTE_DESC_CONDICIONAL_EM_INCONDICIONAL'   
and b.id_modalidade_tipo  = a.id_modalidade_tipo;
rc3    c3_desconto_incondicional%rowtype;
--
cursor c4_fat_financeiro 
( p4_id_financeiro              number
, p4_nr_ordem_titulo            number
, p4_id_modalidade_cobranca     number
, pc_tp_periodo                 varchar2 
, pc_tp_arquivo                 number 
, pc_nr_dia_vencimento_padrao   number 
, pc_dt_processamento           date
, pc_dt_primeira_mensalidade_pg date 
) is
select a.nr_matricula
 , a.id_pessoa_aluno 
 , decode(c.cd_faixa_regime, 1, substr(s_periodo_completo(p_cd_periodo => c.cd_periodo_regular), 1, 4) || '.' || 
                                substr(s_periodo_completo(p_cd_periodo => c.cd_periodo_regular), 5, 1), c.cd_periodo_especial
         ) ds_periodo 

 , d.id_academico_titulo 
 , d.nr_ordem_titulo 
 , case
   when pc_tp_periodo   =  'N'  then
   -- Período especial de férias
        to_date( '01/' || to_char( add_months( pc_dt_processamento, p4_nr_ordem_titulo - 1 ), 'mm/yyyy'), 'dd/mm/yyyy' )
   when pc_tp_arquivo   =  1  then
   -- Graduação
        d.dt_mes_ano_competencia 
   when pc_tp_arquivo   =  3  then
   -- Pós-Graduação
        add_months( pc_dt_primeira_mensalidade_pg, p4_nr_ordem_titulo - 1 )
   end                                                         dt_mes_ano_competencia
 , d.pc_multa 
 , d.pc_juros 

 , case
   when pc_tp_arquivo   =  1  then
        e.id_acad_tit_vencimento 
   when pc_tp_arquivo   =  3  then
   -- Pós-Graduação
        null
   end id_acad_tit_vencimento
 , case
   when pc_tp_periodo   =  'N'  then
   -- Período especial de férias
        add_months( to_date( lpad(pc_nr_dia_vencimento_padrao, 2, '0') || to_char( pc_dt_processamento, '/mm/yyyy'), 'dd/mm/yyyy' )  
                  , p4_nr_ordem_titulo - 1 )
   when pc_tp_arquivo   =  1  then
   -- Graduação
      to_date( LPAD( pc_nr_dia_vencimento_padrao, 2, '0') || '/' || to_char( e.dt_vencimento , 'mm/yyyy'), 'dd/mm/yyyy' )

   when pc_tp_arquivo   =  3  then   -- g_rec_mc_aluno.tp_arquivo
   -- Pós-Graduação
      add_months( pc_dt_primeira_mensalidade_pg, p4_nr_ordem_titulo - 1 )
   end   dt_vencimento 

 , f.id_modalidade 
 , f.id_modalidade_tipo 
 , f.cd_externo_padrao            
 , nvl(f.fg_agrupa_sacado, 'N')                 fg_agrupa_sacado 

 , i.ds_apresentacao 
 , i.ds_tp_aluno 

 , case 
   when i.tp_periodo in ('R','I') then
        nvl(( select 'S' 
              from   ca.v_fat_status_financeiro a1
              where  a1.cd_dominio = a.cd_dominio_st_financeiro
              and    a1.cd_faixa = a.cd_faixa_st_financeiro
              and    a1.ds_controle = 'MATRICULA'
             ),'N')
   else
        'N'
   end fg_titulo_oferta

 , h.curso_atual 
 , h.cd_habilitacao  
 , h.dv_matricula

 , ban.nr_banco                           cd_agente_cobrador 
 , f.id_banco_agencia_carteira 
 , f.fg_considerar_encargos
--
from ca.ctr_banco_agencia_carteira   j
   , ca.banco ban
   , ca.v_fat_tipo_regime            i 
   , ( select nr_matricula 
          , dv_matricula
          , curso_atual
          , cd_habilitacao
      from ca.aluno     
     union all  
     select nr_matricula 
          , dv_matricula
          , null curso_atual
          , null cd_habilitacao 
       from pg.aluno          
   )                               h 
   , ca.fat_modalidade               f 
   , ca.fat_vencimento_padrao        g 
   , ca.fat_acad_titulo_vencimento   e 
   , ca.fat_academico_titulo         d 
   , ca.fat_academico                c 
   , ca.fat_nome_parametro           b 
   , ca.fat_financeiro               a 
--
where a.id_financeiro               =  p4_id_financeiro
and a.cd_faixa_motivo_inativacao    is null
and b.nr_matricula                  =  a.nr_matricula
and b.fg_ativo                      =  'S'
and c.id_academico                  =  a.id_academico
and c.fg_ativo                      =  'S'
and d.id_academico                  =  a.id_academico
and d.nr_ordem_titulo               =  p4_nr_ordem_titulo

and e.id_academico_titulo           =  d.id_academico_titulo
and g.id_vencimento_padrao          =  e.id_vencimento_padrao  
and g.cd_identificador              =  decode( pc_tp_periodo, 'N', 'N', b.cd_identificador_vencimento )    -- g_rec_mc_aluno.tp_periodo
and g.cd_dominio_regime             =  c.cd_dominio_regime
and g.cd_faixa_regime               =  c.cd_faixa_regime
and g.fg_ativo                      =  'S'

and f.id_modalidade                 =  p4_id_modalidade_cobranca   
and f.fg_ativo                      =  'S'        
and h.nr_matricula                  =  a.nr_matricula

and i.cd_dominio                    =  c.cd_dominio_regime 
and i.cd_faixa                      =  c.cd_faixa_regime
and j.id_banco_agencia_carteira(+)  =  f.id_banco_agencia_carteira 
and ban.nr_banco(+)                 =  f.cd_agente_cobrador;         
rc4                      c4_fat_financeiro%rowtype;
g_rc4_ultimo             c4_fat_financeiro%rowtype;
--
-- Obter os dados dos padrões de cálculo do financeiro do aluno
-- -- !!* Aqui - Período especial não segue o padrão do período regular
cursor c5_padrao( p5_id_financeiro number
                , p5_tp_indice     number
                , p5_vl_indice     number) is
select sum(decode( a.nr_ordem_titulo, 1, a.un_financeiro, 0 ))                         qt_unidade_titulo_01
     , sum(decode( a.nr_ordem_titulo, 2, a.un_financeiro, 0 ))                          qt_unidade_titulo_02
     , sum(decode( a.nr_ordem_titulo, 1, trunc((a.un_financeiro * b.vl_indice),2), 0 )) vl_titulo_01
     , sum(decode( a.nr_ordem_titulo, 2, trunc((a.un_financeiro * b.vl_indice),2), 0 )) vl_titulo_02 
 from ca.v_fat_tipo_indice d
    , ca.fat_padrao_mensalidade a
    , ca.fat_academico c
    , ( select b.id_academico
             , p5_vl_indice vl_indice  
             , p5_tp_indice tp_indice
          from ca.fat_financeiro b
         where b.id_financeiro                =       p5_id_financeiro
           and b.cd_faixa_motivo_inativacao   is      null ) b
where c.id_academico                      =       b.id_academico
  and a.cd_dominio_regime                 =       c.cd_dominio_regime
  and a.cd_faixa_regime                   =       c.cd_faixa_regime
  and d.tp_indice                         =       b.tp_indice
  and a.cd_dominio_tipo_calculo           =       d.cd_dominio_tipo_calculo
  and a.cd_faixa_tipo_calculo             =       d.cd_faixa_tipo_calculo
  and a.fg_ativo                          = 'S'
  and (( c.dt_mes_ano_inicio_competencia  between a.dt_inicio_vigencia and a.dt_termino_vigencia)
   or  ( c.dt_mes_ano_termino_competencia between a.dt_inicio_vigencia and a.dt_termino_vigencia) 
      ) 
  and    a.nr_ordem_titulo in (1,2) ;
rc5    c5_padrao%rowtype; 
--
-- Assinaturas de procedures e funções
-- ----------------------------------------------------------------------------- 
function f_busca_ultimas_disciplinas(p_matricula in number) return ca.pk_fat_mc_plt.ar_mc_disciplina;
--
procedure p_atualiza_titulos(p_rec_financeiro in out nocopy ca.pk_fat_mc_plt.rec_financeiro);
--
FUNCTION f_dia_vencimento_padrao(
p_id_academico IN ca.fat_academico.id_academico%type,
p_nr_ordem_titulo IN ca.fat_academico_titulo.nr_ordem_titulo%type,
p_dv_matricula IN ca.fat_vencimento_padrao.cd_identificador%type,
p_tipo_retorno IN number
)
RETURN varchar2;
--
FUNCTION f_diferenca_segundos(
p_dt_hr_inicio IN timestamp,
p_dt_hr_fim IN timestamp
)
RETURN number;
--
FUNCTION f_financeiro_modalidade(
p_rec_mc_aluno IN ca.pk_fat_mc_plt.rec_mc_aluno,
p_id_modalidade IN ca.fat_modalidade.id_modalidade%type
)
RETURN number;
--
FUNCTION f_hora_optativa_utilizada(
p_cd_estabelecimento IN number,
p_nr_matricula IN number,
p_cd_periodo IN number,
p_tp_arquivo IN number,
p_tp_periodo IN varchar2
)
RETURN number;
--
FUNCTION f_obter_id_academico(
p_tp_arquivo IN number,
p_tp_periodo IN varchar2,
p_cd_periodo IN number,
p_cd_periodo_especial IN number
)
RETURN ca.fat_academico.id_academico%type;
--
FUNCTION f_obter_id_financeiro(
p_nr_matricula IN number,
p_tp_arquivo IN number,
p_tp_periodo IN varchar2,
p_cd_periodo IN number,
p_cd_periodo_especial IN number
)
RETURN ca.fat_financeiro.id_financeiro%type;
--
FUNCTION f_obter_id_financeiro(
p_nr_matricula IN number,
p_id_academico IN number
)
RETURN ca.fat_financeiro.id_financeiro%type;
--
FUNCTION f_qt_competencia_preservar(
p_dt_base_referencia IN date,
p_dt_processamento IN date,
p_dt_inclusao_titulo IN date
)
RETURN number;
--
FUNCTION f_qt_titulo_modalidade(
p_vt_titulos_aux IN ca.pk_fat_mc_plt.vt_titulo_aux,
p_id_modalidade IN ca.fat_modalidade.id_modalidade%type,
p_nr_competencia IN ca.ctr_titulo.nr_competencia%type
)
RETURN number;
--
FUNCTION first_day(
pdata IN date default sysdate
)
RETURN date;
--
PROCEDURE p_academico_titulo(
p_id_academico IN ca.fat_academico_titulo.id_academico%type,
p_nr_competencia IN ca.fat_academico_titulo.nr_ordem_titulo%type,
p_id_academico_titulo OUT ca.fat_academico_titulo.id_academico_titulo%type,
p_dt_mes_ano_competencia OUT ca.fat_academico_titulo.dt_mes_ano_competencia%type
);
--
PROCEDURE p_aluno_regular(
p_vt_modalidade_financeiro_aux IN ca.pk_fat_mc_plt.vt_fin_modalidade_aux,
p_rec_financeiro IN OUT nocopy ca.pk_fat_mc_plt.rec_financeiro,
p_rec_mc_aluno IN ca.pk_fat_mc_plt.rec_mc_aluno,
p_nr_sequencia_calc_modalidade IN OUT nocopy number
);
--
PROCEDURE p_array_financeiro_modalidade(
p_rec_mc_aluno IN ca.pk_fat_mc_plt.rec_mc_aluno,
p_vt_regra_academica IN ca.pk_fat_mc_plt.ar_mc_regra_academica,
p_rec_financeiro IN OUT nocopy ca.pk_fat_mc_plt.rec_financeiro
);
--
PROCEDURE p_array_titulo(
p_rec_financeiro IN OUT nocopy ca.pk_fat_mc_plt.rec_financeiro,
p_vt_modalidade_competencia_aux IN ca.pk_fat_mc_plt.vt_modalidade_competencia, 
p_qt_titulos_por_competencia_modalidade IN OUT number
);
--
PROCEDURE p_atualiza_array_modalidade_competencia_fies(
p_rec_financeiro IN OUT nocopy ca.pk_fat_mc_plt.rec_financeiro
);
--
PROCEDURE p_atualiza_base_calculo_competencia(
p_rec_financeiro IN OUT nocopy ca.pk_fat_mc_plt.rec_financeiro,
p_nr_ind_competencia IN number
);
--
PROCEDURE p_autorizacao_matricula(
p_array_aluno IN OUT nocopy ca.pk_fat_mc_plt.ar_mc_aluno,
p_array_disciplina IN OUT nocopy ca.pk_fat_mc_plt.ar_mc_disciplina,
p_array_modalidade IN OUT nocopy ca.pk_fat_mc_plt.ar_mc_disciplina_modalidade,
p_dt_processamento IN date,
p_fg_retorno OUT varchar2,
p_ds_retorno OUT varchar2
);
--
PROCEDURE p_bolsa(
p_vt_modalidade_financeiro_aux IN ca.pk_fat_mc_plt.vt_fin_modalidade_aux,
p_rec_financeiro IN OUT nocopy ca.pk_fat_mc_plt.rec_financeiro,
p_rec_mc_aluno IN ca.pk_fat_mc_plt.rec_mc_aluno,
p_nr_sequencia_calc_modalidade IN OUT nocopy number
);
--
PROCEDURE p_calculo_creditos(
p_rec_mc_aluno IN OUT nocopy ca.pk_fat_mc_plt.rec_mc_aluno,
p_vt_mc_disciplina IN OUT nocopy ca.pk_fat_mc_plt.ar_mc_disciplina,
p_fg_exibir IN varchar2,
p_fg_retorno OUT varchar2,
p_ds_retorno OUT varchar2
);
--
PROCEDURE p_calculo_mensalista(
p_rec_mc_aluno IN OUT nocopy ca.pk_fat_mc_plt.rec_mc_aluno,
p_vt_mc_disciplina IN OUT nocopy ca.pk_fat_mc_plt.ar_mc_disciplina,
p_fg_exibir IN varchar2,
p_fg_retorno OUT varchar2,
p_ds_retorno OUT varchar2
);
--
PROCEDURE p_calculo_semestralidade(
p_rec_mc_aluno IN OUT nocopy ca.pk_fat_mc_plt.rec_mc_aluno,
p_vt_mc_disciplina IN OUT nocopy ca.pk_fat_mc_plt.ar_mc_disciplina,
p_fg_exibir IN varchar2,
p_fg_retorno OUT varchar2,
p_ds_retorno OUT varchar2
);
--
PROCEDURE p_competencia_shift(
p_dt_base_referencia IN date,
p_dt_processamento IN date,
p_qt_competencia OUT number
);
--
PROCEDURE p_ctr_titulo_incluir(
p_tp_operacao IN varchar,
p_tp_periodo IN varchar2,
p_tp_arquivo IN number,
p_id_academico IN ca.fat_academico.id_academico%type,
p_rec_ctr_titulo IN OUT nocopy ca.ctr_titulo%rowtype,
p_rec_financeiro IN OUT nocopy ca.pk_fat_mc_plt.rec_financeiro,
p_ind_titulo IN number,
p_qt_mes_incremento_vencimento IN number,
p_dt_processamento IN date,
p_dt_primeira_mensalidade_pg IN date,
p_fg_retorno OUT varchar2,
p_ds_retorno OUT varchar2
);
--
PROCEDURE p_dados_titulo(
p_id_financeiro IN ca.fat_financeiro.id_financeiro%type,
p_tp_periodo IN varchar2,
p_tp_arquivo IN number,
p_id_academico IN ca.fat_academico.id_academico%type,
p_cd_identificador_vencimento IN varchar2,
p_nr_dia_vencimento_padrao IN number,
p_qt_competencia IN number,
p_nr_competencia_inicio IN number,
p_id_modalidade_cobranca IN number,
p_nr_ordem_titulo IN number,
p_qt_mes_incremento_vencimento IN number,
p_dt_processamento IN date,
p_dt_primeira_mensalidade_pg IN date,
p_id_pessoa_irrf OUT number,
p_dt_competencia OUT date,
p_dt_vencimento OUT date,
p_pc_multa OUT number,
p_pc_juros OUT number,
p_ds_referencia OUT varchar2,
p_fg_fatura OUT varchar2,
p_fg_contabiliza_rlp OUT varchar2,
p_cd_agente_cobrador OUT number,
p_fg_agrupa_sacado OUT varchar2,
p_fg_titulo_oferta OUT varchar2,
p_fg_instrucao_banco OUT varchar2,
p_ds_mensagem_01 OUT varchar2,
p_ds_mensagem_02 OUT varchar2,
p_ds_mensagem_03 OUT varchar2,
p_ds_mensagem_04 OUT varchar2,
p_fg_retorno OUT varchar2,
p_ds_retorno OUT varchar2,
p_id_academico_titulo OUT number,
p_id_modalidade_tipo OUT number,
p_id_banco_agencia_carteira OUT ca.fat_modalidade.id_banco_agencia_carteira%type,
p_fg_gerar_boleto OUT ca.ctr_titulo.fg_gerar_boleto%type,
p_fg_postar_boleto OUT ca.ctr_titulo.fg_gerar_boleto%type,
p_qt_dias_anteced_gerar_boleto OUT ca.ctr_titulo.fg_gerar_boleto%type
);
--
PROCEDURE p_desconto_condicional(
p_vt_modalidade_financeiro_aux IN ca.pk_fat_mc_plt.vt_fin_modalidade_aux,
p_rec_financeiro IN OUT nocopy ca.pk_fat_mc_plt.rec_financeiro,
p_rec_mc_aluno IN ca.pk_fat_mc_plt.rec_mc_aluno,
p_nr_sequencia_calc_modalidade IN OUT nocopy number
);
--
PROCEDURE p_desconto_incondicional(
p_vt_modalidade_financeiro_aux IN ca.pk_fat_mc_plt.vt_fin_modalidade_aux,
p_rec_financeiro IN OUT nocopy ca.pk_fat_mc_plt.rec_financeiro,
p_rec_mc_aluno IN ca.pk_fat_mc_plt.rec_mc_aluno,
p_nr_sequencia_calc_modalidade IN OUT nocopy number,
p_fg_retorno OUT varchar2,
p_ds_retorno OUT varchar2
);
--
PROCEDURE p_desconto_incondicional_percentual(
p_rec_financeiro IN OUT nocopy ca.pk_fat_mc_plt.rec_financeiro,
p_rec_mc_aluno IN ca.pk_fat_mc_plt.rec_mc_aluno,
p_cd_modalidade_externo IN ca.fat_modalidade.cd_modalidade_externo%type,
p_cd_externo_padrao IN ca.fat_modalidade.cd_externo_padrao%type,
p_ind_competencia IN number,
p_ind_modalidade_comp IN number,
p_id_modalidade IN ca.fat_modalidade.id_modalidade%type,
p_id_modalidade_tipo IN ca.fat_modalidade_tipo.id_modalidade_tipo%type,
p_pc_modalidade IN number,
p_vl_diferenca IN number,
p_fg_retorno OUT varchar2,
p_ds_retorno OUT varchar2
);
--
PROCEDURE p_desconto_incondicional_valor(
p_rec_financeiro IN OUT nocopy ca.pk_fat_mc_plt.rec_financeiro,
p_cd_modalidade_externo IN ca.fat_modalidade.cd_modalidade_externo%type,
p_ind_competencia IN number,
p_ind_modalidade_comp IN number,
p_vl_modalidade IN number,
p_vl_diferenca IN number
);
--
PROCEDURE p_desconto_retroativo_sda(
p_tp_aluno IN number,
p_ano_mes_competencia IN date,
p_pc_desconto IN number,
p_ds_mensagem_sda IN varchar2,
p_fg_retorno OUT varchar2,
p_ds_retorno OUT varchar2
);
--
PROCEDURE p_desmatricular(
p_tp_operacao IN number,
p_nr_matricula IN ca.aluno.nr_matricula%type,
p_tp_periodo IN varchar2,
p_cd_periodo_regular IN ca.periodo.cd_periodo%type,
p_cd_periodo_especial IN ca.periodo_especial.cd_periodo%type,
p_cd_est_operador IN ca.usuario.cd_estabelecimento%type,
p_nr_mat_operador IN ca.usuario.nr_matricula%type,
p_id_movimento_financeiro_sda OUT ca.sda_movimento_financeiro.id_movimento_financeiro%type,
p_fg_retorno OUT varchar2,
p_ds_retorno OUT varchar2
);
--
PROCEDURE p_distribuir_modalidades_cobranca(
p_vt_modalidade_financeiro_aux IN ca.pk_fat_mc_plt.vt_fin_modalidade_aux,
p_rec_financeiro IN OUT nocopy ca.pk_fat_mc_plt.rec_financeiro,
p_rec_mc_aluno IN ca.pk_fat_mc_plt.rec_mc_aluno,
p_nr_sequencia_calc_modalidade IN OUT nocopy number
);
--
PROCEDURE p_fat_financeiro_incluir(
p_rec_mc_aluno IN OUT nocopy ca.pk_fat_mc_plt.rec_mc_aluno,
p_fg_retorno OUT varchar2,
p_ds_retorno OUT varchar2
);
--
PROCEDURE p_gerar_disciplina_modalidade(
p_rec_mc_aluno IN ca.pk_fat_mc_plt.rec_mc_aluno,
p_vt_mc_disciplina IN OUT ca.pk_fat_mc_plt.ar_mc_disciplina,
p_vt_mc_disciplina_modalidade IN OUT pk_fat_mc_plt.ar_mc_disciplina_modalidade,
p_fg_exibir IN varchar2,
p_fg_retorno OUT varchar2,
p_ds_retorno OUT varchar2
);
--
PROCEDURE p_mc_aluno_incluir(
p_vl_financeiro_preservado IN number,
p_rec_mc_aluno IN OUT nocopy ca.pk_fat_mc_plt.rec_mc_aluno,
p_fg_retorno OUT varchar2,
p_ds_retorno OUT varchar2
);
--
PROCEDURE p_mc_disciplina_incluir(
p_id_mc_aluno IN ca.fat_mc_aluno.id_mc_aluno%type,
p_vt_mc_disciplina IN OUT nocopy ca.pk_fat_mc_plt.ar_mc_disciplina,
p_vt_mc_disciplina_modalidade IN OUT nocopy pk_fat_mc_plt.ar_mc_disciplina_modalidade,
p_fg_retorno OUT varchar2,
p_ds_retorno OUT varchar2
);
--
PROCEDURE p_mc_disciplina_modalidade_incluir(
p_vt_mc_disciplina_modalidade IN OUT pk_fat_mc_plt.ar_mc_disciplina_modalidade,
p_id_mc_disciplina IN ca.fat_mc_aluno.id_mc_aluno%type,
p_cd_disciplina IN ca.fat_mc_disciplina.cd_disciplina%type,
p_fg_retorno OUT varchar2,
p_ds_retorno OUT varchar2
);
--
PROCEDURE p_mc_modalidade_competencia_incluir(
p_rec_mc_aluno IN ca.pk_fat_mc_plt.rec_mc_aluno,
p_rec_financeiro IN ca.pk_fat_mc_plt.rec_financeiro,
p_vt_modalidade_competencia_aux IN OUT nocopy ca.pk_fat_mc_plt.vt_modalidade_competencia,
p_fg_retorno OUT varchar2,
p_ds_retorno OUT varchar2
);
--
PROCEDURE p_mc_titulo_incluir(
p_rec_mc_aluno IN ca.pk_fat_mc_plt.rec_mc_aluno,
p_reg_ctr_titulo IN ca.ctr_titulo%rowtype,
p_id_academico_titulo IN number,
p_id_mc_titulo OUT ca.fat_mc_titulo.id_mc_titulo%type,
p_fg_retorno OUT varchar2,
p_ds_retorno OUT varchar2
);
--
PROCEDURE p_mc_titulo_modalidade_incluir(
p_rec_mc_aluno IN ca.pk_fat_mc_plt.rec_mc_aluno,
p_vt_titulo_modalidade_aux IN ca.pk_fat_mc_plt.vt_titulo_modalidade,
p_nr_competencia IN number,
p_id_mc_titulo IN ca.fat_mc_titulo.id_mc_titulo%type,
p_fg_retorno OUT varchar2,
p_ds_retorno OUT varchar2
);
--
PROCEDURE p_mc_valor_competencia_incluir(
p_rec_financeiro IN OUT nocopy ca.pk_fat_mc_plt.rec_financeiro,
p_rec_mc_aluno IN ca.pk_fat_mc_plt.rec_mc_aluno,
p_fg_retorno OUT varchar2,
p_ds_retorno OUT varchar2
);
--
PROCEDURE p_memoria_calculo_gr(
p_tp_operacao IN varchar2,
p_fg_exibir IN varchar2 default 'N',
p_rec_mc_aluno IN OUT nocopy ca.pk_fat_mc_plt.rec_mc_aluno,
p_vt_mc_disciplina IN OUT nocopy ca.pk_fat_mc_plt.ar_mc_disciplina,
p_vt_regra_academica IN ca.pk_fat_mc_plt.ar_mc_regra_academica,
p_vt_titulo_gerado OUT nocopy ca.pk_fat_mc_plt.ar_mc_titulo,
p_modalidades in CA.PK_FAT_MC_PLT.vt_financeiro_modalidade,
p_fg_retorno OUT varchar2,
p_ds_retorno OUT clob,
p_dt_processamento IN date default sysdate
);
--
PROCEDURE p_memoria_calculo_pg(
p_tp_operacao IN varchar2,
p_fg_exibir IN varchar2 default 'N',
p_dt_vencto_1a_mensalidade IN date,
p_rec_aluno_pg IN OUT nocopy ca.pk_fat_mc_plt.rec_mc_aluno_pg,
p_array_mensalidade_pg IN ca.pk_fat_mc_plt.ar_mensalidade_pg,
p_fg_retorno OUT varchar2,
p_ds_retorno OUT varchar2
);
--
PROCEDURE p_montar_vt_financeiro_modalidade_aux(
p_rec_financeiro IN ca.pk_fat_mc_plt.rec_financeiro,
p_vt_financeiro_modalidade_aux OUT ca.pk_fat_mc_plt.vt_fin_modalidade_aux
);
--
PROCEDURE p_montar_vt_modalidade_competencia_aux(
p_rec_financeiro IN ca.pk_fat_mc_plt.rec_financeiro,
p_vt_modalidade_competencia_aux OUT ca.pk_fat_mc_plt.vt_modalidade_competencia
);
--
PROCEDURE p_montar_vt_titulos_aux(
p_rec_financeiro IN ca.pk_fat_mc_plt.rec_financeiro,
p_fg_titulo_preservado IN varchar2,
p_dt_vencimento_titulo_oferta in date default null,
p_vt_titulos_aux OUT ca.pk_fat_mc_plt.vt_titulo_aux
);
--
PROCEDURE p_montar_vt_titulos_modalidade_aux(
p_rec_financeiro IN ca.pk_fat_mc_plt.rec_financeiro,
p_ind_titulo IN number,
p_vt_titulos_modalidade_aux in OUT nocopy ca.pk_fat_mc_plt.vt_titulo_modalidade
);
--
PROCEDURE p_ordenar_apresentacao_disciplinas(
p_vt_mc_disciplina IN OUT nocopy ca.pk_fat_mc_plt.ar_mc_disciplina);
--
PROCEDURE p_percentual_fator_limite(
p_rec_mc_aluno IN OUT nocopy ca.pk_fat_mc_plt.rec_mc_aluno,
p_rec_financeiro IN ca.pk_fat_mc_plt.rec_financeiro,
p_vl_limite IN OUT number,
p_pc_fator_limite IN OUT number
);
--
PROCEDURE p_persistir_financeiro(
p_rec_mc_aluno IN ca.pk_fat_mc_plt.rec_mc_aluno,
p_rec_financeiro IN ca.pk_fat_mc_plt.rec_financeiro,
p_fg_retorno OUT varchar2,
p_ds_retorno OUT varchar2
);
--
PROCEDURE p_popular_financeiro_vetor_mc_aluno(
p_rec_mc_aluno IN OUT nocopy ca.pk_fat_mc_plt.rec_mc_aluno,
p_fg_retorno OUT varchar2,
p_ds_retorno OUT varchar2
);
--
PROCEDURE p_titulo_persistir(
p_tp_operacao IN varchar2,
p_rec_mc_aluno IN ca.pk_fat_mc_plt.rec_mc_aluno,
p_vt_titulos_aux IN OUT nocopy ca.pk_fat_mc_plt.vt_titulo_aux,
p_vt_titulo_modalidade_aux IN OUT nocopy ca.pk_fat_mc_plt.vt_titulo_modalidade,
p_fl_exibir IN varchar2,
p_id_pessoa_aluno IN ca.cp_pessoa.id_pessoa%type,
p_rec_financeiro IN OUT nocopy ca.pk_fat_mc_plt.rec_financeiro,
p_qt_titulos_por_competencia_modalidade IN number,
p_dt_processamento IN date,
p_dt_primeira_mensalidade_pg IN date,
p_fg_retorno OUT varchar2,
p_ds_retorno OUT varchar2
);
--
PROCEDURE p_titulo_preservar_cancelar(
p_rec_mc_aluno IN OUT ca.pk_fat_mc_plt.rec_mc_aluno,
p_rec_financeiro IN OUT ca.pk_fat_mc_plt.rec_financeiro,
p_dt_processamento IN date,
p_fg_retorno OUT varchar2,
p_ds_retorno OUT varchar2
);
--
PROCEDURE p_validar_dados(
p_rec_mc_aluno IN OUT nocopy ca.pk_fat_mc_plt.rec_mc_aluno,
p_vt_mc_disciplina IN OUT nocopy ca.pk_fat_mc_plt.ar_mc_disciplina,
p_fg_retorno OUT varchar2,
p_ds_retorno OUT varchar2
);
--
PROCEDURE p_valor_habilitacao_aluno(
p_rec_mc_aluno IN OUT nocopy ca.pk_fat_mc_plt.rec_mc_aluno,
p_vt_mc_disciplina IN OUT nocopy ca.pk_fat_mc_plt.ar_mc_disciplina,
p_fg_exibir IN varchar2,
p_index IN number,
p_fg_retorno OUT varchar2,
p_ds_retorno OUT varchar2
);
--
PROCEDURE p_valor_habilitacao_oferta(
p_rec_mc_aluno IN OUT nocopy ca.pk_fat_mc_plt.rec_mc_aluno,
p_vt_mc_disciplina IN OUT nocopy ca.pk_fat_mc_plt.ar_mc_disciplina,
p_fg_exibir IN varchar2,
p_index IN number,
p_fg_retorno OUT varchar2,
p_ds_retorno OUT varchar2
);
--
PROCEDURE p_valor_mensalista_sem_onus(
p_rec_mc_aluno IN OUT nocopy ca.pk_fat_mc_plt.rec_mc_aluno,
p_vt_mc_disciplina IN OUT nocopy ca.pk_fat_mc_plt.ar_mc_disciplina,
p_fg_exibir IN varchar2,
p_index IN number,
p_fg_retorno OUT varchar2,
p_ds_retorno OUT varchar2
);
--
PROCEDURE p_valor_mensalidade(
p_rec_mc_aluno IN OUT nocopy ca.pk_fat_mc_plt.rec_mc_aluno,
p_vt_mc_disciplina IN OUT nocopy ca.pk_fat_mc_plt.ar_mc_disciplina,
p_fg_exibir IN varchar2,
p_index IN number,
p_nr_carga_horaria_total IN number,
p_index_ultima_disciplina_padrao IN number,
p_nr_acumulado_unidades IN OUT nocopy number,
p_fg_retorno OUT varchar2,
p_ds_retorno OUT varchar2
);
--
PROCEDURE p_mc_persistir_tabela_gr(
p_tp_operacao IN varchar2,
p_rec_mc_aluno IN OUT nocopy ca.pk_fat_mc_plt.rec_mc_aluno,
p_vt_mc_disciplina IN OUT nocopy ca.pk_fat_mc_plt.ar_mc_disciplina,
p_vt_mc_disciplina_modalidade OUT nocopy ca.pk_fat_mc_plt.ar_mc_disciplina_modalidade,
p_rec_financeiro IN OUT nocopy ca.pk_fat_mc_plt.rec_financeiro,
p_vt_titulos_aux IN OUT nocopy ca.pk_fat_mc_plt.vt_titulo_aux,
p_vt_titulos_modalidade_aux IN OUT nocopy ca.pk_fat_mc_plt.vt_titulo_modalidade,
p_vt_modalidade_competencia_aux IN OUT nocopy ca.pk_fat_mc_plt.vt_modalidade_competencia,
p_qt_titulos_por_competencia_modalidade IN number,
p_fg_exibir IN varchar2,
p_fg_titulo_oferta IN varchar2,
p_dt_processamento IN date,
p_fg_retorno OUT varchar2,
p_ds_retorno OUT varchar2
);
--
PROCEDURE p_mc_modalidade_regra_incluir(
p_id_mc_aluno IN ca.fat_mc_aluno.id_mc_aluno%type,
p_rec_financeiro IN ca.pk_fat_mc_plt.rec_financeiro,
p_fg_retorno OUT varchar,
p_ds_retorno OUT varchar2
);
--
PROCEDURE p_calculo
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
, p_qt_titulos_por_competencia_modalidade in out    number  
, p_vt_mensalidade_pg             in            ca.pk_fat_mc_plt.ar_mensalidade_pg     
, p_vt_regra_academica            in            ca.pk_fat_mc_plt.ar_mc_regra_academica 
, p_tp_operacao                   in            varchar2  
, p_fg_exibir                     in            varchar2  
, p_fg_titulo_oferta              in            varchar2 
, p_dt_processamento              in            date
, p_dt_vencimento_titulo_oferta   in            date default null
, p_fg_retorno                    out           varchar2
, p_ds_retorno                    out           varchar2
);
--
PROCEDURE p_distribuir_semestre_competencia(
p_rec_financeiro IN OUT nocopy ca.pk_fat_mc_plt.rec_financeiro,
p_rec_mc_aluno IN ca.pk_fat_mc_plt.rec_mc_aluno,
p_vt_titulos_preservados_aux IN ca.pk_fat_mc_plt.vt_titulo_aux,
p_vt_mensalidade_pg IN ca.pk_fat_mc_plt.ar_mensalidade_pg
);
--
FUNCTION f_modalidades_homologadas(
p_id_nome_parametro IN ca.fat_nome_modalidade.id_nome_parametro%type,
p_id_academico IN ca.fat_academico.id_academico%type,
p_tp_arquivo IN number
)
RETURN varchar2;
-- Assinatura 2
PROCEDURE p_indice_financeiro(
p_id_academico IN number,
p_nr_matricula IN number,
p_dt_referencia IN date,
p_vl_indice OUT number,
p_un_financeiro OUT number,
p_vl_financeiro OUT number,
p_tp_indice OUT number,
p_id_valor_indice OUT number,
p_id_academico_tabela_preco OUT number
);
--
PROCEDURE p_buscar_informacoes(
p_rec_mc_aluno IN OUT nocopy pk_fat_mc_plt.rec_mc_aluno,
p_vt_mc_disciplina IN OUT nocopy pk_fat_mc_plt.ar_mc_disciplina,
p_dt_processamento IN date,
p_fg_retorno OUT varchar2,
p_ds_retorno OUT varchar2
);
--
PROCEDURE p_processar(
p_rec_mc_aluno IN OUT nocopy ca.pk_fat_mc_plt.rec_mc_aluno,
p_vt_mc_disciplina IN OUT nocopy ca.pk_fat_mc_plt.ar_mc_disciplina,
p_vt_mc_disciplina_modalidade IN OUT nocopy ca.pk_fat_mc_plt.ar_mc_disciplina_modalidade,
p_dt_processamento IN date,
p_fg_exibir IN varchar2,
p_fg_retorno OUT varchar2,
p_ds_retorno OUT varchar2
);
--
PROCEDURE p_mc_criticar(
p_rec_mc_aluno IN OUT nocopy ca.pk_fat_mc_plt.rec_mc_aluno,
p_vt_mc_disciplina IN OUT nocopy pk_fat_mc_plt.ar_mc_disciplina,
p_array_regra IN OUT nocopy ca.pk_fat_mc_plt.ar_mc_modalidade_regra,
p_dt_processamento IN date,
p_fg_retorno OUT varchar2,
p_ds_retorno OUT varchar2
);
-- Assinatura 1
PROCEDURE p_indice_financeiro(
p_id_academico IN number,
p_tp_indice IN number,
p_dt_referencia IN date,
p_vl_indice OUT number,
p_id_valor_indice OUT number,
p_id_academico_tabela_preco OUT number
);
--
function f_indice_financeiro( p_tipo_retorno         in  number 
, p_id_academico         in  number
, p_nr_matricula         in  number   )
return number;
--
FUNCTION f_check_modalidade_permitida(
p_id_nome_parametro IN ca.fat_nome_modalidade.id_nome_parametro%type,
p_id_modalidade IN ca.fat_modalidade.id_modalidade%type
)
RETURN varchar2;
--
--
PROCEDURE p_complementar_dados 
( p_rec_mc_aluno in out nocopy ca.pk_fat_mc_plt.rec_mc_aluno );
--
end;