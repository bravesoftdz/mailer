unit ONMCredentials;

interface

type
  TONMCredentials = class abstract(TObject)
  const
    From = 'info@offertenuovimandati.com';
    EmailInternal = 'mailertest@ritolladvd.it';
    Name = 'Info Offerte Nuovi Mandati';
    Subject_Client = 'Registrazione sul portale Offerte Nuovi Mandati';
    Subject_Internal = 'Ricezione Dati Agente';
    Host = 'mailbus.fastweb.it';
  end;

implementation

end.
