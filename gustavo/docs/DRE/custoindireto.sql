
PROCEDURE P_APURA_CUSTO_SISPRO (p_nr_ano in ca.dre_vl_apropriacao_direta.nr_ano%type,
                                p_nr_mes in ca.dre_vl_apropriacao_direta.nr_mes%type,
                                p_cd_estabelecimento in ca.dre_controle_execucao.cd_estabelecimento%type,
                                p_nr_registro in ca.dre_controle_execucao.nr_registro%type) IS

    -- Apura custo nas grades de verba e cria vl_aproplicacao_indireta
    v_dt_folha                    DATE;
    v_cd_professor                VARCHAR2 (7)    := NULL;
    v_mensagem                    VARCHAR2 (1000) := NULL;
    v_nr_ano                      VARCHAR2 (4)    := NULL;
    v_nr_ano_ebs                  VARCHAR2 (2)    := NULL;
    v_nr_mes_ebs                  VARCHAR2 (2)    := NULL;
    v_qtd_linhas                  NUMBER   (6)    := 0;
    v_vl_apropriacao              NUMBER   (15,2) := 0;
    v_vl_docencia                 NUMBER   (15,2) := 0;
    v_vl_docencia_pos             NUMBER   (15,2) := 0;
    v_vl_adm                      NUMBER   (15,2) := 0;
    v_vl_disciplina_turma         NUMBER   (15,2) := 0;
    v_id_grade_alocacao_docente   NUMBER   (8)    := 0;
    v_id_estrutura_org_ex         NUMBER   (8)    := 0;
    v_id_plano_de_contas          NUMBER   (8)    := 0;
    v_id_grade_verbas             NUMBER   (8)    := 0;
    v_cd_disciplina               VARCHAR2 (4)    := NULL;
    v_cd_turma                    NUMBER   (2)    := 0;
    v_cd_curso                    NUMBER   (4)    := 0;
    v_cd_centro_custo_ebs         VARCHAR2 (30)   := NULL;
    v_qtd_disc                    NUMBER   (6)    := 0;
    v_qtd_mat                     NUMBER   (6)    := 0;
    v_qtd_mem                     NUMBER   (6)    := 0;
    v_qtd_adm                     NUMBER   (6)    := 0;
    v_id_vl_apropriacao_indireta  NUMBER   (8)    := 0;
    v_id_vl_apropriacao_ind_ex    NUMBER   (8)    := 0;
    v_vl_custo_ex                 NUMBER   (15,2) := 0;
    p_id_plano_execucao           NUMBER   (8)    := 0;
    p_id_controle_execucao        NUMBER   (8)    := 0;
    p_ds_msg                      VARCHAR2 (500)  := NULL;
    p_tp_mensagem                 VARCHAR2 (1)    := NULL;
    p_status                      VARCHAR2 (1)    := NULL;

    v_cd_indicador_un_negocio     NUMBER   (3)    := 0;
    v_tp_conta                    NUMBER   (1)    := 0;

    cursor c_apura_custo is
           select v.cd_professor,v.cd_estabelecimento,v.nr_registro,
                 (sum(decode(vf.tipo_lancto,'DB',vf.valor,0)) - sum(decode(vf.tipo_lancto,'CR',vf.valor,0))) vl_custo
             from ca.ebs_fp_verbas_funcionarios vf,
                  ca.dre_grade_verbas v
            where vf.competencia = v_dt_folha
              and ((vf.cta_contabil like '5201%') or (vf.cta_contabil like '6201%') or (vf.cta_contabil like '6401%'))
              and vf.competencia = v.dt_folha
              and to_number(trim(vf.estb)) = v.cd_estabelecimento
              and to_number(trim(vf.matricula)) = v.nr_registro
              --and v.id_grade_verbas = 2374
         group by v.cd_professor,v.cd_estabelecimento,v.nr_registro
         order by v.cd_professor,v.cd_estabelecimento,v.nr_registro;


    cursor c_calcula_custo is
            select id_grade_verbas, dt_folha, cd_professor, vl_docencia, vl_percentual_docencia, vl_adm, vl_percentual_adm,
                   vl_pos, vl_percentual_pos, vl_custo, cd_estabelecimento, nr_registro,
                   --to_char(nr_registro,'0000000') nr_registro,
                   fl_n_disc, fl_n_mat, fl_n_mem, fl_n_adm
              from ca.dre_grade_verbas v
             where v.dt_folha = v_dt_folha
          order by v.id_grade_verbas;

    cursor c_grade_alocacao_docente is
           select *
             from ca.dre_grade_alocacao_docente
            where dt_folha = v_dt_folha
              and trim(cd_professor) = trim(v_cd_professor);

    cursor c_grade_disciplina_turma is
           select *
             from ca.dre_grade_disciplina_turma
            where dt_folha = v_dt_folha
              and trim(cd_disciplina) = trim(v_cd_disciplina)
              and trim(cd_turma) = trim(v_cd_turma)
              and id_grade_alocacao_docente is not null
              and id_grade_alocacao_docente = v_id_grade_alocacao_docente;
              --and trim(cd_curso) = trim(v_cd_curso)

    cursor c_grade_verbas_pos is
           select *
             from ca.dre_grade_verbas_pos
            where id_grade_verbas = v_id_grade_verbas
           order by id_grade_verbas;

    cursor c_grade_verbas_adm is
           select *
             from ca.dre_grade_verbas_adm
            where id_grade_verbas = v_id_grade_verbas
         order by id_grade_verbas;

    cac             c_apura_custo%ROWTYPE;
    ccc             c_calcula_custo%ROWTYPE;
    gad             c_grade_alocacao_docente%ROWTYPE;
    gdt             c_grade_disciplina_turma%ROWTYPE;
    gvp             c_grade_verbas_pos%ROWTYPE;
    gva             c_grade_verbas_adm%ROWTYPE;
   -- cta             c_tecnico_adm%ROWTYPE;

BEGIN

    -- Busca código do plano de execução --
    select id_plano_execucao
      into p_id_plano_execucao
      from ca.dre_plano_execucao
     where nm_procedure = 'P_APURA_CUSTO_SISPRO';


    s_DRE_ANALISE_GERENCIAL.P_INICIO_EXECUCAO_DRE (p_nr_ano,
                                                   p_nr_mes,
                                                   p_id_plano_execucao,
                                                   p_cd_estabelecimento,
                                                   p_nr_registro,
                                                   p_id_controle_execucao);


    p_status := 1;

    v_nr_ano     := trim(to_char(p_nr_ano,'9999'));
    v_nr_ano_ebs := substr(v_nr_ano,3,2);
    v_nr_mes_ebs := trim(to_char(p_nr_mes,'00'));
    v_dt_folha := To_Date( '01/' ||v_nr_mes_ebs||'/'||v_nr_ano_ebs,'dd/mm/yy') ;

    v_qtd_linhas := 0;

    p_ds_msg := 'Apura custo no Sispro e atualiza tabela de grade de verbas.';
    p_tp_mensagem := 'A';
    s_DRE_ANALISE_GERENCIAL.P_LOG_EXECUCAO_DRE (p_id_controle_execucao,p_ds_msg,p_tp_mensagem);


    -- Apura custo no Sispro e atualiza tabela de grade de verbas.

    OPEN c_apura_custo;

    LOOP
        FETCH c_apura_custo INTO cac;

        EXIT WHEN c_apura_custo%NOTFOUND;

        IF c_apura_custo%FOUND THEN
           v_id_grade_verbas := 0;
           BEGIN
               -- Verificar código na grade de verbas
               select id_grade_verbas
                 into v_id_grade_verbas
                 from ca.dre_grade_verbas
                where dt_folha = v_dt_folha
                  and cd_estabelecimento = cac.cd_estabelecimento
                  and nr_registro = cac.nr_registro;
           EXCEPTION
                 when no_data_found then
                      BEGIN
                          v_qtd_linhas := v_qtd_linhas + 1;
                          INSERT INTO ca.dre_grade_verbas
                                      (ID_GRADE_VERBAS,
                                       DT_FOLHA,
                                       CD_PROFESSOR,
                                       VL_DOCENCIA,
                                       VL_PERCENTUAL_DOCENCIA,
                                       VL_ADM,
                                       VL_PERCENTUAL_ADM,
                                       VL_POS,
                                       VL_PERCENTUAL_POS,
                                       VL_CUSTO,
                                       CD_ESTABELECIMENTO,
                                       NR_REGISTRO
                                      )
                               VALUES (ca.sq_dre_grade_verbas.nextval,
                                       v_dt_folha,
                                       cac.cd_professor,
                                       0,
                                       0,
                                       0,
                                       0,
                                       0,
                                       0,
                                       cac.vl_custo,
                                       cac.cd_estabelecimento,
                                       cac.nr_registro
                                      );

                      EXCEPTION
                            WHEN OTHERS THEN
                                 p_ds_msg := 'Mensagem: ' || sqlerrm;
                                 p_tp_mensagem := 'A';
                                 --p_status := 2;
                                 s_DRE_ANALISE_GERENCIAL.P_LOG_EXECUCAO_DRE (p_id_controle_execucao,p_ds_msg,p_tp_mensagem);
                      END;
           END;

           IF (v_id_grade_verbas <> 0) THEN
               BEGIN
                   update ca.dre_grade_verbas
                      set vl_custo = cac.vl_custo
                    where id_grade_verbas  = v_id_grade_verbas;
                    v_qtd_linhas := v_qtd_linhas + 1;
               EXCEPTION
                  WHEN OTHERS THEN
                       p_ds_msg := 'Mensagem: ' || sqlerrm;
                       p_tp_mensagem := 'A';
                       --p_status := 2;
                       s_DRE_ANALISE_GERENCIAL.P_LOG_EXECUCAO_DRE (p_id_controle_execucao,p_ds_msg,p_tp_mensagem);
               END;

               -- Tratamento para dois casos que estão na grade com custo e sem valores na docência, adm e pós.
               BEGIN
                   update ca.dre_grade_verbas
                      set vl_adm = cac.vl_custo
                    where id_grade_verbas  = v_id_grade_verbas
                      and vl_custo <> 0
                      and vl_docencia = 0
                      and vl_adm = 0
                      and vl_pos = 0
                      and vl_percentual_adm <> 0;
                    v_qtd_linhas := v_qtd_linhas + 1;
               EXCEPTION
                  WHEN OTHERS THEN
                       p_ds_msg := 'Mensagem: ' || sqlerrm;
                       p_tp_mensagem := 'A';
                       --p_status := 2;
                       s_DRE_ANALISE_GERENCIAL.P_LOG_EXECUCAO_DRE (p_id_controle_execucao,p_ds_msg,p_tp_mensagem);
               END;

           END IF;
        END IF;
    END LOOP;
    CLOSE c_apura_custo;
    commit;

    IF v_qtd_linhas = 0 THEN
       v_mensagem := sqlerrm;
       p_ds_msg := 'Não foi realizada atualização na DRE_GRADE_VERBAS do ano ' || p_nr_ano ||
                            ' mês ' || p_nr_mes || '. Mensagem: ' || v_mensagem;
       p_tp_mensagem := 'A';
       s_DRE_ANALISE_GERENCIAL.P_LOG_EXECUCAO_DRE (p_id_controle_execucao,p_ds_msg,p_tp_mensagem);
    ELSE
       v_mensagem := v_qtd_linhas;
       p_ds_msg := 'Total de linhas alteradas na tabela DRE_GRADE_VERBAS ' || v_mensagem;
       p_tp_mensagem := 'A';
       s_DRE_ANALISE_GERENCIAL.P_LOG_EXECUCAO_DRE (p_id_controle_execucao,p_ds_msg,p_tp_mensagem);
    END IF;

    v_qtd_linhas := 0;

    p_ds_msg := 'Calcula custo e atualiza tabela de apropriação indireta.';
    p_tp_mensagem := 'A';
    s_DRE_ANALISE_GERENCIAL.P_LOG_EXECUCAO_DRE (p_id_controle_execucao,p_ds_msg,p_tp_mensagem);


    -- Calcula custo e atualiza tabela de apropriação indireta.

    -- Zerar flags --
    BEGIN
        update ca.dre_grade_verbas
           set fl_n_disc = 0,
               fl_n_mat = 0,
               fl_n_mem = 0,
               fl_n_adm = 0
         where dt_folha = v_dt_folha;
    EXCEPTION
          WHEN OTHERS THEN
               p_ds_msg := 'Mensagem: ' || sqlerrm;
               p_tp_mensagem := 'A';
               --p_status := 2;
               s_DRE_ANALISE_GERENCIAL.P_LOG_EXECUCAO_DRE (p_id_controle_execucao,p_ds_msg,p_tp_mensagem);
    END;
    commit;
    -- Zerar vl_custo na grade de verbas pós --
    BEGIN
        update ca.dre_grade_verbas_pos p
           set vl_custo = 0, id_vl_apropriacao_indireta = null
         where exists (select 1
                         from ca.dre_grade_verbas v
                        where v.dt_folha = v_dt_folha
                          and v.id_grade_verbas = p.id_grade_verbas);
    EXCEPTION
          WHEN OTHERS THEN
               p_ds_msg := 'Mensagem: ' || sqlerrm;
               p_tp_mensagem := 'A';
               --p_status := 2;
               s_DRE_ANALISE_GERENCIAL.P_LOG_EXECUCAO_DRE (p_id_controle_execucao,p_ds_msg,p_tp_mensagem);
    END;
    commit;
    -- Zerar vl_custo na grade de verbas adm --
    BEGIN
        update ca.dre_grade_verbas_adm a
           set vl_custo = 0, id_vl_apropriacao_indireta = null
         where exists (select 1
                         from ca.dre_grade_verbas v
                        where v.dt_folha = v_dt_folha
                          and v.id_grade_verbas = a.id_grade_verbas);
    EXCEPTION
          WHEN OTHERS THEN
               p_ds_msg := 'Mensagem: ' || sqlerrm;
               p_tp_mensagem := 'A';
               --p_status := 2;
               s_DRE_ANALISE_GERENCIAL.P_LOG_EXECUCAO_DRE (p_id_controle_execucao,p_ds_msg,p_tp_mensagem);
    END;
    commit;
    -- Zerar vl_custo na grade alocação docente --
    BEGIN
        update ca.dre_grade_alocacao_docente
           set vl_custo = 0, id_vl_apropriacao_indireta = null
         where dt_folha = v_dt_folha;
    EXCEPTION
          WHEN OTHERS THEN
               p_ds_msg := 'Mensagem: ' || sqlerrm;
               p_tp_mensagem := 'A';
               --p_status := 2;
               s_DRE_ANALISE_GERENCIAL.P_LOG_EXECUCAO_DRE (p_id_controle_execucao,p_ds_msg,p_tp_mensagem);
    END;
    commit;
    -- Zerar vl_custo na grade disciplina turma --
    BEGIN
        update ca.dre_grade_disciplina_turma
           set vl_custo = 0, id_vl_apropriacao_indireta = null
         where dt_folha = v_dt_folha;
    EXCEPTION
          WHEN OTHERS THEN
               p_ds_msg := 'Mensagem: ' || sqlerrm;
               p_tp_mensagem := 'A';
               --p_status := 2;
               s_DRE_ANALISE_GERENCIAL.P_LOG_EXECUCAO_DRE (p_id_controle_execucao,p_ds_msg,p_tp_mensagem);
    END;
    commit;
    OPEN c_calcula_custo;

    LOOP
        FETCH c_calcula_custo INTO ccc;

        EXIT WHEN c_calcula_custo%NOTFOUND;

        IF c_calcula_custo%FOUND THEN
           -- Graduação --
           IF (ccc.vl_percentual_docencia <> 0) THEN
               v_vl_docencia := ccc.vl_custo * ccc.vl_percentual_docencia / 100;
               v_cd_professor := ccc.cd_professor;

               v_qtd_disc := 0;
               -- Para cada disciplina turma do docente --
               OPEN c_grade_alocacao_docente;

               LOOP
                  FETCH c_grade_alocacao_docente INTO gad;

                  EXIT WHEN c_grade_alocacao_docente%NOTFOUND;

                  IF c_grade_alocacao_docente%FOUND THEN
                     v_qtd_disc := v_qtd_disc + 1;
                     v_qtd_mat := 0;
                     -- Para cada disciplina turma
                     v_vl_disciplina_turma := v_vl_docencia * gad.vl_percentual / 100;

                     v_cd_disciplina := gad.cd_disciplina;
                     v_cd_turma := gad.cd_turma;
                     v_id_grade_alocacao_docente := gad.id_grade_alocacao_docente;

                     OPEN c_grade_disciplina_turma;

                     LOOP
                        --v_cd_disciplina := gad.cd_disciplina;
                        --v_cd_turma := gad.cd_turma;
                        ----v_cd_curso := gad.cd_curso;
                        ----v_id_grade_alocacao_docente := gad.id_grade_alocacao_docente;

                        FETCH c_grade_disciplina_turma INTO gdt;

                        EXIT WHEN c_grade_disciplina_turma%NOTFOUND;

                        IF c_grade_disciplina_turma%FOUND THEN
                           v_qtd_mat := v_qtd_mat + 1;
                           -- Verifica centro de custo do curso
                           BEGIN
                               v_cd_centro_custo_ebs := '';
                               select cd_centro_custo_ebs
                                 into v_cd_centro_custo_ebs
                                 from ca.curso cur,
                                      al.centro_custo cc
                                where cur.cd_curso = gdt.cd_curso
                                  and cc.cd_centro_custo = cur.cd_centro_custo;
                           EXCEPTION
                                when no_data_found then
                                     v_mensagem := gdt.cd_curso;
                                     p_ds_msg := 'Curso não encontrado: ' || v_mensagem;
                                     p_tp_mensagem := 'A';
                                     s_DRE_ANALISE_GERENCIAL.P_LOG_EXECUCAO_DRE (p_id_controle_execucao,p_ds_msg,p_tp_mensagem);
                           END;

                           -- Para cada curso
                           -- Localizar parâmetro de conversão do centro de custo do curso de graduação na tabela CA.DRE_ESTRUTURA_ORG_EX
                           BEGIN
                               select eo.id_estrutura_org_ex
                                 into v_id_estrutura_org_ex
                                 from ca.dre_estrutura_org_ex eo,
                                      ca.dre_estrutura_org_itens_ex eoi
                                where eo.nr_ano = p_nr_ano
                                  and eo.nr_mes = p_nr_mes
                                  and eoi.id_estrutura_org_ex = eo.id_estrutura_org_ex
                                  and trim(eoi.cd_centro_custo_ebs) = trim(v_cd_centro_custo_ebs);
                           EXCEPTION
                                when no_data_found then
                                     v_mensagem := v_cd_centro_custo_ebs;
                                     p_ds_msg := 'Centro de Custo não esta cadastrado no organograma: ' || v_mensagem;
                                     p_tp_mensagem := 'A';
                                     s_DRE_ANALISE_GERENCIAL.P_LOG_EXECUCAO_DRE (p_id_controle_execucao,p_ds_msg,p_tp_mensagem);
                           END;

                           -- Localizar conta de custos na tabela CA.DRE_PLANO_DE_CONTAS
                           BEGIN
                               select id_plano_de_contas
                                 into v_id_plano_de_contas
                                 from ca.dre_plano_de_contas
                                where tp_conta = 1;
                           EXCEPTION
                                when no_data_found then
                                     p_ds_msg := 'Conta de custo não existe no plano de contas: ' || sqlerrm;
                                     p_tp_mensagem := 'A';
                                     --p_status := 2;
                                     s_DRE_ANALISE_GERENCIAL.P_LOG_EXECUCAO_DRE (p_id_controle_execucao,p_ds_msg,p_tp_mensagem);
                           END;

                           v_vl_apropriacao := v_vl_disciplina_turma * gdt.vl_percentual / 100;

                           v_id_vl_apropriacao_indireta := 0;
                           BEGIN
                              v_qtd_linhas := v_qtd_linhas + 1;
                              v_id_vl_apropriacao_indireta := ca.sq_dre_vl_apropriacao_indireta.nextval;
                              INSERT INTO ca.dre_vl_apropriacao_indireta
                                          (ID_VL_APROPRIACAO_INDIRETA,
                                           NR_ANO,
                                           NR_MES,
                                           ID_PLANO_CONTAS,
                                           ID_ESTRUTURA_ORG_EX,
                                           VL_APROPRIACAO,
                                           CD_CENTRO_CUSTO_ORIGEM,
                                           TP_ORIGEM,
                                           ID_GRADE_VERBAS
                                          )
                                   VALUES (v_id_vl_apropriacao_indireta,
                                           p_nr_ano,
                                           p_nr_mes,
                                           v_id_plano_de_contas,
                                           v_id_estrutura_org_ex,
                                           v_vl_apropriacao * -1,
                                           v_cd_centro_custo_ebs,
                                           3,
                                           ccc.id_grade_verbas
                                           );
                           EXCEPTION
                              WHEN OTHERS THEN
                                   p_ds_msg := 'Mensagem: ' || sqlerrm;
                                   p_tp_mensagem := 'A';
                                   --p_status := 2;
                                   s_DRE_ANALISE_GERENCIAL.P_LOG_EXECUCAO_DRE (p_id_controle_execucao,p_ds_msg,p_tp_mensagem);
                           END;

                           -- Atualização da Grade de Disciplina Turma --
                           v_id_vl_apropriacao_ind_ex := 0;
                           v_vl_custo_ex := 0;
                           BEGIN
                              select id_vl_apropriacao_indireta, vl_custo
                                into v_id_vl_apropriacao_ind_ex, v_vl_custo_ex
                                from ca.dre_grade_disciplina_turma
                               where id_grade_disciplina_turma = gdt.id_grade_disciplina_turma;
                                 --and vl_custo <> 0
                                 --and id_vl_apropriacao_indireta is not null;
                           EXCEPTION
                              WHEN OTHERS THEN
                                   p_ds_msg := 'Mensagem: ' || sqlerrm;
                                   p_tp_mensagem := 'A';
                                   --p_status := 2;
                                   s_DRE_ANALISE_GERENCIAL.P_LOG_EXECUCAO_DRE (p_id_controle_execucao,p_ds_msg,p_tp_mensagem);
                           END;

                           IF (v_id_vl_apropriacao_ind_ex <> 0 and v_vl_custo_ex <> 0) THEN

                               p_ds_msg := 'Apropriação Indireta: ' || v_id_vl_apropriacao_ind_ex ||
                                           ' - Vl. Custo: ' || v_vl_custo_ex ||
                                           ' Grade de Verbas Disciplina Turma: ' || gdt.id_grade_disciplina_turma;
                               p_tp_mensagem := 'A';
                               s_DRE_ANALISE_GERENCIAL.P_LOG_EXECUCAO_DRE (p_id_controle_execucao,p_ds_msg,p_tp_mensagem);
                           END IF;

                           update ca.dre_grade_disciplina_turma
                              set vl_custo = (nvl(vl_custo,0) + (v_vl_apropriacao * -1)),
                                  id_vl_apropriacao_indireta = v_id_vl_apropriacao_indireta
                            where id_grade_disciplina_turma = gdt.id_grade_disciplina_turma;

                        END IF;
                     END LOOP;
                     CLOSE c_grade_disciplina_turma;

                     -- Se não existir grade disciplina turma
                     IF (v_qtd_mat = 0) THEN
                         -- Verifica centro de custo do curso
                         BEGIN
                             v_cd_centro_custo_ebs := '';
                             select distinct vf.centro_custo
                               into v_cd_centro_custo_ebs
                               from ca.ebs_fp_verbas_funcionarios vf
                              where vf.competencia = v_dt_folha
                                and ((vf.cta_contabil like '5201%') or (vf.cta_contabil like '6201%') or (vf.cta_contabil like '6401%'))
                                and to_number(trim(vf.estb)) = ccc.cd_estabelecimento
                                and to_number(trim(vf.matricula)) = ccc.nr_registro;
                         EXCEPTION
                              when no_data_found then
                                   v_mensagem := ccc.nr_registro;
                                   p_ds_msg := 'Matricula não encontrada: ' || v_mensagem;
                                   p_tp_mensagem := 'A';
                                   s_DRE_ANALISE_GERENCIAL.P_LOG_EXECUCAO_DRE (p_id_controle_execucao,p_ds_msg,p_tp_mensagem);
                         END;

                         -- Para cada curso
                         -- Localizar parâmetro de conversão do centro de custo do curso de graduação na tabela CA.DRE_ESTRUTURA_ORG_EX
                         BEGIN
                             select eo.id_estrutura_org_ex
                               into v_id_estrutura_org_ex
                               from ca.dre_estrutura_org_ex eo,
                                    ca.dre_estrutura_org_itens_ex eoi
                              where eo.nr_ano = p_nr_ano
                                and eo.nr_mes = p_nr_mes
                                and eoi.id_estrutura_org_ex = eo.id_estrutura_org_ex
                                and trim(eoi.cd_centro_custo_ebs) = trim(v_cd_centro_custo_ebs);
                         EXCEPTION
                              when no_data_found then
                                   v_mensagem := v_cd_centro_custo_ebs;
                                   p_ds_msg := 'Centro de Custo não esta cadastrado no organograma: ' || v_mensagem;
                                   p_tp_mensagem := 'A';
                                   s_DRE_ANALISE_GERENCIAL.P_LOG_EXECUCAO_DRE (p_id_controle_execucao,p_ds_msg,p_tp_mensagem);
                         END;

                         -- Localizar conta de custos na tabela CA.DRE_PLANO_DE_CONTAS
                         BEGIN
                             select id_plano_de_contas
                               into v_id_plano_de_contas
                               from ca.dre_plano_de_contas
                              where tp_conta = 1;
                         EXCEPTION
                              when no_data_found then
                                   p_ds_msg := 'Conta de custo não existe no plano de contas: ' || sqlerrm;
                                   p_tp_mensagem := 'A';
                                   --p_status := 2;
                                   s_DRE_ANALISE_GERENCIAL.P_LOG_EXECUCAO_DRE (p_id_controle_execucao,p_ds_msg,p_tp_mensagem);
                         END;

                         v_vl_apropriacao := v_vl_disciplina_turma;

                         v_id_vl_apropriacao_indireta := 0;
                         BEGIN
                            v_qtd_linhas := v_qtd_linhas + 1;
                            v_id_vl_apropriacao_indireta := ca.sq_dre_vl_apropriacao_indireta.nextval;
                            INSERT INTO ca.dre_vl_apropriacao_indireta
                                        (ID_VL_APROPRIACAO_INDIRETA,
                                         NR_ANO,
                                         NR_MES,
                                         ID_PLANO_CONTAS,
                                         ID_ESTRUTURA_ORG_EX,
                                         VL_APROPRIACAO,
                                         CD_CENTRO_CUSTO_ORIGEM,
                                         TP_ORIGEM,
                                         ID_GRADE_VERBAS
                                        )
                                 VALUES (v_id_vl_apropriacao_indireta,
                                         p_nr_ano,
                                         p_nr_mes,
                                         v_id_plano_de_contas,
                                         v_id_estrutura_org_ex,
                                         v_vl_apropriacao * -1,
                                         v_cd_centro_custo_ebs,
                                         2,
                                         ccc.id_grade_verbas
                                         );
                         EXCEPTION
                            WHEN OTHERS THEN
                                 p_ds_msg := 'Mensagem: ' || sqlerrm;
                                 p_tp_mensagem := 'A';
                                 --p_status := 2;
                                 s_DRE_ANALISE_GERENCIAL.P_LOG_EXECUCAO_DRE (p_id_controle_execucao,p_ds_msg,p_tp_mensagem);
                         END;

                         v_id_vl_apropriacao_ind_ex := 0;
                         v_vl_custo_ex := 0;
                         BEGIN
                              select id_vl_apropriacao_indireta, vl_custo
                                into v_id_vl_apropriacao_ind_ex, v_vl_custo_ex
                                from ca.dre_grade_alocacao_docente
                               where id_grade_alocacao_docente = gad.id_grade_alocacao_docente;
                                 --and vl_custo <> 0
                                 --and id_vl_apropriacao_indireta is not null;
                         EXCEPTION
                              WHEN OTHERS THEN
                                   p_ds_msg := 'Mensagem: ' || sqlerrm;
                                   p_tp_mensagem := 'A';
                                   --p_status := 2;
                                   s_DRE_ANALISE_GERENCIAL.P_LOG_EXECUCAO_DRE (p_id_controle_execucao,p_ds_msg,p_tp_mensagem);
                         END;

                         IF (v_id_vl_apropriacao_ind_ex <> 0 and v_vl_custo_ex <> 0) THEN
                             p_ds_msg := 'Apropriação Indireta: ' || v_id_vl_apropriacao_ind_ex ||
                                         ' - Vl. Custo: ' || v_vl_custo_ex ||
                                         ' Grade de Verbas Alocação: ' || gad.id_grade_alocacao_docente;
                             p_tp_mensagem := 'A';
                             s_DRE_ANALISE_GERENCIAL.P_LOG_EXECUCAO_DRE (p_id_controle_execucao,p_ds_msg,p_tp_mensagem);
                         END IF;

                         update ca.dre_grade_verbas
                            set fl_n_mat = 1
                          where id_grade_verbas = ccc.id_grade_verbas;

                         -- Atualização da Grade de Alocação Docente --
                         update ca.dre_grade_alocacao_docente
                            set vl_custo = (nvl(vl_custo,0) + (v_vl_apropriacao * -1)),
                                id_vl_apropriacao_indireta = v_id_vl_apropriacao_indireta
                          where id_grade_alocacao_docente = gad.id_grade_alocacao_docente;

                     END IF;
                 --END IF;
                  END IF;
               END LOOP;
               CLOSE c_grade_alocacao_docente;

               -- Se não existir grade alocação de docente
               IF (v_qtd_disc = 0) THEN
                   -- Verifica centro de custo do curso
                   BEGIN
                       v_cd_centro_custo_ebs := '';
                       select distinct vf.centro_custo
                         into v_cd_centro_custo_ebs
                         from ca.ebs_fp_verbas_funcionarios vf
                        where vf.competencia = v_dt_folha
                          and ((vf.cta_contabil like '5201%') or (vf.cta_contabil like '6201%') or (vf.cta_contabil like '6401%'))
                          and to_number(trim(vf.estb)) = ccc.cd_estabelecimento
                          and to_number(trim(vf.matricula)) = ccc.nr_registro;
                   EXCEPTION
                        when no_data_found then
                             v_mensagem := ccc.nr_registro;
                             p_ds_msg := 'Matricula não encontrada: ' || v_mensagem;
                             p_tp_mensagem := 'A';
                             s_DRE_ANALISE_GERENCIAL.P_LOG_EXECUCAO_DRE (p_id_controle_execucao,p_ds_msg,p_tp_mensagem);
                   END;

                   -- Para cada curso
                   -- Localizar parâmetro de conversão do centro de custo do curso de graduação na tabela CA.DRE_ESTRUTURA_ORG_EX
                   BEGIN
                       select eo.id_estrutura_org_ex
                         into v_id_estrutura_org_ex
                         from ca.dre_estrutura_org_ex eo,
                              ca.dre_estrutura_org_itens_ex eoi
                        where eo.nr_ano = p_nr_ano
                          and eo.nr_mes = p_nr_mes
                          and eoi.id_estrutura_org_ex = eo.id_estrutura_org_ex
                          and trim(eoi.cd_centro_custo_ebs) = trim(v_cd_centro_custo_ebs);
                   EXCEPTION
                        when no_data_found then
                             v_mensagem := v_cd_centro_custo_ebs;
                             p_ds_msg := 'Centro de Custo não esta cadastrado no organograma: ' || v_mensagem;
                             p_tp_mensagem := 'A';
                             s_DRE_ANALISE_GERENCIAL.P_LOG_EXECUCAO_DRE (p_id_controle_execucao,p_ds_msg,p_tp_mensagem);
                   END;

                   -- Localizar conta de custos na tabela CA.DRE_PLANO_DE_CONTAS
                   BEGIN
                       select id_plano_de_contas
                         into v_id_plano_de_contas
                         from ca.dre_plano_de_contas
                        where tp_conta = 1;
                   EXCEPTION
                        when no_data_found then
                             p_ds_msg := 'Conta de custo não existe no plano de contas: ' || sqlerrm;
                             p_tp_mensagem := 'A';
                             --p_status := 2;
                             s_DRE_ANALISE_GERENCIAL.P_LOG_EXECUCAO_DRE (p_id_controle_execucao,p_ds_msg,p_tp_mensagem);
                   END;

                   v_vl_apropriacao := v_vl_docencia;

                   v_id_vl_apropriacao_indireta := 0;
                   BEGIN
                      v_qtd_linhas := v_qtd_linhas + 1;
                      v_id_vl_apropriacao_indireta := ca.sq_dre_vl_apropriacao_indireta.nextval;
                      INSERT INTO ca.dre_vl_apropriacao_indireta
                                  (ID_VL_APROPRIACAO_INDIRETA,
                                   NR_ANO,
                                   NR_MES,
                                   ID_PLANO_CONTAS,
                                   ID_ESTRUTURA_ORG_EX,
                                   VL_APROPRIACAO,
                                   CD_CENTRO_CUSTO_ORIGEM,
                                   TP_ORIGEM,
                                   ID_GRADE_VERBAS
                                  )
                           VALUES (v_id_vl_apropriacao_indireta,
                                   p_nr_ano,
                                   p_nr_mes,
                                   v_id_plano_de_contas,
                                   v_id_estrutura_org_ex,
                                   v_vl_apropriacao * -1,
                                   v_cd_centro_custo_ebs,
                                   1,
                                   ccc.id_grade_verbas
                                   );
                   EXCEPTION
                      WHEN OTHERS THEN
                           p_ds_msg := 'Mensagem: ' || sqlerrm;
                           p_tp_mensagem := 'A';
                           --p_status := 2;
                           s_DRE_ANALISE_GERENCIAL.P_LOG_EXECUCAO_DRE (p_id_controle_execucao,p_ds_msg,p_tp_mensagem);
                   END;

                   v_id_vl_apropriacao_ind_ex := 0;
                   v_vl_custo_ex := 0;
                   BEGIN
                      select id_vl_apropriacao_indireta, vl_custo
                        into v_id_vl_apropriacao_ind_ex, v_vl_custo_ex
                        from ca.dre_grade_verbas
                       where id_grade_verbas = ccc.id_grade_verbas;
                         --and vl_custo <> 0
                         --and id_vl_apropriacao_indireta is not null;
                   EXCEPTION
                      WHEN OTHERS THEN
                           p_ds_msg := 'Mensagem: ' || sqlerrm;
                           p_tp_mensagem := 'A';
                           --p_status := 2;
                           s_DRE_ANALISE_GERENCIAL.P_LOG_EXECUCAO_DRE (p_id_controle_execucao,p_ds_msg,p_tp_mensagem);
                   END;

                   IF (v_id_vl_apropriacao_ind_ex <> 0 and v_vl_custo_ex <> 0) THEN
                       p_ds_msg := 'Apropriação Indireta: ' || v_id_vl_apropriacao_ind_ex ||
                                   ' - Vl. Custo: ' || v_vl_custo_ex ||
                                   ' Grade de Verbas: ' || ccc.id_grade_verbas;
                       p_tp_mensagem := 'A';
                       s_DRE_ANALISE_GERENCIAL.P_LOG_EXECUCAO_DRE (p_id_controle_execucao,p_ds_msg,p_tp_mensagem);
                   END IF;

                   -- Professor não dá nenhuma disciplina
                   update ca.dre_grade_verbas
                      set fl_n_disc = 1,
                          id_vl_apropriacao_indireta = v_id_vl_apropriacao_indireta
                    where id_grade_verbas = ccc.id_grade_verbas;

               END IF;
               commit;
           END IF;

           -- Pós-Graduação --
           IF (ccc.vl_percentual_pos <> 0) THEN
               v_vl_docencia_pos := ccc.vl_custo * ccc.vl_percentual_pos / 100;
               v_id_grade_verbas := ccc.id_grade_verbas;

               v_qtd_mem := 0;
               -- Para cada curso da pós-graduação --
               OPEN c_grade_verbas_pos;

               LOOP
                  FETCH c_grade_verbas_pos INTO gvp;

                  EXIT WHEN c_grade_verbas_pos%NOTFOUND;

                  IF c_grade_verbas_pos%FOUND THEN
                     v_qtd_mem := v_qtd_mem + 1;
                     -- Localizar parâmetro de conversão do centro de custo do curso de graduação na tabela CA.DRE_ESTRUTURA_ORG_EX
                     BEGIN
                         select eo.id_estrutura_org_ex
                           into v_id_estrutura_org_ex
                           from ca.dre_estrutura_org_ex eo,
                                ca.dre_estrutura_org_itens_ex eoi
                          where eo.nr_ano = p_nr_ano
                            and eo.nr_mes = p_nr_mes
                            and eoi.id_estrutura_org_ex = eo.id_estrutura_org_ex
                            and trim(eoi.cd_centro_custo_ebs) = trim(gvp.cd_centro_custo_ebs);
                     EXCEPTION
                          when no_data_found then
                               v_mensagem := gvp.cd_centro_custo_ebs;
                               p_ds_msg := 'Centro de Custo não esta cadastrado no organograma: ' || v_mensagem;
                               p_tp_mensagem := 'A';
                               s_DRE_ANALISE_GERENCIAL.P_LOG_EXECUCAO_DRE (p_id_controle_execucao,p_ds_msg,p_tp_mensagem);
                     END;

                     -- Localizar conta de custos na tabela CA.DRE_PLANO_DE_CONTAS
                     BEGIN
                         select id_plano_de_contas
                           into v_id_plano_de_contas
                           from ca.dre_plano_de_contas
                          where tp_conta = 1;
                     EXCEPTION
                          when no_data_found then
                               p_ds_msg := 'Conta de custo não existe no plano de contas: ' || sqlerrm;
                               p_tp_mensagem := 'A';
                               --p_status := 2;
                               s_DRE_ANALISE_GERENCIAL.P_LOG_EXECUCAO_DRE (p_id_controle_execucao,p_ds_msg,p_tp_mensagem);
                     END;

                     v_vl_apropriacao := v_vl_docencia_pos * gvp.vl_percentual_pos / 100;
                     v_id_vl_apropriacao_indireta := 0;

                     BEGIN
                        v_qtd_linhas := v_qtd_linhas + 1;
                        v_id_vl_apropriacao_indireta := ca.sq_dre_vl_apropriacao_indireta.nextval;
                        INSERT INTO ca.dre_vl_apropriacao_indireta
                                    (ID_VL_APROPRIACAO_INDIRETA,
                                     NR_ANO,
                                     NR_MES,
                                     ID_PLANO_CONTAS,
                                     ID_ESTRUTURA_ORG_EX,
                                     VL_APROPRIACAO,
                                     CD_CENTRO_CUSTO_ORIGEM,
                                     TP_ORIGEM,
                                     ID_GRADE_VERBAS
                                    )
                             VALUES (v_id_vl_apropriacao_indireta,
                                     p_nr_ano,
                                     p_nr_mes,
                                     v_id_plano_de_contas,
                                     v_id_estrutura_org_ex,
                                     v_vl_apropriacao * -1,
                                     gvp.cd_centro_custo_ebs,
                                     4,
                                     v_id_grade_verbas
                                     );
                     EXCEPTION
                        WHEN OTHERS THEN
                             p_ds_msg := 'Mensagem: ' || sqlerrm;
                             p_tp_mensagem := 'A';
                             --p_status := 2;
                             s_DRE_ANALISE_GERENCIAL.P_LOG_EXECUCAO_DRE (p_id_controle_execucao,p_ds_msg,p_tp_mensagem);
                     END;

                     v_id_vl_apropriacao_ind_ex := 0;
                     v_vl_custo_ex := 0;
                     BEGIN
                        select id_vl_apropriacao_indireta, vl_custo
                          into v_id_vl_apropriacao_ind_ex, v_vl_custo_ex
                          from ca.dre_grade_verbas_pos
                         where id_grade_verbas_pos = gvp.id_grade_verbas_pos;
                           --and vl_custo <> 0
                           --and id_vl_apropriacao_indireta is not null;
                     EXCEPTION
                        WHEN OTHERS THEN
                             p_ds_msg := 'Mensagem: ' || sqlerrm;
                             p_tp_mensagem := 'A';
                             --p_status := 2;
                             s_DRE_ANALISE_GERENCIAL.P_LOG_EXECUCAO_DRE (p_id_controle_execucao,p_ds_msg,p_tp_mensagem);
                     END;

                     IF (v_id_vl_apropriacao_ind_ex <> 0 and v_vl_custo_ex <> 0) THEN
                         p_ds_msg := 'Apropriação Indireta: ' || v_id_vl_apropriacao_ind_ex ||
                                                      ' - Vl. Custo: ' || v_vl_custo_ex ||
                                                  ' Grade de Verbas Pos: ' || gvp.id_grade_verbas_pos;
                         p_tp_mensagem := 'A';
                         s_DRE_ANALISE_GERENCIAL.P_LOG_EXECUCAO_DRE (p_id_controle_execucao,p_ds_msg,p_tp_mensagem);
                     END IF;

                     -- Atualização da Grade Verbas Pós --
                     update ca.dre_grade_verbas_pos
                        set vl_custo = (nvl(vl_custo,0) + (v_vl_apropriacao * -1)),
                            id_vl_apropriacao_indireta = v_id_vl_apropriacao_indireta
                      where id_grade_verbas_pos = gvp.id_grade_verbas_pos;
                  END IF;
               END LOOP;
               CLOSE c_grade_verbas_pos;

               -- Se nao existir grade de verbas da pós
              IF (v_qtd_mem = 0) THEN
                  -- Verifica centro de custo do curso
                   --BEGIN

                       v_cd_centro_custo_ebs := '1405601001';	--VICE-REITORIA DE PESQUISA E PÓS-GRADUAÇÃO 
                     --  Conforme CI 10/06/2019
                  --     select distinct vf.centro_custo
                  --       into v_cd_centro_custo_ebs
                  --       from ca.ebs_fp_verbas_funcionarios vf
                  --      where vf.competencia = v_dt_folha
                  --        and ((vf.cta_contabil like '5201%') or (vf.cta_contabil like '6201%') or (vf.cta_contabil like '6401%'))
                  --        and to_number(trim(vf.estb)) = ccc.cd_estabelecimento
                  --        and to_number(trim(vf.matricula)) = ccc.nr_registro;
                  -- EXCEPTION
                  --      when no_data_found then
                  --           v_mensagem := ccc.nr_registro;
                  --           p_ds_msg := 'Matricula não encontrada: ' || v_mensagem;
                  --           p_tp_mensagem := 'A';
                  --           s_DRE_ANALISE_GERENCIAL.P_LOG_EXECUCAO_DRE (p_id_controle_execucao,p_ds_msg,p_tp_mensagem);
                  -- END;

                   -- Para cada curso
                   -- Localizar parâmetro de conversão do centro de custo do curso de graduação na tabela CA.DRE_ESTRUTURA_ORG_EX
                   BEGIN
                       select eo.id_estrutura_org_ex
                         into v_id_estrutura_org_ex
                         from ca.dre_estrutura_org_ex eo,
                              ca.dre_estrutura_org_itens_ex eoi
                        where eo.nr_ano = p_nr_ano
                          and eo.nr_mes = p_nr_mes
                          and eoi.id_estrutura_org_ex = eo.id_estrutura_org_ex
                          and trim(eoi.cd_centro_custo_ebs) = trim(v_cd_centro_custo_ebs);
                   EXCEPTION
                        when no_data_found then
                             v_mensagem := v_cd_centro_custo_ebs;
                             p_ds_msg := 'Centro de Custo não esta cadastrado no organograma: ' || v_mensagem;
                             p_tp_mensagem := 'A';
                             s_DRE_ANALISE_GERENCIAL.P_LOG_EXECUCAO_DRE (p_id_controle_execucao,p_ds_msg,p_tp_mensagem);
                   END;

                   -- Localizar conta de custos na tabela CA.DRE_PLANO_DE_CONTAS
                   BEGIN
                       select id_plano_de_contas
                         into v_id_plano_de_contas
                         from ca.dre_plano_de_contas
                        where tp_conta = 1;
                   EXCEPTION
                        when no_data_found then
                             p_ds_msg := 'Conta de custo não existe no plano de contas: ' || sqlerrm;
                             p_tp_mensagem := 'A';
                             --p_status := 2;
                             s_DRE_ANALISE_GERENCIAL.P_LOG_EXECUCAO_DRE (p_id_controle_execucao,p_ds_msg,p_tp_mensagem);
                   END;

                   v_vl_apropriacao := v_vl_docencia_pos;
                   v_id_vl_apropriacao_indireta := 0;

                   BEGIN
                      v_qtd_linhas := v_qtd_linhas + 1;
                      v_id_vl_apropriacao_indireta := ca.sq_dre_vl_apropriacao_indireta.nextval;
                      INSERT INTO ca.dre_vl_apropriacao_indireta
                                  (ID_VL_APROPRIACAO_INDIRETA,
                                   NR_ANO,
                                   NR_MES,
                                   ID_PLANO_CONTAS,
                                   ID_ESTRUTURA_ORG_EX,
                                   VL_APROPRIACAO,
                                   CD_CENTRO_CUSTO_ORIGEM,
                                   TP_ORIGEM,
                                   ID_GRADE_VERBAS
                                  )
                           VALUES (v_id_vl_apropriacao_indireta,
                                   p_nr_ano,
                                   p_nr_mes,
                                   v_id_plano_de_contas,
                                   v_id_estrutura_org_ex,
                                   v_vl_apropriacao * -1,
                                   v_cd_centro_custo_ebs,
                                   5,
                                   v_id_grade_verbas
                                   );
                   EXCEPTION
                      WHEN OTHERS THEN
                           p_ds_msg := 'Mensagem: ' || sqlerrm;
                           p_tp_mensagem := 'A';
                           --p_status := 2;
                           s_DRE_ANALISE_GERENCIAL.P_LOG_EXECUCAO_DRE (p_id_controle_execucao,p_ds_msg,p_tp_mensagem);
                   END;

                   v_id_vl_apropriacao_ind_ex := 0;
                   v_vl_custo_ex := 0;
                   BEGIN
                      select id_vl_apropriacao_indireta, vl_custo
                        into v_id_vl_apropriacao_ind_ex, v_vl_custo_ex
                        from ca.dre_grade_verbas
                       where id_grade_verbas = ccc.id_grade_verbas;
                         --and vl_custo <> 0
                         --and id_vl_apropriacao_indireta is not null;
                   EXCEPTION
                      WHEN OTHERS THEN
                           p_ds_msg := 'Mensagem: ' || sqlerrm;
                           p_tp_mensagem := 'A';
                           --p_status := 2;
                           s_DRE_ANALISE_GERENCIAL.P_LOG_EXECUCAO_DRE (p_id_controle_execucao,p_ds_msg,p_tp_mensagem);
                   END;

                   IF (v_id_vl_apropriacao_ind_ex <> 0 and v_vl_custo_ex <> 0) THEN
                       p_ds_msg := 'Apropriação Indireta: ' || v_id_vl_apropriacao_ind_ex ||
                                   ' - Vl. Custo: ' || v_vl_custo_ex ||
                                   ' Grade de Verbas da Pós: ' || ccc.id_grade_verbas;
                       p_tp_mensagem := 'A';
                       s_DRE_ANALISE_GERENCIAL.P_LOG_EXECUCAO_DRE (p_id_controle_execucao,p_ds_msg,p_tp_mensagem);
                   END IF;

                   -- Professor não está no memorando
                   update ca.dre_grade_verbas
                      set fl_n_mem = 1,
                          id_vl_apropriacao_indireta = v_id_vl_apropriacao_indireta
                    where id_grade_verbas = ccc.id_grade_verbas;

              END IF;
              commit;
           END IF;

           -- Administrativo --
           IF ((ccc.vl_adm <> 0) and (ccc.vl_percentual_adm <> 0)) THEN
               v_vl_adm := ccc.vl_custo * ccc.vl_percentual_adm / 100;
               v_id_grade_verbas := ccc.id_grade_verbas;
               v_qtd_adm := 0;
               -- Para cada cargo ou lotação --
               OPEN c_grade_verbas_adm;

               LOOP
                  FETCH c_grade_verbas_adm INTO gva;

                  EXIT WHEN c_grade_verbas_adm%NOTFOUND;

                  IF c_grade_verbas_adm%FOUND THEN
                     v_qtd_adm := v_qtd_adm + 1;
                     v_cd_indicador_un_negocio := 0;
                     -- Localizar parâmetro de conversão do centro de custo do curso de graduação na tabela CA.DRE_ESTRUTURA_ORG_EX
                     BEGIN
                         select eo.id_estrutura_org_ex, eo.cd_indicador_un_negocio
                           into v_id_estrutura_org_ex, v_cd_indicador_un_negocio
                           from ca.dre_estrutura_org_ex eo,
                                ca.dre_estrutura_org_itens_ex eoi
                          where eo.nr_ano = p_nr_ano
                            and eo.nr_mes = p_nr_mes
                            and eoi.id_estrutura_org_ex = eo.id_estrutura_org_ex
                            and trim(eoi.cd_centro_custo_ebs) = trim(gva.cd_centro_custo_ebs);
                     EXCEPTION
                          when no_data_found then
                               v_mensagem := gva.cd_centro_custo_ebs;
                               p_ds_msg := 'Centro de Custo não esta cadastrado no organograma: ' || v_mensagem;
                               p_tp_mensagem := 'A';
                               s_DRE_ANALISE_GERENCIAL.P_LOG_EXECUCAO_DRE (p_id_controle_execucao,p_ds_msg,p_tp_mensagem);
                     END;

                     v_tp_conta := 2;
                     IF (v_cd_indicador_un_negocio = 1 or v_cd_indicador_un_negocio = 2) THEN
                        v_tp_conta := 5;
                     END IF;
                     IF (v_cd_indicador_un_negocio = 3 ) THEN
                        v_tp_conta := 1;
                     END IF;

                     -- Localizar conta de custos na tabela CA.DRE_PLANO_DE_CONTAS
                     BEGIN
                         select id_plano_de_contas
                           into v_id_plano_de_contas
                           from ca.dre_plano_de_contas
                          where tp_conta = v_tp_conta;
                     EXCEPTION
                          when no_data_found then
                               p_ds_msg := 'Conta de custo não existe no plano de contas: ' || sqlerrm;
                               p_tp_mensagem := 'A';
                               --p_status := 2;
                               s_DRE_ANALISE_GERENCIAL.P_LOG_EXECUCAO_DRE (p_id_controle_execucao,p_ds_msg,p_tp_mensagem);
                     END;

                     v_vl_apropriacao := v_vl_adm * gva.vl_percentual_adm / 100;

                     v_id_vl_apropriacao_indireta := 0;
                     BEGIN
                        v_qtd_linhas := v_qtd_linhas + 1;
                        v_id_vl_apropriacao_indireta := ca.sq_dre_vl_apropriacao_indireta.nextval;
                        INSERT INTO ca.dre_vl_apropriacao_indireta
                                    (ID_VL_APROPRIACAO_INDIRETA,
                                     NR_ANO,
                                     NR_MES,
                                     ID_PLANO_CONTAS,
                                     ID_ESTRUTURA_ORG_EX,
                                     VL_APROPRIACAO,
                                     CD_CENTRO_CUSTO_ORIGEM,
                                     TP_ORIGEM,
                                     ID_GRADE_VERBAS
                                    )
                             VALUES (v_id_vl_apropriacao_indireta,
                                     p_nr_ano,
                                     p_nr_mes,
                                     v_id_plano_de_contas,
                                     v_id_estrutura_org_ex,
                                     v_vl_apropriacao  * -1,
                                     gva.cd_centro_custo_ebs,
                                     6,
                                     v_id_grade_verbas
                                     );
                     EXCEPTION
                        WHEN OTHERS THEN
                             p_ds_msg := 'Mensagem: ' || sqlerrm;
                             p_tp_mensagem := 'A';
                             --p_status := 2;
                             s_DRE_ANALISE_GERENCIAL.P_LOG_EXECUCAO_DRE (p_id_controle_execucao,p_ds_msg,p_tp_mensagem);
                     END;

                     -- Atualização da Grade Verbas Adm --
                     update ca.dre_grade_verbas_adm
                        set vl_custo = (nvl(vl_custo,0) + (v_vl_apropriacao * -1)),
                            id_vl_apropriacao_indireta = v_id_vl_apropriacao_indireta
                      where id_grade_verbas_adm = gva.id_grade_verbas_adm;

                  END IF;
               END LOOP;
               CLOSE c_grade_verbas_adm;

               -- Se nao existir grade de verbas adm
                IF (v_qtd_adm = 0) THEN
                    -- Verifica centro de custo do curso
                     BEGIN
                         v_cd_centro_custo_ebs := '';
                         select distinct vf.centro_custo
                           into v_cd_centro_custo_ebs
                           from ca.ebs_fp_verbas_funcionarios vf
                          where vf.competencia = v_dt_folha
                            --and ((vf.cta_contabil like '5201%') or (vf.cta_contabil like '6201%') or (vf.cta_contabil like '6401%'))
                            and to_number(trim(vf.estb)) = ccc.cd_estabelecimento
                            and to_number(trim(vf.matricula)) = ccc.nr_registro;
                     EXCEPTION
                          when no_data_found then
                               v_mensagem := ccc.nr_registro;
                               p_ds_msg := 'Matricula não encontrada: ' || v_mensagem;
                               p_tp_mensagem := 'A';
                               s_DRE_ANALISE_GERENCIAL.P_LOG_EXECUCAO_DRE (p_id_controle_execucao,p_ds_msg,p_tp_mensagem);
                     END;

                     -- Para cada curso
                     -- Localizar parâmetro de conversão do centro de custo do curso de graduação na tabela CA.DRE_ESTRUTURA_ORG_EX
                     v_cd_indicador_un_negocio := 0;
                     BEGIN
                         select eo.id_estrutura_org_ex, eo.cd_indicador_un_negocio
                           into v_id_estrutura_org_ex, v_cd_indicador_un_negocio
                           from ca.dre_estrutura_org_ex eo,
                                ca.dre_estrutura_org_itens_ex eoi
                          where eo.nr_ano = p_nr_ano
                            and eo.nr_mes = p_nr_mes
                            and eoi.id_estrutura_org_ex = eo.id_estrutura_org_ex
                            and trim(eoi.cd_centro_custo_ebs) = trim(v_cd_centro_custo_ebs);
                     EXCEPTION
                          when no_data_found then
                               v_mensagem := v_cd_centro_custo_ebs;
                               p_ds_msg := 'Centro de Custo não esta cadastrado no organograma: ' || v_mensagem;
                               p_tp_mensagem := 'A';
                               s_DRE_ANALISE_GERENCIAL.P_LOG_EXECUCAO_DRE (p_id_controle_execucao,p_ds_msg,p_tp_mensagem);
                     END;

                     -- Localizar conta de custos na tabela CA.DRE_PLANO_DE_CONTAS
                     v_tp_conta := 2;
                     IF (v_cd_indicador_un_negocio = 1 or v_cd_indicador_un_negocio = 2 or v_cd_indicador_un_negocio = 3 ) THEN
                        v_tp_conta := 1;
                     END IF;


                     BEGIN
                         select id_plano_de_contas
                           into v_id_plano_de_contas
                           from ca.dre_plano_de_contas
                          where tp_conta = v_tp_conta;
                     EXCEPTION
                          when no_data_found then
                               p_ds_msg := 'Conta de custo não existe no plano de contas: ' || sqlerrm;
                               p_tp_mensagem := 'A';
                               --p_status := 2;
                               s_DRE_ANALISE_GERENCIAL.P_LOG_EXECUCAO_DRE (p_id_controle_execucao,p_ds_msg,p_tp_mensagem);
                     END;

                     v_vl_apropriacao := v_vl_adm;
                     v_id_vl_apropriacao_indireta := 0;
                     BEGIN
                        v_qtd_linhas := v_qtd_linhas + 1;
                        v_id_vl_apropriacao_indireta := ca.sq_dre_vl_apropriacao_indireta.nextval;
                        INSERT INTO ca.dre_vl_apropriacao_indireta
                                    (ID_VL_APROPRIACAO_INDIRETA,
                                     NR_ANO,
                                     NR_MES,
                                     ID_PLANO_CONTAS,
                                     ID_ESTRUTURA_ORG_EX,
                                     VL_APROPRIACAO,
                                     CD_CENTRO_CUSTO_ORIGEM,
                                     TP_ORIGEM,
                                     ID_GRADE_VERBAS
                                    )
                             VALUES (v_id_vl_apropriacao_indireta,
                                     p_nr_ano,
                                     p_nr_mes,
                                     v_id_plano_de_contas,
                                     v_id_estrutura_org_ex,
                                     v_vl_apropriacao * -1,
                                     v_cd_centro_custo_ebs,
                                     7,
                                     v_id_grade_verbas
                                     );
                     EXCEPTION
                        WHEN OTHERS THEN
                             p_ds_msg := 'Mensagem: ' || sqlerrm;
                             p_tp_mensagem := 'A';
                             --p_status := 2;
                             s_DRE_ANALISE_GERENCIAL.P_LOG_EXECUCAO_DRE (p_id_controle_execucao,p_ds_msg,p_tp_mensagem);
                     END;

                     -- Professor não está no memorando
                     update ca.dre_grade_verbas
                        set fl_n_adm = 1,
                            id_vl_apropriacao_indireta = v_id_vl_apropriacao_indireta
                      where id_grade_verbas = ccc.id_grade_verbas;

                END IF;
                commit;

           END IF;
        END IF;
    END LOOP;
    CLOSE c_calcula_custo;
    commit;

    IF v_qtd_linhas = 0 THEN
       v_mensagem := sqlerrm;
       p_ds_msg := 'Não foi realizada inclusão na DRE_VL_APROPRIACAO_INDIRETA do ano ' || p_nr_ano ||
                            ' mês ' || p_nr_mes || '. Mensagem: ' || v_mensagem;
       p_tp_mensagem := 'A';
       s_DRE_ANALISE_GERENCIAL.P_LOG_EXECUCAO_DRE (p_id_controle_execucao,p_ds_msg,p_tp_mensagem);
    ELSE
       v_mensagem := v_qtd_linhas;
       p_ds_msg := 'Total de linhas incluidas na tabela DRE_VL_APROPRIACAO_INDIRETA ' || v_mensagem;
       p_tp_mensagem := 'A';
       s_DRE_ANALISE_GERENCIAL.P_LOG_EXECUCAO_DRE (p_id_controle_execucao,p_ds_msg,p_tp_mensagem);
    END IF;


    s_DRE_ANALISE_GERENCIAL.P_TERMINO_EXECUCAO_DRE (p_id_controle_execucao,p_status);

END P_APURA_CUSTO_SISPRO;
