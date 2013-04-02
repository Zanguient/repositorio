unit acNetUtils;

interface

uses idHTTP, SysUtils;

function getRemoteXmlContent(pUrl: string): string;

implementation

function getRemoteXmlContent(pUrl: string): string;
var
  xmlContent: string;
  http: TIDHTTP;
begin
  http := TIdHTTP.Create(nil);
  try
    http.HandleRedirects := true;
    try
      result := UTF8Decode(http.Get(pUrl));
    except
      result := '';
    end;
  finally
    FreeAndNil(http);
  end;
end;


end.