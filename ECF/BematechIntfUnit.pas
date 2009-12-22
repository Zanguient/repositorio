unit BematechIntfUnit;

interface

type
  IBematech = interface(IInterface)
  ['{1B6E8261-E8DC-4D9A-86CD-EDD97C384B99}']
    // Inicializa��o
    function ProgramaAliquota(var Aliquota: string; Vinculo: Integer): Integer;

    // Fun��es do cupom fiscal
    function AbreCupom(CNPJCPF: string): Integer;
    function CancelaCupom: Integer;

    function VendeItem(Codigo, Descricao, AliquotaICMS, TipoQuantidade,
        Quantidade: string; QtdeDecimais: Integer; ValorUnitario, TipoDesconto,
        Desconto: string): Integer;
    function VendeItemDepartamento(Codigo, Descricao, Aliquota, ValorUnitario,
        Quantidade, Acrescimo, Desconto, IndiceDepartamento, UnidadeMedida: string): Integer;
    function CancelaItemGenerico(Numero: string): Integer;
    function AumentaDescricaoItem(Descricao: string): Integer;
    function IniciaFechamentoCupom(AcrescimoOuDesconto, TipoAcrescimoOuDesconto,
        ValorAcrescimoOuDesconto: string): Integer;
    function EfetuaFormaPagamentoDescricaoForma(Forma, Valor, Descricao: string): Integer;
    function EfetuaFormaPagamento(Forma, Valor: string): Integer;
    function TerminaFechamentoCupom(Mensagem: string): Integer;

    // Fun��es dos Relat�rios Fiscais
    function LeituraX: Integer;
    function ReducaoZ(Data, Hora: String): Integer;
    function LeituraMemoriaFiscalData(dataInicial, dataFinal: string): integer;

    // Outras fun��es
    function AberturaDoDia(var Valor, FormaPagamento: string): Integer;
    function FechamentoDoDia: Integer;
    function RetornoImpressora(var Ack, St1, St2: Integer): Integer;
    function VerificaImpressoraLigada: Integer;

    // Fun��es de informa��es da impressora
    function DataHoraReducao(var DataReducao, HoraReducao: string): Integer;
    function ImprimeConfiguracoesImpressora: Integer;
    function RetornoAliquotas(var Aliquotas: string): Integer;

    function FlagsFiscais(var flag: integer): integer;
    function AbrePortaSerial: integer;

    function numeroSerie(var num: string): integer;
    function numeroCupom(var num: string): integer;


  end;

implementation

end.
