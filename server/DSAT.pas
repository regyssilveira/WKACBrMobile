unit DSAT;

interface

uses
  UNFCeClass,

  System.SysUtils, System.Classes, ACBrPosPrinter, ACBrSATExtratoReportClass,
  ACBrSATExtratoFortesFr, ACBrDFeReport, ACBrSATExtratoClass,
  ACBrSATExtratoESCPOS, ACBrBase, ACBrSAT;

type
  TDtmSAT = class(TDataModule)
    ACBrSAT1: TACBrSAT;
    ACBrSATExtratoESCPOS1: TACBrSATExtratoESCPOS;
    ACBrSATExtratoFortes1: TACBrSATExtratoFortes;
    ACBrPosPrinter1: TACBrPosPrinter;
    procedure ACBrSAT1GetcodigoDeAtivacao(var Chave: AnsiString);
    procedure ACBrSAT1GetsignAC(var Chave: AnsiString);
  private
    procedure ConfigurarSAT;
    function PathNotaFiscalExemplo: string;
  public
    procedure PreencherNFCe(ANFCe: TNFCe);
    function Enviar: string;

    function GerarPDF(numero, serie: integer): string;
    function GerarXML(numero, serie: integer): string;
    function GerarEscPOS(numero, serie: integer): string;
  end;

var
  DtmSAT: TDtmSAT;

implementation

uses
  ACBrUtil, pcnConversao, ACBrSATClass;

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

{ TDataModule1 }

function TDtmSAT.PathNotaFiscalExemplo: string;
begin
  // gerar uma nota sempre com mesmo nome para efeitos de exemplo
  Result := ExtractFilePath(ParamStr(0)) + 'cfe.xml';
end;

procedure TDtmSAT.ACBrSAT1GetcodigoDeAtivacao(var Chave: AnsiString);
begin
  Chave := '00000000';
end;

procedure TDtmSAT.ACBrSAT1GetsignAC(var Chave: AnsiString);
begin
  Chave := 'SGR-SAT SISTEMA DE GESTAO E RETAGUARDA DO SAT';
end;

procedure TDtmSAT.ConfigurarSAT;
var
  PathApp, PathTmp, PathPDF, PathArquivos: string;
begin
  // caminhos de pastas gerais
  PathApp      := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)));
  PathTmp      := PathApp + 'TMP';
  PathPDF      := PathApp + 'PDF';
  PathArquivos := PathApp + 'arquivos';

  ForceDirectories(PathArquivos);
  ForceDirectories(PathTmp);
  ForceDirectories(PathPDF);

  ACBrSAT1.DesInicializar;
  ACBrSAT1.Modelo                        := TACBrSATModelo.satDinamico_cdecl;
  ACBrSAT1.NomeDLL                       := 'GERSAT.dll';
  ACBrSAT1.Config.ide_numeroCaixa        := 1;
  ACBrSAT1.Config.ide_CNPJ               := '16716114000172';  // cnpj software house
  ACBrSAT1.Config.emit_CNPJ              := '03654119000176';
  ACBrSAT1.Config.emit_IE                := '000052619494';
  ACBrSAT1.Config.emit_IM                := '';
  ACBrSAT1.Config.emit_cRegTribISSQN     := RTISSMicroempresaMunicipal;
  ACBrSAT1.Config.emit_indRatISSQN       := irSim;
  ACBrSAT1.Config.emit_cRegTrib          := RTSimplesNacional;
  ACBrSAT1.Config.PaginaDeCodigo         := 0;
  ACBrSAT1.Config.EhUTF8                 := True;
  ACBrSAT1.Config.infCFe_versaoDadosEnt  := 0.08;

  ACBrSAT1.ConfigArquivos.SalvarCFe      := True;
  ACBrSAT1.ConfigArquivos.SalvarCFeCanc  := True;
  ACBrSAT1.ConfigArquivos.SalvarEnvio    := True;
  ACBrSAT1.ConfigArquivos.SepararPorCNPJ := True;
  ACBrSAT1.ConfigArquivos.SepararPorMes  := True;

  // diretorios onde salvar os arquivos
  ACBrSAT1.ConfigArquivos.PastaCFeVenda        := PathArquivos;
  ACBrSAT1.ConfigArquivos.PastaCFeCancelamento := PathArquivos;
  ACBrSAT1.ConfigArquivos.PastaEnvio           := PathTmp;

  ACBrSAT1.CFe.IdentarXML       := False;
  ACBrSAT1.CFe.TamanhoIdentacao := 3;

  ACBrSAT1.Inicializar;

  ACBrSAT1.Extrato.Sistema               := 'nome do sistema';
  ACBrSAT1.Extrato.ImprimeEmUmaLinha     := True;
  ACBrSAT1.Extrato.PathPDF               := PathPDF;
  ACBrSAT1.Extrato.ImprimeDescAcrescItem := False;
  ACBrSAT1.Extrato.ImprimeCodigoEan      := True;
  ACBrSAT1.Extrato.Logo                  := '';
  ACBrSAT1.Extrato.Site                  := 'https://regys.com.br';
  ACBrSAT1.Extrato.Email                 := 'regys.silveira@gmail.com';

  // configurações para gerar pdf
  ACBrSATExtratoFortes1.PathPDF := PathPDF;

  // configurar margens do danfe
//    ACBrSAT1.Extrato.MargemSuperior := ;
//    ACBrSAT1.Extrato.MargemInferior := ;
//    ACBrSAT1.Extrato.MargemDireita  := ;
//    ACBrSAT1.Extrato.MargemEsquerda := ;
end;

procedure TDtmSAT.PreencherNFCe(ANFCe: TNFCe);
var
  NumItem: Integer;
  vOK: Boolean;
  CodigoGTIN: String;
  MsgErroGTIN: String;
  Item: TNFCeItem;
  ValorTotal: Double;
begin
  ConfigurarSAT;

  ACBrSAT1.InicializaCFe;

  // Montando uma Venda //
  with ACBrSAT1.CFe do
  begin
    ide.numeroCaixa := ACBrSAT1.Config.ide_numeroCaixa;

    // dados do cliente
    Dest.CNPJCPF := ANFCe.cpf;
    Dest.xNome   := ANFCe.Nome;

    // endereço de entrega
    Entrega.xLgr    := '';
    Entrega.nro     := '';
    Entrega.xCpl    := '';
    Entrega.xBairro := '';
    Entrega.xMun    := '';
    Entrega.UF      := '';

    // itens da venda
    NumItem := 0;
    ValorTotal := 0;
    for Item in ANFCe.Itens do
    begin
      NumItem := NumItem + 1;

      with Det.New do
      begin
        nItem         := NumItem;
        Prod.cProd    := Item.Id.ToString;
        Prod.cEAN     := '';
        Prod.xProd    := Item.Descricao;
        prod.NCM      := '99';
        Prod.CFOP     := '5102';
        Prod.uCom     := 'UN';
        Prod.indRegra := irArredondamento;
        Prod.qCom     := Item.Quantidade;
        Prod.vUnCom   := Item.Valor;
        Prod.vDesc    := 0;
        Prod.vOutro   := 0;
        Prod.CEST     := '';

        ValorTotal := ValorTotal + (Prod.qCom * Prod.vUnCom);

        // observações do produto
        infAdProd := '';

        // ICMS ********************************************************
        Imposto.ICMS.orig  := TpcnOrigemMercadoria.oeNacional;
        Imposto.ICMS.CSOSN := TpcnCSOSNIcms.csosn102;

        // PIS *********************************************************
        with Imposto.PIS do
        begin
          CST       := TpcnCstPis.pis49;
          vBC       := 0;
          pPIS      := 0;
          qBCProd   := 0;
          vAliqProd := 0;
        end;

        // COFINS ******************************************************
        with Imposto.COFINS do
        begin
          CST       := TpcnCstCofins.cof49;
          vBC       := 0;
          pCOFINS   := 0;
          qBCProd   := 0;
          vAliqProd := 0;
        end;

        // imposto aproximado
        Imposto.vItem12741 := 0;
      end;
    end;

    Total.DescAcrEntr.vDescSubtot := 0;
    Total.vCFeLei12741 := 0;

    //PAGAMENTOS apenas para NFC-e
    with Pagto.New do
    begin
      vMP := ValorTotal;
      cMP := TpcnCodigoMP.mpDinheiro;
    end;
  end;
end;

function TDtmSAT.Enviar: string;
begin
  ConfigurarSAT;

  // gerar o XML do CF-e
  try
    ACBrSAT1.EnviarDadosVenda;
  except
    on E: Exception do
    begin
      raise Exception.CreateFmt(
        'Ocorreu o seguinte erro ao tentar enviar o CF-e:' + sLineBreak +
        E.Message + sLineBreak + sLineBreak +
        '%d - %s', [ACBrSAT1.Resposta.codigoDeErro, ACBrSAT1.Resposta.mensagemRetorno]
      );
    end;
  end;

  if ACBrSAT1.Resposta.codigoDeRetorno = 6000 then
  begin
    // gravar no banco o xml e status da venda
    Result :=
      '{ ' +
      '  "numero:": ' + ACBrSAT1.CFe.ide.nCFe.ToString   + ',' +
      '  "numerocaixa:": '  + ACBrSAT1.CFe.ide.numeroCaixa.ToString +
      '} ' ;

    ACBrSAT1.CFe.SaveToFile(PathNotaFiscalExemplo);
  end
  else
    raise Exception.CreateFmt('%d - %s', [ACBrSAT1.Resposta.codigoDeErro, ACBrSAT1.Resposta.mensagemRetorno]);
end;

function TDtmSAT.GerarPDF(numero, serie: integer): string;
var
  OldCfgDANFE: TACBrSATExtratoClass;
begin
  OldCfgDANFE := ACBrSAT1.Extrato;
  try
    Self.ConfigurarSAT;
    ACBrSAT1.Extrato := ACBrSATExtratoFortes1;

    ACBrSAT1.CFe.Clear;
    ACBrSAT1.CFe.LoadFromFile(PathNotaFiscalExemplo);
    //ACBrSAT1.CFe.SetXMLString('xml que vc gravou no banco após emitiro o cfe');
    ACBrSAT1.Extrato.PathPDF := ExtractFilePath(ParamStr(0)) + 'PDF';
    ACBrSAT1.Extrato.Filtro  := TACBrSATExtratoFiltro.fiPDF;
    ACBrSAT1.ImprimirExtrato;

    Result := ACBrSAT1.Extrato.ArquivoPDF;
    if not FileExists(Result) then
      raise Exception.Create('Arquivo PDF não encontrado no servidor!');
  finally
    ACBrSAT1.Extrato := OldCfgDANFE;
  end;
end;

function TDtmSAT.GerarXML(numero, serie: integer): string;
begin
  if not FilesExists(PathNotaFiscalExemplo) then
    raise Exception.Create('Arquivo XML de nota fiscal não encontrado');

  ACBrSAT1.CFe.Clear;
  ACBrSAT1.CFe.LoadFromFile(PathNotaFiscalExemplo);

  Result := ACBrSAT1.CFe.AsXMLString;
end;

function TDtmSAT.GerarEscPOS(numero, serie: integer): string;
var
  OldCfgDANFE: TACBrSATExtratoClass;
  PathTempImpressao: string;
begin
  OldCfgDANFE := ACBrSAT1.Extrato;
  try
    Self.ConfigurarSAT;
    ACBrSAT1.Extrato := ACBrSATExtratoESCPOS1;

    PathTempImpressao     := ExtractFilePath(ParamStr(0)) + 'arquivoescpos.txt';
    ACBrPosPrinter1.Porta := PathTempImpressao;

    // Porta pode ser:
    // \\192.168.1.1 - endereço ip da impressora
    // \\nomecomputador\nomecompartilhamento - caminho do compartilhamento
    // COMx - Porta COM
    // LPTx - Porta LPT
    // c:\diretorio\nomearquio.txt - gerando para arquivo
    // RAW:nome da impressora - nome da impressora no windows   "RAW:MP-45200 TH"

    ACBrSAT1.CFe.Clear;
    ACBrSAT1.CFe.LoadFromFile(PathNotaFiscalExemplo);
    ACBrSAT1.ImprimirExtrato;

    if FileExists(PathTempImpressao) then
      Result := PathTempImpressao
    else
      raise Exception.Create('Arquivo EscPOS não encontrado no servidor!');
  finally
    ACBrSAT1.Extrato := OldCfgDANFE;
  end;
end;

end.

