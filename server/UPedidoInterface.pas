unit UPedidoInterface;

interface

uses
  UNFCeClass;

type
  IPedido = interface
  ['{56935591-EC7B-47D4-8BAB-BF320B234750}']
    procedure PreencherNFCe(ANFCe: TNFCe);
    function Enviar: string;

    function GerarPDF(numero, serie: integer): string;
    function GerarXML(numero, serie: integer): string;
    function GerarEscPOS(numero, serie: integer): string;
  end;


implementation

end.
