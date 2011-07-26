{* Unit CNAB400.pas
 *
 * Cria��o: Ricardo Nast�s Acras (ricardo@acras.net)
 * Data: 17/10/2005
 *
 * Objetivo: Tratar arquivos CNAB 400 posi��es.
}
unit CNAB400;

interface

uses
  Dialogs, classes, SysUtils, DBClient, DB, DateUtils;
type
  TTipoArquivo = (taRemessa, taRetorno);

  TCNAB400 = class
  private
    FClientDataSetTitulos: TClientDataSet;
    FRazaoSocial: string;
    FCodigoEmpresa: integer;
    FSequencialArquivo: integer;
    FAgenciaEmpresa: integer;
    FContaEmpresa: integer;
    FTipoArquivo: TTipoArquivo;
    FdataGeracaoArquivo: TDateTime;
    FSeqRegistro: integer;
    FValorBoleto: currency;
    FDataHoraGeracao: TDateTime;
    FClientDataSetRetorno: TClientDataSet;
    function getCodigoEmpresa: String;
    function getRazaoSocial: String;
    function getCodigoBanco: String;
    function getNomebanco: string;
    function getSequencialArquivo: string;
    function getStrDataGeracao: string;
    function getItentificacaoEmpresa: string;
    function getTextoSequencialBoleto: string;
    function getNumDocumentoBoleto: string;
    function getTextoDatavencimentoBoleto: string;
    function getTextoValorBoleto: string;
    function getInstrucaoProtesto: string;
    function getStrCPFCNPJ: string;
    function getTextoEnderecoCompleto: string;
    function getTextoNomeSacado: string;
    function getTextoPrimeiraMensagem: string;
    function getTextoSegundaMensagem: string;
    function getNumSeqRegistro: string;
    function getTrailer: string;
    function getUltimoSequencial: string;
    function getLinhaBoleto: string;
    function getLinhaMensagem: string;
    function getTextoValorMultaDia: string;
    procedure criarDataSetRetorno;
  protected
    function getHeader: String;
  public
    procedure abrirArquivo(sNomeArquivo: string);
    procedure adicionarBoleto(sequencial: integer;
                              numDocumento: string;
                              datavencimento: TDateTime;
                              valor: Currency;
                              valorDiaAtraso: currency;
                              CPFCNPJ: string;
                              nomeSacado: string;
                              enderecoCompleto: string;
                              CEP: string;
                              mensagem1: string;
                              mensagem2: string;
                              mensagem3: string;
                              mensagem4: string
                              );
    property RazaoSocial: string read FRazaoSocial write FRazaoSocial;
    property CodigoEmpresa: integer read FCodigoEmpresa write FCodigoEmpresa;
    property SequencialArquivo: integer read FSequencialArquivo
      write FSequencialArquivo;
    property tipoArquivo: TTipoArquivo read FTipoArquivo;
    property dataGeracaoArquivo: TDateTime read FdataGeracaoArquivo write FdataGeracaoArquivo;
    property dataSet: TClientDataSet read FClientDataSetTitulos;
    property dataSetRetorno: TClientDataSet read FClientDataSetRetorno;

    //as propriedades carteira, agencia e conta s�o geradas para cada boleto
    //mas como nos casos detectados era sempre o mesmo ficaram como dados
    //da classe, se preisar diferente, mude.
    //carteira sempre � 009 (at� agora) ent�o ficou como const
    property AgenciaEmpresa: integer read FAgenciaEmpresa write FAgenciaEmpresa;
    property ContaEmpresa: integer read FContaEmpresa write FContaEmpresa;

    property ValorBoleto: currency read FValorBoleto write FValorBoleto;

    property dataHoraGeracao: TDateTime read FDataHoraGeracao write FDataHoraGeracao;

    destructor Destroy; override;
    function SalvarArquivo(var nomeArquivo: string): boolean;


    procedure testar;
  public
    constructor Create;
  end;

const
  FNomeBanco = 'Bradesco';
  FCodigoBanco = '237';
  FCarteira = '009';

  //constantes para os tipos de opera��o
  toEntradaConfirmada                       = 2;
  toEntradaRejeitada                        = 3;
  toLiquidacaoNormal                        = 6;
  toBaixadoAutomaticamenteViaArquivo        = 9;
  toBaixadoConformeInstrucaoAgencia         = 10;
  toArquivoTitulosPendentes                 = 11;
  toAbatimentoConncedido                    = 12;
  toAbatimentoCancelado                     = 13;
  toVencimentoAlterado                      = 14;
  toLiquidacaoCartorio                      = 15;
  toTituloPagoCheque                        = 16;
  toLiquidacaoAposBaixaOuNaoRegistrado      = 17;
  toAcertoDepositaria                       = 18;
  toConfirmacaoRecebInstProtesto            = 19;
  toConfirmacaoRecebInstSustacaoCheque      = 20;
  toAcertoControleParticipante              = 21;
  toTituloPagamentoCancelado                = 22;
  toEntradaTituloCartorio                   = 23;
  toEntradaRejeitadaCEPIrregular            = 24;
  toBaixaRejeitada                          = 27;
  toDebitoTarifasCustas                     = 28;
  toAlteracaoOutrosDadosRejeitados          = 30;
  toInstrucaoRejeitada                      = 32;
  toConfirmacaoPedidoAlteracaoOutorsDados   = 33;
  toRetiradoCartorioManutencaoCarteira      = 34;
  toDesagendamentoDebitoAutomatico          = 35;
  toAcertoDadosRateioCredito                = 68;
  toCancelamentoDadosRateio                 = 69;

implementation




uses TypInfo, acStrUtils;





{ TCNAB400 }

constructor TCNAB400.Create;
begin
  FValorBoleto := 0;
  FTipoArquivo := taRemessa;
  FSeqRegistro := 1;
  FClientDataSetTitulos := TClientDataSet.Create(nil);

  with TIntegerField.Create(FClientDataSetTitulos) do
  begin
    FieldName := 'Sequencial';
    DataSet   := FClientDataSetTitulos;
  end;

  with TDateField.Create(FClientDataSetTitulos) do
  begin
    FieldName := 'DataVencimento';
    DataSet   := FClientDataSetTitulos;
  end;

  with TStringField.Create(FClientDataSetTitulos) do
  begin
    FieldName := 'NumDocumento';
    DataSet   := FClientDataSetTitulos;
  end;

  with TFloatField.Create(FClientDataSetTitulos) do
  begin
    FieldName := 'Valor';
    currency := True;
    DataSet   := FClientDataSetTitulos;
  end;

  with TStringField.Create(FClientDataSetTitulos) do
  begin
    FieldName := 'CPFCNPJ';
    DataSet   := FClientDataSetTitulos;
  end;

  with TStringField.Create(FClientDataSetTitulos) do
  begin
    FieldName := 'NomeSacado';
    DataSet   := FClientDataSetTitulos;
    size := 40;
  end;

  with TStringField.Create(FClientDataSetTitulos) do
  begin
    FieldName := 'EnderecoCompleto';
    Size := 40;
    DisplayWidth := 40;
    DataSet   := FClientDataSetTitulos;
  end;

  with TStringField.Create(FClientDataSetTitulos) do
  begin
    FieldName := 'CEP';
    DataSet   := FClientDataSetTitulos;
  end;

  with TStringField.Create(FClientDataSetTitulos) do
  begin
    FieldName := 'Mensagem1';
    Size := 80;
    DataSet   := FClientDataSetTitulos;
  end;

  with TStringField.Create(FClientDataSetTitulos) do
  begin
    FieldName := 'Mensagem2';
    Size := 80;
    DataSet   := FClientDataSetTitulos;
  end;

  with TStringField.Create(FClientDataSetTitulos) do
  begin
    FieldName := 'Mensagem3';
    Size := 80;
    DataSet   := FClientDataSetTitulos;
  end;

  with TStringField.Create(FClientDataSetTitulos) do
  begin
    FieldName := 'Mensagem4';
    Size := 80;
    DataSet   := FClientDataSetTitulos;
  end;


  with TCurrencyField.Create(FClientDataSetTitulos) do
  begin
    FieldName := 'ValorDiaAtraso';
    DataSet := FClientDataSetTitulos;
  end;

  FClientDataSetTitulos.CreateDataSet;
end;

destructor TCNAB400.Destroy;
begin
  FClientDataSetTitulos.Free;
  if FClientDataSetRetorno<>nil then
    FreeAndNil(FClientDataSetRetorno);
end;

procedure TCNAB400.criarDataSetRetorno;
begin
  FClientDataSetRetorno := TClientDataSet.Create(nil);

  with TIntegerField.Create(FClientDataSetRetorno) do
  begin
    FieldName := 'Sequencial';
    DataSet   := FClientDataSetRetorno;
  end;

  with TIntegerField.Create(FClientDataSetRetorno) do
  begin
    FieldName := 'TipoOcorrencia';
    DataSet   := FClientDataSetRetorno;
  end;

  with TCurrencyField.Create(FClientDataSetRetorno) do
  begin
    FieldName := 'ValorBoleto';
    DataSet   := FClientDataSetRetorno;
  end;

  with TCurrencyField.Create(FClientDataSetRetorno) do
  begin
    FieldName := 'ValorPago';
    DataSet   := FClientDataSetRetorno;
  end;

  with TCurrencyField.Create(FClientDataSetRetorno) do
  begin
    FieldName := 'Mora';
    DataSet   := FClientDataSetRetorno;
  end;

  with TStringField.Create(FClientDataSetRetorno) do
  begin
    FieldName := 'MotivoRecusa';
    Size := 2000;
    DataSet   := FClientDataSetRetorno;
  end;

  with TDateTimeField.Create(FClientDataSetRetorno) do
  begin
    FieldName := 'DataPagamento';
    DataSet   := FClientDataSetRetorno;
  end;

  FClientDataSetRetorno.CreateDataSet;
end;

procedure TCNAB400.abrirArquivo(sNomeArquivo: string);
var
  conteudo: TStringList;
  sHeader, linhaAtual: string;
  iLinhaAtual, i, codMotivo, tipoOperacao: integer;
  mensagem, statusProtesto: string;
begin
  conteudo := TStringList.Create;
  try
    conteudo.LoadFromFile(sNomeArquivo);

    //Interpretar a primeira linha do arquivo
    //A primeira linha do arquivo � o Header de Arquivo
    //Adicionados apenas campos com uso pr�tico detectado, caso necessite
    //mais campos basta consultar a documenta��o do CNAB40 e adiciona-los
    sHeader := conteudo[0];

    if copy(sHeader, 2,1) = '1' then
      FTipoArquivo := taRemessa
    else
    begin
      FTipoArquivo := taRetorno;
      criarDataSetRetorno;
    end;

    FDataHoraGeracao := EncodeDateTime(
      2000+StrToInt(copy(sHeader,99,2)),
      StrToInt(copy(sHeader,97,2)),
      StrToInt(copy(sHeader,95,2)),
      0,
      0,
      0,
      0
      );

    //processar campos de interesse no header
    linhaAtual := conteudo[0];
    FSequencialArquivo := StrToInt(copy(linhaAtual,109,5));

    //interpretar as linhas do boleto, cada linha � um boleto
    iLinhaAtual := 1;
    while iLinhaAtual < conteudo.Count do
    begin
      linhaAtual := conteudo[iLinhaAtual];
      //se � linha de retonro e o sequencial n�o � zero
      if (copy(linhaAtual,1,1) = '1') AND (strToInt(copy(linhaAtual,38,25))<>0) then
      begin
        FClientDataSetRetorno.Append;
        FClientDataSetRetorno.FieldByName('Sequencial').AsInteger :=
          strToInt(copy(linhaAtual,38,25));
        FClientDataSetRetorno.FieldByName('TipoOcorrencia').AsInteger :=
          strToInt(copy(linhaAtual,109,2));
        FClientDataSetRetorno.FieldByName('ValorBoleto').AsCurrency :=
          StrToFloat(copy(linhaAtual, 176, 11)+','+copy(linhaAtual, 187, 2));
        FClientDataSetRetorno.FieldByName('ValorPago').AsCurrency :=
          StrToFloat(copy(linhaAtual, 254, 11)+','+copy(linhaAtual, 265, 2));
        FClientDataSetRetorno.FieldByName('Mora').AsCurrency :=
          StrToFloat(copy(linhaAtual, 267, 11)+','+copy(linhaAtual, 278, 2));
        FClientDataSetRetorno.FieldByName('DataPagamento').AsDateTime :=
          encodedate(
            2000+strToInt(copy(linhaAtual, 115, 2)),
            strToInt(copy(linhaAtual, 113, 2)),
            strToInt(copy(linhaAtual, 111, 2))
          );

        tipoOperacao :=
          FClientDataSetRetorno.FieldByName('TipoOcorrencia').AsInteger;

        mensagem := '';
        case tipoOperacao of
        //Entrada Confirmada
        02 :
        begin
          for i := 0 to 4 do
          begin
            codMotivo := strToInt(copy(linhaAtual,319+i*2,2));
            if codMotivo <> 0 then
            case codMotivo of
              00: mensagem := mensagem + 'Ocorr�ncia aceita. ';
              01: mensagem := mensagem + 'C�digo do Banco inv�lido.';
              17: mensagem := mensagem + 'Data de vencimento anterior a data de emiss�o.';
              21: mensagem := mensagem + 'Esp�cie do T�tulo inv�lido.';
              24: mensagem := mensagem + 'Data da emiss�o inv�lida.';
              38: mensagem := mensagem + 'Prazo para protesto inv�lido.';
              39: mensagem := mensagem + 'Pedido para protesto n�o permitido para t�tulo.';
              43: mensagem := mensagem + 'Prazo para baixa e devolu��o inv�lido.';
              45: mensagem := mensagem + 'Nome do Sacado inv�lido.';
              46: mensagem := mensagem + 'Tipo/num. de inscri��o do Sacado inv�lidos.';
              47: mensagem := mensagem + 'Endere�o do Sacado n�o informado.';
              48: mensagem := mensagem + 'CEP irregular.';
              50: mensagem := mensagem + 'CEP referente a Banco correspondente.';
              53: mensagem := mensagem + 'N� de inscri��o do Sacador/avalista inv�lidos (CPF/CNPJ).';
              54: mensagem := mensagem + 'Sacador/avalista n�o informado.';
              67: mensagem := mensagem + 'D�bito autom�tico agendado';
              68: mensagem := mensagem + 'D�bito n�o agendado - erro nos dados de remessa.';
              69: mensagem := mensagem + 'D�bito n�o agendado - Sacado n�o consta no cadastro de autorizante.';
              70: mensagem := mensagem + 'D�bito n�o agendado - Cedente n�o autorizado pelo Sacado.';
              71: mensagem := mensagem + 'D�bito n�o agendado - Cedente n�o participa da modalidade de d�b.autom�tico.';
              72: mensagem := mensagem + 'D�bito n�o agendado - C�digo de moeda diferente de R$.';
              73: mensagem := mensagem + 'D�bito n�o agendado - Data de vencimento inv�lida.';
              75: mensagem := mensagem + 'D�bito n�o agendado - Tipo do n�mero de inscri��o do sacado debitado inv�lido.';
              86: mensagem := mensagem + 'Seu n�mero do documento inv�lido.';
            end;
          end;
        end;

        //Entrada Rejeitada
        03 :
        begin
          for i := 0 to 4 do
          begin
            codMotivo := strToInt(copy(linhaAtual,319+i*2,2));
            if codMotivo <> 0 then
            case codMotivo of
              02: mensagem := mensagem + 'C�digo do registro detalhe inv�lido.';
              03: mensagem := mensagem + 'C�digo da ocorr�ncia inv�lida.';
              04: mensagem := mensagem + 'C�digo de ocorr�ncia n�o permitida para a carteira.';
              05: mensagem := mensagem + 'C�digo de ocorr�ncia n�o num�rico.';
              07: mensagem := mensagem + 'Ag�ncia/conta/Digito - |Inv�lido.';
              08: mensagem := mensagem + 'Nosso n�mero inv�lido.';
              09: mensagem := mensagem + 'Nosso n�mero duplicado.';
              10: mensagem := mensagem + 'Carteira inv�lida.';
              16: mensagem := mensagem + 'Data de vencimento inv�lida.';
              18: mensagem := mensagem + 'Vencimento fora do prazo de opera��o.';
              20: mensagem := mensagem + 'Valor do T�tulo inv�lido.';
              21: mensagem := mensagem + 'Esp�cie do T�tulo inv�lida.';
              22: mensagem := mensagem + 'Esp�cie n�o permitida para a carteira.';
              24: mensagem := mensagem + 'Data de emiss�o inv�lida.';
              38: mensagem := mensagem + 'Prazo para protesto inv�lido.';
              44: mensagem := mensagem + 'Ag�ncia Cedente n�o prevista.';
              50: mensagem := mensagem + 'CEP irregular - Banco Correspondente.';
              63: mensagem := mensagem + 'Entrada para T�tulo j� cadastrado.';
              68: mensagem := mensagem + 'D�bito n�o agendado - erro nos dados de remessa.';
              69: mensagem := mensagem + 'D�bito n�o agendado - Sacado n�o consta no cadastro de autorizante.';
              70: mensagem := mensagem + 'D�bito n�o agendado - Cedente n�o autorizado pelo Sacado.';
              71: mensagem := mensagem + 'D�bito n�o agendado - Cedente n�o participa do d�bito Autom�tico.';
              72: mensagem := mensagem + 'D�bito n�o agendado - C�digo de moeda diferente de R$.';
              73: mensagem := mensagem + 'D�bito n�o agendado - Data de vencimento inv�lida.';
              74: mensagem := mensagem + 'D�bito n�o agendado - Conforme seu pedido, T�tulo n�o registrado.';
              75: mensagem := mensagem + 'D�bito n�o agendado � Tipo de n�mero de inscri��o do debitado inv�lido.';
            end;
          end;
        end;

        //Liquida��o
        06 :
        begin
          for i := 0 to 4 do
          begin
            codMotivo := strToInt(copy(linhaAtual,319+i*2,2));
            if codMotivo <> 0 then
            case codMotivo of
              00: mensagem := mensagem + 'T�tulo pago com dinheiro ( Novo ).';
              15: mensagem := mensagem + 'T�tulo pago com cheque.';
            end;
          end;
        end;

        //Baixado Automaticamente via arquivo
        09 :
        begin
          for i := 0 to 4 do
          begin
            codMotivo := strToInt(copy(linhaAtual,319+i*2,2));
            if codMotivo <> 0 then
            case codMotivo of
              10: mensagem := mensagem + 'Baixa Comandada pelo Cliente. ';
            end;
          end;
        end;

        //Baixado pelo banco
        10 :
        begin
          for i := 0 to 4 do
          begin
            codMotivo := strToInt(copy(linhaAtual,319+i*2,2));
            if codMotivo <> 0 then
            case codMotivo of

              00: mensagem := mensagem + 'Baixado Conforme Instru��es da Ag�ncia.';
              14: mensagem := mensagem + 'T�tulo Protestado.';
              15: mensagem := mensagem + 'T�tulo exclu�do.';
              16: mensagem := mensagem + 'T�tulo Baixado pelo Banco por decurso Prazo.';
              20: mensagem := mensagem + 'T�tulo Baixado e transferido para desconto.';
            end;
          end;
        end;

        //Liquidacao em cart�rio
        15 :
        begin
          for i := 0 to 4 do
          begin
            codMotivo := strToInt(copy(linhaAtual,319+i*2,2));
            if codMotivo <> 0 then
            case codMotivo of
              00: mensagem := mensagem + 'Titulo pago com dinehiro. ';
              15: mensagem := mensagem + 'Titulo pago com cheque. ';
            end;
          end;
        end;

        //Liquida��o ap�s baixa ou t�tulo n�o registrado
        17 :
        begin
          for i := 0 to 4 do
          begin
            codMotivo := strToInt(copy(linhaAtual,319+i*2,2));
            if codMotivo <> 0 then
            case codMotivo of
              00: mensagem := mensagem + 'T�tulo pago com dinheiro.';
              15: mensagem := mensagem + 'T�tulo pago com cheque.';
            end;
          end;
        end;

        //Confirma��o de Recebimento Instru��o de Protesto
        19 :
        begin
            statusProtesto := copy(linhaAtual,295,1);
            if statusProtesto <> '' then
            if statusProtesto = 'A' then
              mensagem := mensagem + 'Protesto aceito.';
            if statusProtesto = 'D' then
              mensagem := mensagem + 'Protesto desprezado.';
        end;

        //Entrada rejeitada por CEP irregular
        24 :
        begin
          for i := 0 to 4 do
          begin
            codMotivo := strToInt(copy(linhaAtual,319+i*2,2));
            if codMotivo <> 0 then
            case codMotivo of
              48: mensagem := mensagem + 'CEP Inv�lido. ';
            end;
          end;
        end;

        //Baixa Rejeitada
        27 :
        begin
          for i := 0 to 4 do
          begin
            codMotivo := strToInt(copy(linhaAtual,319+i*2,2));
            if codMotivo <> 0 then
            case codMotivo of
              04: mensagem := mensagem + 'C�digo de ocorr�ncia n�o permitido para a carteira.';
              07: mensagem := mensagem + 'Ag�ncia/Conta/d�gito inv�lidos.';
              08: mensagem := mensagem + 'Nosso n�mero inv�lido.';
              10: mensagem := mensagem + 'Carteira inv�lida.';
              15: mensagem := mensagem + 'Carteira/Ag�ncia/Conta/nosso n�mero inv�lidos.';
              40: mensagem := mensagem + 'T�tulo com ordem de protesto emitido.';
              42: mensagem := mensagem + 'C�digo para baixa/devolu��o via Telebradesco inv�lido.';
              60: mensagem := mensagem + 'Movimento para T�tulo n�o cadastrado.';
              77: mensagem := mensagem + 'Transfer�ncia para desconto n�o permitido para a carteira.';
              85: mensagem := mensagem + 'T�tulo com pagamento vinculado.';
            end;
          end;
        end;

        //D�bito de tarifas/Custas
        28 :
        begin
          for i := 0 to 4 do
          begin
            codMotivo := strToInt(copy(linhaAtual,319+i*2,2));
            if codMotivo <> 0 then
            case codMotivo of
              03: mensagem := mensagem + 'Tarifa de susta��o.';
              04: mensagem := mensagem + 'Tarifa de protesto.';
              08: mensagem := mensagem + 'Custas de protesto.';
            end;
          end;
        end;

        //Altera��o de outros dados rejeitados
        30 :
        begin
          for i := 0 to 4 do
          begin
            codMotivo := strToInt(copy(linhaAtual,319+i*2,2));
            if codMotivo <> 0 then
            case codMotivo of
              01: mensagem := mensagem + 'C�digo do Banco inv�lido.';
              04: mensagem := mensagem + 'C�digo de ocorr�ncia n�o permitido para a carteira.';
              05: mensagem := mensagem + 'C�digo da ocorr�ncia n�o num�rico.';
              08: mensagem := mensagem + 'Nosso n�mero inv�lido.';
              15: mensagem := mensagem + 'Caracter�stica da cobran�a imcop�tivel.';
              16: mensagem := mensagem + '.Data de vencimento inv�lido.';
              17: mensagem := mensagem + 'Data de vencimento anterior a data de emiss�o.';
              18: mensagem := mensagem + 'Vencimento fora do prazo de opera��o.';
              24: mensagem := mensagem + 'Data de emiss�o Inv�lida.';
              29: mensagem := mensagem + 'Valor do desconto maior/igual ao valor do T�tulo.';
              30: mensagem := mensagem + 'Desconto a conceder n�o confere.';
              31: mensagem := mensagem + 'Concess�o de desconto j� existente ( Desconto anterior ).';
              33: mensagem := mensagem + 'Valor do abatimento inv�lido.';
              34: mensagem := mensagem + 'Valor do abatimento maior/igual ao valor do T�tulo.';
              38: mensagem := mensagem + 'Prazo para protesto inv�lido.';
              39: mensagem := mensagem + 'Pedido de protesto n�o permitido para o T�tulo.';
              40: mensagem := mensagem + 'T�tulo com ordem de protesto emitido.';
              42: mensagem := mensagem + 'C�digo para baixa/devolu��o inv�lido.';
              60: mensagem := mensagem + 'Movimento para T�tulo n�o cadastrado.';
              85: mensagem := mensagem + 'T�tulo com Pagamento Vinculado.';
            end;
          end;
        end;

        //Instru��o rejeitada
        32 :
        begin
          for i := 0 to 4 do
          begin
            codMotivo := strToInt(copy(linhaAtual,319+i*2,2));
            if codMotivo <> 0 then
            case codMotivo of
              01: mensagem := mensagem + '.C�digo do Banco inv�lido.';
              02: mensagem := mensagem + 'C�digo do registro detalhe inv�lido.';
              04: mensagem := mensagem + 'C�digo de ocorr�ncia n�o permitido para a carteira.';
              05: mensagem := mensagem + 'C�digo de ocorr�ncia n�o num�rico.';
              07: mensagem := mensagem + 'Ag�ncia/Conta/d�gito inv�lidos.';
              08: mensagem := mensagem + 'Nosso n�mero inv�lido.';
              10: mensagem := mensagem + 'Carteira inv�lida.';
              15: mensagem := mensagem + 'Caracter�sticas da cobran�a incompat�veis.';
              16: mensagem := mensagem + 'Data de vencimento inv�lida.';
              17: mensagem := mensagem + 'Data de vencimento anterior a data de emiss�o.';
              18: mensagem := mensagem + 'Vencimento fora do prazo de opera��o.';
              20: mensagem := mensagem + 'Valor do t�tulo inv�lido.';
              21: mensagem := mensagem + 'Esp�cie do T�tulo inv�lida.';
              22: mensagem := mensagem + '.Esp�cie n�o permitida para a carteira.';
              24: mensagem := mensagem + 'Data de emiss�o inv�lida.';
              28: mensagem := mensagem + 'C�digo de desconto via Telebradesco inv�lido.';
              29: mensagem := mensagem + 'Valor do desconto maior/igual ao valor do T�tulo.';
              30: mensagem := mensagem + 'Desconto a conceder n�o confere.';
              31: mensagem := mensagem + 'Concess�o de desconto - J� existe desconto anterior.';
              33: mensagem := mensagem + 'Valor do abatimento inv�lido.';
              34: mensagem := mensagem + 'Valor do abatimento maior/igual ao valor do T�tulo.';
              36: mensagem := mensagem + 'Concess�o abatimento - J� existe abatimento anterior.';
              38: mensagem := mensagem + 'Prazo para protesto inv�lido.';
              39: mensagem := mensagem + 'Pedido de protesto n�o permitido para o T�tulo.';
              40: mensagem := mensagem + 'T�tulo com ordem de protesto emitido.';
              41: mensagem := mensagem + 'Pedido cancelamento/susta��o para T�tulo sem instru��o de protesto.';
              42: mensagem := mensagem + 'C�digo para baixa/devolu��o inv�lido.';
              45: mensagem := mensagem + 'Nome do Sacado n�o informado.';
              46: mensagem := mensagem + 'Tipo/n�mero de inscri��o do Sacado inv�lidos.';
              47: mensagem := mensagem + 'Endere�o do Sacado n�o informado.';
              48: mensagem := mensagem + 'CEP Inv�lido.';
              50: mensagem := mensagem + 'CEP referente a um Banco correspondente.';
              53: mensagem := mensagem + 'Tipo de inscri��o do sacador avalista inv�lidos.';
              60: mensagem := mensagem + 'Movimento para T�tulo n�o cadastrado.';
              85: mensagem := mensagem + 'T�tulo com pagamento vinculado.';
              86: mensagem := mensagem + 'Seu n�mero inv�lido.';
            end;
          end;
        end;

        //Desagendamento do d�bito autom�tico
        35 :
        begin
          for i := 0 to 4 do
          begin
            codMotivo := strToInt(copy(linhaAtual,319+i*2,2));
            if codMotivo <> 0 then
            case codMotivo of
              81: mensagem := mensagem + 'Tentativas esgotadas, baixado.';
              82: mensagem := mensagem + 'Tentativas esgotadas, pendente.';
            end;
          end;
        end;

        end;
        FClientDataSetRetorno.fieldByName('MotivoRecusa').AsString :=
          mensagem;
        FClientDataSetRetorno.Post;
      end;
      inc(iLinhaAtual);
    end;
  finally
    FreeAndNil(conteudo);
  end;
end;


function TCNAB400.getCodigoEmpresa: String;
begin
  result := IntToStr(FCodigoEmpresa);
  result := stringOfChar('0', 20-length(result)) + result;
end;

function TCNAB400.getCodigoBanco: String;
begin
  result := FCodigobanco;
end;

function TCNAB400.getRazaoSocial: String;
begin
  result := FRazaoSocial + stringOfChar(' ', 30-length(FRazaoSocial));
end;

function TCNAB400.getHeader: String;
begin
  result := '01REMESSA01COBRANCA       '; //inicial fixo do header
  result := result + getCodigoEmpresa + getRazaoSocial + getCodigoBanco +
    getNomebanco + getStrDataGeracao;
  result := Result + StringOfChar(' ', 8); //8 brancos
  result := Result + 'MX'; //quando � micro a micro deve ser MX, quando n�o �
                           //ser� desconsiderado. Por isso fica sempre MX
  Result := Result + getSequencialArquivo;
  result := Result + StringOfChar(' ', 277); //277 brancos
  result := Result + getNumSeqRegistro;
end;

function TCNAB400.SalvarArquivo(var nomeArquivo: string): boolean;
var
  conteudoArquivo: TStringList;
begin
  result := false;
  FSeqRegistro := 1;
  with TSaveDialog.Create(nil) do
  begin
    FileName := nomeArquivo;
    if Execute then
    begin
      result := true;
      conteudoArquivo := TStringList.Create;
      try
        conteudoArquivo.Add(getHeader);
        FClientDataSetTitulos.First;
        while not FClientDataSetTitulos.Eof do
        begin
          conteudoArquivo.add(getLinhaBoleto);
          conteudoArquivo.add(getLinhaMensagem);
          FClientDataSetTitulos.Next;
        end;
        conteudoArquivo.add(getTrailer);
        conteudoArquivo.SaveToFile(FileName);
        nomeArquivo := FileName;
      finally
        FreeAndNil(conteudoArquivo);
      end;
    end;
    free;
  end;
end;

procedure TCNAB400.testar;
begin
  with TStringList.Create do
  begin
    add(getHeader);
    FClientDataSetTitulos.First;
    while not FClientDataSetTitulos.Eof do
    begin
      FClientDataSetTitulos.Next;
    end;
    add(getTrailer);
    SaveToFile('c:\testecnab400.txt');
    free
  end;
end;

function TCNAB400.getTrailer: string;
begin
  result := '9';
  result := result + stringOfChar(' ', 393);
  result := result + getNumSeqRegistro;
end;

function TCNAB400.getUltimoSequencial: string;
begin
  result := IntToStr(FSeqRegistro-1);
  result := stringOfChar('0',6-length(result));
end;

function TCNAB400.getNomebanco: string;
begin
  result := FNomeBanco + stringOfChar(' ', 15-length(FNomeBanco));
end;

function TCNAB400.getStrDataGeracao: string;
begin
  result := FormatDateTime('ddmmyy',date);
end;

function TCNAB400.getSequencialArquivo: string;
begin
  Result := IntToStr(FSequencialArquivo);
  Result := StringOfChar('0', 7-length(result)) + Result;
end;

function TCNAB400.getItentificacaoEmpresa: string;
begin
  result := FCarteira +
    FormatFloat('00000', FAgenciaEmpresa) +
    FormatFloat('00000000', FContaEmpresa)
end;

procedure TCNAB400.adicionarBoleto(
  sequencial: integer;
  numDocumento: string;
  datavencimento: TDateTime;
  valor: Currency;
  valorDiaAtraso: Currency;
  CPFCNPJ: string;
  nomeSacado: string;
  enderecoCompleto: string;
  CEP: string;
  mensagem1: string;
  mensagem2: string;
  mensagem3: string;
  mensagem4: string
  );
begin
  FClientDataSetTitulos.Append;
  FClientDataSetTitulos.FieldByName('Sequencial').AsInteger :=
    sequencial;
  FClientDataSetTitulos.FieldByName('NumDocumento').AsString :=
    numDocumento;
  FClientDataSetTitulos.FieldByName('dataVencimento').AsDateTime :=
    datavencimento;
  FClientDataSetTitulos.FieldByName('Valor').AsFloat :=
    valor;
  FClientDataSetTitulos.FieldByName('ValorDiaAtraso').AsFloat :=
    valorDiaAtraso;
  FClientDataSetTitulos.FieldByName('CPFCNPJ').AsString :=
    CPFCNPJ;
  FClientDataSetTitulos.FieldByName('NomeSacado').AsString :=
    RemoveAcento(nomeSacado);
  FClientDataSetTitulos.FieldByName('EnderecoCompleto').AsString :=
    RemoveAcento(enderecoCompleto);
  FClientDataSetTitulos.FieldByName('CEP').AsString :=
    CEP;
  FClientDataSetTitulos.FieldByName('Mensagem1').AsString :=
    RemoveAcento(Mensagem1);
  FClientDataSetTitulos.FieldByName('Mensagem2').AsString :=
    RemoveAcento(Mensagem2);
  FClientDataSetTitulos.FieldByName('Mensagem3').AsString :=
    RemoveAcento(Mensagem3);
  FClientDataSetTitulos.FieldByName('Mensagem4').AsString :=
    RemoveAcento(Mensagem4);
  FClientDataSetTitulos.Post;
end;

function TCNAB400.getTextoNomeSacado: string;
begin
  result := FClientDataSetTitulos.fieldByName('NomeSacado').AsString;
  result := result + stringOfChar(' ', 40-length(result));
end;

function TCNAB400.getTextoEnderecoCompleto: string;
begin
  result := FClientDataSetTitulos.fieldByName('EnderecoCompleto').AsString;
  result := result + stringOfChar(' ', 40-length(result));
end;

function TCNAB400.getTextoSequencialBoleto: string;
begin
  result := FClientDataSetTitulos.fieldByName('Sequencial').AsString;
  result := stringOfChar('0',25-length(result)) + result;
end;

function TCNAB400.getNumDocumentoBoleto: string;
begin
  Result := FClientDataSetTitulos.fieldByName('NumDocumento').AsString;
  result := stringOfChar(' ',10-length(result)) + result;
end;

function TCNAB400.getTextoDatavencimentoBoleto: string;
begin
  Result := FormatDateTime('ddmmyy',
    FClientDataSetTitulos.fieldByName('DataVencimento').AsDateTime);
  result := stringOfChar('0',6-length(result)) + result;
end;

function TCNAB400.getTextoValorBoleto: string;
var
  valInteiro: integer;
  valFrac: integer;
  valFloat: double;
begin
  valFloat := FClientDataSetTitulos.fieldByName('Valor').AsFloat + FValorBoleto;
  Result := FormatFloat('0000000000000',valFloat*100);
end;

function TCNAB400.getTextoValorMultaDia: string;
var
  valInteiro: integer;
  valFrac: integer;
  valFloat: double;
begin
  valFloat := FClientDataSetTitulos.fieldByName('ValorDiaAtraso').AsFloat;
  valInteiro := trunc(valFloat);
  valFrac := trunc((valFloat - trunc(valFloat))*100);
  Result := FormatFloat('00000000000',valInteiro) +
    FormatFloat('00',valFrac);
end;

function TCNAB400.getInstrucaoProtesto: string;
begin
  result := '0000'; //n�o protesta, est� fixo
end;

function TCNAB400.getStrCPFCNPJ: string;
begin
  result := '01'; //CPF
  result := result+ '000' + FClientDataSetTitulos.FieldByName('CPFCNPJ').AsString;
            //o 000 acima � por que � CPF
end;

function TCNAB400.getTextoPrimeiraMensagem: string;
begin
  result := stringOfChar(' ', 12);
end;

function TCNAB400.getTextoSegundaMensagem: string;
begin
  result := '';
  result := result + stringOfChar(' ', 60-length(result));
end;

function TCNAB400.getNumSeqRegistro: string;
begin
  result := IntToStr(FSeqRegistro);
  inc(FSeqRegistro);
  result := stringOfChar('0', 6-length(result)) + result;
end;

function TCNAB400.getLinhaBoleto: string;
begin
  result := '1';
  result := result + stringOfChar('0', 19); //19 zeros. esta parte dever� ser
                        //preenchida caso se queira contemplar o d�bito em conta
  result := Result + '0' + getItentificacaoEmpresa;
  result := result + getTextoSequencialBoleto;
  result := result + '000';
  result := result + stringOfChar('0', 5); //5 zeros, fixo
  result := result + stringOfChar('0', 12); //12 zeros, assim a papeleta do
                        //boleto � emitida pelo banco
  result := result + stringOfChar('0', 10); //zero de desconto, se quiser tem
                        //que mudar
  result := result + '1'; //banco emite a papeleta, mudar caso precise que o
                        //cliente emita. Mudar pra algo n�o fixo, claro.
  result := result + 'N'; //n�o entra no d�bito autom�tico
  result := result + stringOfChar(' ', 10); //10 brancos, fixo.
                        //o campo significa: Identifica��o da opera��o do Banco
  result := Result + ' '; //um branco por que n�o participa do rateio
  result := Result + '2'; //n�o emite aviso de d�bito autom�tico
  result := result + stringOfChar(' ', 2); //2 brancos, fixo
  result := result + '01'; //indica remessa
  result := result + getNumDocumentoBoleto + getTextoDatavencimentoBoleto +
    getTextoValorBoleto;
  result := result + '000'; //banco encarregado
  result := result + '00000'; //agencia deposit�ria
  result := result + '01'; //esp�cie do t�tulo = 99 -> DM
  result := result + 'N';  //o que significa Aceito?
  result := result + FormatDateTime('ddmmyy', date); //data da emiss�o do t�tulo
  result := result + getInstrucaoProtesto; //instrucoes de protesto
  result := result + getTextoValorMultaDia;
  result := result + stringOfChar('0',19); //32 zeros fixos
                     //aqui est�o os valores dos descontos
  result := result + stringOfChar('0',13); //13 zeros. IOF, s� deve ser
                     //preenchido quando a cedente for administradora de seguros
  result := result + stringOfChar('0',13); //13 zeros. abatimento
  result := result + getStrCPFCNPJ;
  result := result + getTextoNomeSacado;
  result := result + getTextoEnderecoCompleto;
  result := result + getTextoPrimeiraMensagem;
  result := result + FClientDataSetTitulos.fieldByName('CEP').AsString;
  result := result + getTextoSegundaMensagem;
  result := result + getNumSeqRegistro;
end;


function TCNAB400.getLinhaMensagem: string;
begin
  result := '2';
  result := result + trim(FClientDataSetTitulos.fieldByName('Mensagem1').AsString) + StringOfChar(' ',80-length(trim(FClientDataSetTitulos.fieldByName('Mensagem1').AsString)));
  result := result + trim(FClientDataSetTitulos.fieldByName('Mensagem2').AsString) + StringOfChar(' ',80-length(trim(FClientDataSetTitulos.fieldByName('Mensagem2').AsString)));
  result := result + trim(FClientDataSetTitulos.fieldByName('Mensagem3').AsString) + StringOfChar(' ',80-length(trim(FClientDataSetTitulos.fieldByName('Mensagem3').AsString)));
  result := result + trim(FClientDataSetTitulos.fieldByName('Mensagem4').AsString) + StringOfChar(' ',80-length(trim(FClientDataSetTitulos.fieldByName('Mensagem4').AsString)));
  result := result + stringOfChar(' ', 45);
  result := result + getItentificacaoEmpresa;
  result := result + stringOfChar('0',12);
  result := result + getNumSeqRegistro;
end;






end.
