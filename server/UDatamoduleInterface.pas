unit UDatamoduleInterface;

interface

uses
  UNFCeClass;

type
  IDatamodule = interface
  ['{6C42599C-E8F8-4ABB-AB56-6AABFD771CC8}']
    procedure PreencherNFCe(ANFCe: TNFCe);
    function Enviar: string;

    function GerarPDF(numero, serie: integer): string;
    function GerarXML(numero, serie: integer): string;
    function GerarEscPOS(numero, serie: integer): string;
  end;

implementation

end.
