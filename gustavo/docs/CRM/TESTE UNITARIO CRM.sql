DECLARE
  P_INSCRICAO VARCHAR2(200);
  P_CD_CONCURSO NUMBER;
  P_NR_FICHA_REQUERIMENTO NUMBER;
  P_NR_FICHA NUMBER;
  P_PESSOA_JSON CLOB;
  P_ID_TITULO NUMBER;
  P_PROCESSO NUMBER;
  P_ST_RETORNO VARCHAR2(200);
  P_DS_RETORNO VARCHAR2(200);
  P_DS_ERRO VARCHAR2(200);
BEGIN
  P_INSCRICAO := 'CAN-176336-UNI';
  P_CD_CONCURSO := 619;  
  P_NR_FICHA_REQUERIMENTO := 1029;
  P_NR_FICHA := 1029;  
  P_PESSOA_JSON := 
'{
   "tpPessoa":"F",
   "nmPessoa":"ANA LIS BATISTA FREITAS",
   "nrCpf":" 70626553",    
   "dvCpf":"9",
   "cdSexo":"M",
   "dtNascimento":"14/01/73",
   "nrPassaporte":NULL,
   "cdPais":76,
   "nrIdentidade":"1008468",
   "cdOrgaoExpedidor":"SSP",
   "cdIdentidadeUf":"PI",
   "cdNaturalidade":NULL,
   "tpEstadoCivil":"S",
   "flBrasileiroNato":"S",
   "nrCnpj":null,
   "dvCnpj":null,
   "dtAbertura":null,
   "logradouros":[
      {
         "nrCep":"62800000",
         "flEnderecoCorrespondencia":"S",
         "cdFaixaTpEndereco":2,
         "nrEndereco":543,
         "dsComplemento":"Ao lado do Estadio MunicipalL",
         "nmLogradouro":"Rua Alexandre LimaA",
         "nmBairro":"CentroO"
      }
   ],
   "contatos": [
      {
         "cdFaixaContato": 3 ,
         "dsContato": "testechamadacrm@gmail.com"
      },
      {
        "cdFaixaContato": 2 ,
        "dsContato": "85985952259"                                    
      }
    ]
}';

  PK_FINANCEIRO_CRM_CLC.GERAR_FINANCEIRO_INSCRICAO(
    P_INSCRICAO => P_INSCRICAO,
    P_CD_CONCURSO => P_CD_CONCURSO,
    P_NR_FICHA_REQUERIMENTO => P_NR_FICHA_REQUERIMENTO,
    P_NR_FICHA => P_NR_FICHA,
    P_PESSOA_JSON => P_PESSOA_JSON,
    P_ID_TITULO => P_ID_TITULO,
    P_PROCESSO => P_PROCESSO,
    P_ST_RETORNO => P_ST_RETORNO,
    P_DS_RETORNO => P_DS_RETORNO,
    P_DS_ERRO => P_DS_ERRO
  );
 
DBMS_OUTPUT.PUT_LINE('P_ID_TITULO = ' || P_ID_TITULO);
 
  :P_ID_TITULO := P_ID_TITULO;

DBMS_OUTPUT.PUT_LINE('P_PROCESSO = ' || P_PROCESSO);

  :P_PROCESSO := P_PROCESSO;

DBMS_OUTPUT.PUT_LINE('P_ST_RETORNO = ' || P_ST_RETORNO);
 
  :P_ST_RETORNO := P_ST_RETORNO;

DBMS_OUTPUT.PUT_LINE('P_DS_RETORNO = ' || P_DS_RETORNO);

  :P_DS_RETORNO := P_DS_RETORNO;

DBMS_OUTPUT.PUT_LINE('P_DS_ERRO = ' || P_DS_ERRO);
 
  :P_DS_ERRO := P_DS_ERRO;
 
END;


--Sa??da:
--
--cadastrar_pessoa->l_id_pessoa_cadastrada=378153
--cadastrar_pessoa->l_st_retorno=S
--cadastrar_pessoa->ds_erro=
--gerar_financeiro_inscricao->p_id_pessoa=378153
--cadastrar_processo_titulo->p_cd_periodo_processo=221
--cadastrar_processo_titulo->p_nr_processo=5124828
--P_ID_TITULO = 1541401
--P_PROCESSO = 5124828
--P_ST_RETORNO = S
--P_DS_RETORNO = Processo criado =>> nr_processo: 5124828 - Titulo criado =>> id_titulo: 1541401
--P_DS_ERRO = 