unit DNFCe;

interface

uses
  UNFCeClass,

  System.SysUtils, System.Classes, ACBrNFeDANFEClass, ACBrDANFCeFortesFr,
  ACBrBase, ACBrDFe, ACBrNFe, ACBrDFeReport, ACBrDFeDANFeReport,
  ACBrPosPrinter, ACBrNFeDANFeESCPOS;

type
  TdtmNFCe = class(TDataModule)
    ACBrNFe1: TACBrNFe;
    ACBrNFeDANFCeFortes1: TACBrNFeDANFCeFortes;
    ACBrNFeDANFeESCPOS1: TACBrNFeDANFeESCPOS;
    ACBrPosPrinter1: TACBrPosPrinter;
  private
    procedure ConfigurarNFe;
    function PathNotaFiscalExemplo: string;
  public
    procedure PreencherNFCe(ANFCe: TNFCe);
    function Enviar: string;

    function GerarPDF(numero, serie: integer): string;
    function GerarXML(numero, serie: integer): string;
    function GerarEscPOS(numero, serie: integer): string;
  end;

implementation

uses
  pcnConversaoNFe, pcnConversao, ACBrDFeSSL, blcksock, pcnAuxiliar, pcnNFe,
  System.StrUtils, ACBrUtil,  ACBrValidador;

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

function ValorInRange(const AValor: Variant; const ARange: array of Variant): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := Low(ARange) to High(ARange) do
  begin
    if ARange[I] = AValor then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

function TdtmNFCe.PathNotaFiscalExemplo: string;
begin
  // gerar uma nota sempre com mesmo nome para efeitos de exemplo
  Result := ExtractFilePath(ParamStr(0)) + 'notafiscal.xml';
end;

procedure TdtmNFCe.ConfigurarNFe;
var
  PathApp: string;
  PathArqDFe: string;
  PathPDF: string;
  PathArquivos: string;
  PathSchemas: string;
  PathTmp: string;
begin
  // caminhos de pastas gerais
  PathApp := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)));

  // somente para NFC-e
  PathSchemas := IncludeTrailingPathDelimiter(PathApp + 'SCHEMAS');

  // caminhos de pastas especificos por cnpj e comuns aos dois modos de funcionamento
  PathArqDFe      := IncludeTrailingPathDelimiter(PathApp + 'DOCUMENTOS');
  PathPDF         := IncludeTrailingPathDelimiter(PathArqDFe + 'PDF');
  PathArquivos    := IncludeTrailingPathDelimiter(PathArqDFe + 'ARQUIVOS');
  PathTmp         := IncludeTrailingPathDelimiter(PathArqDFe + 'TMP');

  ForceDirectories(PathPDF);
  ForceDirectories(PathArquivos);
  ForceDirectories(PathTmp);

  // configuração do ACBRNFE
  ACBrNFe1.Configuracoes.Arquivos.AdicionarLiteral := False;
  ACBrNFe1.Configuracoes.Arquivos.EmissaoPathNFe   := True;
  ACBrNFe1.Configuracoes.Arquivos.SepararPorMes    := True;
  ACBrNFe1.Configuracoes.Arquivos.SepararPorModelo := True;
  ACBrNFe1.Configuracoes.Arquivos.SepararPorCNPJ   := True;
  ACBrNFe1.Configuracoes.Arquivos.Salvar           := True;
  ACBrNFe1.Configuracoes.Arquivos.SalvarEvento     := True;
  ACBrNFe1.Configuracoes.Arquivos.PathNFe          := PathArquivos;
  ACBrNFe1.Configuracoes.Arquivos.PathInu          := PathArquivos;
  ACBrNFe1.Configuracoes.Arquivos.PathEvento       := PathArquivos;
  ACBrNFe1.Configuracoes.Arquivos.PathSalvar       := PathTmp;
  ACBrNFe1.Configuracoes.Arquivos.PathSchemas      := PathSchemas;

  // configurações gerais
  ACBrNFe1.Configuracoes.Geral.ModeloDF := moNFCe;

  // configurações do token
  ACBrNFe1.Configuracoes.Geral.IdCSC        := '1';
  ACBrNFe1.Configuracoes.Geral.CSC          := '0123456789';
  ACBrNFe1.Configuracoes.Geral.Salvar       := True;
  ACBrNFe1.Configuracoes.Geral.VersaoDF     := TpcnVersaoDF.ve400;
  ACBrNFe1.Configuracoes.Geral.VersaoQRCode := TpcnVersaoQrCode.veqr200;
  ACBrNFe1.Configuracoes.Geral.FormaEmissao := TpcnTipoEmissao.teNormal;

  // autenticação e assinatura seguras
  ACBrNFe1.Configuracoes.Geral.SSLLib := TSSLLib.libWinCrypt;
  ACBrNFe1.SSL.SSLType                := TSSLType.LT_TLSv1_2;

  // configurações de timezone
  ACBrNFe1.Configuracoes.WebServices.TimeZoneConf.ModoDeteccao := TTimeZoneModoDeteccao.tzSistema;

  // propriedades para melhorar a aparência dos retornos de validação dos schemas
  // %TAGNIVEL%  : Representa o Nivel da TAG; ex: <transp><vol><lacres>
  // %TAG%       : Representa a TAG; ex: <nLacre>
  // %ID%        : Representa a ID da TAG; ex X34
  // %MSG%       : Representa a mensagem de alerta
  // %DESCRICAO% : Representa a Descrição da TAG
  ACBrNFe1.Configuracoes.Geral.ExibirErroSchema := False;
  ACBrNFe1.Configuracoes.Geral.FormatoAlerta    := '[ %TAGNIVEL% %TAG% ] %DESCRICAO% - %MSG%';

  // certificado
  ACBrNFe1.Configuracoes.Certificados.Senha         := '1234566';
  ACBrNFe1.Configuracoes.Certificados.ArquivoPFX    := PathApp + 'certificado.pfx';
  //ACBrNFe1.Configuracoes.Certificados.NumeroSerie := '';
  //ACBrNFe1.Configuracoes.Certificados.DadosPFX    := '';

  // configurações do webservice
  ACBrNFe1.Configuracoes.WebServices.UF         := 'AM';
  ACBrNFe1.Configuracoes.WebServices.Salvar     := True;
  ACBrNFe1.Configuracoes.WebServices.Visualizar := False;
  ACBrNFe1.Configuracoes.WebServices.Ambiente   := taHomologacao;

  // interessante deixar configuravel para nf-e, para nfc-e somente timeout, os outros não são relevantes
  ACBrNFe1.Configuracoes.WebServices.TimeOut                  := 18000;  // tempo limite de espera pelo webservice
  ACBrNFe1.Configuracoes.WebServices.AguardarConsultaRet      := 5000;   // tempo padrão que vai aguardar para consultar após enviar a NF-e
  ACBrNFe1.Configuracoes.WebServices.IntervaloTentativas      := 3000;   // Intervalo entre as tentativas de envio
  ACBrNFe1.Configuracoes.WebServices.Tentativas               := 10;     // quantidade de tentativas de envio
  ACBrNFe1.Configuracoes.WebServices.AjustaAguardaConsultaRet := True;   // ajustar "AguardarConsultaRet" com o valor retornado pelo webservice

  // proxy de acesso
  ACBrNFe1.Configuracoes.WebServices.ProxyHost := '';
  ACBrNFe1.Configuracoes.WebServices.ProxyPort := '';
  ACBrNFe1.Configuracoes.WebServices.ProxyUser := '';
  ACBrNFe1.Configuracoes.WebServices.ProxyPass := '';

  ACBrNFe1.DANFE.PathPDF := PathPDF;
  ACBrNFe1.DANFE.Logo    := '';
  ACBrNFe1.DANFE.Sistema := 'nome sistema';
  ACBrNFe1.DANFE.Site    := 'https://regys.com.br';
  ACBrNFe1.DANFE.Email   := 'regys.silveira@gmail.com';
end;

function TdtmNFCe.Enviar: string;
var
  PathTempImpressao: string;
var
  StatusNFCe: Integer;
  StrErros: string;
  NumeroLote: string;
begin
  if ACBrNFe1.NotasFiscais.Count <= 0 then
    raise Exception.Create('nenhuma nota fiscal informada');

  Self.ConfigurarNFe;

//  // assinar omitido para facilitar o uso no curso
//  ACBrNFe1.NotasFiscais.Assinar;
//
//  // validar
//  try
//    ACBrNFe1.NotasFiscais.Validar;
//  except
//    on E: Exception do
//    begin
//      raise EFilerError.Create(
//        'ERRO VALIDAÇÃO: ' +
//        IFThen(
//          ACBrNFe1.NotasFiscais.Items[0].Alertas <> '',
//          ACBrNFe1.NotasFiscais.Items[0].ErroValidacao,
//          ACBrNFe1.NotasFiscais.Items[0].ErroValidacaoCompleto
//        )
//      );
//    end;
//  end;
//
//  // validar regras de negocios
//  if not ACBrNFe1.NotasFiscais.ValidarRegrasdeNegocios(StrErros) then
//    raise EFilerError.Create('ERRO REGRAS DE NEGOCIO: ' + StrErros);


  PathTempImpressao := ExtractFilePath(ParamStr(0)) + '\impressao\';
  ForceDirectories(PathTempImpressao);

  ACBrPosPrinter1.Porta := PathTempImpressao +'\impressao_' + FormatDateTime('hhmmsszzz', NOW) + '.txt';

  // salvar a nota em um arquivo conhecido somente para efeitos de exemplo
  // na vida real o XML deverá ser gravado no banco de dados ou em pasta de
  // arquivamento e mantido por 5 anos
  ACBrNFe1.NotasFiscais[0].GravarXML(PathNotaFiscalExemplo);

  // para gravar no banco ler a propriedade
  //ACBrNFe1.NotasFiscais[0].XML

  // opcional imprimir diretamente do servidor, para isso é preciso ter
  // confiurado o impressor
  ACBrNFe1.NotasFiscais.Imprimir;

  Result :=
    '{ ' +
    '  "numero:": ' + ACBrNFe1.NotasFiscais[0].NFe.Ide.nNF.ToString   + ',' +
    '  "Serie:": '  + ACBrNFe1.NotasFiscais[0].NFe.Ide.serie.ToString +
    '}' ;

//  omitido para evitar o uso de certificado durante o curso
//  NumeroLote := FormatDateTime('yymmddhhmm', NOW);
//  if ACBrNFe1.Enviar(NumeroLote, True, True) then
//  begin
//    StatusNFCe := ACBrNFe1.WebServices.Enviar.cStat;
//
//    //if ACBrNFe1.NotasFiscais[0].Confirmada then  ou
//    if ACBrNFe1.CstatConfirmada(StatusNFCe) then
//    begin
//      Result := ACBrNFe1.WebServices.Enviar.cStat.ToString + ' - ' +
//                ACBrNFe1.WebServices.Enviar.xMotivo;
//    end
//    else
//    begin
//      raise Exception.Create(
//        ACBrNFe1.WebServices.Enviar.cStat.ToString + ' - ' + ACBrNFe1.WebServices.Enviar.xMotivo
//      );
//    end;
//  end
//  else
//  begin
//    raise Exception.CreateFmt('Erro ao enviar: %d - %s', [
//      ACBrNFe1.WebServices.Enviar.cStat,
//      ACBrNFe1.WebServices.Enviar.xMotivo
//    ]);
//  end;
end;

procedure TdtmNFCe.PreencherNFCe(ANFCe: TNFCe);
var
  ONFe: TNFe;
  OPagto: TpagCollectionItem;
  OItemNota: TDetCollectionItem;
  NFCeItem: TNFCeItem;
  I: Integer;
  ValorTotalNF: double;
begin
  ACBrNFe1.NotasFiscais.Clear;

  ConfigurarNFe;

  ONFe := ACBrNFe1.NotasFiscais.Add.NFe;

  // numeração da nota, cada software deve fazer conforme seu controle
  ANFCe.Numero := 1;
  ANFCe.Serie  := 1;

  // Ambiente
  ONFe.Ide.tpAmb     := ACBrNFe1.Configuracoes.WebServices.Ambiente;
  ONFe.Ide.verProc   := '1.0.0.0';
  ONFe.Ide.tpImp     := ACBrNFe1.DANFE.TipoDANFE;

  // Identificação da nota fiscal eletrônica
  ONFe.Ide.modelo    := 65;
  ONFe.Ide.tpNF      := tnSaida;
  ONFe.Ide.finNFe    := fnNormal;
  ONFe.Ide.indFinal  := cfConsumidorFinal;
  ONFe.Ide.nNF       := ANFCe.Numero;
  ONFe.Ide.serie     := ANFCe.Serie;
  ONFe.Ide.natOp     := 'VENDA A CONSUMIDOR FINAL';
  ONFe.Ide.dEmi      := NOW;
  ONFe.Ide.dSaiEnt   := ONFe.Ide.dEmi;
  ONFe.Ide.cUF       := UFtoCUF('AM');
  ONFe.Ide.cMunFG    := 1302603;

  // deixar o acbr gerar um numero randomico conforme manual da nfe
  ONFe.Ide.cNF := 0;

  // entrar em contingência quando configurado
  ONFe.Ide.tpEmis := teOffLine;
  ONFe.Ide.dhCont := NOW;
  ONFe.Ide.xJust  := 'WK CURSO NFCE MOBILE';

  // identificação do EMITENTE
  ONFe.Emit.xNome             := 'EMISSOR TESTE';
  ONFe.Emit.xFant             := 'EMISSOR TESTE';
  ONFe.Emit.CNPJCPF           := '07193169000154';
  ONFe.Emit.IE                := '1234567890';
  ONFe.Emit.IEST              := '';
  ONFe.Emit.CNAE              := '';
  ONFe.Emit.EnderEmit.fone    := '(11)2222.4444';
  ONFe.Emit.EnderEmit.xLgr    := 'ENDERECO TESTE';
  ONFe.Emit.EnderEmit.nro     := '1';
  ONFe.Emit.EnderEmit.xCpl    := '';
  ONFe.Emit.EnderEmit.xBairro := 'BAIRRO';
  ONFe.Emit.EnderEmit.xMun    := 'MANAUS';
  ONFe.Emit.EnderEmit.cMun    := 1302603;
  ONFe.Emit.EnderEmit.UF      := CUFtoUF(13);
  ONFe.Emit.EnderEmit.CEP     := 11222333;
  ONFe.Emit.enderEmit.cPais   := 1058;
  ONFe.Emit.enderEmit.xPais   := 'BRASIL';
  ONFe.Emit.CRT               := crtSimplesNacional;

  // informações do destinatário da nota fiscal
  ONFe.Dest.CNPJCPF := ANFCe.cpf;
  ONFe.Dest.xNome   := ANFCe.Nome;

  ONFe.Dest.EnderDest.fone    := '(11)2222.4444';
  ONFe.Dest.EnderDest.xLgr    := 'ENDERECO TESTE';
  ONFe.Dest.EnderDest.nro     := '1';
  ONFe.Dest.EnderDest.xCpl    := '';
  ONFe.Dest.EnderDest.xBairro := 'BAIRRO';
  ONFe.Dest.EnderDest.xMun    := 'MANAUS';
  ONFe.Dest.EnderDest.cMun    := 1302603;
  ONFe.Dest.EnderDest.UF      := CUFtoUF(13);
  ONFe.Dest.EnderDest.CEP     := 11222333;
  ONFe.Dest.EnderDest.cPais   := 1058;
  ONFe.Dest.EnderDest.xPais   := 'BRASIL';

  ValorTotalNF := 0.00;
  I := 0;
  for NFCeItem in ANFCe.Itens do
  begin
    Inc(I);

    OItemNota := ONFe.Det.Add;
    OItemNota.Prod.nItem    := I;
    OItemNota.Prod.cProd    := NFCeItem.Id.ToString;
    OItemNota.Prod.xProd    := NFCeItem.Descricao;
    OItemNota.Prod.NCM      := '10061092';
    OItemNota.Prod.CFOP     := '5102';
    OItemNota.Prod.CEST     := '';

    OItemNota.Prod.cEAN     := 'SEM GTIN';
    OItemNota.Prod.uCom     := 'UN';
    OItemNota.Prod.qCom     := NFCeItem.Quantidade;
    OItemNota.Prod.vUnCom   := NFCeItem.Valor;
    OItemNota.Prod.vProd    := OItemNota.Prod.qCom * OItemNota.Prod.vUnCom;

    OItemNota.Prod.cEANTrib := OItemNota.Prod.cEAN;
    OItemNota.Prod.uTrib    := OItemNota.Prod.uCom;
    OItemNota.Prod.qTrib    := OItemNota.Prod.qCom;
    OItemNota.Prod.vUnTrib  := OItemNota.Prod.vUnCom;

    OItemNota.Prod.vDesc    := 0;
    OItemNota.Prod.vOutro   := 0;
    OItemNota.Prod.vFrete   := 0;
    OItemNota.Prod.vSeg     := 0;

    ValorTotalNF := ValorTotalNF + OItemNota.Prod.vProd;

    // origem da mercadoria (fixo por enquanto, GAMBIARRA)
    OItemNota.Imposto.ICMS.orig := TpcnOrigemMercadoria.oeNacional;

    // ICMS ********************************************************
    OItemNota.Imposto.ICMS.CSOSN       := TpcnCSOSNIcms.csosn102;
    OItemNota.Imposto.ICMS.pCredSN     := 0.00;
    OItemNota.Imposto.ICMS.vCredICMSSN := 0.00;

    // PIS *******************************************************
    OItemNota.Imposto.PIS.CST       := TpcnCstPis.pis07;
    OItemNota.Imposto.PIS.vBC       := 0;
    OItemNota.Imposto.PIS.pPIS      := 0;
    OItemNota.Imposto.PIS.vPIS      := 0;
    OItemNota.Imposto.PIS.qBCProd   := 0;
    OItemNota.Imposto.PIS.vAliqProd := 0;

    // COFINS ******************************************************
    OItemNota.Imposto.COFINS.CST       := TpcnCstCofins.cof07;
    OItemNota.Imposto.COFINS.vBC       := 0;
    OItemNota.Imposto.COFINS.pCOFINS   := 0;
    OItemNota.Imposto.COFINS.vCOFINS   := 0;
    OItemNota.Imposto.COFINS.qBCProd   := 0;
    OItemNota.Imposto.COFINS.vAliqProd := 0;
  end;

  // pagamento
  OPagto := ONFe.pag.Add;
  OPagto.tPag      := TpcnFormaPagamento.fpDinheiro;
  OPagto.vPag      := ValorTotalNF;
  OPagto.tpIntegra := tiPagNaoIntegrado;

  // totais da nota fiscal
  ONFe.Total.ICMSTot.vBC      := 0.00;
  ONFe.Total.ICMSTot.vICMS    := 0.00;
  ONFe.Total.ICMSTot.vBCST    := 0.00;
  ONFe.Total.ICMSTot.vST      := 0.00;
  ONFe.Total.ICMSTot.vProd    := ValorTotalNF;
  ONFe.Total.ICMSTot.vFrete   := 0.00;
  ONFe.Total.ICMSTot.vSeg     := 0.00;
  ONFe.Total.ICMSTot.vDesc    := 0.00;
  ONFe.Total.ICMSTot.vII      := 0.00;
  ONFe.Total.ICMSTot.vIPI     := 0.00;
  ONFe.Total.ICMSTot.vPIS     := 0.00;
  ONFe.Total.ICMSTot.vCOFINS  := 0.00;
  ONFe.Total.ICMSTot.vOutro   := 0.00;
  ONFe.Total.ICMSTot.vFCP     := 0.00;
  ONFe.Total.ICMSTot.vNF      := ValorTotalNF;
  ONFe.Total.ICMSTot.vTotTrib := 0.00;

  // serviços (não existe na NFC-e)
  ONFe.Total.ISSQNtot.vServ   := 0.00;
  ONFe.Total.ISSQNTot.vBC     := 0.00;
  ONFe.Total.ISSQNTot.vISS    := 0.00;
  ONFe.Total.ISSQNTot.vPIS    := 0.00;
  ONFe.Total.ISSQNTot.vCOFINS := 0.00;

  // transporte (frete), no caso de NFC-e não pode ter frete
  ONFe.Transp.modFrete := mfSemFrete;
end;

function TdtmNFCe.GerarEscPOS(numero, serie: integer): string;
var
  OldCfgDANFE: TACBrDFeDANFeReport;
  PathTempImpressao: string;
begin
  OldCfgDANFE := ACBrNFe1.DANFE;
  try
    ACBrNFe1.DANFE := ACBrNFeDANFeESCPOS1;
    Self.ConfigurarNFe;

    PathTempImpressao     := ExtractFilePath(ParamStr(0)) + 'arquivoescpos.txt';
    ACBrPosPrinter1.Porta := PathTempImpressao;

    // Porta pode ser:
    // \\192.168.1.1 - endereço ip da impressora
    // \\nomecomputador\nomecompartilhamento - caminho do compartilhamento
    // COMx - Porta COM
    // LPTx - Porta LPT
    // c:\diretorio\nomearquio.txt - gerando para arquivo
    // RAW:nome da impressora - nome da impressora no windows   "RAW:MP-45200 TH"

    ACBrNFe1.NotasFiscais.Clear;
    ACBrNFe1.NotasFiscais.LoadFromFile(PathNotaFiscalExemplo);
    ACBrNFe1.NotasFiscais.Imprimir;

    if FileExists(PathTempImpressao) then
      Result := PathTempImpressao
    else
      raise Exception.Create('Arquivo EscPOS não encontrado no servidor!');
  finally
    ACBrNFe1.DANFE := OldCfgDANFE;
  end;
end;

function TdtmNFCe.GerarPDF(numero, serie: integer): string;
var
  OldCfgDANFE: TACBrDFeDANFeReport;
begin
  OldCfgDANFE := ACBrNFe1.DANFE;
  try
    ACBrNFe1.DANFE := ACBrNFeDANFCeFortes1;
    Self.ConfigurarNFe;

    ACBrNFe1.NotasFiscais.Clear;
    ACBrNFe1.NotasFiscais.LoadFromFile(PathNotaFiscalExemplo);
    ACBrNFe1.NotasFiscais.ImprimirPDF;

    Result := ACBrNFe1.DANFE.ArquivoPDF;

    if not FileExists(Result) then
      raise Exception.Create('Arquivo PDF não encontrado no servidor!');
  finally
    ACBrNFe1.DANFE := OldCfgDANFE;
  end;
end;

function TdtmNFCe.GerarXML(numero, serie: integer): string;
begin
  if not FilesExists(PathNotaFiscalExemplo) then
    raise Exception.Create('Arquivo XML de nota fiscal não encontrado');

  ACBrNFe1.NotasFiscais.Clear;
  ACBrNFe1.NotasFiscais.LoadFromFile(PathNotaFiscalExemplo);

  Result := ACBrNFe1.NotasFiscais[0].XML;
end;

end.
